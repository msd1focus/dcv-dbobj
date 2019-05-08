drop user focusdcv;

create user focusdcv identified by focusdcv
default tablespace fcs_dcv_fdi_ts
temporary tablespace FCS_DCV_FDI_TEMP
quota unlimited on FCS_DCV_FDI_TS;

grant connect, resource to focusdcv;
grant create view to focusdcv;
