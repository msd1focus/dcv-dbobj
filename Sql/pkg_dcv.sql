create or replace PACKAGE DCV_PKG AS
    FUNCTION get_dcv_no RETURN VARCHAR2;
--    FUNCTION get_proposal_id (pNoPc VARCHAR2) RETURN NUMBER
    FUNCTION cek_new_request (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE) RETURN INTEGER;
    FUNCTION uom_conversion_rate (uomfrom VARCHAR2, uomto VARCHAR2) RETURN NUMBER;
    PROCEDURE cek_new_request (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE,
                                response OUT NUMBER, errm OUT VARCHAR2) ;
    FUNCTION cek_stm_report (custcode VARCHAR2, periode1 DATE, periode2 DATE) RETURN NUMBER;
    FUNCTION new_dcv_req (pCustcode VARCHAR2, pNoPc VARCHAR2, pDcvPeriod1 DATE, pDcvPeriod2 DATE) RETURN NUMBER;
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

  FUNCTION get_proposal_id (pNoPc VARCHAR2) RETURN NUMBER AS
    vProposalId proposal.proposal_id%TYPE;
    
  BEGIN
    SELECT * INTO vProposalId
    FROM PROPOSAL;
    RETURN(-1);
  END get_proposal_id;

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

  FUNCTION uom_conversion_rate (uomfrom VARCHAR2, uomto VARCHAR2) RETURN NUMBER
  AS
  BEGIN
    RETURN(1);
  END;
/*
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
*/


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

  PROCEDURE new_dcv_req (pCustcode IN VARCHAR2, pNoPc IN VARCHAR2, pDcvPeriod1 IN DATE, pDcvPeriod2 IN DATE,
                        pResponse OUT VARCHAR2, pStatus OUT VARCHAR2)
  AS
    vPropId proposal.proposal_id%TYPE;
    vProp proposal%ROWTYPE;
    vCustName VARCHAR2(50) := 'Nama customer';
    vNoDcv VARCHAR2 (15);
    vTaskId NUMBER;
  BEGIN

    vPropId := get_proposal_id(pNoPc);
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

    /* insert into dcv_user_auth_mapping */

    pRequestStatus := 'Success';
    pResponse := 'noDcv Baru';
  END;

END DCV_PKG;
/
