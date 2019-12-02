/**************************************/
/*       Untuk layar Monitoring       */
/**************************************/
CREATE OR REPLACE FORCE VIEW DCV_MONITOR_NONSALES (
    vwrow_id,
    dcvh_id,
    no_dcv,
    dcv_start_dt, dcv_end_dt,
    periode_submit,
    customer_code, customer_name,
    NO_PC,
    region, area, loc,
    periode_pc_start, periode_pc_end,
    kategori_pc,
    tipe_pc,
    dcv_value,
    appv_value,
    no_faktur,
    no_kwitansi,
    return_task,
    last_step, current_step,
    nodecode, dcv_status, sla, bagian, sales_appv) AS
WITH
task_qry AS
(SELECT t1.id, t1.dcvh_id, t1.no_dcv, t1.bagian, t1.nodecode, t1.return_task, t1.sla
FROM wf_task t1
WHERE t1.task_type = 'Human'
AND t1.progress_status = 'WAIT' -- harusnya wait
AND CASE
    WHEN t1.prime_route = 'N' AND EXISTS (select 'x' from wf_task t2
                                    where t1.no_dcv = t2.no_dcv
                                    and t2.progress_status = 'WAIT'
                                    and t2.bagian = t1.bagian
                                    and t2.id <> t1.id
                                    and t2.prime_route = 'Y') THEN 2
    ELSE 1
    END =1
)
SELECT
r.dcvh_id||'.'||t.id
,r.dcvh_id
,r.dcvh_no_dcv
,r.dcvh_periode_dcv_start
,r.dcvh_periode_dcv_end
,r.dcvh_submit_time
,r.dcvh_cust_code
,r.dcvh_cust_name
,r.dcvh_no_pc
,r.dcvh_region
,r.dcvh_area
,r.dcvh_location
,r.dcvh_periode_pc_start
,r.dcvh_periode_pc_end
,r.dcvh_pc_kategori
,r.dcvh_pc_tipe
,r.dcvh_value
,r.dcvh_appv_value
,fp.doc_no AS nofaktur
,kw.doc_no AS nokwitansi
,t.return_task
,r.dcvh_last_step
,r.dcvh_current_step
,t.nodecode
,r.dcvh_status
,t.sla
,t.bagian
,NULL
FROM dcv_request r
LEFT OUTER JOIN dcv_documents fp ON fp.dcvh_id = r.dcvh_id AND fp.doc_type = 'FAKTUR'
LEFT OUTER JOIN dcv_documents kw ON fp.dcvh_id = r.dcvh_id AND fp.doc_type = 'KWITANSI'
LEFT OUTER JOIN task_qry t ON t.dcvh_id = r.dcvh_id
/

CREATE OR REPLACE FORCE VIEW DCV_MONITOR_SALES (
    vwrow_id,
    dcvh_id,
    no_dcv,
    dcv_start_dt, dcv_end_dt,
    periode_submit,
    customer_code, customer_name,
    NO_PC,
    region, area, loc,
    periode_pc_start, periode_pc_end,
    kategori_pc,
    tipe_pc,
    dcv_value,
    appv_value,
    no_faktur,
    no_kwitansi,
    return_task,
    last_step, current_step,
    nodecode, dcv_status, sla, bagian, sales_appv) AS
WITH
task_qry AS
(SELECT t1.id, t1.dcvh_id, t1.no_dcv, t1.bagian, t1.nodecode, t1.return_task, t1.sla
FROM wf_task t1
WHERE t1.task_type = 'Human'
AND t1.progress_status = 'WAIT' -- harusnya wait
AND CASE
    WHEN t1.prime_route = 'N' AND EXISTS (select 'x' from wf_task t2
                                    where t1.no_dcv = t2.no_dcv
                                    and t2.progress_status = 'WAIT'
                                    and t2.bagian = t1.bagian
                                    and t2.id <> t1.id
                                    and t2.prime_route = 'Y') THEN 2
    ELSE 1
    END =1
)
SELECT
r.dcvh_id||'.'||t.id
,r.dcvh_id
,r.dcvh_no_dcv
,r.dcvh_periode_dcv_start
,r.dcvh_periode_dcv_end
,r.dcvh_submit_time
,r.dcvh_cust_code
,r.dcvh_cust_name
,r.dcvh_no_pc
,r.dcvh_region
,r.dcvh_area
,r.dcvh_location
,r.dcvh_periode_pc_start
,r.dcvh_periode_pc_end
,r.dcvh_pc_kategori
,r.dcvh_pc_tipe
,r.dcvh_value
,r.dcvh_appv_value
,fp.doc_no AS nofaktur
,kw.doc_no AS nokwitansi
,t.return_task
,r.dcvh_last_step
,r.dcvh_current_step
,t.nodecode
,r.dcvh_status
,t.sla
,t.bagian
,sales.user_id
FROM dcv_request r
LEFT OUTER JOIN dcv_documents fp ON fp.dcvh_id = r.dcvh_id AND fp.doc_type = 'FAKTUR'
LEFT OUTER JOIN dcv_documents kw ON fp.dcvh_id = r.dcvh_id AND fp.doc_type = 'KWITANSI'
LEFT OUTER JOIN task_qry t ON t.dcvh_id = r.dcvh_id
LEFT OUTER JOIN dcv_sales_mapping sales ON sales.dcvh_id = r.dcvh_id
/

/**************************************/
/*      List UOM di STM (dummy)       */
/**************************************/
CREATE OR REPLACE FORCE VIEW uom_stm_v (uom) AS
SELECT 'Terkecil' as uom FROM dual
UNION
SELECT 'Dus' as uom FROM dual
UNION
SELECT 'Analysis' as uom FROM dual;

/**************************************/
/*      List PO di EBS  (dummy)       */
/**************************************/
CREATE OR REPLACE VIEW dcv_po_list_v (no_dcv, no_po, line_no, pc_pengganti, pc_tambahan, kode_prod, nama_prod,
                          calc_start_dt, calculation_end_dt, flag_budget, qty, uom, unit_price_exc)
AS SELECT
    'no_dcv',
    'no_po',
    1,
    'PCxxxx1-1',
    'PCyyyyy1-2',
    'abckd',
    'xsfsdlfksdlkfs',
    sysdate-1,
    sysdate ,
    'PB',
    1000,
    'uom',
    30000
FROM dual;

/**************************************/
/*      List Action Options           */
/**************************************/
CREATE OR REPLACE VIEW action_list_v (no_dcv, tahapan, bagian, nodecode, pilihan, keterangan) AS
WITH Q1 AS
(SELECT  p.priv_name, p.id priv_id, r.role_code, ro.node_id, ro.pilihan, ro.description
FROM dcv_privs p, role_privs rp, dcv_role r, dcv_user_role ur, wf_route ro
WHERE rp.priv_id = p.id
AND rp.role_code = r.role_code
AND ur.role_code = r.role_code
AND p.priv_type = 'ACTION'
AND p.ref_id = ro.id),
Q2 AS
(SELECT  t.nodecode, t.no_dcv, t.bagian
FROM wf_task t
WHERE t.task_type = 'Human'
AND t.progress_status = 'WAIT')
SELECT q2.no_dcv, q1.role_code, q2.nodecode, q2.bagian, q1.pilihan, q1.description
FROM Q1, Q2
WHERE q1.node_id = q2.nodecode;

create view all_user_v (id, username, user_source, password, fullname) as
select cust_id, username, 'WO', password, name
from focuspp.wo_users where company = 'FDI'
union
select id, user_name, 'DCV', password, full_name
from dcv_user_access
union
select id, user_name, 'PPPC', password, full_name
from focuspp.app_user_access;

create view all_user_role_v (user_id, role_code, role_name, role_type, bagian) as
select to_char(ur.user_id), r.role_code, r.role_name, r.role_type, r.bagian
from dcv_role r, dcv_user_role ur
where r.role_code = ur.role_code
UNION
select user_id, 'DISTRIBUTOR_ROLE', 'Distributor', 'WF', 'Distributor'
from wo_users;
