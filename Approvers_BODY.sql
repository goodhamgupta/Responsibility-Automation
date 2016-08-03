  SELECT * FROM wf_user_roles WHERE role_name = 'TESTROLE';
   select * from WF_ITEM_ATTRIBUTE_VALUES WHERE item_type = 'XXFE_RES' order by item_key desc;

CREATE OR REPLACE PACKAGE BODY XXFE_APPROVERS_LIST AS
	PROCEDURE XX_ASSIGN_USERID(L_USER_ID IN NUMBER) 
	AS
	BEGIN
		G_TEMP_UID := L_USER_ID;
	END;
	
	FUNCTION XXFE_GET_APPROVER_NAME (P_RESPID IN NUMBER) RETURN VARCHAR2 
	AS
		I number;
		L_USER_ID NUMBER;
		L_MANAGER_ID NUMBER;
		L_MO_ID1 NUMBER;
		L_MO_ID2 NUMBER;
		L_MO_ID3 NUMBER;
		L_MO_ID4 NUMBER;
		L_PO_ID1 NUMBER;
		L_PO_ID2 NUMBER;
		L_PO_ID3 NUMBER;
		L_PO_ID4 NUMBER;
		L_MUNAME VARCHAR2(100);
		L_MO_NAME1 VARCHAR2(100);
		L_MO_NAME2 VARCHAR2(100);
		L_MO_NAME3 VARCHAR2(100);
		L_MO_NAME4 VARCHAR2(100);
		L_PO_NAME1 VARCHAR2(100);
		L_PO_NAME2 VARCHAR2(100);
		L_PO_NAME3 VARCHAR2(100);
		L_PO_NAME4 VARCHAR2(100);
		L_FINAL_STRING VARCHAR2(1000);
		L_TEMP_UNAME VARCHAR2(250);
		NO_USER NUMBER;
		--EXCEPTIONS
		NO_APPROVERS_EXCEPTION EXCEPTION;
	BEGIN
		SELECT EMPLOYEE_ID INTO L_USER_ID 
		FROM FND_USER 
		WHERE USER_ID = G_TEMP_UID;
		--Code to get manager name
		SELECT supervisor_id INTO L_MANAGER_ID 
		FROM PER_ALL_ASSIGNMENTS_F 
		WHERE person_id = L_USER_ID 
		AND supervisor_id IS NOT NULL 
		AND OBJECT_VERSION_NUMBER = (SELECT MAX(OBJECT_VERSION_NUMBER) FROM PER_ALL_ASSIGNMENTS_F WHERE person_id = L_USER_ID);
		
		SELECT DESCRIPTION INTO L_MUNAME FROM FND_USER WHERE EMPLOYEE_ID = L_MANAGER_ID;
		-- End of manager name code
		--MODULE OWNERS;
		SELECT MAX(MODULE_OWNER1),MAX(MODULE_OWNER2),MAX(MODULE_OWNER3),MAX(MODULE_OWNER4) 
		INTO L_MO_ID1,L_MO_ID2,L_MO_ID3,L_MO_ID4 
		FROM XXFE_RESP_APPROVER_LIST WHERE RESPONSIBILITY_ID = P_RESPID;
		--PROCESS OWNERS
		SELECT MAX(PROCESS_OWNER1),MAX(PROCESS_OWNER2),MAX(PROCESS_OWNER3),MAX(PROCESS_OWNER4) 
		INTO L_PO_ID1,L_PO_ID2,L_PO_ID3,L_PO_ID4 
		FROM XXFE_RESP_APPROVER_LIST WHERE RESPONSIBILITY_ID = P_RESPID;
		-- MODULE OWNER NAMES
		IF L_MO_ID1 IS NOT NULL THEN
			SELECT DESCRIPTION INTO L_MO_NAME1 FROM fnd_user WHERE USER_ID = L_MO_ID1;
		END IF;
		IF L_MO_ID2 IS NOT NULL THEN
			SELECT DESCRIPTION INTO L_MO_NAME2 FROM fnd_user WHERE USER_ID = L_MO_ID2;
		END IF;
		IF L_MO_ID3 IS NOT NULL THEN
			SELECT DESCRIPTION INTO L_MO_NAME3 FROM fnd_user WHERE USER_ID = L_MO_ID3;
		END IF;
		IF L_MO_ID4 IS NOT NULL THEN
			SELECT DESCRIPTION INTO L_MO_NAME4 FROM fnd_user WHERE USER_ID = L_MO_ID4;
		END IF;
		--PROCESS OWNER NAMES
		IF L_PO_ID1 IS NOT NULL THEN
			SELECT DESCRIPTION INTO L_PO_NAME1 FROM fnd_user WHERE USER_ID = L_PO_ID1;
		END IF;
		IF L_PO_ID2 IS NOT NULL THEN
			SELECT DESCRIPTION INTO L_PO_NAME2 FROM fnd_user WHERE USER_ID = L_PO_ID2;
		END IF;
		IF L_PO_ID3 IS NOT NULL THEN
			SELECT DESCRIPTION INTO L_PO_NAME3 FROM fnd_user WHERE USER_ID = L_PO_ID3;
		END IF;
		IF L_PO_ID4 IS NOT NULL THEN
			SELECT DESCRIPTION INTO L_PO_NAME4 FROM fnd_user WHERE USER_ID = L_PO_ID4;
		END IF;
		SELECT L_MUNAME||(DECODE(L_MO_NAME1,NULL,NULL,'-->'||L_MO_NAME1)||DECODE(L_MO_NAME2,NULL,NULL,'-->'||L_MO_NAME2)||DECODE(L_MO_NAME3,NULL,NULL,'-->'||L_MO_NAME3)
		||DECODE(L_MO_NAME4,NULL,NULL,'-->'||L_MO_NAME4)||DECODE(L_PO_NAME1,NULL,NULL,'-->'||L_PO_NAME1)||DECODE(L_PO_NAME2,NULL,NULL,'-->'||L_PO_NAME2)
		||DECODE(L_PO_NAME3,NULL,NULL,'-->'||L_PO_NAME3)||DECODE(L_PO_NAME4,NULL,NULL,'-->'||L_PO_NAME4)) 
		INTO L_FINAL_STRING
		FROM DUAL;
		RETURN L_FINAL_STRING;
		EXCEPTION
			WHEN NO_APPROVERS_EXCEPTION THEN
				RETURN L_FINAL_STRING;
			WHEN OTHERS THEN
				RETURN L_FINAL_STRING;			
		
	END;
	
	--SEQUENCE NUMBER INCLUDED FOR INSERTION. WILL BE USED TO DETECT CANCELLED REQUESTS(NEEDS TO BE DISCUSSED IN DETAIL!)
	PROCEDURE XX_REQUEST(L_USER_ID IN NUMBER,L_RESPONSIBILITY_ID IN NUMBER ,L_NOTIFICATION_ID IN NUMBER,L_START_DATE IN OUT DATE,L_END_DATE IN OUT DATE,L_NOTE IN VARCHAR2) 
	AS
	L_UNAME VARCHAR2(100);
	L_TEMP_VAR NUMBER;
	L_NOTIFID NUMBER;
	L_MANAGER_ID NUMBER;
	L_APP_ID NUMBER;
	L_UID NUMBER;
	BEGIN
		IF L_START_DATE IS NULL THEN	
			L_START_DATE := SYSDATE;
		END IF;
		IF L_END_DATE IS NULL THEN
			L_END_DATE := SYSDATE + 7;
		END IF;
		
		/*--*************CODE FOR NOTIF ID*****************
		SELECT employee_id INTO L_UID FROM FND_USER WHERE USER_ID = L_USER_ID;
		--Used to get manager employee id
		SELECT supervisor_id INTO L_MANAGER_ID FROM PER_ALL_ASSIGNMENTS_F 
		WHERE person_id = L_UID AND OBJECT_VERSION_NUMBER = (SELECT MAX(OBJECT_VERSION_NUMBER) FROM PER_ALL_ASSIGNMENTS_F WHERE person_id = L_UID);
		--Used to get manager user name
		SELECT user_name INTO L_UNAME FROM fnd_user WHERE employee_id = L_MANAGER_ID;
		--Used to get notifcation_id using the manager user name as recipient
		SELECT NOTIFICATION_ID INTO L_NOTIFID 
		FROM wf_notifications 
		WHERE recipient_role = L_UNAME AND BEGIN_DATE = (SELECT MAX(BEGIN_DATE) FROM wf_notifications WHERE recipient_role = L_UNAME);
		--********END OF CODE FOR NOTIF ID*****************/
		INSERT INTO XXFE_USER_RESP_PROVISION(USER_ID,RESPONSIBILITY_ID,NOTIFICATION_ID,START_DATE,END_DATE,SEQ_NO,NOTES) 
		VALUES (L_USER_ID,L_RESPONSIBILITY_ID,L_NOTIFICATION_ID,L_START_DATE,L_END_DATE,XXFE.XX_APPROVERS_LIST_SEQ.NEXTVAL,L_NOTE);	
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
	END;
	
	PROCEDURE XX_REVOKE(L_USER_ID IN NUMBER,L_RESPONSIBILITY_ID IN NUMBER ,L_NOTIFICATION_ID IN NUMBER ) AS
	BEGIN
		UPDATE XXFE_USER_RESP_PROVISION 
		SET STATUS='REVOKED' WHERE USER_ID = L_USER_ID AND RESPONSIBILITY_ID=L_RESPONSIBILITY_ID AND NOTIFICATION_ID=L_NOTIFICATION_ID;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN	
			ROLLBACK;
	END;
	
	--THIS PROCEDURE WILL BE CALLED IN THE APPROVERS OAF PAGE
	PROCEDURE XX_APPROVER_SUBMIT(L_APPLNAME VARCHAR2,L_RESPNAME VARCHAR2,L_APPNAME_1 IN VARCHAR2,L_APPNAME_2 IN VARCHAR2,L_APPNAME_3 IN VARCHAR2) AS
	L_APPLID INTEGER;
	L_RESPID INTEGER;
    L_APP_ID1 INTEGER;
    L_APP_ID2 INTEGER;
    L_APP_ID3 INTEGER;
	BEGIN
		SELECT APPLICATION_ID INTO L_APPLID FROM FND_APPLICATION_TL FAT WHERE FAT.APPLICATION_NAME = L_APPLNAME;
		SELECT RESPONSIBILITY_ID INTO L_RESPID FROM FND_RESPONSIBILITY_TL FRT WHERE FRT.RESPONSIBILITY_NAME = L_RESPNAME;
		SELECT USER_ID INTO L_APP_ID1 FROM FND_USER FU WHERE FU.USER_NAME = L_APPNAME_1;
		SELECT USER_ID INTO L_APP_ID1 FROM FND_USER FU WHERE FU.USER_NAME = L_APPNAME_1;
		SELECT USER_ID INTO L_APP_ID2 FROM FND_USER FU WHERE FU.USER_NAME = L_APPNAME_2;
		SELECT USER_ID INTO L_APP_ID3 FROM FND_USER FU WHERE FU.USER_NAME = L_APPNAME_3;
		--UPDATE XXFE_RESP_APPROVER_LIST  SET APPROVER1=L_APP_ID1,APPROVER2=L_APP_ID2,APPROVER3=L_APP_ID3 WHERE APPLICATION_ID=L_APPLID AND RESPONSIBILITY_ID = L_RESPID;
		COMMIT;
		EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
	END;
	
	PROCEDURE XX_CANCEL(L_USER_ID IN NUMBER,L_RESPONSIBILITY_ID IN NUMBER ,L_NOTIFICATION_ID IN NUMBER ) AS
	BEGIN
		DELETE FROM XXFE_USER_RESP_PROVISION WHERE USER_ID = L_USER_ID AND RESPONSIBILITY_ID=L_RESPONSIBILITY_ID AND NOTIFICATION_ID=L_NOTIFICATION_ID;
		COMMIT;
	EXCEPTION
	WHEN OTHERS THEN	
		ROLLBACK;
	END;
	
	--*******************|
	--INITIATING WORKFLOW|
	--*******************|
	PROCEDURE XX_WORKFLOW_START(L_USER_ID IN NUMBER,L_R_ID IN NUMBER ,L_A_ID IN NUMBER,L_RESNAME IN VARCHAR2,L_APPNAME IN VARCHAR2,L_START_DATE IN DATE,L_END_DATE IN DATE,L_NOTE IN VARCHAR2) 
	AS
	L_U_ID NUMBER;
	BEGIN
		G_TEMP_UID := L_USER_ID;
		SELECT EMPLOYEE_ID INTO L_U_ID FROM FND_USER WHERE user_id = L_USER_ID;
		APPS.WF_ENGINE.CREATEPROCESS(itemtype => 'XXFE_RES',		--Internal name of the workflow
									itemkey => XXFE.XX_TEST_WORKFLOW.NEXTVAL ,	-- Item number. Should be unique
									process => 'XXFE_RESP_PROCESS'		-- Internal Name of process.
									);
		APPS.WF_ENGINE.STARTPROCESS(itemtype => 'XXFE_RES',
									itemkey => XXFE.XX_TEST_WORKFLOW.CURRVAL	-- CURVAL to SELECT the current value from the sequence                      
                                    );
		--*******************************************************
		--Setting all the attributes required during the workflow
		--*******************************************************
		wf_engine.setitemattrnumber(itemtype => 'XXFE_RES'
								,itemkey  => XXFE.XX_TEST_WORKFLOW.CURRVAL
								,aname    => 'XXFE_USERID_ATTR'
								,avalue   => L_U_ID);
        wf_engine.setitemattrnumber(itemtype => 'XXFE_RES'
								,itemkey  => XXFE.XX_TEST_WORKFLOW.CURRVAL
								,aname    => 'XXFE_RESPID_ATTR'
								,avalue   => L_R_ID);
        wf_engine.setitemattrnumber(itemtype => 'XXFE_RES'
								,itemkey  => XXFE.XX_TEST_WORKFLOW.CURRVAL
								,aname    => 'XXFE_APPID_ATTR'
								,avalue   => L_A_ID);
		wf_engine.setitemattrdate(itemtype => 'XXFE_RES'
								,itemkey  => XXFE.XX_TEST_WORKFLOW.CURRVAL
								,aname    => 'XXFE_SDATE_ATTR'
								,avalue   => L_START_DATE);
        wf_engine.setitemattrdate(itemtype => 'XXFE_RES'
								,itemkey  => XXFE.XX_TEST_WORKFLOW.CURRVAL
								,aname    => 'XXFE_EDATE_ATTR'
								,avalue   => L_END_DATE);
		wf_engine.setitemattrtext(itemtype => 'XXFE_RES'
								,itemkey  => XXFE.XX_TEST_WORKFLOW.CURRVAL
								,aname    => 'XXFE_NOTES_ATTR'
								,avalue   => L_NOTE);
		wf_engine.setitemattrtext(itemtype => 'XXFE_RES'
								,itemkey  => XXFE.XX_TEST_WORKFLOW.CURRVAL
								,aname    => 'XXFE_RESNAME_ATTR'
								,avalue   => L_RESNAME);
		wf_engine.setitemattrtext(itemtype => 'XXFE_RES'
								,itemkey  => XXFE.XX_TEST_WORKFLOW.CURRVAL
								,aname    => 'XXFE_APPNAME_ATTR'
								,avalue   => L_APPNAME);
        COMMIT;
	END;
	
	--TEST PROCEDURE FOR ASSIGNING MANAGER ATTRIBUTE
	PROCEDURE XX_MANAGER_APPROVAL(itemtype IN VARCHAR2,itemkey  IN VARCHAR2,actid IN NUMBER,funcmode IN VARCHAR2,RESULT IN OUT VARCHAR2) 
	AS
	G_USER_ID NUMBER;
	v_role_email varchar2(50);
	L_PERSON_ID NUMBER;
	L_MANAGER_ID NUMBER;
	L_EMAIL VARCHAR(100);
	V_USER_UNAME VARCHAR2(50);
	V_MANAGER_UNAME VARCHAR2(50);
	BEGIN
		--CODE TO START THE WORKFLOW FIRST
		--CODE TO GET THE MANAGER ID
		SELECT EMPLOYEE_ID INTO G_USER_ID FROM FND_USER WHERE USER_ID = G_TEMP_UID;
		SELECT supervisor_id INTO L_MANAGER_ID FROM PER_ALL_ASSIGNMENTS_F 
		WHERE person_id = G_USER_ID AND OBJECT_VERSION_NUMBER = (SELECT MAX(OBJECT_VERSION_NUMBER) FROM PER_ALL_ASSIGNMENTS_F WHERE person_id = G_USER_ID);
		SELECT user_name INTO V_MANAGER_UNAME from FND_USER WHERE EMPLOYEE_ID = L_MANAGER_ID;
		SELECT user_name INTO V_USER_UNAME FROM FND_USER WHERE EMPLOYEE_ID = G_USER_ID;
		wf_engine.setitemattrtext(itemtype => itemtype
								,itemkey  => itemkey
								,aname    => 'XXFE_MANAGER_ATTRIBUTE'
								,avalue   => V_MANAGER_UNAME);
		wf_engine.setitemattrtext(itemtype => itemtype
								,itemkey  => itemkey
								,aname    => 'XXFE_USER_ATTRIBUTE'
								,avalue   => V_USER_UNAME);
		RESULT := 'COMPLETE:Y';
	END;
	
	PROCEDURE XX_APPROVER_ALL(itemtype IN VARCHAR2,itemkey  IN VARCHAR2,actid IN NUMBER,funcmode IN VARCHAR2,RESULT IN OUT VARCHAR2) 
	AS
	L_APP1 VARCHAR2(100);
	L_APP2 VARCHAR2(100);
	L_APP3 VARCHAR2(100);
	L_APP4 VARCHAR2(100);
	L_APPID1 NUMBER;
	L_APPID2 NUMBER;
	L_APPID3 NUMBER;
	L_APPID4 NUMBER;
	L_POID1 NUMBER ;
	L_POID2 NUMBER ;
	L_POID3 NUMBER ;
	L_POID4 NUMBER ;
	L_PONAME1 VARCHAR2(100);
	L_PONAME2 VARCHAR2(100);
	L_PONAME3 VARCHAR2(100);
	L_PONAME4 VARCHAR2(100);
	L_RESP_ID NUMBER;
	L_APPLICATION_ID NUMBER;
	L_APPROVER_ID NUMBER;
	L_MOWNER_STRING VARCHAR2(1000);
	L_POWNER_STRING VARCHAR2(1000);
	L_ROLE_NAME VARCHAR2(100);
	BEGIN
		L_ROLE_NAME := 'TESTROLE1';
		L_RESP_ID :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                        itemkey  => itemkey,
														aname    => 'XXFE_RESPID_ATTR');
		L_APPLICATION_ID :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                        itemkey  => itemkey,
														aname    => 'XXFE_APPID_ATTR');
		
		SELECT MAX(MODULE_OWNER1),MAX(MODULE_OWNER2),MAX(MODULE_OWNER3),MAX(MODULE_OWNER4),MAX(PROCESS_OWNER1),MAX(PROCESS_OWNER2),MAX(PROCESS_OWNER3),MAX(PROCESS_OWNER4)
		INTO L_APPID1,L_APPID2,L_APPID3,L_APPID4,L_POID1,L_POID2,L_POID3,L_POID4
		FROM XXFE_RESP_APPROVER_LIST
		WHERE responsibility_id = L_RESP_ID AND application_id = L_APPLICATION_ID;
		SELECT max(user_name) INTO L_APP1 FROM fnd_user WHERE user_id = L_APPID1;
		SELECT max(user_name) INTO L_APP2 FROM fnd_user WHERE user_id = L_APPID2;
		SELECT max(user_name) INTO L_APP3 FROM fnd_user WHERE user_id = L_APPID3;
		SELECT max(user_name) INTO L_APP4 FROM fnd_user WHERE user_id = L_APPID4;
		SELECT max(user_name) INTO L_PONAME1 FROM fnd_user WHERE user_id = L_POID1;
		SELECT max(user_name) INTO L_PONAME2 FROM fnd_user WHERE user_id = L_POID2 ;
		SELECT max(user_name) INTO L_PONAME3 FROM fnd_user WHERE user_id = L_POID3;
		SELECT max(user_name) INTO L_PONAME4 FROM fnd_user WHERE user_id = L_POID4;
		--CREATING FINAL STRING WITH MODULE OWNER NAMES
		SELECT L_PONAME1||(DECODE(L_APP2,NULL,NULL,' '||L_APP2)||DECODE(L_APP3,NULL,NULL,' '||L_APP3)||DECODE(L_APP4,NULL,NULL,' '||L_APP4))
		INTO L_MOWNER_STRING
		FROM DUAL;
		--CREATING FINAL STRING WITH PROCESS OWNER NAMES
		SELECT L_APP1||(DECODE(L_PONAME2,NULL,NULL,' '||L_PONAME2)||DECODE(L_PONAME3,NULL,NULL,' '||L_PONAME3)||DECODE(L_PONAME4,NULL,NULL,' '||L_PONAME4))
		INTO L_POWNER_STRING
		FROM DUAL;
		--DELETING PREVIOUS USERS ASSIGNED TO MODULE OWNER ROLE
		L_ROLE_NAME := 'MOWNER';
		WF_DIRECTORY.RemoveUsersFromAdHocRole(L_ROLE_NAME);
		--ADDING NEW USERS
		WF_DIRECTORY.AddUsersToAdHocRole (
											role_name => L_ROLE_NAME,
											role_users => L_MOWNER_STRING
										);
		wf_engine.setitemattrtext(itemtype => itemtype
								,itemkey  => itemkey
								,aname    => 'XXFE_MO1_ATTR'
								,avalue   => L_ROLE_NAME);
		--DELETING PREVIOUS USERS ASSIGNED TO PROCESS OWNER ROLE
		L_ROLE_NAME := 'POWNER';
		WF_DIRECTORY.RemoveUsersFromAdHocRole(L_ROLE_NAME);
		--ADDING NEW USERS
		WF_DIRECTORY.AddUsersToAdHocRole (
											role_name => L_ROLE_NAME,
											role_users => L_POWNER_STRING
										);
		wf_engine.setitemattrtext(itemtype => itemtype
								,itemkey  => itemkey
								,aname    => 'XXFE_POWNER_ATTR'
								,avalue   => L_ROLE_NAME);
		RESULT := 'COMPLETE:Y';	
		EXCEPTION
			WHEN OTHERS THEN
				RESULT := 'COMPLETE:N';
	END;
	
	
	--COMPILE ASSIGN PROCEDURE IN STAGE. CALL IT IN WORKFLOW!
	PROCEDURE XX_ASSIGN_RESP (itemtype IN VARCHAR2,itemkey  IN VARCHAR2,actid IN NUMBER,funcmode IN VARCHAR2,RESULT IN OUT VARCHAR2) 
	AS
	L_USER_NAME fnd_user.user_name%TYPE;
	L_APP_ID NUMBER;
	L_START_DATE DATE;
	L_END_DATE DATE;
	L_RESPONSIBILITY_NAME VARCHAR2(1000);
	L_APP_NAME VARCHAR2(1000);
	L_NOTIFID NUMBER;
	L_USERID NUMBER;
	L_RESP_ID NUMBER;
	L_RESP_KEY VARCHAR2(1000);
	L_APP_SHORTNAME VARCHAR2(1000);
	L_TYPE VARCHAR2(100);
	BEGIN
		 L_USER_NAME :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                                        itemkey  => itemkey,
														aname    => 'XXFE_USER_ATTRIBUTE');
		 L_RESP_ID :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                        itemkey  => itemkey,
														aname    => 'XXFE_RESPID_ATTR');
		L_APP_ID :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                        itemkey  => itemkey,
														aname    => 'XXFE_APPID_ATTR');
		L_START_DATE :=  wf_engine.GetItemAttrDate (itemtype => itemtype,
                                                        itemkey  => itemkey,
														aname    => 'XXFE_SDATE_ATTR');
		L_END_DATE :=  wf_engine.GetItemAttrDate (itemtype => itemtype,
                                                itemkey  => itemkey,
														aname    => 'XXFE_EDATE_ATTR');
		IF L_START_DATE IS NULL THEN 
			L_START_DATE := SYSDATE;
		END IF;
		IF L_END_DATE IS NULL THEN
			L_END_DATE := SYSDATE + 7;
    END IF;
		SELECT APPROVAL_TYPE INTO L_TYPE FROM XXFE_RESP_APPROVER_LIST 
		WHERE responsibility_id = L_RESP_ID AND application_id = L_APP_ID;
		/*IF L_TYPE = 'ALL' THEN
			L_APP_NAME :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                                        itemkey  => itemkey,
														aname    => 'XXFE_APPROVER_ATTRIBUTE');
		ELSE
			L_APP_NAME := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                        itemkey  => itemkey,
														aname    => 'XXFE_APP1_ATTR');
		END IF;*/
		L_APP_NAME := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                        itemkey  => itemkey,
														aname    => 'XXFE_MANAGER_ATTRIBUTE');
		--Updating notification ID in the custom table
		SELECT notification_id INTO L_NOTIFID FROM wf_notifications wn WHERE wn.recipient_role = L_APP_NAME and wn.item_key=itemkey;
		SELECT user_id INTO L_USERID FROM fnd_user WHERE user_name = L_USER_NAME;
		UPDATE xxfe_user_resp_provision
			SET notification_id = L_NOTIFID 
			WHERE user_id = L_USERID AND RESPONSIBILITY_ID = L_RESP_ID;
		-- end of notification ID update
		SELECT responsibility_key INTO L_RESP_KEY FROM fnd_responsibility_vl WHERE responsibility_id = L_RESP_ID;
		SELECT application_short_name INTO L_APP_SHORTNAME FROM fnd_application WHERE application_id = L_APP_ID;
		--Assigning the responsibilities 
		
		fnd_user_pkg.addresp(username       => L_USER_NAME
						,resp_app       => L_APP_SHORTNAME
						,resp_key       => L_RESP_KEY
						,security_group => 'STANDARD'
						,description    => 'Auto Responsibility Assignment'
						,start_date     => L_START_DATE
						,end_date       => L_END_DATE);
		COMMIT;

	END;
	
	--************************************************
	-- FUNCTIONS FOR SQL LOADER
	--************************************************
	FUNCTION XX_SL_RNAME(L_RESPNAME IN VARCHAR2) RETURN NUMBER 
	AS
	L_RID NUMBER;
	BEGIN
		SELECT responsibility_id INTO L_RID FROM fnd_responsibility_tl WHERE responsibility_name = L_RESPNAME;
		RETURN L_RID;
	END;
	
	FUNCTION XX_SL_ANAME(L_ANAME IN VARCHAR2) RETURN NUMBER 	-- ANAME IS FOR APPLICATION NAME
	AS
	L_AID NUMBER;
	BEGIN
		SELECT application_id INTO L_AID FROM fnd_application_tl WHERE application_name = L_ANAME;
		RETURN L_AID;
	END;
	
	FUNCTION XX_SL_APPNAME(L_APPEMAIL IN VARCHAR2) RETURN NUMBER -- APPNAME IS FOR APPROVERS NAME
	AS
	L_APPID NUMBER;
	BEGIN
		--PASS EMAIL ADDRESS OF APPROVER AND RETURN THE USER ID
		SELECT user_id INTO L_APPID FROM FND_USER WHERE EMAIL_ADDRESS = L_APPEMAIL;
		RETURN L_APPID;
	END;
	--************************************************
	-- END OF FUNCTIONS FOR SQL LOADER
	--************************************************
END XXFE_APPROVERS_LIST;
