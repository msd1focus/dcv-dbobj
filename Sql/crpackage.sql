create or replace PACKAGE DCV_PKG AS
    FUNCTION get_dcv_no RETURN VARCHAR2;
    FUNCTION cek_new_request (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE) RETURN INTEGER;
    FUNCTION get_uom_conversion (uomfrom VARCHAR2, uomto VARCHAR2) RETURN NUMBER;
    PROCEDURE cek_new_request (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE,
                                response OUT NUMBER, errm OUT VARCHAR2) ;
    FUNCTION cek_stm_report (custcode VARCHAR2, periode1 DATE, periode2 DATE) RETURN NUMBER;
    FUNCTION new_dcv_req (pCustcode VARCHAR2, pNoPc VARCHAR2, pDcvPeriod1 DATE, pDcvPeriod2 DATE) RETURN NUMBER;

END DCV_PKG;
/

create or replace PACKAGE BODY DCV_PKG AS

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

  PROCEDURE cek_new_request (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE,
                                response OUT NUMBER, errm OUT VARCHAR2) AS
    vres NUMBER;
    vErr VARCHAR2(100);
    vujung CHAR(1);
  BEGIN
    vujung := SUBSTR(nopc, -1,1);
    CASE TRUE
        WHEN vujung NOT IN ('1','2','3','4','5','6','7','8','9','0') THEN
            vres := -9;
            vErr := 'No PC '||nopc||' tidak ada.';
        WHEN vujung = '1' THEN
            vres := -1;
            vErr := 'No PC '||nopc||' tidak ada.';
        WHEN vujung = '2' THEN
            vres := -2;
            vErr := 'Periode tidak sesuai.';
        WHEN vujung = '3' THEN
            vres := 0;
        ELSE
            vres := 1;
    END CASE;
    response := vres;
    errm := vErr;
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

  FUNCTION cek_stm_report (custcode VARCHAR2, periode1 DATE, periode2 DATE) RETURN NUMBER AS
  BEGIN

    RETURN(-1);
  END cek_stm_report;

  FUNCTION new_dcv_req (pCustcode VARCHAR2, pNoPc VARCHAR2, pDcvPeriod1 DATE, pDcvPeriod2 DATE) RETURN NUMBER AS
    vnodcv VARCHAR2(15);
  BEGIN
/*    vno
    INSERT INTO dcv_request (dcv_hdr_id, customer_code, customer_name, company, no_pc, key_pc,
                periode_dcv_start, periode_dcv_end, pc_kategori, pc_tipe, periode_pc_start, periode_pc_end,
                pc_initiator, ppn, region_code, region_desc, area_code, area_desc, loc_code,
                loc_desc, discount_type, modified_dt, modified_by)
    SELECT dcv_seq.nextval, custcode, '..', 'FDI', pNoPc,
    FROM proposal
    WHERE confirm_no = no_pc;
*/
    RETURN(112);
  END;


END DCV_PKG;
/

create or replace PACKAGE WF_PKG AS
    FUNCTION post_action (pTask_id NUMBER, pAction_id NUMBER, pPesan VARCHAR2, pUser VARCHAR2) return NUMBER;
    FUNCTION sla_pct (psla NUMBER, startdate DATE, enddate DATE) RETURN NUMBER;
    FUNCTION get_pr_cm (pTaskId NUMBER) RETURN NUMBER ;
END WF_PKG;
/

create or replace PACKAGE BODY WF_PKG AS
    vNoDCV  dcv_request.no_dcv%TYPE;
    vDept sec_dept.dept_code%TYPE;
    vUser sec_user.username%TYPE;

FUNCTION get_pr_cm (pTaskId NUMBER) RETURN NUMBER AS
    vmethod VARCHAR2(5);
BEGIN
    SELECT NVL(metode_bayar,'PR') INTO vmethod
    FROM dcv_request WHERE no_dcv = (
        SELECT no_dcv FROM wf_task WHERE id = pTaskId);

    IF vmethod = 'PR' THEN RETURN (1);
    ELSE RETURN (2);
    END IF;
END get_pr_cm;


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
        WHERE nodecode = (SELECT o.refnode FROM wf_node_route o
                          WHERE o.node_id = pNextNode.nodecode);

        INSERT INTO wf_task (id, no_dcv, task_type, assign_time, assign_to_bu, progress_status, nodecode,
                        prev_task, prev_node, prime_route)
            VALUES (dcv_seq.nextval, vNoDcv, vNextNode.nodetype, SYSDATE, vNextNode.department, 'WAIT',
            vNextNode.nodecode, vMergeTask.id, vMergeTask.nodecode, NVL(vNextNode.prime_route,'Y'))
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
    dbms_output.put_line('new merge task'|| pNextNode.nodecode ||' - '|| pnextnode.department);
        INSERT INTO wf_task (id, no_dcv, task_type, assign_to_bu, assign_time, progress_status, nodecode, decision)
                VALUES (dcv_seq.nextval, vNoDcv, pNextNode.nodetype, pNextNode.department,
                SYSDATE, 'WAIT', pNextNode.nodecode, pNextNode.merge_count-1)
        RETURNING id INTO newId;
    dbms_output.put_line('seribu tiga ');
        RETURN (newId);
END post_merge;


FUNCTION post_action (pTask_id NUMBER, pAction_id NUMBER, pPesan VARCHAR2, pUser VARCHAR2)
  RETURN NUMBER AS
    CURSOR cSplit(thenode VARCHAR2) IS
            SELECT n.nodetype, n.department, n.nodecode, n.execscript,
                   NVL(n.prime_route,'Y') AS prime_route, NVL(o.return_task,'T') AS return_task
            FROM wf_node n JOIN wf_node_route o
            ON n.nodecode = o.refnode
            WHERE o.node_id = thenode;
    newTaskId NUMBER;
    newid NUMBER;
    vTask wf_task%ROWTYPE;
    vnewTask wf_task%ROWTYPE;
    vLockedTask wf_task%ROWTYPE;
    vOption wf_node_route%ROWTYPE;
    vNextNode wf_node%ROWTYPE;
    res NUMBER;
    vscript VARCHAR2(40);
    vRoute NUMBER;
BEGIN
    -- get dept info
    SELECT u.username, d.dept_code INTO vuser, vdept
    FROM sec_user u JOIN sec_dept d
    ON u.department = d.id
    WHERE u.username = pUser;
    dbms_output.put('Satu - ');

    -- retrieve & lock current task
    SELECT t.* INTO vLockedTask
    FROM wf_task t
    WHERE t.id = pTask_id FOR UPDATE NOWAIT;
    vnoDCV := vLockedTask.no_dcv;
    dbms_output.put_line('Dua');

    IF vLockedTask.task_type = 'Script' THEN
            vscript := 'Begin :a := '|| vLockedTask.execscript || '(:id); End;';
            dbms_output.put_line(vscript);
            EXECUTE IMMEDIATE vscript USING OUT vRoute, pTask_id;
            dbms_output.put_line('Res : '||vRoute);
    ELSE
      vRoute := pAction_id;
    END IF;

    dbms_output.put('Option : ');
    SELECT * INTO vOption
    FROM wf_node_route
    WHERE node_id = vLockedTask.nodecode
    AND pilihan = vRoute;
    dbms_output.put_line(vOPtion.refnode);

    -- retrieve option & next node
    SELECT n.* INTO vNextNode
    FROM wf_node n
    WHERE nodecode = vOption.refnode;
    --vNextNodeType := vNextNode.nodetype;

dbms_output.put_line('Node Type: '|| vNextNode.NodeType);
    -- create new task based on next node type
    IF vNextNode.nodetype = 'Split' THEN

        FOR i IN cSplit(vNextNode.nodecode) LOOP
            IF (i.return_task = 'T') OR (i.prime_route = 'Y') THEN
                INSERT INTO wf_task (id, no_dcv, task_type, assign_time, assign_to_bu, progress_status,
                        nodecode, prev_task, prev_node, prime_route, return_task, execscript)
                VALUES (dcv_seq.nextval, vNoDcv, i.nodetype, SYSDATE, i.department, 'WAIT',
                i.nodecode, pTask_id, vLockedTask.nodecode, NVL(i.prime_route,'Y'), i.return_task, i.execscript)
                RETURNING id into newTaskId;
            END IF;
        END LOOP;

    ELSIF vNextNode.nodetype = 'Merge' THEN
       newTaskId := post_merge (vNextNode);

    ELSE
        dbms_output.put('newTaskId: ');
        INSERT INTO wf_task (id, no_dcv, task_type, assign_time, assign_to_bu, progress_status, nodecode,
                        prev_task, prev_node, prime_route, return_task, execscript)
        VALUES (dcv_seq.nextval, vNoDcv, vNextNode.nodetype, SYSDATE, vNextNode.department, 'WAIT',
            vNextNode.nodecode, pTask_id, vLockedTask.nodecode, NVL(vNextNode.prime_route,'Y'),
            vOption.return_task, vNextNode.execscript)
        RETURNING id into newTaskId;
        dbms_output.put_line(newTaskId);
    END IF;

    UPDATE wf_task SET
        decision = pAction_id,
        pesan = pPesan,
        progress_status = 'DONE',
        next_task = DECODE(vNextNode.nodetype,'Split','',newTaskId),
        next_node = DECODE(vNextNode.nodetype,'Split','',vNextNode.nodecode),
        process_by = pUser,
        process_time = SYSDATE
    WHERE id = vLockedTask.id;
dbms_output.put_line('wf task updated');

    UPDATE dcv_request SET
        dcv_status = DECODE(vNextNode.nodetype,'Stop','CANCEL','End','PAID','ON-PROCESS'),
        last_step = vOption.description ||' - '||vDept,
        current_step = vNextNode.node_desc,
        modified_dt = SYSDATE,
        modified_by = pUser
    WHERE no_dcv = vNoDcv;

    IF vNextNode.nodetype = 'Script' THEN
      newid := post_action (newTaskId, null, '', pUser);
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
