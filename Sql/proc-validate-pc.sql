--------------------------------------------------------
--  File created - Tuesday-October-29-2019   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure VALIDATE_PC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "VALIDATE_PC" (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE,
                                response OUT varchar2, message OUT VARCHAR2) AS
    vres NUMBER := 1;
    vResp VARCHAR2(100);
    vProposalId NUMBER;
    vProposal proposal%ROWTYPE;
    vDcv1 dcv_request%ROWTYPE;
    vujung CHAR(1);
    isMultiMonth BOOLEAN; 
    isLastMonth BOOLEAN;
  BEGIN
  /* jika sukses : response = 1, message = nomor proposal */
  /* jika error : response < 0, message = error information */

    vProposalId := dcv_pkg.get_proposal_id_by_pcno(nopc);
    IF vProposalId = -1 THEN
            vres := -1;
            message := 'No PC '||nopc||' tidak ada.';
            GOTO ujung;
    END IF;

    SELECT * INTO vProposal FROM proposal WHERE proposal_id = vProposalId;
    
    -- validasi 0
    IF period1 > period2 THEN
       response := 'FAILED';
       message := 'input periode salah';
       GOTO ujung;
    END IF;

    -- validasi 1
    IF vProposal.mekanisme_penagihan != 'OFFINVOICE' THEN
       response := 'FAILED';
       message := 'Mekanisme Penagihan PC Harus Off Invoices';
       GOTO ujung;
    END IF;

     -- validasi 2
    IF vProposal.STATUS != 'ACTIVE' THEN
       response := 'FAILED';
       message := 'Status PC tidak aktif';
       GOTO ujung;
    END IF;

    -- validasi 3
    IF vProposal.report_run_number != keypc THEN
       response := 'FAILED';
       message := 'No Key PC tidak sesuai  dengan no PC';
       GOTO ujung;
    END IF;

    --validasi ke 4
    IF util_pkg.working_days_between(SYSDATE, period2) < 7 THEN
      response := 'FAILED';
      message := 'Klaim PC harus di atas 7 hari kerja ( di luar hari libur dan sabtu minggu )';
      GOTO ujung;
    END IF;


    --validasi ke 5
    IF sysdate <= period2 THEN
      response := 'FAILED';
      message := 'Klaim PC tidak bisa ketika periode promo masih atau belum berjalan';
      GOTO ujung;
    END IF;
    
    --validasi ke 6
    IF period2 not between vProposal.periode_prog_from and vProposal.periode_prog_to THEN
      response := 'FAILED';
      message := 'Klaim PC tidak boleh di luar atau melebihi tanggal promo';
      GOTO ujung;
      
     ELSIF period1 not between vProposal.periode_prog_from and vProposal.periode_prog_to THEN
      response := 'FAILED';
      message := 'Klaim PC tidak boleh di luar atau melebihi tanggal promo';
      GOTO ujung;
    END IF;

    --validasi ke 7
    IF last_Day(period1) = last_day(period2)
        then 
             isMultiMonth := False;
        else
             isMultiMonth := True;
    end if;
    
    IF last_day(vProposal.periode_prog_to) = last_day(period2)
        then
             isLastMonth := True;
        else
             isLastMonth := False;
        end if;
        
       
    IF isMultimonth  
    AND isLastMonth   
    AND vProposal.periode_prog_to != period2 
    THEN
      response := 'FAILED';
      message := 'Hanya bisa klaim bulan yang sudah lewat ( close month ) 0';
    GOTO ujung;
      
    ElSIF isMultiMonth
    AND NOT isLastMonth  
    AND last_day(period2) != period2 
    THEN
      response := 'FAILED';
      message := 'Hanya bisa klaim bulan yang sudah lewat ( close month ) 1';
    GOTO ujung;
      
    ElSIF NOT isMultiMonth
    AND isLastMonth
    AND  vProposal.periode_prog_to != period2 
    THEN
      response := 'FAILED';
      message := 'Hanya bisa klaim bulan yang sudah lewat ( close month ) 2';
    GOTO ujung;
    
    ElSIF NOT isMultiMonth
    AND NOT isLastMonth
    AND  last_day(period2) != period2
    THEN
      response := 'FAILED';
      message := 'Hanya bisa klaim bulan yang sudah lewat ( close month ) 4';
    GOTO ujung;
    
    END IF;

    -- validasi 8
    BEGIN 
      SELECT * INTO vDcv1 FROM dcv_request
      WHERE dcvh_no_pp_id = vProposalId
      AND TO_CHAR(dcvh_submit_time,'YYYYMM') = TO_CHAR(SYSDATE,'YYYYMM')
      AND dcvh_status != 'CANCEL';
      response := 'FAILED';
      message := 'Hanya bisa 1x Klaim untuk nomor PC dengan periode yang sama';
      GOTO ujung;
      
    EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN TOO_MANY_ROWS THEN
      response := 'FAILED';
      message := 'Hanya bisa 1x Klaim untuk nomor PC dengan periode yang sama';
      GOTO ujung;
    END;
    
    -- sukses
    response := 'PASSED';
    <<ujung>>
    null;
  END ;

/
