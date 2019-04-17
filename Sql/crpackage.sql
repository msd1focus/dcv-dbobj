create or replace PACKAGE DCV_PKG AS
    FUNCTION get_dcv_no RETURN VARCHAR2;
    FUNCTION cek_new_request (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE) RETURN INTEGER;
    FUNCTION get_sla (role NUMBER, startdt DATE, enddt DATE) RETURN NUMBER;
    FUNCTION get_uom_conversion (uomfrom VARCHAR2, uomto VARCHAR2) RETURN NUMBER;
END DCV_PKG;
/

CREATE OR REPLACE PACKAGE BODY DCV_PKG AS

  FUNCTION get_dcv_no RETURN VARCHAR2 AS
    lnumber NUMBER;
  BEGIN
    SELECT lastnum INTO lnumber
    FROM dcv_number
    WHERE period = to_number(to_char(sysdate,'YYYYMM'))
    FOR UPDATE;

    UPDATE dcv_number SET lastnum = lnumber + 1, modified_dt = SYSDATE
    WHERE period = to_number(to_char(SYSDATE,'YYYYMM'));

    COMMIT;
    RETURN (lnumber + 1);
  END get_dcv_no;

  FUNCTION cek_new_request (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE) RETURN INTEGER AS
  BEGIN
    -- TODO: Implementation required for FUNCTION DCV_PKG.cek_new_request
    RETURN NULL;
  END cek_new_request;

  FUNCTION get_sla (role NUMBER, startdt DATE, enddt DATE)
  RETURN NUMBER AS
    vSla NUMBER;
    vHariKerja NUMBER;
    vSelisihHari NUMBER;
    vNumOfHoliday NUMBER;
    vAchievement NUMBER;
  BEGIN
    SELECT sla1 INTO vSla
    FROM sec_dept
    WHERE id = role;

    vSelisihHari := enddt - startdt;

    -- cek jumlah hari libur antara tanggal tersebut
    vNumOfHoliday := 0;

    vHariKerja := vSelisihHari - vNumOfHoliday;

    vAchievement := vHariKerja / vSla;

    RETURN vAchievement;
  END get_sla;

  FUNCTION get_uom_conversion (uomfrom VARCHAR2, uomto VARCHAR2) RETURN NUMBER AS
  BEGIN
    -- TODO: Implementation required for FUNCTION DCV_PKG.get_elapsed_day
    RETURN (1);
  END get_uom_conversion;

END DCV_PKG;
/

CREATE OR REPLACE PACKAGE WF_PKG AS
    FUNCTION post_action (pTask_id NUMBER, pAction_id NUMBER, pPesan VARCHAR2, pUser VARCHAR2) return NUMBER;
    FUNCTION sla_pct (psla NUMBER, startdate DATE, enddate DATE) RETURN NUMBER;
END WF_PKG;
/

create or replace PACKAGE BODY WF_PKG AS
    vCurrentNode  wf_node%ROWTYPE;
    vCurrentTask  wf_task%ROWTYPE;
    vNextNode wf_node%ROWTYPE;
    vOption    wf_node_route%ROWTYPE;


FUNCTION post_human  RETURN NUMBER
    AS
      newId NUMBER;
BEGIN
        INSERT INTO wf_task (id, no_dcv, task_type, assign_time, assign_to_bu, progress_status, nodecode,
                        prev_task, prev_node, prime_route, return_task, execscript)
        VALUES (dcv_seq.nextval, vCurrentTask.no_dcv, vNextNode.nodetype, SYSDATE, vNextNode.department, 'WAIT',
            vNextNode.nodecode, vCurrentTask.id, vCurrentNode.nodecode, NVL(vNextNode.prime_route,'Y'),
            vOption.return_task, vNextNode.execscript)
        RETURNING id into newId;
        RETURN newId; --newtask;
END post_human;

FUNCTION post_merge
    RETURN NUMBER AS
        vcnt NUMBER;
        newId NUMBER;
        vMergeTask wf_task%ROWTYPE;
        vNextNodeCode wf_node_route.refnode%TYPE;
BEGIN
    -- cari task yg M1 jika sudah ada
    SELECT * INTO vMergeTask
      FROM wf_task
      WHERE no_dcv = vCurrentTask.no_dcv
      AND nodecode = vNextNode.nodecode
      AND progress_status = 'WAIT' FOR UPDATE;

    UPDATE wf_task SET
        decision = decision -1,
        progress_status = DECODE(decision, 1, 'DONE', 'WAIT'),
        process_time = SYSDATE,
        process_by = 'SYSTEM'
      WHERE id = vMergeTask.id
      RETURNING decision INTO vcnt;

    IF vcnt = 0 THEN       -- merge sudah komplit

        --cek node selanjutnya apa
        SELECT o.refnode INTO vNextNodeCode
        FROM wf_node_route o
        WHERE o.node_id = vNextNode.nodecode;
        SELECT * INTO vNextNode
        FROM wf_node
        WHERE nodecode = vNextNodeCode;

        INSERT INTO wf_task (id, no_dcv, task_type, assign_time, assign_to_bu, progress_status, nodecode,
                        prev_task, prev_node, prime_route)
        VALUES (dcv_seq.nextval, vCurrentTask.no_dcv, vNextNode.nodetype, SYSDATE, vNextNode.department, 'WAIT',
            vNextNode.nodecode, vMergeTask.id, vCurrentNode.nodecode, NVL(vNextNode.prime_route,'Y'))
        RETURNING id into newId;
        RETURN (newId);

      ELSE
        RETURN (vMergeTask.id);
      END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('new merge task');
        INSERT INTO wf_task (id, no_dcv, task_type, assign_to_bu, assign_time, progress_status, nodecode, decision)
                VALUES (dcv_seq.nextval,vCurrentTask.no_dcv, vNextNode.nodetype, vNextNode.department,
                SYSDATE, 'WAIT', vNextNode.nodecode, vNextNode.merge_count-1)
        RETURNING id INTO newId;
        RETURN (newId);
END post_merge;

FUNCTION post_split
    RETURN NUMBER AS
      CURSOR cSplit(thenode VARCHAR2) IS
            SELECT n.nodetype, n.department, n.nodecode,
                   NVL(n.prime_route,'Y') AS prime_route, NVL(o.return_task,'T') AS return_task
            FROM wf_node n JOIN wf_node_route o
            ON n.nodecode = o.refnode
            WHERE   o.node_id = thenode;
      newId NUMBER;
BEGIN
    FOR i IN cSplit(vNextNode.nodecode) LOOP
        IF (i.return_task = 'T') OR (i.prime_route = 'Y') THEN
            INSERT INTO wf_task (id, no_dcv, task_type, assign_time, assign_to_bu, progress_status,
                        nodecode, prev_task, prev_node, prime_route, return_task)
            VALUES (dcv_seq.nextval, vCurrentTask.no_dcv, i.nodetype, SYSDATE, i.department, 'WAIT',
            i.nodecode, vCurrentTask.id, vCurrentNode.nodecode, NVL(i.prime_route,'Y'), i.return_task)
            RETURNING id into newId;
        END IF;
    END LOOP;
    RETURN (newId);
END post_split;

FUNCTION post_action (pTask_id NUMBER, pAction_id NUMBER, pPesan VARCHAR2, pUser VARCHAR2)
  RETURN NUMBER AS
    newid NUMBER;
    vDept sec_dept.dept_code%TYPE;
BEGIN

    SELECT d.dept_code INTO vdept
    FROM sec_user u JOIN sec_dept d
    ON u.department = d.id
    WHERE u.username = pUser;

    SELECT t.* INTO vCurrentTask
    FROM wf_task t
    WHERE t.id = pTask_id FOR UPDATE NOWAIT;

    SELECT * INTO vCurrentNode
    FROM wf_node
    WHERE nodecode = vCurrentTask.nodecode;

    SELECT * INTO vOption
    FROM wf_node_route
    WHERE node_id = vCurrentNode.nodecode
    AND pilihan = pAction_Id;

    SELECT * INTO vNextNode
    FROM wf_node
    WHERE nodecode = vOption.refnode;

    IF vNextNode.NodeType IN ('Human','Job') THEN
      newId := post_human;
    dbms_output.put_line('Newid : '||newId);

    ELSIF vNextNode.NodeType = 'Split' THEN
      newId := post_split;

    ELSIF vNextNode.NodeType = 'Merge' THEN
        newid := post_merge;
        dbms_output.put_line ('Merge id:'|| newid);
    ELSIF vNextNode.NodeType = 'Script' THEN
    null;
    END IF;

    UPDATE wf_task SET
        decision = pAction_id,
        pesan = pPesan,
        progress_status = 'DONE',
        next_task = newId,
        next_node = vNextNode.nodecode,
        process_by = pUser,
        process_time = SYSDATE
    WHERE id = ptask_id;

    UPDATE dcv_request SET
        dcv_status = DECODE(vNextNode.nodetype,'Stop','CANCEL','End','PAID','ON-PROCESS'),
        last_step = vOption.description ||' - '||vDept,
        current_step = vNextNode.node_desc,
        modified_dt = SYSDATE,
        modified_by = pUser
    WHERE no_dcv = vCurrentTask.no_dcv;

  --  COMMIT;
    RETURN (newId);

EXCEPTION WHEN OTHERS THEN
    RETURN (-1);
END post_action;


FUNCTION sla_pct (psla NUMBER, startdate DATE, enddate DATE)
  RETURN NUMBER AS
    slanum NUMBER;
    vselisih NUMBER;
    vwd NUMBER;
BEGIN
  /*
    SELECT sla1 into slanum
    FROM sec_role
    WHERE role_code = pRole;
    */

    SELECT COUNT(*) INTO vwd
    FROM work_day
    WHERE rundt BETWEEN TRUNC(startdate) AND TRUNC(enddate);

    vselisih := enddate - startdate;
    IF vselisih < 0.5 THEN NULL;
    ELSIF vselisih < 1 THEN NULL;
    ELSE NULL;
    END IF;

    RETURN (vselisih);
END sla_pct;

END WF_PKG;
/

create or replace PACKAGE WF_JOB AS

    FUNCTION run_ap2 (pTask_id NUMBER) RETURN NUMBER;
    PROCEDURE run_wf_jobs;
END WF_JOB;
/

create or replace PACKAGE BODY WF_JOB AS

FUNCTION run_ap2 (pTask_id NUMBER) RETURN NUMBER AS
  vcomplete BOOLEAN := TRUE;
  BEGIN

    -- custom logic


    IF vcomplete THEN
        RETURN (1); -- any number > 0
    ELSE
      RETURN(-1);
    END IF;
END run_ap2;

PROCEDURE run_wf_jobs AS
    CURSOR cJob IS SELECT t.id, t.nodecode, t.no_dcv, t.execscript, d.dept_code
            FROM wf_task t JOIN sec_dept d
            ON t.assign_to_bu = d.id
            WHERE t.task_type = 'Job'
            AND t.progress_status = 'WAIT'
            ORDER BY t.assign_time;
    vstring VARCHAR2(100);
    res NUMBER;
    vNextNode wf_node%ROWTYPE;
    vOption wf_node_route%ROWTYPE;
BEGIN
    FOR t IN cJob LOOP
        vstring := 'Begin :a := '|| t.execscript || '(:id); End;';
        EXECUTE IMMEDIATE vstring USING OUT res, t.id;
        dbms_output.put_line('Hasil : '|| res);

        IF res <> -1 THEN

            SELECT * INTO vOption
                FROM wf_node_route
                WHERE node_id = t.nodecode
                AND pilihan = res;

            SELECT * INTO vNextNode FROM wf_node
            WHERE nodecode = vOption.refnode;

            UPDATE wf_task SET
                decision = res,
                progress_status = 'DONE',
                process_by = 'SYSTEM',
                process_time = SYSDATE
            WHERE id = t.id;

            UPDATE dcv_request SET
                dcv_status = DECODE(vNextNode.nodetype,'Stop','CANCEL','End','PAID','ON-PROCESS'),
                last_step = vOption.description ||' - '|| t.dept_code,
                current_step = vNextNode.node_desc,
                modified_dt = SYSDATE,
                modified_by = 'SYSTEM'
            WHERE no_dcv = t.no_dcv;

            IF vNextNode.nodetype NOT IN ('End', 'Stop') THEN
            -- create new task
                INSERT INTO wf_task (id, no_dcv, task_type, assign_time, assign_to_bu, progress_status, nodecode,
                        prev_task, prev_node, prime_route)
                VALUES (dcv_seq.nextval, t.no_dcv, vNextNode.nodetype, SYSDATE, vNextNode.department, 'WAIT',
                    vNextNode.nodecode, t.id, t.nodecode, NVL(vNextNode.prime_route,'Y'));

            END IF;
        END IF;

    END LOOP;

END run_wf_jobs;

END WF_JOB;
/
