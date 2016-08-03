-- UPDATE SCRIPT FOR XXFE_RESP_APPROVER_LIST
insert into xxfe_resp_approver_list(application_id,responsibility_id,approver1,approver2) 
( select b.APPLICATION_ID
,responsibility_id
,(select USER_ID from fnd_user where upper(email_address)=UPPER(bo_email1)) isd1
,(select USER_ID from fnd_user where UPPER(email_address)=UPPER(bo_email2)) id2
from xxfe_test a, fnd_responsibility_vl b 
where a.responsibility_name = b.responsibility_name );
