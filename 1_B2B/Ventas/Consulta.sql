SELECT * 
FROM dba_DIRECTORIES 
WHERE DIRECTORY_NAME = 'TP_FILE_B2B';

SELECT OBJECT_TYPE, OWNER
FROM dba_OBJECTS
WHERE OBJECT_NAME = 'TP_FILE_B2B';

    Select *
      From tpeparep tpe
     Where tpe.tpe_app_name = 'TP_B2B_VTA';