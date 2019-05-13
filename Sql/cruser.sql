# as user SYS

drop user focusdcv;

create user focusdcv identified by focusdcv
default tablespace fcs_dcv_fdi_ts
temporary tablespace FCS_DCV_FDI_TEMP
quota unlimited on FCS_DCV_FDI_TS;

alter user focusdcv enable editions;

grant connect, resource to focusdcv;
grant create view to focusdcv;
grant create synonym to focusdcv;

grant select on focuspp.proposal to focusdcv;
grant select on apps.fcs_view_item_uom to focusdcv;
grant select on apps.fcs_view_uom_conversion to focusdcv;
grant select on apps.ar_customers to focusdcv;
grant select on apps.fcs_flex_values_vl to focusdcv;
grant select on apps.fcs_flex_values_vl to focusdcv;
grant select on apps.fcs_flex_values_vl to focusdcv;
grant select on apps.fcs_flex_values_vl to focusdcv;
grant select on apps.fcs_flex_values_vl to focusdcv;
