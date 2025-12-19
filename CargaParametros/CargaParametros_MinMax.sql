/*
 DELETE EDSR.temp_CargaMasivaMinMax;
 ALTER SEQUENCE EDSR.TEMP_CargaMasivaMinMax_SEQ RESTART START WITH 1;
 DELETE EDSR.TPCARPAR;
 COMMIT;
 */

--VALIDACION
SELECT COUNT(1) temp_CargaMasivaMinMax FROM EDSR.temp_CargaMasivaMinMax;
SELECT * FROM EDSR.temp_CargaMasivaMinMax ORDER BY ID;
SELECT * FROM EDSR.temp_CargaMasivaMinMax ORDER BY ID DESC;
SELECT COUNT(1) from EDSR.TPCARPAR;
BEGIN
	DBMS_OUTPUT.PUT_LINE('Test');
END;
SELECT * FROM EDSR.temp_CargaMasivaMinMax WHERE E_PRODUCTO = '43881';
SELECT * FROM EDSR.temp_CargaMasivaMinMax WHERE ID IN (508,507,509);
--CARGA
DECLARE
    TOTAL NUMBER := 0;
    MINIMO NUMBER := 0;
    MAXIMO NUMBER := 0;

    p_secuencia NUMBER;

    V_PRD_LVL_NUMBER VARCHAR2(15);
    

BEGIN
    SELECT COUNT(*)
     INTO TOTAL
    FROM EDSR.temp_CargaMasivaMinMax;

    IF TOTAL > 0 THEN
        SELECT MIN(ID), MAX(id)
        INTO MINIMO,MAXIMO
        FROM EDSR.temp_CargaMasivaMinMax
        --WHERE ID <=50 --OPCIONAL
        ;

        SELECT EDSR.TP_SEQ_RPL_SEQ.NEXTVAL
        INTO p_secuencia
        FROM DUAL;

       DBMS_OUTPUT.PUT_LINE('TOTAL: ' || TOTAL);
       DBMS_OUTPUT.PUT_LINE('MINIMO: ' || MINIMO);
       DBMS_OUTPUT.PUT_LINE('MAXIMO: ' || MAXIMO);
       DBMS_OUTPUT.PUT_LINE('p_secuencia: ' || p_secuencia);

       DBMS_OUTPUT.PUT_LINE('BEGIN: WHILE MINIMO <= MAXIMO LOOP');
        WHILE MINIMO <= MAXIMO LOOP
            SELECT E_PRODUCTO
            INTO V_PRD_LVL_NUMBER
            FROM EDSR.temp_CargaMasivaMinMax
            WHERE ID = MINIMO;


            UPDATE EDSR.temp_CargaMasivaMinMax
                SET
                    RPL_SEQ = p_secuencia,
                    RPL_SEQ_REG = ID,
                    RPL_METHOD_CODE = 1,
                    PRD_LVL_CHILD = EDSR.S_OBT_PRODUCTO(E_PRODUCTO),
                    ORG_LVL_CHILD = EDSR.S_OBT_SUCURSAL(E_TIENDA),
                    RPL_DIST_METHOD = CASE WHEN E_METODO_RPL = 'OCS' THEN 2
                                           WHEN E_METODO_RPL = 'CAT' THEN 6
                                           WHEN E_METODO_RPL = 'RAT' THEN 3
                                       END,
                    RPL_MIN_STK = E_MIN ,
                    RPL_MAX_STK = E_MAX,
                    USR_CRE = 'SISTEMAS'
                WHERE ID = MINIMO;

            MINIMO := MINIMO + 1 ;
            --DBMS_OUTPUT.PUT_LINE(V_PRD_LVL_NUMBER);
            COMMIT;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('END: WHILE MINIMO <= MAXIMO LOOP');
       
	   MINIMO := MINIMO - 1 ;
       DBMS_OUTPUT.PUT_LINE('PROCESADOS: ' || MINIMO);
       DBMS_OUTPUT.PUT_LINE('INSERT INTO EDSR.TPCARPAR');
       INSERT INTO EDSR.TPCARPAR
          (
           RPL_SEQ,
           RPL_SEQ_REG,
           RPL_METHOD_CODE,
           PRD_LVL_CHILD,
           ORG_LVL_CHILD,
           RPL_DIST_METHOD,
           RPL_MIN_STK,
           RPL_MAX_STK,
           USR_CRE,
           FEC_CRE
          )
        SELECT
           RPL_SEQ,
           RPL_SEQ_REG,
           RPL_METHOD_CODE,
           PRD_LVL_CHILD,
           ORG_LVL_CHILD,
           RPL_DIST_METHOD,
           RPL_MIN_STK,
           RPL_MAX_STK,
           USR_CRE,
           sysdate
        FROM temp_CargaMasivaMinMax
        --WHERE ID <=50 --OPCIONAL
        ;
       COMMIT;

       DBMS_OUTPUT.PUT_LINE('Busca los productos que no tienen habilitado el cross-docking y los borra');
       -- Busca los productos que no tienen habilitado el cross-docking y los borra
        INSERT INTO TPCARPAR_REC_TMP
          (RPL_SEQ, RPL_SEQ_REG, PRD_LVL_CHILD, ORG_LVL_CHILD)
          SELECT T1.RPL_SEQ, T1.RPL_SEQ_REG, T1.PRD_LVL_CHILD, T1.ORG_LVL_CHILD
            FROM TPCARPAR T1
           INNER JOIN TPPRDMST P
              ON T1.PRD_LVL_CHILD = P.PRD_LVL_CHILD
           WHERE RPL_SEQ = p_secuencia
             AND RPL_DIST_METHOD = 6 -- CAT
             AND (P.VPC_TECH_KEY, P.COD_AREA, T1.ORG_LVL_CHILD) NOT IN
                 (SELECT PRV_AREA.VPC_TECH_KEY, PRV_AREA.COD_AREA, AO.ORG_LVL_CHILD
                    FROM (SELECT DISTINCT PC1.VPC_TECH_KEY, TA.COD_AREA, TCD.TIPO
                            FROM HP_CROSS_PROV PC1
                           CROSS JOIN (SELECT TRIM(PRD_LVL_NUMBER) COD_AREA
                                        FROM PRDMSTEE
                                       WHERE PRD_LVL_ID = 4) TA
                           CROSS JOIN (SELECT DISTINCT TIPO FROM HP_CROSS_PROV) TCD) PRV_AREA
                    LEFT JOIN HP_CROSS_PROV PC2
                      ON PC2.VPC_TECH_KEY = PRV_AREA.VPC_TECH_KEY
                     AND PC2.TIPO = PRV_AREA.TIPO
                     AND PC2.COD_AREA IS NULL
                    LEFT JOIN HP_CROSS_PROV PC3
                      ON PC3.VPC_TECH_KEY = PRV_AREA.VPC_TECH_KEY
                     AND PC3.TIPO = PRV_AREA.TIPO
                     AND PC3.COD_AREA = PRV_AREA.COD_AREA
                    LEFT JOIN BASACDEE CA
                      ON NVL(PC3.TIPO, PC2.TIPO) = CA.ATR_COD_TECH_KEY
                    LEFT JOIN BASATOEE AO
                      ON CA.ATR_COD_TECH_KEY = AO.ATR_COD_TECH_KEY
                    LEFT JOIN HP_CROSS_SUC SC
                      ON NVL(PC2.ID, PC3.ID) = SC.ID
                     AND AO.ORG_LVL_CHILD = SC.ORG_LVL_CHILD
                    LEFT JOIN ORGMSTEE O
                      ON AO.ORG_LVL_CHILD = O.ORG_LVL_CHILD
                   WHERE NOT NVL(PC2.ID, PC3.ID) IS NULL
                     AND SC.ORG_LVL_CHILD IS NULL);

        DBMS_OUTPUT.PUT_LINE('DELETE FROM TPCARPAR');
        DELETE FROM TPCARPAR
        WHERE (RPL_SEQ, RPL_SEQ_REG) IN
                (SELECT RPL_SEQ, RPL_SEQ_REG
                 FROM TPCARPAR_REC_TMP
                 WHERE RPL_SEQ = p_secuencia);



        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontraron registros');
    END if;
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('HORROR: ' || SQLERRM);
		DBMS_OUTPUT.PUT_LINE('ULTIMO SKU PROCESADO: ' || V_PRD_LVL_NUMBER);
END;

-- Validacion Carga
SELECT COUNT(1) FROM EDSR.temp_CargaMasivaMinMax;
SELECT COUNT(1) FROM EDSR.TPCARPAR;

/*
  Secuencia 55 (768 OCS)
  Secuencia 60 (748 OCS)
  Secuencia 61 (146 RAT)
  QA => Secuencia 75 (244 RAT 1era Semana)  12/12/2024 01:00
  Secuencia 398 (244 RAT 1era Semana)  12/12/2024 09:17
  Secuencia 413 (581 OCS) 26/12/2024 16:06
  Secuencia 581 (581 OCS-RAT)  15/04/2025 22:57
  Secuencia XXX (581 OCS-RAT)  16/04/2025 13:15
  Secuencia 777 (508 RAT)  31/10/2025 14:52
*/

BEGIN
    EDSR.TP_PKG_REPDIN.SP_CARGA_PARAM_REPO(777,'SISTEMAS');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga Exitosa');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR EN LA CARGA');
        DBMS_OUTPUT.PUT_LINE('Descripcion: ' || sqlerrm);
END;



--**************************
--  VALIDACIONES DE CARGA
--**************************
--temp_CargaMasivaMinMax
SELECT count(1) FROM EDSR.temp_CargaMasivaMinMax ORDER BY ID;
--TPCARPAR
SELECT COUNT(1) FROM EDSR.TPCARPAR;
--TPCARPAR_REC_TMP
SELECT COUNT(1) FROM EDSR.TPCARPAR_REC_TMP;

SELECT * FROM EDSR.temp_CargaMasivaMinMax ORDER BY ID;
SELECT * FROM EDSR.temp_CargaMasivaMinMax ORDER BY ID DESC;


SELECT * FROM EDSR.TPCARPAR;

SELECT * FROM EDSR.TPCARPAR_REC_TMP;

SELECT RPL_SEQ,RPL_SEQ_REG,RPL_METHOD_CODE,PRD_LVL_CHILD,ORG_LVL_CHILD,RPL_DIST_METHOD,RPL_MIN_STK,RPL_MAX_STK,USR_CRE,FEC_CRE
 FROM EDSR.TPCARPAR;


 DROP SEQUENCE EDSR.TEMP_CargaMasivaMinMax_SEQ;
 CREATE SEQUENCE EDSR.TEMP_CargaMasivaMinMax_SEQ
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE;

  COMMIT;
SELECT EDSR.TEMP_CargaMasivaMinMax_SEQ.NEXTVAL AS SEC FROM DUAL;
-- antes: temp_CargaMasiv4_ParametrosPMM
CREATE TABLE EDSR.temp_CargaMasivaMinMax(
    ID NUMBER DEFAULT EDSR.TEMP_CargaMasivaMinMax_SEQ.NEXTVAL,
    E_PRODUCTO VARCHAR(20),
    E_TIENDA VARCHAR(20),
    E_METODO_RPL VARCHAR(20),
    E_MIN VARCHAR(20),
    E_MAX VARCHAR(20),
    E_OBS VARCHAR(20),


    PRD_LVL_NUMBER  VARCHAR2(15), --
    ORG_LVL_NUMBER  NUMBER(12), --

    RPL_SEQ         NUMBER ,
    RPL_SEQ_REG     NUMBER ,
    RPL_METHOD_CODE NUMBER(3),
    PRD_LVL_CHILD NUMBER(12),
    ORG_LVL_CHILD NUMBER(12),
    RPL_DIST_METHOD VARCHAR2(4),
    RPL_MIN_STK     NUMBER(13, 4),
    RPL_MAX_STK     NUMBER(13, 4),
    USR_CRE         VARCHAR2(20)
);

