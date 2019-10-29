create or replace PACKAGE UTIL_PKG AS
   TYPE t_split_array IS TABLE OF VARCHAR2(4000);
   
    FUNCTION split_text (p_text IN  CLOB, p_delimeter  IN  VARCHAR2 DEFAULT ',') RETURN t_split_array;
    FUNCTION terbilang (n NUMBER) RETURN VARCHAR2;
    PROCEDURE send_mail (p_to VARCHAR2, p_cc VARCHAR2, p_subject VARCHAR2, p_message VARCHAR2) ;
    FUNCTION working_days_between (fromDate DATE, toDate DATE) RETURN NUMBER;
END UTIL_PKG;
/

create or replace PACKAGE BODY util_pkg
AS

  recursive_num number := 0;

  FUNCTION split_text (p_text       IN  CLOB,
                         p_delimeter  IN  VARCHAR2 DEFAULT ',')
      RETURN t_split_array IS
    -- ----------------------------------------------------------------------------
    -- Could be replaced by APEX_UTIL.STRING_TO_TABLE.
    -- ----------------------------------------------------------------------------
      l_array  t_split_array   := t_split_array();
      l_text   CLOB := p_text;
      l_idx    NUMBER;
  BEGIN
      l_array.delete;

      IF l_text IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'P_TEXT parameter cannot be NULL');
      END IF;

      WHILE l_text IS NOT NULL LOOP
        l_idx := INSTR(l_text, p_delimeter);
        l_array.extend;
        IF l_idx > 0 THEN
          l_array(l_array.last) := SUBSTR(l_text, 1, l_idx - 1);
          l_text := SUBSTR(l_text, l_idx + 1);
        ELSE
          l_array(l_array.last) := l_text;
          l_text := NULL;
        END IF;
      END LOOP;
      RETURN l_array;
  END split_text;

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
    vSign NUMBER;
    date1 DATE;
    date2 DATE;
  BEGIN

    IF TRUNC(fromDate) < TRUNC(toDate) THEN
        date1 := TRUNC(fromDate);
        date2 := TRUNC(todate);
        vSign := 1;
    ELSE
        date1 := TRUNC(toDate);
        date2 := TRUNC(fromdate);
        vSign := -1;
    END IF;
    
    vSelisih := date2 - date1;
    weekend_num := FLOOR(vSelisih/7);
    rems := MOD(vSelisih,7);

    IF (rems = 0) THEN addwe := 0;
    ELSIF (rems = 6) THEN addwe := 1;
    ELSIF TO_CHAR(date1,'D') = '1' THEN addwe := 0.5;
    ELSIF TO_CHAR(date1,'D') + rems < 7 THEN addwe := 0;
    ELSIF TO_CHAR(date1,'D') + rems > 7 THEN addwe := 1;
    ELSE addwe := 0.5;
    END IF; 

    -- jumlah holiday ???
    SELECT COUNT(*) INTO holiday_num FROM holiday
      WHERE tgl_libur BETWEEN date1 AND date2;

    RETURN (vSign*(vSelisih - 2*(weekend_num + addwe) - holiday_num));    
  END working_days_between;

  PROCEDURE process_recipients(p_mail_conn IN OUT UTL_SMTP.connection,
                               p_list      IN     VARCHAR2)
  AS
    l_tab t_split_array;
  BEGIN
    IF TRIM(p_list) IS NOT NULL THEN
      l_tab := split_text(p_list);
      FOR i IN 1 .. l_tab.COUNT LOOP
        UTL_SMTP.rcpt(p_mail_conn, TRIM(l_tab(i)));
      END LOOP;
    END IF;
  END;

  PROCEDURE send_mail (p_to VARCHAR2, p_cc VARCHAR2, p_subject VARCHAR2, p_message VARCHAR2) 
  AS
    vHost VARCHAR2(20);
    vPort NUMBER;
    vRecipients VARCHAR2(100);
    l_mail_conn   UTL_SMTP.connection;
    vFrom VARCHAR2(50) := 'focusdcv_admin@focus.co.id';
  BEGIN
    l_mail_conn := UTL_SMTP.open_connection(vHost, vPort);

    UTL_SMTP.helo(l_mail_conn, vHost);
    UTL_SMTP.mail(l_mail_conn, 'admindcv@focus.co.id');
    process_recipients(l_mail_conn, p_to);
    process_recipients(l_mail_conn, p_cc);

    UTL_SMTP.open_data(l_mail_conn);
    UTL_SMTP.write_data(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'To: ' || p_to || UTL_TCP.crlf);
    IF TRIM(p_cc) IS NOT NULL THEN
      UTL_SMTP.write_data(l_mail_conn, 'Cc: ' || REPLACE(p_cc, ',', ';') || UTL_TCP.crlf);
    END IF;
    UTL_SMTP.write_data(l_mail_conn, 'From: ' || vFrom || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || p_subject || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || vFrom || UTL_TCP.crlf || UTL_TCP.crlf);

    UTL_SMTP.write_data(l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);

    UTL_SMTP.close_data(l_mail_conn);

    UTL_SMTP.quit(l_mail_conn);


  END send_mail;

END util_pkg;
/
