create or replace PACKAGE UTIL_PKG AS
    FUNCTION next_working_dt (fromDt DATE, numOfDays NUMBER) RETURN DATE;
    FUNCTION working_days_between (fromDate DATE, toDate DATE) RETURN NUMBER;
    FUNCTION terbilang (n NUMBER) RETURN VARCHAR2;
END UTIL_PKG;

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
    date1 DATE;
    date2 DATE;
  BEGIN
    IF fromDate <= to_date THEN
      date1 := fromDate;
      date2 := toDate;
    ELSE
      date1 := toDate;
      date2 := fromDate;
    END IF;

    vSelisih = date2-date1;
    SELECT vSelisih - 2*FLOOR(vSelisih)/7) -
        DECODE(SIGN(TO_CHAR(toDate,'D')-))
    RETURN (1);
  END;

  FUNCTION next_working_dt (fromDt DATE, numOfDays NUMBER) RETURN DATE
  AS
  BEGIN
      RETURN(SYSDATE);
  END next_working_dt;

END util_pkg;
