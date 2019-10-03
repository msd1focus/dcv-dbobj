/**************************************/
/*       Untuk layar Monitoring       */
/**************************************/
CREATE OR REPLACE FORCE VIEW DCV_MONITOR (
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
    nodecode, dcv_status, sla, bagian, auth_appv) AS
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
,CASE WHEN t.bagian = 'DISTRIBUTOR' THEN r.dcvh_cust_code
      WHEN t.bagian = 'SALES' THEN authmap.USER_NAME
      ELSE '' END
FROM dcv_request r
LEFT OUTER JOIN dcv_documents fp ON fp.dcvh_id = r.dcvh_id AND fp.doc_type = 'FAKTUR'
LEFT OUTER JOIN dcv_documents kw ON fp.dcvh_id = r.dcvh_id AND fp.doc_type = 'KWITANSI'
LEFT OUTER JOIN task_qry t ON t.dcvh_id = r.dcvh_id
LEFT OUTER JOIN dcv_user_auth_mapping authmap
    ON authmap.pp_no = CASE
                                WHEN t.bagian = 'SALES' THEN r.dcvh_no_pp
                                ELSE 'x'
                            END;


/**************************************/
/* Gabungan usermgmt PPPC, WO dan DCV */
/**************************************/
CREATE OR REPLACE VIEW dcv_all_users_v (id, user_name, password, full_name, bagian, role_code) as
SELECT id, user_name, password, full_name, 'Sales', 'Sales'
FROM focuspp.app_user_access
UNION
SELECT id, user_name, password, full_name, r.bagian, r.role_code
FROM dcv_user_access u, dcv_user_role ur, dcv_role r
WHERE u.id = ur.user_id
AND ur.role_code = r.role_code;

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
