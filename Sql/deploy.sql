# as user sysdate

connect sys/.... as sysdba
@crtablespace.sql
@cruser.sql

connect focusdcv/focusdcv
@crseq.sql
@crtab.sql
@crwftab.sql
@crview.sql
--@crpackage.sql
@pkg_wf.sql
@pkg_dcv.sql
@pkg_integrasi.sql
@crsynonym.sql
