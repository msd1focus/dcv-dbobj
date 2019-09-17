# As user SYS

create tablespace FCS_DCV_FDI_TS
  logging
  datafile '/data03/UATFDI/data/fcs_dcv_fdi.dbf'
  size 100M reuse
  autoextend on
  extent management local;

create TEMPORARY tablespace FCS_DCV_FDI_TEMP
  tempfile '/data03/UATFDI/data/fcs_dcv_fdi_temp.dbf'
  size 30M reuse
  autoextend on
  extent management local;
