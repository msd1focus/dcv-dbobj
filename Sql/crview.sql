CREATE OR REPLACE FORCE VIEW "DCV"."DCV_MONITOR" ("DCV_HDR_ID", "CUSTOMER_CODE", "CUSTOMER_NAME", "COMPANY", "NO_PC", "KEY_PC", "PERIODE_DCV_START", "PERIODE_DCV_END", "PC_KATEGORI", "PC_TIPE", "PERIODE_PC_START", "PERIODE_PC_END", "NO_DCV", "DCV_SUBMIT_TIME", "DCV_VALUE", "APPV_VALUE", "PPN", "REGION_CODE", "REGION_DESC", "AREA_CODE", "AREA_DESC", "LOC_CODE", "LOC_DESC", "KETR_KWITANSI", "FILE_COMPLETE", "PC_TC", "TYPE_PC_TC", "DISCOUNT_TYPE", "METODE_BAYAR", "DCV_STATUS", "CURRENT_STEP", "LAST_STEP", "NOTES", "MODIFIED_DT", "MODIFIED_BY", "NO_FAKTUR", "FAKTUR_DATE", "TASK_ID", "ASSIGN_TIME", "PROGRESS_STATUS", "NODECODE", "PREV_NODE", "PESAN", "ASSIGN_TO_BU", "RETURN_TASK") AS
  SELECT
    a.dcv_hdr_id,
    a.customer_code,
    a.customer_name       ,
    a.company             ,
    a.no_pc               ,
    a.key_pc              ,
    a.periode_dcv_start   ,
    a.periode_dcv_end     ,
    a.pc_kategori  ,
    a.pc_tipe      ,
    a.periode_pc_start    ,
    a.periode_pc_end      ,
    a.no_dcv              ,
    a.dcv_submit_time     ,
    a.dcv_value           ,
    a.appv_value          ,
    a.ppn                 ,
    a.region_code         ,
    a.region_desc         ,
    a.area_code           ,
    a.area_desc           ,
    a.loc_code            ,
    a.loc_desc            ,
    a.ketr_kwitansi       ,
    a.file_complete       ,
    a.pc_tc               ,
    a.type_pc_tc          ,
    a.discount_type       ,
    a.metode_bayar        ,
    a.dcv_status          ,
    a.current_step,
    a.last_step         ,
    a.notes               ,
    a.modified_dt         ,
    a.modified_by         ,
    d.doc_no  no_faktur    ,
    d.doc_date faktur_date ,
    t.id task_id        ,
  	t.assign_time       ,
  	t.progress_status   ,
  	t.nodecode          ,
  	t.prev_node         ,
  	t.pesan             ,
  	t.assign_to_bu      ,
    t.return_task
FROM dcv_request a,
     dcv_documents d,
	 wf_task t
WHERE d.dcv_hdr_id = a.dcv_hdr_id
AND   d.doc_type = 'FAKTUR'
AND   t.no_dcv = a.no_dcv
AND   t.task_type = 'HUMANTASK';


CREATE OR REPLACE FORCE VIEW "DCV"."UOM_LIST" ("UOMCODE", "UOMDESC", "UOMTYPE") AS
select 'uom_code' uomcode, 'uom_desc' uomdesc, 'uom_type' uomtype from dual;
