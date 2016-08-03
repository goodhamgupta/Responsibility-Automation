SELECT r.responsibility_key,a.application_name
    FROM fnd_user u,
         fnd_user_resp_groups ur,
         fnd_responsibility r,
         fnd_application_tl a,
         fnd_application fa
   WHERE  ur.responsibility_id = r.responsibility_id
         AND u.user_id = ur.user_id
         AND fa.APPLICATION_ID = a.APPLICATION_ID
         AND r.application_id = a.application_id
         AND upper(u.user_name) = UPPER ('SGUPTA') --Instead of SGUPTA we can use the oaf method to get the user name.(String userid= pageContext.getUsername())
         AND a.language = 'US'
ORDER BY 1;
