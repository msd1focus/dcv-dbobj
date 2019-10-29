DECLARE 
  vResponse VARCHAR2(300);
  res NUMBER;
BEGIN
--    vResponse := wf_pkg.post_action ('201909000026', 'SL1', 2, 'Sales1') ;  -- sales nolak
    vResponse := wf_pkg.post_action ('201909000026', 'D1', 2, 'Disti1') ;  -- sales nolak
 
    dbms_output.put_line('Hasilnya: '|| vResponse);   
END;
/
                      
                      