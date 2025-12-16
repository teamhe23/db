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
                    PRD_LVL_CHILD = S_OBT_PRODUCTO(E_PRODUCTO),
                    ORG_LVL_CHILD = S_OBT_SUCURSAL(E_TIENDA),
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

        DELETE FROM TPCARPAR
        WHERE (RPL_SEQ, RPL_SEQ_REG) IN
                (SELECT RPL_SEQ, RPL_SEQ_REG
                 FROM TPCARPAR_REC_TMP
                 WHERE RPL_SEQ = p_secuencia);



        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontraron registros');
    END if;
END;

-- temp_CargaMasivaMinMax
SELECT COUNT(1) FROM EDSR.temp_CargaMasivaMinMax;


-- 29/01/2024
-- OCS: 15205 32913
-- RAT: 10140 18355
SELECT * FROM EDSR.temp_CargaMasivaMinMax ORDER BY ID;
SELECT * FROM EDSR.temp_CargaMasivaMinMax ORDER BY ID DESC;

-- TPCARPAR
SELECT COUNT(1) FROM EDSR.TPCARPAR;
SELECT * FROM EDSR.TPCARPAR;



SELECT RPL_SEQ,RPL_SEQ_REG,RPL_METHOD_CODE,PRD_LVL_CHILD,ORG_LVL_CHILD,RPL_DIST_METHOD,RPL_MIN_STK,RPL_MAX_STK,USR_CRE,FEC_CRE
 FROM EDSR.TPCARPAR;

/*
  Secuencia 103 (768 OCS) 26/01/2024 19:59
  Secuencia 112 (748 OCS) 29/01/2024 21:41
  Secuencia 113 (146 RAT) 29/01/2024 21:45
*/

BEGIN
    EDSR.TP_PKG_REPDIN.SP_CARGA_PARAM_REPO(113,'SISTEMAS');
END;



/*
 TRUNCATE TABLE EDSR.temp_CargaMasivaMinMax;
 DROP SEQUENCE EDSR.TEMP_CargaMasivaMinMax_SEQ;
 COMMIT;
 */
CREATE SEQUENCE EDSR.TEMP_CargaMasivaMinMax_SEQ
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE;

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

