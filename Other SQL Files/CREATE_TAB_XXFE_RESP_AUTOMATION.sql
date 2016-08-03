set termout on
--set define on

--prompt 'Connecting to APPS schema..Please Enter Password'
--CONNECT APPS/&&passwd1

prompt 'Dropping table XXFE.XXFE_USER_RESP_PROVISION'
drop table "XXFE"."XXFE_USER_RESP_PROVISION"
/

prompt 'Creating table XXFE.XXFE_USER_RESP_PROVISION'
CREATE TABLE "XXFE"."XXFE_USER_RESP_PROVISION"
  (
    user_id    				NUMBER,
	responsibility_id		NUMBER,
	notification_id			NUMBER,
	status					VARCHAR2(250),
	approver1       		NUMBER,
	approver2       		NUMBER
	approver3       		NUMBER,
	attribute1       		VARCHAR2(250),
    attribute2       		VARCHAR2(250),
    attribute3       		VARCHAR2(250),
    attribute4       		VARCHAR2(250),
    attribute5       		VARCHAR2(250),
	attribute6       		VARCHAR2(250),
    attribute7       		VARCHAR2(250),
    attribute8       		VARCHAR2(250),
    attribute9       		VARCHAR2(250),
    attribute10       		VARCHAR2(250),
    creation_date    		DATE,
    created_by       		NUMBER,
    last_update_date 		DATE,
    updated_by       		NUMBER
	-- NEW COLUMNS INCLUDED AFTER DISCUSSION
	start_date		DATE,
	end_date		DATE,
	notes			VARCHAR2(100),
	SEQ_NO 			NUMBER
  )
/

PROMPT 'Recreating Synonym XXFE_RESP_AUTOMATION'
DROP PUBLIC SYNONYM XXFE_RESP_AUTOMATION
/

CREATE PUBLIC SYNONYM XXFE_RESP_AUTOMATION
FOR XXFE.XXFE_RESP_AUTOMATION
/

--undefine passwd1