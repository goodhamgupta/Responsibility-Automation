set termout on
--set define on

--prompt 'Connecting to APPS schema..Please Enter Password'
--CONNECT APPS/&&passwd1

prompt 'Dropping table XXFE.XXFE_RESP_APPROVER_LIST'
drop table "XXFE"."XXFE_RESP_APPROVER_LIST"
/

prompt 'Creating table XXFE.XXFE_RESP_APPROVER_LIST'
CREATE TABLE "XXFE"."XXFE_RESP_APPROVER_LIST"
  (
    application_id    	NUMBER,
    responsibility_id  	NUMBER,
    approver1     		NUMBER,
	approver2     		NUMBER,
	approver3     		NUMBER,
    attribute1       	VARCHAR2(250),
    attribute2       	VARCHAR2(250),
    attribute3       	VARCHAR2(250),
    attribute4       	VARCHAR2(250),
    attribute5       	VARCHAR2(250),
    attribute6       	VARCHAR2(250),
    attribute7       	VARCHAR2(250),
    attribute8       	VARCHAR2(250),
    attribute9       	VARCHAR2(250),
    attribute10      	VARCHAR2(250),
    creation_date    	DATE,
    created_by       	NUMBER,
    last_update_date 	DATE,
    updated_by       	NUMBER,
    approval_type 	VARCHAR2(100) DEFAULT 'ALL'
  )
/

PROMPT 'Recreating Synonym XXFE_RESP_APPROVER_LIST'
DROP PUBLIC SYNONYM XXFE_RESP_APPROVER_LIST
/

CREATE PUBLIC SYNONYM XXFE_RESP_APPROVER_LIST
FOR XXFE.XXFE_RESP_APPROVER_LIST
/

--undefine passwd1