# as user sysdate

connect sys/.... as sysdba
@crtablespace.sql
@cruser.sql

connect focusdcv/focusdcv
@crseq.sql
@crtab.sql
@crview.sql
@crpackage.sql
@crsynonym.sql
