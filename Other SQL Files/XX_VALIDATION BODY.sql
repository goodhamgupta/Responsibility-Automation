CREATE OR REPLACE PACKAGE BODY XX_VALIDATION AS 
	PROCEDURE XX_REQUEST(L_USER_ID IN NUMBER,L_RESPONSIBILITY_ID IN NUMBER ,L_NOTIFICATION_ID IN NUMBER ) AS
	DECLARE
	
	
	BEGIN
	INSERT INTO XXFE_USER_RESP_PROVISION(USER_ID,RESPONSIBILITY_ID,NOTIFICATION_ID) VALUES (L_USER_ID,L_RESPONSIBILITY_ID,L_NOTIFICATION_ID);
	END;
	
	PROCEDURE XX_REVOKE(L_USER_ID IN NUMBER,L_RESPONSIBILITY_ID IN NUMBER ,L_NOTIFICATION_ID IN NUMBER ) AS
	BEGIN
		DELETE FROM XXFE_USER_RESP_PROVISION WHERE USER_ID = L_USER_ID AND RESPONSIBILITY_ID=L_RESPONSIBILITY_ID AND NOTIFICATION_ID=L_NOTIFICATION_ID;
	END;
END XX_VALIDATION;
	
	
	