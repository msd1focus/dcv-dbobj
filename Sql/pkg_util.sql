create or replace PACKAGE UTIL_PKG AS
    FUNCTION terbilang (n NUMBER) RETURN VARCHAR2;
 --   PROCEDURE send_email (fromUsr VARCHAR2, recipients VARCHAR2, message VARCHAR2);
    FUNCTION working_days_between (fromDate DATE, toDate DATE) RETURN NUMBER;
END UTIL_PKG;
/

create or replace PACKAGE BODY util_pkg
AS

  recursive_num number := 0;

  FUNCTION terbilang_satuan (n number)
  RETURN VARCHAR2 AS
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
  END terbilang_satuan;

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

  FUNCTION working_days_between (fromDate DATE, toDate DATE)
  RETURN NUMBER
  AS
    vSelisih NUMBER;
    rems NUMBER;
    weekend_num NUMBER;
    addwe NUMBER;
    holiday_num NUMBER;
  BEGIN

    vSelisih := ABS(toDate-fromDate);
    weekend_num := FLOOR(vSelisih/7);
    rems := MOD(vSelisih,7);
    
    IF (rems = 0) THEN addwe := 0;
    ELSIF (rems = 6) THEN addwe := 1;
    ELSIF TO_CHAR(fromDate,'D') = '1' THEN addwe := 0.5;
    ELSIF TO_CHAR(fromDate,'D') + rems < 7 THEN addwe := 0;
    ELSIF TO_CHAR(fromDate,'D') + rems > 7 THEN addwe := 1;
    ELSE addwe := 0.5;
    END IF; 
   
    -- jumlah holiday ???
    SELECT COUNT(*) INTO holiday_num FROM holiday
      WHERE tgl_libur BETWEEN TRUNC(fromDate) AND toDate;

    RETURN (vSelisih - 2*(weekend_num + addwe) - holiday_num);    
  END working_days_between;

END util_pkg;
/
