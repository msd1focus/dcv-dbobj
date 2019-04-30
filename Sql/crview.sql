CREATE OR REPLACE FORCE VIEW "DCV_MONITOR" AS
WITH task_query AS
(SELECT t1.*, dp.dept_code
FROM wf_task t1, sec_dept dp
WHERE t1.progress_status = 'WAIT'
AND t1.task_type <> 'Merge'
and t1.assign_to_bu = dp.id
AND CASE WHEN t1.prime_route = 'Y' THEN 'A'
      WHEN t1.prime_route = 'N' AND EXISTS (SELECT 'X' FROM wf_task t2
               WHERE t1.no_dcv = t2.no_dcv
              AND progress_status = 'WAIT'
              AND t1.assign_to_bu = t2.assign_to_bu
              AND t1.id <> t2.id
              AND t2.prime_route = 'Y') THEN 'B'
      WHEN t1.prime_route = 'N' AND NOT EXISTS (SELECT 'X' FROM wf_task t2
               WHERE t1.no_dcv = t2.no_dcv
              AND progress_status = 'WAIT'
              AND t1.assign_to_bu = t2.assign_to_bu
              AND t1.id <> t2.id
              AND t2.prime_route = 'Y') THEN 'A'
  END = 'A' )
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
,t.dept_code
,NVL(t.return_task,'T') return_task
,t.sla
FROM dcv_request r
LEFT OUTER JOIN dcv_documents d
ON
d.dcv_hdr_id = r.dcv_hdr_id AND
d.doc_type = 'FAKTUR'
LEFT OUTER JOIN task_query t
ON
t.no_dcv = r.no_dcv;

CREATE OR REPLACE FORCE VIEW "DCV"."UOM_LIST" ("UOMCODE", "UOMDESC", "UOMTYPE") AS
select 'uom_code' uomcode, 'uom_desc' uomdesc, 'uom_type' uomtype from dual;
