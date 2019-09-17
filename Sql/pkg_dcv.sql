create or replace PACKAGE DCV_PKG AS
    FUNCTION get_dcv_no RETURN VARCHAR2;
    FUNCTION cek_new_request (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE) RETURN INTEGER;
    FUNCTION uom_conversion_rate (uomfrom VARCHAR2, uomto VARCHAR2) RETURN NUMBER;
    PROCEDURE cek_new_request (nopc VARCHAR2, keypc VARCHAR2, period1 DATE, period2 DATE,
                                response OUT NUMBER, errm OUT VARCHAR2) ;
    FUNCTION cek_stm_report (custcode VARCHAR2, periode1 DATE, periode2 DATE) RETURN NUMBER;
    FUNCTION new_dcv_req (pCustcode VARCHAR2, pNoPc VARCHAR2, pDcvPeriod1 DATE, pDcvPeriod2 DATE) RETURN NUMBER;
    FUNCTION terbilang (n NUMBER) RETURN VARCHAR2;
END DCV_PKG;
/

create or replace PACKAGE BODY DCV_PKG AS
  recursive_num number := 0;

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

  FUNCTION terbilang_satuan (n number)
  return varchar2 as
    hasil varchar2(200);
    a number;
    sisa number;
    kecil number;
  BEGIN
      CASE n
          WHEN 0 THEN RETURN ('');
          WHEN 1 THEN RETURN ('se');
          WHEN 2 THEN RETURN ('dua');
          WHEN 3 THEN RETURN ('tiga');
          WHEN 4 THEN RETURN ('empat');
          WHEN 5 THEN RETURN ('lima');
          WHEN 6 THEN RETURN ('enam');
          WHEN 7 THEN RETURN ('tujuh');
          WHEN 8 THEN RETURN ('delapan');
          WHEN 9 THEN RETURN ('sembilan');
          WHEN 10 THEN RETURN ('sepuluh');
          WHEN 11 THEN RETURN ('sebelas');
          WHEN 12 THEN RETURN ('duabelas');
          WHEN 13 THEN RETURN ('tigabelas');
          WHEN 14 THEN RETURN ('empatbelas');
          WHEN 15 THEN RETURN ('limabelas');
          WHEN 16 THEN RETURN ('enambelas');
          WHEN 17 THEN RETURN ('tujuhbelas');
          WHEN 18 THEN RETURN ('delapanbelas');
          WHEN 19 THEN RETURN ('sembilanbelas');
      END CASE;
  end terbilang_satuan;

  FUNCTION terbilang (n NUMBER) RETURN VARCHAR2 AS
      bilang VARCHAR2(300) := '';
      ekor VARCHAR2(20);
      digitnum NUMBER;
      pembagi NUMBER;
  BEGIN
      recursive_num := recursive_num + 1;

      digitnum := LENGTH(TO_CHAR(n));
      CASE
          WHEN digitnum >= 10 THEN
              pembagi := 1000000000;
              ekor := 'milyar';
          WHEN digitnum >= 7 THEN
              pembagi := 1000000;
              ekor := 'juta';
          WHEN digitnum >= 4 THEN
              pembagi := 1000;
              ekor := 'ribu';
          WHEN digitnum = 3 THEN
              pembagi := 100;
              ekor := 'ratus';
          WHEN digitnum=2 THEN
              pembagi := 10;
              IF n BETWEEN 11 AND 19 THEN ekor := 'belas';
              ELSE ekor := 'puluh';
              END IF;
          WHEN digitnum=1 THEN
              pembagi := 1;
              ekor := '';
      END CASE;

      IF n < 20 THEN bilang := terbilang_satuan(n);
      ELSE
          bilang := terbilang(floor(n/pembagi)) ||' '|| ekor ||' '|| terbilang(MOD(n,pembagi));
      END IF;

      IF recursive_num = 1 THEN
          bilang := REGEXP_REPLACE(bilang,' se$',' satu');
      END IF;
      recursive_num := recursive_num - 1;

      RETURN ltrim(bilang);
  END terbilang;

END DCV_PKG;
/
