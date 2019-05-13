CREATE OR REPLACE FORCE VIEW "DCV_MONITOR" AS
WITH
task_query AS
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
  END = 'A'
),
sales_hierarchy as
(  SELECT username, CONNECT_BY_ROOT username AS AuthAppr, LEVEL-1 AS Pathlen
   FROM sec_user
   WHERE department = 2
   CONNECT BY PRIOR id = report_to_id
)
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
,CASE WHEN t.dept_code = 'DISTI' THEN r.customer_code
      WHEN t.dept_code = 'SALES' THEN sh.AuthAppr
      ELSE '' END AS auth_appr
FROM dcv_request r
LEFT OUTER JOIN dcv_documents d
ON
d.dcv_hdr_id = r.dcv_hdr_id AND
d.doc_type = 'FAKTUR'
LEFT OUTER JOIN sales_hierarchy sh
ON r.pc_initiator = sh.username
LEFT OUTER JOIN task_query t
ON
t.no_dcv = r.no_dcv;


CREATE VIEW pc_produk_vw AS
SELECT p.proposal_id
, p.proposal_no
, p.proposal_date
, p.periode_prog_from
, p.periode_prog_to
, p.prog_promo
, p.proposal_type
, p.discount_type
, p.mekanisme_penagihan
, p.status
, p.pemohon
, p.confirm_no
, p.user_type_creator
, p.report_run_number
, pp.product_category
, pp.product_category_desc
, pp.product_class
, pp.product_class_desc
, pp.product_brand
, pp.product_brand_desc
, pp.product_ext
, pp.product_ext_desc
, pp.product_pack
, pp.product_pack_desc
FROM promo_produk pp
, proposal p
WHERE p.proposal_id = pp.proposal_id
AND NVL(p.confirm_no,'Auto Generated') <> 'Auto Generated';


CREATE OR REPLACE FORCE EDITIONABLE VIEW MASTER_CUSTOMER AS
select
  a.customer_id as cust_id,
  a.customer_number as cust_code,
  a.customer_name as cust_name,
  (a.customer_number || ' - ' || a.customer_name || ' - ' || b.description) as cust_fullname,
  a.attribute3 as region_code,
c.description as region_name,
  (a.attribute3 || ' ' || c.description) as region_fullname,
  a.attribute4 as area_code,
d.description as area_name,
  (a.attribute4 || ' ' || d.description) as area_fullname,
  a.attribute5 as location_code,
b.description as location_name,
  (a.attribute5 || ' ' || b.description) as location_fullname,
  a.attribute8 as type_code,
f.description as type_name,
  (a.attribute8 || ' ' || f.description) as type_fullname,
  a.attribute1 as group_code,
e.description as group_name,
  (a.attribute1 || ' ' || e.description) as group_fullname,
a.status as cust_status
from
  apps.ar_customers a,
  apps.fcs_flex_values_vl b,
  apps.fcs_flex_values_vl c,
  apps.fcs_flex_values_vl d,
  apps.fcs_flex_values_vl e,
  apps.fcs_flex_values_vl f
where a.attribute5 = b.flex_value
  and a.attribute3 = c.flex_value
  and a.attribute4 = d.flex_value
  and a.attribute1 = e.flex_value
  and a.attribute8 = f.flex_value
order by region_code, area_code, location_code, cust_fullname;
