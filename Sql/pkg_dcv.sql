create or replace PACKAGE DCV_PKG AS
    FUNCTION get_dcv_no RETURN VARCHAR2;
    FUNCTION get_proposal_id_by_pcno (pPcNo VARCHAR2) RETURN NUMBER;
    PROCEDURE validate_pc (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE,
                                response OUT NUMBER, message OUT VARCHAR2) ;
    PROCEDURE new_dcv_req (pCustcode IN VARCHAR2, pNoPc IN VARCHAR2, pDcvPeriod1 IN DATE, pDcvPeriod2 IN DATE,
                          pResponse OUT VARCHAR2, pStatus OUT VARCHAR2);
END DCV_PKG;
/

create or replace PACKAGE BODY DCV_PKG AS

  FUNCTION get_dcv_no RETURN VARCHAR2 AS
    lnumber NUMBER;
    vDcvno VARCHAR2(15);
  BEGIN
    SELECT lastnum INTO lnumber
    FROM dcv_number
    WHERE period = to_number(to_char(sysdate,'YYYYMM'))
    FOR UPDATE;

    lnumber := lnumber+1;
    UPDATE dcv_number SET lastnum = lnumber, modified_dt = SYSDATE
    WHERE period = to_number(to_char(SYSDATE,'YYYYMM'));
    vDcvNo := TO_CHAR(SYSDATE,'YYYYMM')||TO_CHAR(lnumber,'fm000009');
    COMMIT;
    RETURN (vDcvNo);
  END get_dcv_no;


  FUNCTION get_proposal_id_by_pcno (pPcNo VARCHAR2) RETURN NUMBER AS
    vPropId proposal.proposal_id%TYPE;
    vNoPc proposal.confirm_no%TYPE;
    vNoAdd proposal.addendum_ke%TYPE;
    vDashPos NUMBER;
  BEGIN
    vDashPos := INSTR(pPCNo,'-');

    BEGIN
        IF vDashPos > 0 THEN
            vNoPc := SUBSTR(pPcNo,1, vDashPos-1);
            vNoAdd := SUBSTR(pPcNo, vDashPos+1);

            SELECT proposal_id INTO vPropId
            FROM proposal
            WHERE confirm_no = vNoPc
            AND addendum_ke = vNoAdd;
        ELSE
            vNoPc := pPcNo;
            
            SELECT proposal_id INTO vPropId
            FROM proposal
            WHERE confirm_no = vNoPc
            AND addendum_ke IS NULL;
        END IF;
        
        RETURN (vPropId);
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN (-1);
    END;

  END;


  PROCEDURE validate_pc (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE,
                                response OUT NUMBER, message OUT VARCHAR2) AS
    vres NUMBER;
    vErr VARCHAR2(100);
    vujung CHAR(1);
  BEGIN
  
  /* jika sukses : response = 1, message = no proposal */
  /* jika error : response < 0, message = error information */
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
    message := vErr;
  END validate_pc;


  PROCEDURE new_dcv_req (pCustcode IN VARCHAR2, pNoPc IN VARCHAR2, pDcvPeriod1 IN DATE, pDcvPeriod2 IN DATE,
                        pResponse OUT VARCHAR2, pStatus OUT VARCHAR2)
  AS
    vPropId proposal.proposal_id%TYPE;
    vProp proposal%ROWTYPE;
    vCustName VARCHAR2(50) := 'Nama customer';
    vNoDcv VARCHAR2 (15);
    vTaskId NUMBER;
  BEGIN

    vPropId := get_proposal_id_by_pcno(pNoPc);

    SELECT * INTO vProp
    FROM proposal
    WHERE proposal_id = vPropId;

    vnodcv := get_dcv_no;
    Insert into DCV_REQUEST (
    DCVH_ID,
    DCVH_CUST_CODE,
    DCVH_CUST_NAME,
    DCVH_COMPANY,
    DCVH_NO_PC,
    DCVH_KEY_PC,
    DCVH_NO_PP,
    DCVH_NO_PP_ID,
    DCVH_PERIODE_DCV_START, DCVH_PERIODE_DCV_END,
    DCVH_PC_KATEGORI,
    DCVH_PC_TIPE,
    DCVH_PERIODE_PC_START,
    DCVH_PERIODE_PC_END,
    DCVH_NO_DCV,
    DCVH_SUBMIT_TIME,
    DCVH_SELISIH_HARI,
    DCVH_VALUE,
    DCVH_METODE_BAYAR,
    DCVH_STATUS,
    DCVH_CURRENT_STEP,MODIFIED_DT,MODIFIED_BY)
    VALUES (
    dcv_seq.nextval, pCustCode, vCustName, 'FDI',
    vProp.confirm_no,
    vProp.REPORT_RUN_NUMBER,
    vProp.PROPOSAL_NO,
    vProp.PROPOSAL_ID,
    pDcvPeriod1, pDcvPeriod2,
    vProp.CATEGORY_PC,
    vProp.PC_TYPE,
    vProp.PERIODE_PROG_FROM,
    vProp.PERIODE_PROG_TO,
    vNoDcv,
    SYSDATE,
    SYSDATE - vProp.periode_prog_to,
    0, 'PO',
    'START',
    'Tunggu proses Sales',
    SYSDATE, pCustCode);

    SELECT dcv_seq.nextval INTO vTaskId FROM DUAL;
    SELECT dcv_seq.nextval INTO vTaskId FROM DUAL; -- sengaja 2x

    Insert into WF_TASK (
    ID,
    NO_DCV,
    TASK_TYPE,
    ASSIGN_TIME,
    BAGIAN,
    SORTING_TAG,
    PROGRESS_STATUS,
    NODECODE,
    PREV_TASK,TAHAPAN,
    DECISION, NEXT_TASK,
    NEXT_NODE,PRIME_ROUTE,
    PROCESS_BY,PROCESS_TIME
    ) values (
    vTaskId -1,
    vNoDcv,
    'Start',
    SYSDATE,
    'DISTRIBUTOR',
    'A',
    'DONE',
    'D0',null,'DCV Request - Distributor',
    1, vTaskId,
    'SL1','Y',
    pCustCode,
    SYSDATE);

    Insert into WF_TASK (
    ID,
    NO_DCV,
    TASK_TYPE,
    ASSIGN_TIME,
    BAGIAN,
    SORTING_TAG,
    PROGRESS_STATUS,
    NODECODE,
    PREV_TASK,TAHAPAN,
    DECISION,
    NEXT_NODE,PRIME_ROUTE,
    PROCESS_BY,PROCESS_TIME
    ) values (
    vTaskId,
    vNoDcv,
    'Human',
    SYSDATE,
    'SALES',
    'A',
    'WAIT',
    'SL1',
    vTaskId-1,
    'Sedang Proses Sales',
    null,
    null,'Y',
    pCustCode,
    SYSDATE);

    /* insert into dcv_user_mapping */

    pStatus := 'Success';
    pResponse := 'No DCV: '||vnodcv;
  END;

END DCV_PKG;
/
