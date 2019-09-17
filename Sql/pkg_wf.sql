create or replace PACKAGE WF_PKG AS
    gvUser VARCHAR2(30);
    gvBagian VARCHAR2(20);
    FUNCTION post_action (pTask_id NUMBER, pAction_id NUMBER, pPesan VARCHAR2) return NUMBER;
    FUNCTION post_action (pDcvNo VARCHAR2, pNodeCode VARCHAR2, pAction_id NUMBER, pUser VARCHAR2) RETURN VARCHAR2;
    FUNCTION post_action (pDcvNo IN VARCHAR2, pNodeCode IN VARCHAR2, pActionId IN NUMBER, pUser IN VARCHAR2,
                          pNote IN VARCHAR2, pResponse OUT VARCHAR2) RETURN NUMBER;
    FUNCTION sla_pct (psla NUMBER, startdate DATE, enddate DATE) RETURN NUMBER;
    FUNCTION next_working_dt (fromDt DATE, numOfDays NUMBER) RETURN DATE;
    FUNCTION num_working_days (fromDt DATE, toDt DATE) RETURN NUMBER;
    -- PROCEDURE catat_pembayaran (iNoPC VARCHAR2, iNoInvoice VARCHAR2, iNilai NUMBER, iSisa NUMBER, iNote VARCHAR2);
END WF_PKG;
/

create or replace PACKAGE BODY WF_PKG AS
    vNoDCV  dcv_request.dcvh_no_dcv%TYPE;
 --   vDept VARCHAR2(25);
 --   vUser dcv_user_access.user_name%TYPE;

FUNCTION post_merge (pNextNode wf_node%ROWTYPE)
    RETURN NUMBER AS
        vcnt NUMBER;
        newId NUMBER;
        vMergeTask wf_task%ROWTYPE;
        vNextNode wf_node%ROWTYPE;
BEGIN
    -- cari task yg M1 jika sudah ada
    SELECT * INTO vMergeTask
      FROM wf_task
      WHERE no_dcv = vNoDcv
      AND nodecode = pNextNode.nodecode
      AND progress_status = 'WAIT' FOR UPDATE;
dbms_output.put_line('Sisa rotue '||vMergeTask.decision);
    UPDATE wf_task SET
        decision = decision -1,
        progress_status = DECODE(decision, 1, 'DONE', 'WAIT'),
        process_time = SYSDATE,
        process_by = 'SYSTEM'
      WHERE id = vMergeTask.id
      RETURNING decision INTO vcnt;

    IF vcnt = 0 THEN       -- merge sudah komplit

        --cek node selanjutnya apa
        SELECT * INTO vNextNode
        FROM wf_node
        WHERE nodecode = (SELECT o.refnode FROM wf_route o
                          WHERE o.node_id = pNextNode.nodecode);

        INSERT INTO wf_task (id, no_dcv, task_type, assign_time, bagian, progress_status, nodecode,
                        prev_task, tahapan, prime_route, sorting_tag)
            VALUES (dcv_seq.nextval, vNoDcv, vNextNode.nodetype, SYSDATE, vNextNode.bagian, 'WAIT',
            vNextNode.nodecode, vMergeTask.id, 'MERGE', NVL(vNextNode.prime_route,'Y'), 'A')
            RETURNING id into newId;
 dbms_output.put_line('update merge');
        UPDATE wf_task SET
                decision = vcnt,
                progress_status = 'DONE',
                next_task = newId,
                next_node = vNextNode.nodecode,
                process_by = 'SYSTEM',
                process_time = SYSDATE
            WHERE id = vMergeTask.id;
        RETURN (newId);

      ELSE
        RETURN (vMergeTask.id);
      END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        INSERT INTO wf_task (id, no_dcv, task_type, bagian, assign_time, progress_status, nodecode, decision)
                VALUES (dcv_seq.nextval, vNoDcv, pNextNode.nodetype, pNextNode.bagian,
                SYSDATE, 'WAIT', pNextNode.nodecode, pNextNode.merge_count-1)
        RETURNING id INTO newId;
        RETURN (newId);
END post_merge;


FUNCTION post_action (pTask_id NUMBER, pAction_id NUMBER, pPesan VARCHAR2) --, pUser VARCHAR2)
  RETURN NUMBER AS
    CURSOR cSplit(thenode VARCHAR2) IS
            SELECT n.nodetype, n.bagian, n.nodecode, n.execscript, n.node_desc,
                   NVL(n.prime_route,'Y') AS prime_route, NVL(o.return_task,'N') AS return_task
            FROM wf_node n JOIN wf_route o
            ON n.nodecode = o.refnode
            WHERE o.node_id = thenode;
    newTaskId NUMBER;
    newid NUMBER;
    vTask wf_task%ROWTYPE;
  --  vnewTask wf_task%ROWTYPE;
    vLockedTask wf_task%ROWTYPE;
    vOption wf_route%ROWTYPE;
    vNextNode wf_node%ROWTYPE;
 --   res NUMBER;
    vscript VARCHAR2(40);
    vRoute NUMBER;
    vSortTag VARCHAR2(1);
BEGIN
    -- get dept info
    --SELECT u.user_name, u.bagian INTO vuser, vdept
    --FROM dcv_user_access u
    --WHERE u.username = pUser;

    -- retrieve & lock current task
    SELECT t.* INTO vLockedTask
    FROM wf_task t
    WHERE t.id = pTask_id FOR UPDATE NOWAIT;
    vnoDCV := vLockedTask.no_dcv;

    IF vLockedTask.task_type = 'Script' THEN
            vscript := 'Begin :a := '|| vLockedTask.execscript || '(:id); End;';
            EXECUTE IMMEDIATE vscript USING OUT vRoute, pTask_id;
    ELSE
      vRoute := pAction_id;
    END IF;

    SELECT * INTO vOption
    FROM wf_route
    WHERE node_id = vLockedTask.nodecode
    AND pilihan = vRoute;

    -- retrieve option & next node, kecuali STOP
    IF vOption.refnode <> 'STOP' THEN
        SELECT n.* INTO vNextNode
        FROM wf_node n
        WHERE nodecode = vOption.refnode;
    END IF;

    -- create new task based on next node type
    IF vOption.refnode = 'STOP' THEN NULL;  -- jika stop do nothing
    ELSIF vNextNode.nodetype = 'Split' THEN
dbms_output.put_line('Harus split disini node: '||vNextNode.nodecode);
        FOR i IN cSplit(vNextNode.nodecode) LOOP
            IF (i.return_task = 'N') OR (i.prime_route = 'Y') THEN
                IF i.nodecode IN ('D3','TC3') THEN vSortTag := 'B';
                ELSIF i.nodecode IN ('TC4','AP1','AP2','AP3','AP4','AR1') THEN vSortTag := 'C';
                ELSE vSortTag := 'A';
                END IF;
                INSERT INTO wf_task (id, no_dcv, task_type, assign_time, bagian, progress_status,
                        nodecode, prev_task, tahapan, prime_route, return_task, execscript, sorting_tag)
                VALUES (dcv_seq.nextval, vNoDcv, i.nodetype, SYSDATE, i.bagian, 'WAIT',
                i.nodecode, pTask_id, i.node_desc, NVL(i.prime_route,'Y'), i.return_task, i.execscript,vSortTag)
                RETURNING id into newTaskId;

                IF i.prime_route = 'Y' THEN
                    UPDATE dcv_request
                        SET dcvh_current_step = DECODE(i.nodetype,'Script',dcvh_current_step, i.node_desc),
                            dcvh_last_step = DECODE(vLockedTask.task_type,'Script',dcvh_last_step,vOption.description ||' - '||gvBagian),
                            dcvh_status = 'ON-PROGRESS',
                            modified_dt = SYSDATE,
                            modified_by = gvUser
                        WHERE dcvh_no_dcv = vNoDcv;
                END IF;
            END IF;

        END LOOP;

    ELSIF vNextNode.nodetype = 'Merge' THEN
       newTaskId := post_merge (vNextNode);

    ELSE
--        dbms_output.put('newTaskId: ');
        IF vNextNode.nodecode IN ('D3','TC3') THEN vSortTag := 'B';
        ELSIF vNextNode.nodecode IN ('TC4','AP1','AP2','AP3','AP4','AR1') THEN vSortTag := 'C';
        ELSE vSortTag := 'A';
        END IF;
        INSERT INTO wf_task (id, no_dcv, task_type, assign_time, bagian, progress_status, nodecode,
                        prev_task, tahapan, prime_route, return_task, execscript, sorting_tag)
        VALUES (dcv_seq.nextval, vNoDcv, vNextNode.nodetype, SYSDATE, vNextNode.bagian, 'WAIT',
            vNextNode.nodecode, pTask_id, vNextNode.node_desc, NVL(vNextNode.prime_route,'Y'),
            vOption.return_task, vNextNode.execscript, 'A')
        RETURNING id into newTaskId;

        IF vLockedTask.prime_route = 'Y' THEN
            UPDATE dcv_request
                SET dcvh_current_step = DECODE(vNextNode.nodetype,'Script',dcvh_current_step, vNextNode.node_desc),
                    dcvh_last_step = DECODE(vLockedTask.task_type,'Script',dcvh_last_step,vOption.description ||' - '||gvBagian),
                    dcvh_status = 'ON-PROGRESS',
                    modified_dt = SYSDATE,
                    modified_by = gvUser
                WHERE dcvh_no_dcv = vNoDcv;
        END IF;
    END IF;
dbms_output.put_line('Akan update wf_task '||vLockedTask.id||', pilihan: '||vRoute);
    UPDATE wf_task SET
        decision = vRoute,
        note = pPesan,
        progress_status = 'DONE',
        next_task = DECODE(vNextNode.nodetype,'Split','',newTaskId),
        next_node = DECODE(vNextNode.nodetype,'Split','',vNextNode.nodecode),
        tahapan = vOption.description || ' - '||gvBagian,
        process_by = gvUser,
        process_time = SYSDATE
    WHERE id = vLockedTask.id;
--dbms_output.put_line('wf task updated');

    IF vNextNode.nodetype = 'Script' THEN
      newid := post_action (newTaskId, null, '');--, pUser);
    END IF;
  --  COMMIT;
    RETURN (newTaskId);

EXCEPTION WHEN OTHERS THEN
dbms_output.put_line(sqlerrm);
    RETURN (-1);
END post_action;


FUNCTION sla_pct (psla NUMBER, startdate DATE, enddate DATE)
  RETURN NUMBER AS
    slanum NUMBER;
    vselisih NUMBER;
    vwd NUMBER;
BEGIN
    vselisih := enddate - startdate;
    IF vselisih < 0.5 THEN NULL;
    ELSIF vselisih < 1 THEN NULL;
    ELSE NULL;
    END IF;

    RETURN (vselisih);
END sla_pct;

FUNCTION post_action (pDcvNo VARCHAR2, pNodeCode VARCHAR2, pAction_id NUMBER, pUser VARCHAR2)
RETURN VARCHAR2 AS
   vDcvId NUMBER;
   vDcvStatus VARCHAR2(50);
    vCurrStep VARCHAR2(100);
    vLastStep VARCHAR2(100);
  -- vDeptId VARCHAR2(25);
   vTaskId NUMBER;
   vErrMsg VARCHAR2 (100);
   vRespMsg VARCHAR2(500);
   vNewTask NUMBER;
BEGIN
    vErrMsg := 'DCV no '|| pDcvNo ||' tidak ditemukan';
    SELECT dcvh_id, dcvh_status INTO vDcvId, vDcvStatus
        FROM dcv_request
        WHERE dcvh_no_dcv = pDcvNo;

    gvUser := pUser;
    vErrMsg := 'User '|| pUser ||' tidak ditemukan';
    SELECT r.bagian INTO gvBagian
    FROM dcv_user_access u, dcv_user_role ur, dcv_role r
    WHERE u.id = ur.user_id
    AND ur.role_code = r.role_code
    AND u.user_name = pUser;

    vErrMsg := 'Task DCV '|| pDcvNo ||' untuk user '||pUser||' tidak ada status WAIT.';
    SELECT id INTO vTaskId
    FROM wf_task
    WHERE no_dcv = pDcvNo
    AND nodecode = pNodeCode
    AND bagian = gvBagian
    AND progress_status = 'WAIT';
    vErrMsg := '';

    vNewTask := post_action (vTaskId, pAction_id, '');
    SELECT dcvh_status, dcvh_current_step, dcvh_last_step INTO vDcvStatus, vCurrStep, vLastStep
    FROM dcv_request
    WHERE dcvh_no_dcv = pDcvNo;
    vRespMsg := 'DCV '|| pDcvNo ||CHR(10)||'Last Status: ' || vLastStep ||CHR(10)||'Current Status: '||vCurrStep;
    RETURN('Reply: '||vRespMsg);

EXCEPTION WHEN NO_DATA_FOUND THEN RETURN('Error: '||vErrmsg);
END post_action;

FUNCTION post_action (pDcvNo IN VARCHAR2, pNodeCode IN VARCHAR2, pActionId IN NUMBER, pUser IN VARCHAR2,
                      pNote IN VARCHAR2, pResponse OUT VARCHAR2) RETURN NUMBER AS
   vDcvId NUMBER;
   vDcvStatus VARCHAR2(50);
    vCurrStep VARCHAR2(100);
    vLastStep VARCHAR2(100);
   vDeptId VARCHAR2(25);
   vTaskId NUMBER;
   vErrMsg VARCHAR2 (100);
   vRespMsg VARCHAR2(500);
   vNewTask NUMBER;
BEGIN
    vErrMsg := 'DCV no '|| pDcvNo ||' tidak ditemukan';
    SELECT dcvh_id, dcvh_status INTO vDcvId, vDcvStatus
        FROM dcv_request
        WHERE dcvh_no_dcv = pDcvNo;

    IF  pNodeCode='SL1' AND pActionId IN (1, 2, 3) THEN vErrMsg := 'Notes nya mannnnaa';
    END IF;
    RETURN(0);

EXCEPTION WHEN NO_DATA_FOUND THEN
    pResponse := vErrMsg;
    RETURN(-1);

END post_action;

FUNCTION next_working_dt (fromDt DATE, numOfDays NUMBER) RETURN DATE
AS
BEGIN
    RETURN(SYSDATE);
END next_working_dt;

FUNCTION num_working_days (fromDt DATE, toDt DATE) RETURN NUMBER
AS
BEGIN
    RETURN (0);
END num_working_days;

END WF_PKG;
/
