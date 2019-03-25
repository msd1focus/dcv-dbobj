REM INSERTING into DCV.SEC_ROLE
SET DEFINE OFF;
Insert into DCV.SEC_ROLE (ID,ROLE_CODE,ROLE_DESC,SLA1,SLA2,ROLE_LEVEL,ROLE_PARENT) values (1,'DISTI','DISTRIBUTOR',null,null,null,null);
Insert into DCV.SEC_ROLE (ID,ROLE_CODE,ROLE_DESC,SLA1,SLA2,ROLE_LEVEL,ROLE_PARENT) values (2,'SALES','SALES',null,null,null,null);
Insert into DCV.SEC_ROLE (ID,ROLE_CODE,ROLE_DESC,SLA1,SLA2,ROLE_LEVEL,ROLE_PARENT) values (3,'TC','TC',null,null,null,null);
Insert into DCV.SEC_ROLE (ID,ROLE_CODE,ROLE_DESC,SLA1,SLA2,ROLE_LEVEL,ROLE_PARENT) values (4,'TAX','TAX',null,null,null,null);
Insert into DCV.SEC_ROLE (ID,ROLE_CODE,ROLE_DESC,SLA1,SLA2,ROLE_LEVEL,ROLE_PARENT) values (5,'PROMO','PROMO',null,null,null,null);

REM INSERTING into DCV.WF_NODE
SET DEFINE OFF;
Insert into DCV.WF_NODE (NODECODE,NODE_DESC,NODETYPE,ROLE_ID,execscript) values ('D0','Entri Data DCV','Start',1,null);
Insert into DCV.WF_NODE (NODECODE,NODE_DESC,NODETYPE,ROLE_ID,execscript) values ('SL1','Sales Process','Human',2,null);
Insert into DCV.WF_NODE (NODECODE,NODE_DESC,NODETYPE,ROLE_ID,execscript) values ('END','End','End',null,null);
Insert into DCV.WF_NODE (NODECODE,NODE_DESC,NODETYPE,ROLE_ID,execscript) values ('TC1','Proses TC','Human',3,null);
Insert into DCV.WF_NODE (NODECODE,NODE_DESC,NODETYPE,ROLE_ID,execscript) values ('TX1','Cek Kwitansi','Human',4,null);
Insert into DCV.WF_NODE (NODECODE,NODE_DESC,NODETYPE,ROLE_ID,execscript) values ('D2','Attach Faktur','Human',1,null);
Insert into DCV.WF_NODE (NODECODE,NODE_DESC,NODETYPE,ROLE_ID,execscript) values ('TX2','Cetak Faktur','Human',4,null);
Insert into DCV.WF_NODE (NODECODE,NODE_DESC,NODETYPE,ROLE_ID,execscript) values ('PR1','Create PO','Human',5,null);

REM INSERTING into DCV.HOLIDAY
SET DEFINE OFF;
Insert into DCV.HOLIDAY (ID,START_DT,END_DT,DESCRIPTION) values (1,to_date('07-MAR-19','DD-MON-RR'),to_date('07-MAR-19','DD-MON-RR'),'Hari Raya Nyepi');
Insert into DCV.HOLIDAY (ID,START_DT,END_DT,DESCRIPTION) values (2,to_date('03-APR-19','DD-MON-RR'),to_date('03-APR-19','DD-MON-RR'),'Hari Raya Nyepi');
Insert into DCV.HOLIDAY (ID,START_DT,END_DT,DESCRIPTION) values (3,to_date('19-APR-19','DD-MON-RR'),to_date('19-APR-19','DD-MON-RR'),'Isra Mi''raj');

BEGIN
FOR I IN 201903..203012 LOOP
  INSERT INTO DCV_NUMBER (PERIOD, LASTNUM, MODIFIED_DT)
  VALUES (I, 0, SYSDATE);
END LOOP;
END;
