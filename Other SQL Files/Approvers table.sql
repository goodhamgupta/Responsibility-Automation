set termout on
--set define on

--prompt 'Connecting to APPS schema..Please Enter Password'
--CONNECT APPS/&&passwd1

prompt 'Dropping table XXFE.XXFE_RESP_APPROVERS'
drop table "XXFE"."XXFE_RESP_APPROVERS"
/

prompt 'Creating table XXFE.XXFE_RESP_APPROVERS'
CREATE TABLE "XXFE"."XXFE_RESP_APPROVERS"
  (
	APPLICATION_ID 		NOT NULL 	NUMBER, 
	APPLICATION_NAME 	NOT NULL 	VARCHAR2(300),
	responsibility_id 	NOT NULL 	NUMBER,
	responsibility_name NOT NULL 	VARCHAR2(100),
	USER_ID      		NOT NULL 	NUMBER(15),
	BUSINESS_APPROVER   NOT NULL 	VARCHAR2(100),
	IT_APPROVER 		NOT NULL 	VARCHAR2(100),
	attribute1 						VARCHAR2(100),
	attribute2 						VARCHAR2(100),
	attribute3 						VARCHAR2(100),
	attribute4 						VARCHAR2(100),
	attribute5 						VARCHAR2(100),
  
	--WHO COLUMNS
  
	last_update_date    			DATE,
	last_updated_by     			NUMBER,
	creation_date       			DATE,
	created_by          			NUMBER   
);
/

PROMPT 'Recreating Synonym XXFE_RESP_APPROVERS'
DROP PUBLIC SYNONYM XXFE_RESP_APPROVERS
/

CREATE PUBLIC SYNONYM XXFE_RESP_APPROVERS
FOR XXFE.XXFE_RESP_APPROVERS
/

--undefine passwd1