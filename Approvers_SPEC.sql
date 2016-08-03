CREATE OR REPLACE PACKAGE XXFE_APPROVERS_LIST AS
	G_TEMP_UID NUMBER;
	PROCEDURE XX_ASSIGN_USERID(L_USER_ID IN NUMBER);
	FUNCTION XXFE_GET_APPROVER_NAME (P_RESPID IN NUMBER) RETURN VARCHAR2;
	PROCEDURE XX_REQUEST (L_USER_ID IN NUMBER,L_RESPONSIBILITY_ID IN NUMBER ,L_NOTIFICATION_ID IN NUMBER,L_START_DATE IN OUT DATE,L_END_DATE IN OUT DATE,L_NOTE IN VARCHAR2);
	PROCEDURE XX_REVOKE (L_USER_ID IN NUMBER,L_RESPONSIBILITY_ID IN NUMBER ,L_NOTIFICATION_ID IN NUMBER );
	PROCEDURE XX_APPROVER_SUBMIT(L_APPLNAME VARCHAR2,L_RESPNAME VARCHAR2,L_APPNAME_1 IN VARCHAR2,L_APPNAME_2 IN VARCHAR2,L_APPNAME_3 IN VARCHAR2);
	PROCEDURE XX_CANCEL (L_USER_ID IN NUMBER,L_RESPONSIBILITY_ID IN NUMBER ,L_NOTIFICATION_ID IN NUMBER );
	PROCEDURE XX_WORKFLOW_START(L_USER_ID IN NUMBER,L_R_ID IN NUMBER ,L_A_ID IN NUMBER,L_RESNAME IN VARCHAR2,L_APPNAME IN VARCHAR2,L_START_DATE IN DATE,L_END_DATE IN DATE,L_NOTE IN VARCHAR2) ;
	PROCEDURE XX_MANAGER_APPROVAL(itemtype IN VARCHAR2,itemkey  IN VARCHAR2,actid IN NUMBER,funcmode IN VARCHAR2,RESULT IN OUT VARCHAR2);
	PROCEDURE XX_APPROVER_ALL(itemtype IN VARCHAR2,itemkey  IN VARCHAR2,actid IN NUMBER,funcmode IN VARCHAR2,RESULT IN OUT VARCHAR2) ;
	PROCEDURE XX_ASSIGN_RESP (itemtype IN VARCHAR2,itemkey  IN VARCHAR2,actid IN NUMBER,funcmode IN VARCHAR2,RESULT IN OUT VARCHAR2); 
	FUNCTION XX_SL_RNAME(L_RESPNAME IN VARCHAR2) RETURN NUMBER;
	FUNCTION XX_SL_ANAME(L_ANAME IN VARCHAR2) RETURN NUMBER;	 -- ANAME IS FOR APPLICATION NAME
	FUNCTION XX_SL_APPNAME(L_APPEMAIL IN VARCHAR2) RETURN NUMBER; -- APPNAME IS FOR APPROVERS NAME
END XXFE_APPROVERS_LIST;

--CREATING SEQUENCE FOR THE IDENTIFICATION OF CANCELLED REQUESTS

CREATE SEQUENCE XXFE.XX_APPROVERS_LIST_SEQ
  MINVALUE 0
  START WITH 1
  INCREMENT BY 1
  CACHE 10;	
  
  --SAMPLE ALTER TABLE COMMAND FOR REFERENCE
  --	ALTER TABLE XXFE.XXFE_USER_RESP_PROVISION 
  --		ADD (SEQ_NO NUMBER);
  -- WFLOAD apps/apps@STAGE 0 Y UPLOAD /home/applmgr/Shubham/XXFE_RESP.wft
  
--**************************************************
ALTER TABLE XXFE.XXFE_RESP_APPROVER_LIST
  ADD (MODULE_OWNER1 NUMBER,MODULE_OWNER2 NUMBER,MODULE_OWNER3 NUMBER,MODULE_OWNER4 NUMBER);
ALTER TABLE XXFE.XXFE_RESP_APPROVER_LIST
  ADD (PROCESS_OWNER1 NUMBER,PROCESS_OWNER2 NUMBER,PROCESS_OWNER3 NUMBER,PROCESS_OWNER4 NUMBER);
--****************************************************
--*******************************************************
--CREATING ROLES FOR MODULE AND PROCESS OWNER
--*******************************************************
--FOR MODULE OWNERS
L_ROLE_NAME := 'MOWNER';
WF_DIRECTORY.CreateAdHocRole (	role_name => L_ROLE_NAME,
										role_display_name => L_ROLE_NAME ,
										language => 'AMERICAN'     ,
										territory => 'AMERICA' ,
										email_address => null,
										notification_preference => 'MAILHTML'
									);	
									
-- FOR PROCESS OWNERS
L_ROLE_NAME := 'POWNER';
WF_DIRECTORY.CreateAdHocRole (	role_name => L_ROLE_NAME,
										role_display_name => L_ROLE_NAME ,
										language => 'AMERICAN'     ,
										territory => 'AMERICA' ,
										email_address => null,
										notification_preference => 'MAILHTML'
									);	
--*******************************************************
--END OF ROLES FOR MODULE AND PROCESS OWNER
--*******************************************************