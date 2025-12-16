SELECT * FROM edsr.hp_dad_stock_actual;
SELECT * FROM edsr.hp_dad_stock_anterior;
SELECT * FROM edsr.hp_dad_stock_maestro;

SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%HP_DAD_STOCK_ACTUAL%';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%HP_DAD_STOCK_ANTERIOR%';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%HP_DAD_STOCK_MAESTRO%';

delete from edsr.hp_dad_stock_actual;
delete from edsr.hp_dad_stock_anterior;
delete from edsr.hp_dad_stock_maestro;

alter table  edsr.hp_dad_stock_actual
modify  ORG_LVL_NUMBER VARCHAR2(15);

alter table  edsr.hp_dad_stock_anterior
modify  ORG_LVL_NUMBER VARCHAR2(15);

alter table  edsr.hp_dad_stock_maestro
modify  ORG_LVL_NUMBER VARCHAR2(15);

SELECT count(*) FROM VPCMSTEE WHERE VENDOR_NUMBER like '0%';



/******************************/
--      OBJECTS
/******************************/

SELECT owner, object_name, object_type, status
FROM dba_objects
WHERE UPPER(object_name) IN ('SEQUENCE_DADAJUSTE','SEQUENCE_DADAJUSTEMZV','SEQ_ID_RCV_DAD');

select * from DADAJUSTEMZV;

/******************************/
--      TABLES
/******************************/
SELECT * FROM dba_tables
WHERE UPPER(table_name) = 'VPCMSTEE_DD_PDF';

/******************************/
--      PROCEDURE
/******************************/

SELECT * FROM dba_procedures
WHERE UPPER(object_name) = 'NOMBRE_DEL_PROCEDIMIENTO'
  --AND object_type = 'PROCEDURE' -- O 'FUNCTION' si es una función
  ;



/******************************/
--      SEQUENCES
/******************************/

SELECT * FROM dba_sequences
WHERE UPPER(sequence_name) = 'NOMBRE_DE_LA_SECUENCIA';
