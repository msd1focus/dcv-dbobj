create or replace PACKAGE wfproc_pkg AS
    FUNCTION terminate_dcv (pTaskId NUMBER) RETURN NUMBER;
END wfproc_pkg;
/

create or replace PACKAGE BODY wfproc_pkg AS

    vNoDCV  dcv_request.dcvh_no_dcv%TYPE;
    vDcv dcv_request%ROWTYPE;

FUNCTION terminate_dcv (pTaskId NUMBER) RETURN NUMBER
AS
BEGIN
    UPDATE dcv_request SET dcvh_status = 'TERMINATED'
    WHERE dcvh_id = (SELECT dcvh_id FROM wf_task WHERE id= pTaskId);
    
    RETURN (0);

EXCEPTION 
WHEN OTHERS THEN RETURN (-1);
END;


END wfproc_pkg;
/
