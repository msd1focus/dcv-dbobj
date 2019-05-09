REM INSERTING into SEC_DEPT
SET DEFINE OFF;
Insert into SEC_DEPT (ID,DEPT_CODE,DEPT_DESC,SLA1,SLA2) values (1,'DISTI','DISTRIBUTOR',2,null);
Insert into SEC_DEPT (ID,DEPT_CODE,DEPT_DESC,SLA1,SLA2) values (2,'SALES','SALES',3,null);
Insert into SEC_DEPT (ID,DEPT_CODE,DEPT_DESC,SLA1,SLA2) values (3,'TC','TC',4,null);
Insert into SEC_DEPT (ID,DEPT_CODE,DEPT_DESC,SLA1,SLA2) values (4,'TAX','TAX',2,null);
Insert into SEC_DEPT (ID,DEPT_CODE,DEPT_DESC,SLA1,SLA2) values (5,'PROMO','PROMO',3,null);
Insert into SEC_DEPT (ID,DEPT_CODE,DEPT_DESC,SLA1,SLA2) values (6,'AP','ACCT PAY',3,null);
Insert into SEC_DEPT (ID,DEPT_CODE,DEPT_DESC,SLA1,SLA2) values (99,'SYSTEM','SYSTEM',null,null);

REM INSERTING into SEC_USER
SET DEFINE OFF;
Insert into SEC_USER (ID,USERNAME,PASSWD,DEPARTMENT,PANGKAT,SP_ASSIGN1,SP_ASSIGN2,REPORT_TO_ID) values (6,'AP1',null,6,null,null,null,null);
Insert into SEC_USER (ID,USERNAME,PASSWD,DEPARTMENT,PANGKAT,SP_ASSIGN1,SP_ASSIGN2,REPORT_TO_ID) values (1,'Sales1',null,2,null,null,null,null);
Insert into SEC_USER (ID,USERNAME,PASSWD,DEPARTMENT,PANGKAT,SP_ASSIGN1,SP_ASSIGN2,REPORT_TO_ID) values (2,'TC1',null,3,null,null,null,null);
Insert into SEC_USER (ID,USERNAME,PASSWD,DEPARTMENT,PANGKAT,SP_ASSIGN1,SP_ASSIGN2,REPORT_TO_ID) values (3,'Tax1',null,4,null,null,null,null);
Insert into SEC_USER (ID,USERNAME,PASSWD,DEPARTMENT,PANGKAT,SP_ASSIGN1,SP_ASSIGN2,REPORT_TO_ID) values (4,'Disti1',null,1,null,null,null,null);
Insert into SEC_USER (ID,USERNAME,PASSWD,DEPARTMENT,PANGKAT,SP_ASSIGN1,SP_ASSIGN2,REPORT_TO_ID) values (5,'Promo1',null,5,null,null,null,null);
Insert into SEC_USER (ID,USERNAME,PASSWD,DEPARTMENT,PANGKAT,SP_ASSIGN1,SP_ASSIGN2,REPORT_TO_ID) values (99,'SYSTEM',null,99,null,null,null,null);

REM INSERTING into WF_NODE
SET DEFINE OFF;
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('AP2','Process Finance','Job',6,null,null,null,'wf_job.run_ap2',null,null,null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('TC2','Collect Dokumen Fisik','Human',3,null,null,null,null,'Terima dokumen fisik dari Tax dan Distributor','N',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('TX4','Update PPh','Human',4,null,null,null,null,'Update PPH sesuai dgn dokumen PO lalu kirim ke TC','Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('D0','Entri Data DCV','Start',1,null,null,null,null,null,'Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('SL1','Proses Sales','Human',2,null,null,null,null,'Silakan approve/reject DCV ini','Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('END','Payment','End',6,null,null,null,null,null,'Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('TC1','Proses TC','Human',3,null,null,null,null,'TC diharapkan input keterangan kwitansi, PPN serta breakdown PC-line','Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('TX1','Cek Ketr. Kwitansi','Human',4,null,null,null,null,'Cek keterangan kwitansi dan flag PPN','Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('PR1','Create PO GR','Human',5,null,null,null,null,null,'Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('D3','Proses Reject','Human',1,null,null,null,null,'DCV ini ditolak. Silakan Terminate','Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('D2','Attach no Resi Kwitansi','Human',1,null,null,null,null,'Silakan upload / update No Resi Faktur','T',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('TC3','Collect Dokumen Fisik','Human',3,null,null,null,null,'Terima dokumen fisik dari Tax dan Distributor','Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('TC4','Serah Dokumen Fisik','Human',3,null,null,null,null,'Serahkan dokumen Kwitansi, Faktur Pajak, PO, GR ke bagian AP','Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('TX3','Terima Kw-c, FP, PO, GR','Human',4,null,null,null,null,'Terima atau tolak dokumen dari Promo','Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('AP1','Proses Finance','Human',6,null,null,null,null,null,'Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('M1','Collect dokumen Fisik','Merge',3,null,null,null,null,null,'Y',2);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('D1','Attach Kwitansi + Faktur Pajak','Human',1,null,null,null,null,'Harap upload dokumen kwitansi dan faktur pajak, serta entri no faktur','Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('TX2','Verify Kwitansi + FP','Human',4,null,null,null,null,'Cetak faktur dan kwitansi, dan revisi no faktur jika salah','Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('S1','Create PO GR','Split',5,null,null,null,null,null,null,null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('STOP','Cancel','Stop',1,null,null,null,null,null,null,null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('PR2','Create PO GR','Human',5,null,null,null,null,null,'Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('PR3','Create PO GR','Human',5,null,null,null,null,null,'Y',null);
Insert into WF_NODE (NODECODE,NODE_DESC,NODETYPE,DEPARTMENT,PANGKAT,SP_ASSIGN1,ASSIGNED_USERS,EXECSCRIPT,KETR_INSTRUKSI,PRIME_ROUTE,MERGE_COUNT) values ('SC1','Cek PR CM','Script',3,null,null,null,'wf_pkg.get_pr_cm',null,'Y',null);

REM INSERTING into WF_NODE_ROUTE
SET DEFINE OFF;
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (70,'AP1',1,'Terima dokumen-2 DCV','AP2',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (71,'AP1',2,'Tolak dokumen-2 DCV','TC4',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (72,'AP2',1,'PAID','END',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (10,'D1',1,'Attach Kwitansi + Faktur Pajak','TX2',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (11,'D2',1,'Attach Resi Kwitansi','TC2',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (12,'D3',1,'Batal DCV','STOP',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (20,'SL1',1,'Approve','TC1',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (21,'SL1',2,'Reject','D3',null,null,'Y');
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (30,'TC1',1,'Approve','SC1',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (31,'TC1',2,'Reject','D3',null,null,'Y');
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (32,'TC2',1,'Terima Kwitansi asli','M1',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (33,'TC2',2,'Tolak Kwitansi asli','D2',null,null,'Y');
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (34,'TC3',1,'Terima Kw-c, FP, PO, GR','M1',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (36,'TC4',1,'Serah Kw-a, Kw-c, FP, PO, GR','AP1',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (35,'TC3',2,'Tolak Kw-c, FP, PO, GR','TX3',null,null,'Y');
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (40,'TX1',1,'Approve','D1',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (41,'TX1',2,'Reject','TC1',null,null,'Y');
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (42,'TX2',1,'Serah Kw-c, FP','S1',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (43,'TX2',2,'Reject','D1',null,null,'Y');
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (44,'TX3',1,'Terima Kw-c, FP, PO, GR','TX4',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (45,'TX3',2,'Tolak Kw-c, FP, PO, GR','PR3',null,null,'Y');
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (46,'TX4',1,'Kirim Kw-c, FP, PO, GR','TC3',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (50,'PR1',1,'Terima Kw-c, FP','PR2',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (51,'PR1',2,'Tolak Kw-c, FP','TX2',null,null,'Y');
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (52,'PR2',1,'Create PR - GR','PR3',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (53,'PR3',1,'Serah Kw-c, FP, PO, GR','TX3',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (90,'S1',1,'Proceed to Promo','PR1',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (91,'S1',2,'Distibutor bisa kirim Kwitansi asli','D2',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (60,'M1',1,'Kumpulkan dokumen fisik','TC4',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (80,'SC1',1,'Bayar dg PR','TX1',null,null,null);
Insert into WF_NODE_ROUTE (ID,NODE_ID,PILIHAN,DESCRIPTION,REFNODE,PANGKAT,SP_ASSIGNMENT,RETURN_TASK) values (81,'SC1',2,'Bayar dg CM','END',null,null,null);

REM INSERTING into HOLIDAY
SET DEFINE OFF;
Insert into HOLIDAY (ID,START_DT,END_DT,DESCRIPTION) values (1,to_date('07-MAR-19','DD-MON-RR'),to_date('07-MAR-19','DD-MON-RR'),'Hari Raya Nyepi');
Insert into HOLIDAY (ID,START_DT,END_DT,DESCRIPTION) values (2,to_date('03-APR-19','DD-MON-RR'),to_date('03-APR-19','DD-MON-RR'),'Hari Raya Nyepi');
Insert into HOLIDAY (ID,START_DT,END_DT,DESCRIPTION) values (3,to_date('19-APR-19','DD-MON-RR'),to_date('19-APR-19','DD-MON-RR'),'Isra Mi''raj');

BEGIN
FOR I IN 201903..203012 LOOP
  INSERT INTO DCV_NUMBER (PERIOD, LASTNUM, MODIFIED_DT)
  VALUES (I, 0, SYSDATE);
END LOOP;
END;
/

REM INSERTING into DCV_REQUEST
SET DEFINE OFF;
Insert into DCV_REQUEST (DCV_HDR_ID,CUSTOMER_CODE,CUSTOMER_NAME,COMPANY,NO_PC,KEY_PC,PERIODE_DCV_START,PERIODE_DCV_END,PC_KATEGORI,PC_TIPE,PERIODE_PC_START,PERIODE_PC_END,NO_DCV,DCV_SUBMIT_TIME,DCV_VALUE,APPV_VALUE,PPN,REGION_CODE,REGION_DESC,AREA_CODE,AREA_DESC,LOC_CODE,LOC_DESC,KETR_KWITANSI,PC_TC,TYPE_PC_TC,DISCOUNT_TYPE,METODE_BAYAR,DCV_STATUS,LAST_STEP,NOTES,MODIFIED_DT,MODIFIED_BY,CURRENT_STEP) values (1,'223','xsdfsdf','fdi','I0318000406','224304-504',to_date('01-MAR-19','DD-MON-RR'),to_date('31-MAR-19','DD-MON-RR'),'FOOD',null,to_date('01-MAR-19','DD-MON-RR'),to_date('30-APR-19','DD-MON-RR'),'201903000001',to_date('14-APR-19','DD-MON-RR'),500000,500000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'D1');

REM INSERTING into DCV.WF_TASK
SET DEFINE OFF;
Insert into WF_TASK (ID,NO_DCV,TASK_TYPE,ASSIGN_TIME,ASSIGN_TO_BU,SP_ASSIGN1,PROGRESS_STATUS,NODECODE,KETR_INSTRUKSI,PREV_TASK,PREV_NODE,DECISION,EXECSCRIPT,PESAN,PRIME_ROUTE,RETURN_TASK,PROCESS_BY,PROCESS_TIME,SLA,NEXT_TASK,NEXT_NODE) values (1,'201903000001','Human',to_date('14-APR-19','DD-MON-RR'),2,null,'DONE','SL1',null,null,null,1,null,null,null,null,'Sales1',to_date('18-APR-19','DD-MON-RR'),null,105,'TC1');
Insert into WF_TASK (ID,NO_DCV,TASK_TYPE,ASSIGN_TIME,ASSIGN_TO_BU,SP_ASSIGN1,PROGRESS_STATUS,NODECODE,KETR_INSTRUKSI,PREV_TASK,PREV_NODE,DECISION,EXECSCRIPT,PESAN,PRIME_ROUTE,RETURN_TASK,PROCESS_BY,PROCESS_TIME,SLA,NEXT_TASK,NEXT_NODE) values (105,'201903000001','Human',to_date('18-APR-19','DD-MON-RR'),3,null,'DONE','TC1',null,null,'SL1',null,null,null,'Y',null,'',null,null,null,'');
