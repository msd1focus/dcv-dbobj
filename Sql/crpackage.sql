create or replace PACKAGE DCV_PKG AS
    FUNCTION get_dcv_no RETURN VARCHAR2;
    FUNCTION cek_new_request (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE) RETURN INTEGER;
    FUNCTION get_elapsed_day (startdt DATE, enddt DATE) RETURN INTEGER;
    FUNCTION get_uom_conversion (uomfrom VARCHAR2, uomto VARCHAR2) RETURN NUMBER;
END DCV_PKG;
/

create or replace PACKAGE BODY DCV_PKG AS

  FUNCTION get_dcv_no RETURN VARCHAR2 AS
    lnumber NUMBER;
  BEGIN
    -- TODO: Implementation required for FUNCTION DCV_PKG.get_dcv_no
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

  FUNCTION get_elapsed_day (startdt DATE, enddt DATE) RETURN INTEGER AS
  BEGIN
    -- TODO: Implementation required for FUNCTION DCV_PKG.get_elapsed_day
    RETURN NULL;
  END get_elapsed_day;

  FUNCTION get_uom_conversion (uomfrom VARCHAR2, uomto VARCHAR2) RETURN NUMBER AS
  BEGIN
    -- TODO: Implementation required for FUNCTION DCV_PKG.get_elapsed_day
    RETURN (1);
  END get_uom_conversion;

END DCV_PKG;
/

create or replace PACKAGE WF_PKG AS

    FUNCTION post_action (pTask_id NUMBER, pAction_id NUMBER, pPesan VARCHAR2, pUser VARCHAR2) return NUMBER;

END WF_PKG;
/

CREATE OR REPLACE PACKAGE BODY WF_PKG AS

  FUNCTION post_action (pTask_id NUMBER, pAction_id NUMBER, pPesan VARCHAR2, pUser VARCHAR2)
  RETURN NUMBER AS
    wft         wf_task%ROWTYPE;
    vnodedesc   wf_node.node_desc%TYPE;
    vnextdesc   wf_node.node_desc%TYPE;
    vnodetype   wf_node.nodetype%TYPE;
    vbu         wf_node.role_id%TYPE;
    vnextnode   wf_node_option.refnode%TYPE;
    vprimeroute VARCHAR2(1);
    newid NUMBER;
    vreturntask VARCHAR2(1);
    vdcvstatus  VARCHAR2(10);
  BEGIN

    SELECT t.* INTO wft
    FROM wf_task t
    WHERE t.id = pTask_id FOR UPDATE NOWAIT;

    SELECT n.node_desc, o.refnode, o.return_task
    INTO vnodedesc, vnextnode, vreturntask
    FROM wf_node n, wf_node_option o
    WHERE n.nodecode = o.node_id
    AND n.nodecode = wft.nodecode
    AND o.pilihan = pAction_id;

    SELECT n.nodetype, n.node_desc, n.role_id, n.prime_route
    INTO vnodetype, vnextdesc, vbu, vprimeroute
    FROM wf_node n
    WHERE n.nodecode = vnextnode;

    -- if task type = humantask

    UPDATE wf_task SET
        decision = pAction_id,
        pesan = pPesan,
        progress_status = 'DONE',
        process_by = pUser,
        process_time = SYSDATE
    WHERE id = ptask_id;

    INSERT INTO wf_task (id, no_dcv, task_type, assign_time, assign_to_bu, progress_status, nodecode,
                        prev_task, prev_node, prime_route, return_task)
    VALUES (dcv_seq.nextval, wft.no_dcv, vnodetype, SYSDATE, vbu, 'WORKING', vnextnode, pTask_id,
            wft.nodecode, vprimeroute, vreturntask)
    RETURNING id into newId;

    IF vnextnode = 'TERM' THEN
       vdcvstatus := 'CANCEL';
    ELSIF vnextnode = 'END' THEN
       vdcvstatus := 'PAID';
    ELSE
       vdcvstatus := 'ON-PROCESS';
    END IF;

    UPDATE dcv_request SET
        dcv_status = vdcvstatus,
        last_step = vnodedesc,
        current_step = vnextdesc
    WHERE no_dcv = wft.no_dcv;
    COMMIT;
    RETURN (newId);

  EXCEPTION WHEN OTHERS THEN
    RETURN (-1);
  END post_action;

END WF_PKG;
/
