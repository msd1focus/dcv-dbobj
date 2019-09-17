drop sequence dcv_seq;
create sequence dcv_seq;
alter sequence dcv_seq increment by 1000;
select dcv_seq.nextval from dual;
alter sequence dcv_seq increment by 1;
