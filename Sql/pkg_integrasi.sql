CREATE OR REPLACE PACKAGE DCV_INTEGRASI AS
  PROCEDURE info_pembayaran (pNoDcv VARCHAR2, pJenis VARCHAR2, pNilai NUMBER, pSisa NUMBER, pDesc VARCHAR2);
  FUNCTION get_uom_converter(pFromUom VARCHAR2, pToUom VARCHAR) RETURN NUMBER;
  PROCEDURE create_gr (pDCV IN VARCHAR2, pNoGR OUT VARCHAR2, pTglGR OUT DATE);
END DCV_INTEGRASI;
/


CREATE OR REPLACE PACKAGE BODY DCV_INTEGRASI AS

  PROCEDURE info_pembayaran (pNoDcv VARCHAR2, pJenis VARCHAR2, pNilai NUMBER, pSisa NUMBER, pDesc VARCHAR2) AS
    vDcvId NUMBER;
  BEGIN
    SELECT dcvh_id INTO vDcvId FROM dcv_request WHERE dcvh_no_dcv = pNoDcv;

    Insert into dokumen_realisasi (ID,dcvh_id,trx_value,descr,tahapan_realisasi,remaining_val,create_dt)
    values (dcv_seq.nextval, vDcvId, pNilai, pDesc, pJenis, pSisa,SYSDATE);

    IF pSisa = 0 THEN
        UPDATE dcv_request SET dcvh_status = 'PAID' WHERE dcvh_id = vDcvId;
        UPDATE wf_task SET progress_status = 'DONE',
                        process_by = 'EBS',
                        process_time = SYSDATE
        WHERE no_dcv = pNoDcv
        AND progress_status = 'WAIT';
    END IF;
  END info_pembayaran;

  FUNCTION get_uom_converter(pFromUom VARCHAR2, pToUom VARCHAR) RETURN NUMBER AS
  BEGIN
    -- TODO: Implementation required for FUNCTION DCV_EBS.get_uom_converter
    RETURN NULL;
  END get_uom_converter;

  PROCEDURE create_gr (pDCV IN VARCHAR2, pNoGR OUT VARCHAR2, pTglGR OUT DATE) AS
  BEGIN
    pNoGr := 'Abcd';
    pTglGr := SYSDATE;
  END;


END DCV_INTEGRASI;
/
