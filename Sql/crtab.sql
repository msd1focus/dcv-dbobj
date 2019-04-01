-- Generated by Oracle SQL Developer Data Modeler 18.1.0.082.1035
--   at:        2019-04-01 20:10:53 ICT
--   site:      Oracle Database 12c
--   type:      Oracle Database 12c



DROP TABLE dcv.dcv_documents CASCADE CONSTRAINTS;

DROP TABLE dcv.dcv_number CASCADE CONSTRAINTS;

DROP TABLE dcv.dcv_request CASCADE CONSTRAINTS;

DROP TABLE dcv.doc_movement CASCADE CONSTRAINTS;

DROP TABLE dcv.holiday CASCADE CONSTRAINTS;

DROP TABLE dcv.lookup_code CASCADE CONSTRAINTS;

DROP TABLE dcv.pcline_tc_appr CASCADE CONSTRAINTS;

DROP TABLE dcv.request_dtl CASCADE CONSTRAINTS;

DROP TABLE dcv.sec_bussunit CASCADE CONSTRAINTS;

DROP TABLE dcv.sec_user CASCADE CONSTRAINTS;

DROP TABLE dcv.wf_node CASCADE CONSTRAINTS;

DROP TABLE dcv.wf_node_option CASCADE CONSTRAINTS;

DROP TABLE dcv.wf_task CASCADE CONSTRAINTS;

DROP TABLE dcv.wf_task_merge CASCADE CONSTRAINTS;

CREATE TABLE dcv.dcv_documents (
    id            INTEGER NOT NULL,
    dcv_id        INTEGER NOT NULL,
    doc_type      VARCHAR2(25 CHAR),
    hardcopy      CHAR(1 CHAR),
    file_name     VARCHAR2(500 CHAR) NOT NULL,
    file_loc      VARCHAR2(500 CHAR),
    keterangan    VARCHAR2(500),
    keeper        VARCHAR2(25 CHAR),
    upload_time   DATE,
    doc_no        VARCHAR2(25 CHAR),
    doc_date      DATE
);

COMMENT ON COLUMN dcv.dcv_documents.doc_type IS
    'beritaacara, rekapfaktur, kwitansi, fakturpajak, buktipotong, fakturpengganti, noresi';

CREATE INDEX dcv.dcv_document_no_idx ON
    dcv.dcv_documents (
        doc_no
    ASC );

ALTER TABLE dcv.dcv_documents ADD CONSTRAINT files_pk PRIMARY KEY ( id );

CREATE TABLE dcv.dcv_number (
    period        INTEGER NOT NULL,
    lastnum       INTEGER NOT NULL,
    modified_dt   DATE
);

ALTER TABLE dcv.dcv_number ADD CONSTRAINT dcv_number_pk PRIMARY KEY ( period );

CREATE TABLE dcv.dcv_request (
    dcv_hdr_id          INTEGER NOT NULL,
    customer_code       VARCHAR2(25 CHAR) NOT NULL,
    customer_name       VARCHAR2(50 CHAR),
    company             VARCHAR2(3 CHAR) NOT NULL,
    no_pc               VARCHAR2(100 CHAR) NOT NULL,
    key_pc              VARCHAR2(14 CHAR) NOT NULL,
    periode_dcv_start   DATE NOT NULL,
    periode_dcv_end     DATE,
    pc_kategori         VARCHAR2(5),
    pc_tipe             VARCHAR2(50),
    periode_pc_start    DATE,
    periode_pc_end      DATE,
    no_dcv              VARCHAR2(15 CHAR),
    dcv_submit_time     DATE,
    dcv_value           NUMBER DEFAULT 0,
    appv_value          NUMBER DEFAULT 0,
    ppn                 VARCHAR2(5 CHAR),
    region_code         VARCHAR2(20 CHAR),
    region_desc         VARCHAR2(30 CHAR),
    area_code           VARCHAR2(20 CHAR),
    area_desc           VARCHAR2(400 CHAR),
    loc_code            VARCHAR2(20 CHAR),
    loc_desc            VARCHAR2(300 CHAR),
    ketr_kwitansi       VARCHAR2(500 CHAR),
    file_complete       VARCHAR2(1 CHAR),
    pc_tc               VARCHAR2(100),
    type_pc_tc          VARCHAR2(10 CHAR),
    discount_type       VARCHAR2(50 CHAR),
    metode_bayar        VARCHAR2(5 CHAR),
    dcv_status          VARCHAR2(30),
    notes               VARCHAR2(200 CHAR),
    modified_dt         DATE,
    modified_by         VARCHAR2(50 CHAR)
);

COMMENT ON COLUMN dcv.dcv_request.no_pc IS
    'pppc:proposal:confirm_no';

COMMENT ON COLUMN dcv.dcv_request.key_pc IS
    'pppc:proposal:report_run_number';

COMMENT ON COLUMN dcv.dcv_request.pc_kategori IS
    '?? I03 ??';

COMMENT ON COLUMN dcv.dcv_request.pc_tipe IS
    'food / non food';

COMMENT ON COLUMN dcv.dcv_request.ppn IS
    'flag ada ppn atau tidak (Y/T)';

COMMENT ON COLUMN dcv.dcv_request.pc_tc IS
    'no PC pengganti / tambahan';

COMMENT ON COLUMN dcv.dcv_request.type_pc_tc IS
    'PENGGANTI / TAMBAHAN';

COMMENT ON COLUMN dcv.dcv_request.discount_type IS
    'pppc:proposal:discount_type -- BIAYA/POTONGAN/PROMOBARANG';

COMMENT ON COLUMN dcv.dcv_request.metode_bayar IS
    'PO / CM';

CREATE UNIQUE INDEX dcv.dcv_no_idx ON
    dcv.dcv_request (
        no_dcv
    ASC );

ALTER TABLE dcv.dcv_request ADD CONSTRAINT request_hdr_pk PRIMARY KEY ( dcv_hdr_id );

CREATE TABLE dcv.doc_movement (
    id              INTEGER NOT NULL,
    dcv_id          INTEGER NOT NULL,
    userid          INTEGER,
    username        VARCHAR2(20 CHAR),
    received_from   VARCHAR2(30 CHAR),
    received_dt     DATE,
    sent_to         VARCHAR2(30 CHAR),
    sent_dt         DATE
);

ALTER TABLE dcv.doc_movement ADD CONSTRAINT doc_movement_pk PRIMARY KEY ( id );

CREATE TABLE dcv.holiday (
    id            INTEGER NOT NULL,
    start_dt      DATE,
    end_dt        DATE,
    description   VARCHAR2(50 CHAR)
);

ALTER TABLE dcv.holiday ADD CONSTRAINT holiday_pk PRIMARY KEY ( id );

CREATE TABLE dcv.lookup_code (
    id      INTEGER NOT NULL,
    title   VARCHAR2(60 CHAR),
    value   VARCHAR2(60 CHAR),
    descr   VARCHAR2(120 CHAR)
);

ALTER TABLE dcv.lookup_code ADD CONSTRAINT lookup_code_pk PRIMARY KEY ( id );

CREATE TABLE dcv.pcline_tc_appr (
    id               INTEGER NOT NULL,
    request_dtl_id   INTEGER NOT NULL,
    prod_code        VARCHAR2(30),
    prod_name        VARCHAR2(100),
    qty              INTEGER,
    uom              VARCHAR2(15 CHAR),
    nilai_satuan     NUMBER DEFAULT 0,
    value_total      NUMBER DEFAULT 0,
    mf_ot            VARCHAR2(2 CHAR),
    conversion_uom   NUMBER,
    notes            VARCHAR2(100),
    modified_dt      DATE,
    modified_by      VARCHAR2(50 CHAR)
);

ALTER TABLE dcv.pcline_tc_appr ADD CONSTRAINT req_line_breakdown_pk PRIMARY KEY ( id );

CREATE TABLE dcv.request_dtl (
    id                    INTEGER NOT NULL,
    dcv_hdr_id            INTEGER NOT NULL,
    pc_no                 VARCHAR2(100 CHAR),
    pc_lineno             INTEGER,
    pc_ganti              VARCHAR2(100 CHAR),
    pcganti_lineno        INTEGER,
    prod_class            VARCHAR2(40 CHAR),
    prod_class_desc       VARCHAR2(100 CHAR),
    prod_brand            VARCHAR2(40 CHAR),
    prod_brand_desc       VARCHAR2(100 CHAR),
    prod_ext              VARCHAR2(40 CHAR),
    prod_ext_desc         VARCHAR2(100 CHAR),
    prod_packaging        VARCHAR2(40 CHAR),
    prod_packaging_desc   VARCHAR2(100 CHAR),
    prod_variant          VARCHAR2(40 CHAR),
    prod_variant_desc     VARCHAR2(100 CHAR),
    prod_item             VARCHAR2(40 CHAR),
    prod_item_desc        VARCHAR2(100 CHAR),
    dcv_qty               INTEGER,
    dcv_uom               VARCHAR2(15 CHAR),
    dcv_val_exc           NUMBER DEFAULT 0,
    approve_val_exc       NUMBER DEFAULT 0,
    ppn_code              VARCHAR2(10 CHAR),
    ppn_val               NUMBER,
    pph_code              CHAR(10 CHAR),
    pph_val               NUMBER DEFAULT 0,
    mf_val                NUMBER,
    ot_val                NUMBER,
    total_val_inc         NUMBER,
    selisih               NUMBER,
    catatan_tc            VARCHAR2(100 CHAR),
    modified_dt           DATE,
    modified_by           VARCHAR2(50 CHAR)
);

ALTER TABLE dcv.request_dtl ADD CONSTRAINT request_dtl_pk PRIMARY KEY ( id );

CREATE TABLE dcv.sec_bussunit (
    id            INTEGER NOT NULL,
    role_code     VARCHAR2(15 CHAR) NOT NULL,
    role_desc     VARCHAR2(50 CHAR),
    sla1          INTEGER,
    sla2          INTEGER,
    role_level    INTEGER,
    role_parent   INTEGER
);

COMMENT ON COLUMN dcv.sec_bussunit.role_code IS
    'DISTRI, SALES, TC, TAX, PROMO, AP, AR, CASSIER';

COMMENT ON COLUMN dcv.sec_bussunit.sla1 IS
    'sla1 : target berapa hari proses harus selesai diproses';

COMMENT ON COLUMN dcv.sec_bussunit.sla2 IS
    'cadangan';

COMMENT ON COLUMN dcv.sec_bussunit.role_level IS
    'jika role ada leveling, mis. member - supervisor - mgr';

COMMENT ON COLUMN dcv.sec_bussunit.role_parent IS
    'hirarchy';

ALTER TABLE dcv.sec_bussunit ADD CONSTRAINT role_pk PRIMARY KEY ( id );

CREATE TABLE dcv.sec_user (
    id           INTEGER NOT NULL,
    username     VARCHAR2(50 CHAR) NOT NULL,
    passwd       VARCHAR2(50 CHAR),
    bus_unit     INTEGER NOT NULL,
    pangkat      VARCHAR2(15 CHAR),
    sp_assign1   VARCHAR2(50 CHAR),
    sp_assign2   VARCHAR2(50 CHAR),
    report_to    INTEGER
);

COMMENT ON COLUMN dcv.sec_user.pangkat IS
    'Superviser, member';

COMMENT ON COLUMN dcv.sec_user.sp_assign1 IS
    'mis: untuk TC: food/non food';

ALTER TABLE dcv.sec_user ADD CONSTRAINT user_pk PRIMARY KEY ( id );

CREATE TABLE dcv.wf_node (
    nodecode        VARCHAR2(10 CHAR) NOT NULL,
    node_desc       VARCHAR2(50 CHAR),
    nodetype        VARCHAR2(30 CHAR) NOT NULL,
    business_unit   INTEGER,
    pangkat         VARCHAR2(100 CHAR),
    sp_assign1      VARCHAR2(50 CHAR),
    execscript      VARCHAR2(100 CHAR)
);

COMMENT ON COLUMN dcv.wf_node.nodetype IS
    'normal: decission
split: jadi banyak
merge: jadi satu
autocheck: scheduled check
serahterima dok
end';

COMMENT ON COLUMN dcv.wf_node.pangkat IS
    'member 
supervisor 
member ; supervisor
';

COMMENT ON COLUMN dcv.wf_node.sp_assign1 IS
    'untuk user tertentu : mis food / non food';

COMMENT ON COLUMN dcv.wf_node.execscript IS
    'nama db function unt di-execute';

ALTER TABLE dcv.wf_node ADD CONSTRAINT node_pk PRIMARY KEY ( nodecode );

CREATE TABLE dcv.wf_node_option (
    id            INTEGER NOT NULL,
    node_id       VARCHAR2(10 CHAR) NOT NULL,
    pilihan       INTEGER NOT NULL,
    description   VARCHAR2(15 CHAR),
    refnode       VARCHAR2(10 CHAR) NOT NULL,
    pangkat       VARCHAR2(15 CHAR)
);

COMMENT ON COLUMN dcv.wf_node_option.pilihan IS
    '1. Approve1
2. Approve2
3. Return/Back
4. Terminate/Cancel';

COMMENT ON COLUMN dcv.wf_node_option.pangkat IS
    'rank tertentu yg bisa lakukan action ini';

ALTER TABLE dcv.wf_node_option ADD CONSTRAINT node_option_pk PRIMARY KEY ( id );

CREATE TABLE dcv.wf_task (
    id                INTEGER NOT NULL,
    dcv_code          VARCHAR2(20 CHAR) NOT NULL,
    task_type         VARCHAR2(10 CHAR),
    assign_time       DATE,
    assign_to_bu      INTEGER NOT NULL,
    sp_assign1        VARCHAR2(50 CHAR),
    progress_status   VARCHAR2(10 CHAR),
    nodecode          VARCHAR2(10 CHAR) NOT NULL,
    prev_task         INTEGER,
    prev_node         VARCHAR2(10 CHAR),
    decision          INTEGER,
    execscript        VARCHAR2(100 CHAR),
    pesan             VARCHAR2(250 CHAR),
    process_by        INTEGER,
    process_time      DATE
);

COMMENT ON COLUMN dcv.wf_task.task_type IS
    'humantask, merge, auto sched';

COMMENT ON COLUMN dcv.wf_task.assign_to_bu IS
    'assign ke bisnis unit (role) mana';

COMMENT ON COLUMN dcv.wf_task.sp_assign1 IS
    'unt user dg special assignment khusus mis. Food / non food ';

COMMENT ON COLUMN dcv.wf_task.progress_status IS
    'DONE, WORKING';

ALTER TABLE dcv.wf_task ADD CONSTRAINT task_pk PRIMARY KEY ( id );

CREATE TABLE dcv.wf_task_merge (
    id           INTEGER NOT NULL,
    task         INTEGER NOT NULL,
    prev_task    INTEGER,
    completed    VARCHAR2(3 CHAR),
    process_dt   DATE
);

ALTER TABLE dcv.wf_task_merge ADD CONSTRAINT task_multiple_pk PRIMARY KEY ( id );

ALTER TABLE dcv.doc_movement
    ADD CONSTRAINT doc_movement_dcv_files_fk FOREIGN KEY ( dcv_id )
        REFERENCES dcv.dcv_documents ( id );

ALTER TABLE dcv.dcv_documents
    ADD CONSTRAINT file_pendukung_request_hdr_fk FOREIGN KEY ( dcv_id )
        REFERENCES dcv.dcv_request ( dcv_hdr_id );

ALTER TABLE dcv.wf_node
    ADD CONSTRAINT node_role_fk FOREIGN KEY ( business_unit )
        REFERENCES dcv.sec_bussunit ( id );

ALTER TABLE dcv.pcline_tc_appr
    ADD CONSTRAINT req_line_breakdown_fk FOREIGN KEY ( request_dtl_id )
        REFERENCES dcv.request_dtl ( id );

ALTER TABLE dcv.request_dtl
    ADD CONSTRAINT request_dtl_request_hdr_fk FOREIGN KEY ( dcv_hdr_id )
        REFERENCES dcv.dcv_request ( dcv_hdr_id );

ALTER TABLE dcv.sec_user
    ADD CONSTRAINT sec_user_report_to_fk FOREIGN KEY ( report_to )
        REFERENCES dcv.sec_user ( id );

ALTER TABLE dcv.wf_task_merge
    ADD CONSTRAINT task_multiple_task_fk FOREIGN KEY ( task )
        REFERENCES dcv.wf_task ( id );

ALTER TABLE dcv.wf_task
    ADD CONSTRAINT task_user_fk FOREIGN KEY ( process_by )
        REFERENCES dcv.sec_user ( id );

ALTER TABLE dcv.sec_user
    ADD CONSTRAINT user_role_fk FOREIGN KEY ( bus_unit )
        REFERENCES dcv.sec_bussunit ( id )
            ON DELETE CASCADE;

ALTER TABLE dcv.wf_node_option
    ADD CONSTRAINT wf_node_option_wf_node_fk FOREIGN KEY ( node_id )
        REFERENCES dcv.wf_node ( nodecode );

ALTER TABLE dcv.wf_node_option
    ADD CONSTRAINT wf_node_option_wf_node_fkv1 FOREIGN KEY ( refnode )
        REFERENCES dcv.wf_node ( nodecode );

ALTER TABLE dcv.wf_task
    ADD CONSTRAINT wf_task_sec_bussunit_fk FOREIGN KEY ( assign_to_bu )
        REFERENCES dcv.sec_bussunit ( id );

ALTER TABLE dcv.wf_task
    ADD CONSTRAINT wf_task_wf_node_fk FOREIGN KEY ( nodecode )
        REFERENCES dcv.wf_node ( nodecode );



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                            14
-- CREATE INDEX                             2
-- ALTER TABLE                             27
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- TSDP POLICY                              0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
