SET DEFINE OFF;

REM TEST SCENARIO approval by sales
REM DCVH_ID = 1010

DELETE WF_TASK WHERE DCVH_ID = 1010;
DELETE DCV_REQUEST WHERE DCVH_ID = 1010;
REM INSERTING into DCV_REQUEST
alter table dcv_request disable all triggers;
Insert into DCV_REQUEST (DCVH_ID,DCVH_NO_DCV,DCVH_STATUS,DCVH_LAST_STEP,DCVH_CURRENT_STEP,MODIFIED_DT,MODIFIED_BY,DCVH_CUST_CODE,DCVH_CUST_NAME,DCVH_COMPANY,DCVH_NO_PC,DCVH_KEY_PC,DCVH_NO_PP,DCVH_NO_PP_ID,DCVH_PERIODE_DCV_START,DCVH_PERIODE_DCV_END,DCVH_PC_KATEGORI,DCVH_PC_TIPE,DCVH_PERIODE_PC_START,DCVH_PERIODE_PC_END,DCVH_SUBMIT_TIME,DCVH_SELISIH_HARI,DCVH_VALUE,DCVH_APPV_VALUE,DCVH_KETR_KWITANSI,DCVH_METODE_BAYAR,DCVH_REGION,DCVH_AREA,DCVH_LOCATION) values (1010,'201909000026','ON-PROGRESS',null,null,to_date('29-OCT-19','DD-MON-RR'),'Disti1','Disti1','Disti1','I','I0318003347','23080356181023','DIA18030052',1827,to_date('21-DEC-18','DD-MON-RR'),to_date('01-JAN-19','DD-MON-RR'),'I03',null,to_date('21-DEC-18','DD-MON-RR'),to_date('01-JAN-19','DD-MON-RR'),to_date('07-JAN-19','DD-MON-RR'),272,null,null,null,'PO',null,null,null);
alter table dcv_request enable all triggers;
REM INSERTING into WF_TASK
SET DEFINE OFF;
Insert into WF_TASK (ID,NO_DCV,TASK_TYPE,ASSIGN_TIME,BAGIAN,ROLE_ASSIGNED,PROGRESS_STATUS,NODECODE,PREV_TASK,TAHAPAN,DECISION,EXECSCRIPT,NEXT_TASK,NEXT_NODE,NOTE,PRIME_ROUTE,RETURN_TASK,PROCESS_BY,PROCESS_TIME,SLA,ROLLBACK_TASK,ROLLBACK_ID,BEBAN_SLA,SORTING_TAG,TARGET_SELESAI,DCVH_ID) values (1011,'201909000026','Start',SYSDATE-3,'Distributor',null,'DONE','D0',null,'Sudah submit DCV Request',1,null,1012,'SL1',null,'Y',null,'Disti1',SYSDATE-3,null,null,null,null,null,null,1010);
Insert into WF_TASK (ID,NO_DCV,TASK_TYPE,ASSIGN_TIME,BAGIAN,ROLE_ASSIGNED,PROGRESS_STATUS,NODECODE,PREV_TASK,TAHAPAN,DECISION,EXECSCRIPT,NEXT_TASK,NEXT_NODE,NOTE,PRIME_ROUTE,RETURN_TASK,PROCESS_BY,PROCESS_TIME,SLA,ROLLBACK_TASK,ROLLBACK_ID,BEBAN_SLA,SORTING_TAG,TARGET_SELESAI,DCVH_ID) values (1012,'201909000026','Human',SYSDATE-3,'Sales',null,'DONE','SL1',1011,'Ditolak - Sales',2,null,1100,'D1',null,'Y',null,'Sales1',SYSDATE-2,null,null,null,null,null,null,1010);
Insert into WF_TASK (ID,NO_DCV,TASK_TYPE,ASSIGN_TIME,BAGIAN,ROLE_ASSIGNED,PROGRESS_STATUS,NODECODE,PREV_TASK,TAHAPAN,DECISION,EXECSCRIPT,NEXT_TASK,NEXT_NODE,NOTE,PRIME_ROUTE,RETURN_TASK,PROCESS_BY,PROCESS_TIME,SLA,ROLLBACK_TASK,ROLLBACK_ID,BEBAN_SLA,SORTING_TAG,TARGET_SELESAI,DCVH_ID) values (1100,'201909000026','Human',SYSDATE-2,'Distributor',null,'DONE','D1',1012,'Submit DCV - Distributor',1,null,1122,'SCRP-1',null,'Y','Y','Disti1',SYSDATE-1,null,null,null,null,'A',null,1010);
Insert into WF_TASK (ID,NO_DCV,TASK_TYPE,ASSIGN_TIME,BAGIAN,ROLE_ASSIGNED,PROGRESS_STATUS,NODECODE,PREV_TASK,TAHAPAN,DECISION,EXECSCRIPT,NEXT_TASK,NEXT_NODE,NOTE,PRIME_ROUTE,RETURN_TASK,PROCESS_BY,PROCESS_TIME,SLA,ROLLBACK_TASK,ROLLBACK_ID,BEBAN_SLA,SORTING_TAG,TARGET_SELESAI,DCVH_ID) values (1122,'201909000026','Script',SYSDATE-1,'Distributor',null,'DONE','SCRP-1',1100,'Submit ulang DCV - Distributor',1,'wfproc_pkg.back2_sales_tc',1123,'SL1',null,'Y',null,'Disti1',SYSDATE-1,null,null,null,null,'A',null,1010);
Insert into WF_TASK (ID,NO_DCV,TASK_TYPE,ASSIGN_TIME,BAGIAN,ROLE_ASSIGNED,PROGRESS_STATUS,NODECODE,PREV_TASK,TAHAPAN,DECISION,EXECSCRIPT,NEXT_TASK,NEXT_NODE,NOTE,PRIME_ROUTE,RETURN_TASK,PROCESS_BY,PROCESS_TIME,SLA,ROLLBACK_TASK,ROLLBACK_ID,BEBAN_SLA,SORTING_TAG,TARGET_SELESAI,DCVH_ID) values (1123,'201909000026','Human',SYSDATE-1,'Sales',null,'WAIT','SL1',1122,'Sedang Proses Sales',null,null,null,null,null,'Y',null,null,null,null,null,null,null,'A',null,1010);

COMMIT;

DECLARE
  vResponse VARCHAR2(300);
  res NUMBER;
BEGIN
    vResponse := wf_pkg.post_action ('201909000026', 'SL1', 1, 'Sales1') ;  -- sales TERIMA
    dbms_output.put_line('Hasilnya:');
    dbms_output.put_line(vResponse);   
END;
/
