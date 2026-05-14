/*
DELETE EDSR.temp_CargaMasiva_ParametrosPMM;
DELETE EDSR.TEMP_TPCARSEM;
DELETE EDSR.TEMP_PARAMREPOSEM;
DELETE EDSR.TPCARSEM;
DELETE EDSR.TPCARPAR;
ALTER SEQUENCE EDSR.TEMP_TPCARPAR_SEQ RESTART START WITH 1;
COMMIT;
*/

/*
 DELETE EDSR.temp_CargaMasivaMinMax;
 ALTER SEQUENCE EDSR.TEMP_CargaMasivaMinMax_SEQ RESTART START WITH 1;
 DELETE EDSR.TPCARPAR;
 COMMIT;
 */

SELECT CAR.CREATED_AT, PROCESS_START, PROCESS_END, STATUS,VALIDATED, CAR.* FROM EDSR.CARPAREPO CAR ORDER BY CAR.CREATED_AT DESC;
SELECT * FROM EDSR.CARPAREPO
--UPDATE EDSR.CARPAREPO SET status = 'FINALIZED', HASHSHA256 = 'Status2w manu54al 7623e3'
WHERE ID = 11;
COMMIT;
SELECT * FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;
SELECT * FROM EDSR.temp_CargaMasivaMinMax ORDER BY ID;

select COUNT(f.pmh_tech_key), f.prf_wgt_weeks 
from EPMM.RPLWGTEE f 
GROUP BY  f.prf_wgt_weeks, f.pmh_tech_key
order BY f.prf_wgt_weeks
;

INSERT INTO EDSR.TEMP_CARGAMASIVAMINMAX (E_PRODUCTO, E_TIENDA, E_METODO_RPL, E_MIN, E_MAX, USR_CRE)
VALUES ('79845', 'TESTTIENDA', '1', '1', '2', 'SISTEMAS');
COMMIT;

SELECT trigger_name, status
FROM all_triggers
WHERE owner='EDSR' AND table_name='TEMP_CARGAMASIVAMINMAX';

SELECT * FROM EPMM.RPLWGTEE;

SELECT * FROM TPPARREP;

SELECT created,LAST_DDL_TIME, status, obj.*
FROM all_objects obj
WHERE owner = 'EDSR'
  AND object_name = 'PKG_CARPAR_CARGA'
  AND object_type = 'PACKAGE BODY';

SELECT privilege, admin_option,grantee
FROM dba_sys_privs
WHERE UPPER(grantee) LIKE '%USR%'
ORDER BY privilege;

--Listar todos los privilegios del usuario 
SELECT owner, table_name, privilege, grantable
FROM user_tab_privs_recd
ORDER BY owner, table_name, privilege;

SELECT username
FROM all_users
WHERE username = 'USR_CARPAR';

SELECT username, account_status
FROM dba_users
WHERE username = 'USR_CARPAR';

SELECT granted_role, admin_option, default_role
FROM dba_role_privs
WHERE grantee = 'USR_CARPAR'
ORDER BY granted_role;

SELECT owner, table_name, privilege, grantable
FROM dba_tab_privs
WHERE grantee = 'USR_CARPAR'
ORDER BY owner, table_name, privilege;

SELECT column_name, data_type, nullable
FROM all_tab_columns
WHERE owner='EDSR'
  AND table_name='TEMP_CARGAMASIVAMINMAX'
ORDER BY column_id;