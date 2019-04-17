CREATE OR REPLACE FORCE VIEW "DCV_MONITOR" AS
SELECT
  r.dcv_hdr_id
  ,r.customer_code
  ,r.customer_name
  ,r.company
  ,r.no_pc
  ,r.key_pc
  ,r.periode_dcv_start
  ,r.periode_dcv_end
  ,r.pc_kategori
  ,r.pc_tipe
  ,r.periode_pc_start
  ,r.periode_pc_end
  ,r.no_dcv
  ,r.dcv_submit_time
  ,r.dcv_value
  ,r.appv_value
  ,r.ppn
  ,r.region_code
  ,r.region_desc
  ,r.area_code
  ,r.area_desc
  ,r.loc_code
  ,r.loc_desc
  ,r.ketr_kwitansi
  ,r.pc_tc
  ,r.type_pc_tc
  ,r.discount_type
  ,r.metode_bayar
  ,r.dcv_status
  ,r.current_step
  ,r.last_step
  ,r.notes
  ,d.doc_no AS no_faktur
  ,d.doc_date AS tgl_faktur
  ,t.id task_id
  ,t.assign_time
  ,t.nodecode
  ,t.prev_node
  ,t.pesan
  ,ro.role_code AS dept
  ,NVL(t.return_task,'T') return_task
  ,t.sla
FROM dcv_request r
LEFT OUTER JOIN dcv_documents d
ON
 d.dcv_hdr_id = r.dcv_hdr_id AND
 d.doc_type = 'FAKTUR'
LEFT OUTER JOIN wf_task t
ON
 t.no_dcv = r.no_dcv
 AND t.progress_status = 'WAIT'
JOIN sec_role ro ON
ro.id = t.assign_to_bu
;

CREATE OR REPLACE FORCE VIEW "DCV"."UOM_LIST" ("UOMCODE", "UOMDESC", "UOMTYPE") AS
select 'uom_code' uomcode, 'uom_desc' uomdesc, 'uom_type' uomtype from dual;
