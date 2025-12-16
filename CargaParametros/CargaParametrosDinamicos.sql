DECLARE
    TOTAL NUMBER := 0;
    MINIMO NUMBER := 0;
    MAXIMO NUMBER := 0;

    p_secuencia NUMBER;

    V_PRD_LVL_NUMBER VARCHAR2(15);
    TOTAL_PARAMETROS NUMBER := 0;
   -- TOTAL_PARAMETROS_SEM NUMBER := 0;
    TOTAL_SKUS_CROSSDOCKING NUMBER := 0;
    intTotSemanas NUMBER := 0;

    strFijo  CHAR;
    intDiaRevision  NUMBER(3);
    intDiaProceso  NUMBER(3);
    intSemSR  NUMBER(3);
    dblPorServicio  NUMBER(4, 2);
    intSemVenta  NUMBER(7);

BEGIN
    SELECT COUNT(*)
     INTO TOTAL
    FROM EDSR.temp_CargaMasiva_ParametrosPMM;

    IF TOTAL > 0 THEN
        SELECT MIN(ID), MAX(id)
        INTO MINIMO,MAXIMO
        FROM EDSR.temp_CargaMasiva_ParametrosPMM
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
            FROM EDSR.temp_CargaMasiva_ParametrosPMM
            WHERE ID = MINIMO;

            SELECT COUNT(*)
            INTO TOTAL_PARAMETROS
            FROM TPPARREP REP,
               TPPRDMST PRD
            WHERE REP.COD_DIV = PRD.COD_DIV
                AND REP.COD_AREA = PRD.COD_AREA
                AND REP.COD_DPTO = PRD.COD_DPTO
                AND REP.COD_LIN = PRD.COD_LIN
                AND PRD.PRD_LVL_NUMBER = V_PRD_LVL_NUMBER;

            IF TOTAL_PARAMETROS > 0 THEN
                SELECT REP.RPL_FIJO, REP.RPL_REVIEW_DAYS, REP.RPL_PROC_DAYS, REP.RPL_SS, REP.PMH_SERV_LVL, REP.PRF_WGT_WEEKS
                INTO strFijo,  intDiaRevision,  intDiaProceso,  intSemSR,  dblPorServicio,  intSemVenta
                FROM TPPARREP REP,
                   TPPRDMST PRD
                WHERE REP.COD_DIV = PRD.COD_DIV
                    AND REP.COD_AREA = PRD.COD_AREA
                    AND REP.COD_DPTO = PRD.COD_DPTO
                    AND REP.COD_LIN = PRD.COD_LIN
                    AND PRD.PRD_LVL_NUMBER = V_PRD_LVL_NUMBER
                    AND ROWNUM = 1;

                IF strFijo = 'T' THEN
                    UPDATE EDSR.temp_CargaMasiva_ParametrosPMM
                    SET
                        RPL_SEQ = p_secuencia,
                        RPL_SEQ_REG = ID,
                        RPL_METHOD_CODE = 3,
                        PRD_LVL_CHILD = S_OBT_PRODUCTO(E_PRODUCTO),
                        ORG_LVL_CHILD = S_OBT_SUCURSAL(E_TIENDA),
                        PRF_TECH_KEY = S_OBT_PERFIL(E_PERFIL),
                        RPL_DIST_METHOD = CASE WHEN E_METODO_RPL = 'OCS' THEN 2
                                               WHEN E_METODO_RPL = 'CAT' THEN 6
                                               WHEN E_METODO_RPL = 'RAT' THEN 6
                                           END,
                        RPL_REVIEW_DAYS = intDiaRevision ,
                        RPL_PROC_DAYS =  intDiaProceso,
                        RPL_SS =  intSemSR,
                        PMH_SERV_LVL = dblPorServicio ,
                        RPL_MIN_STK = E_MIN ,
                        RPL_MAX_STK = E_MAX,
                        PRF_WGT_WEEKS = intSemVenta,
                        USR_CRE = 'SISTEMAS'
                    WHERE ID = MINIMO;

                    intTotSemanas := intSemVenta;

                    INSERT INTO EDSR.TEMP_PARAMREPOSEM(WGT_WEEK, WGT_FACTOR, PRD_LVL_NUMBER)
                    SELECT
                           SEM.WGT_WEEK,
                           SEM.WGT_FACTOR,
                           V_PRD_LVL_NUMBER
                    FROM TPPARSEM SEM,
                           TPPRDMST PRD
                    WHERE SEM.COD_DIV = PRD.COD_DIV
                       AND SEM.COD_AREA = PRD.COD_AREA
                       AND PRD.PRD_LVL_NUMBER = V_PRD_LVL_NUMBER
                       AND SEM.COD_DPTO = PRD.COD_DPTO
                       AND SEM.COD_LIN = PRD.COD_LIN
                    ORDER BY SEM.WGT_WEEK;

                    INSERT INTO EDSR.TEMP_TPCARSEM(RPL_SEQ, RPL_SEQ_REG, WGT_WEEK, WGT_FACTOR, USR_CRE, FEC_CRE)
                    SELECT
                       p_secuencia,
                       MINIMO,
                       TEMPSEM.WGT_WEEK,
                       TEMPSEM.WGT_FACTOR,
                       'SISTEMAS',
                       SYSDATE
                    FROM EDSR.TEMP_PARAMREPOSEM TEMPSEM
                    WHERE TEMPSEM.WGT_WEEK <= intTotSemanas
                          AND PRD_LVL_NUMBER = V_PRD_LVL_NUMBER
                    ORDER BY TEMPSEM.WGT_WEEK;
                END IF;


            ELSE
                SELECT E_SEMANA_VENTA
                INTO intTotSemanas
                FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE ID = MINIMO;

                UPDATE EDSR.temp_CargaMasiva_ParametrosPMM
                SET
                    RPL_SEQ = p_secuencia,
                    RPL_SEQ_REG = ID,
                    RPL_METHOD_CODE = 3,
                    PRD_LVL_CHILD = S_OBT_PRODUCTO(E_PRODUCTO),
                    ORG_LVL_CHILD = S_OBT_SUCURSAL(E_TIENDA),
                    PRF_TECH_KEY = S_OBT_PERFIL(E_PERFIL),
                    RPL_DIST_METHOD = CASE WHEN E_METODO_RPL = 'OCS' THEN 2
                                           WHEN E_METODO_RPL = 'CAT' THEN 6
                                           WHEN E_METODO_RPL = 'RAT' THEN 6
                                       END,
                    RPL_REVIEW_DAYS = E_DIAS_REVISION ,
                    RPL_PROC_DAYS =  E_DIAS_PROCESO,
                    RPL_SS =  E_SEMANAS_SR,
                    PMH_SERV_LVL = E_SERVICIO ,
                    RPL_MIN_STK = E_MIN ,
                    RPL_MAX_STK = E_MAX,
                    PRF_WGT_WEEKS = E_SEMANA_VENTA,
                    USR_CRE = 'SISTEMAS'
                WHERE ID = MINIMO;

                -- SELECT * FROM EDSR.TEMP_PARAMREPOSEM;
                -- TRUNCATE TABLE EDSR.TEMP_PARAMREPOSEM;

                INSERT INTO EDSR.TEMP_PARAMREPOSEM TEMP (WGT_WEEK, PRD_LVL_NUMBER , WGT_FACTOR)
                SELECT ROWNUM, V_PRD_LVL_NUMBER ,WGT_FACTOR
                    FROM (
                        SELECT ID,E_SEM1, E_SEM2, E_SEM3, E_SEM4, E_SEM5, E_SEM6, E_SEM7, E_SEM8, E_SEM9, E_SEM10 FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE ID = MINIMO
                    )
                UNPIVOT(
                     WGT_FACTOR FOR SEMANA IN (E_SEM1, E_SEM2, E_SEM3, E_SEM4, E_SEM5, E_SEM6, E_SEM7, E_SEM8, E_SEM9, E_SEM10)
                    );

                INSERT INTO EDSR.TEMP_TPCARSEM(RPL_SEQ, RPL_SEQ_REG, WGT_WEEK, WGT_FACTOR, USR_CRE, FEC_CRE)
                SELECT
                   p_secuencia,
                   MINIMO,
                   TEMPSEM.WGT_WEEK,
                   TEMPSEM.WGT_FACTOR,
                   'SISTEMAS',
                   SYSDATE
                FROM EDSR.TEMP_PARAMREPOSEM TEMPSEM
                WHERE TEMPSEM.WGT_WEEK <= intTotSemanas
                      AND PRD_LVL_NUMBER = V_PRD_LVL_NUMBER
                ORDER BY TEMPSEM.WGT_WEEK;

            END IF;

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
           PRF_TECH_KEY,
           RPL_DIST_METHOD,
           RPL_REVIEW_DAYS,
           RPL_PROC_DAYS,
           RPL_SS,
           PMH_SERV_LVL,
           RPL_MIN_STK,
           RPL_MAX_STK,
           PRF_WGT_WEEKS,
           USR_CRE,
           FEC_CRE
          )
        SELECT
           RPL_SEQ,
           RPL_SEQ_REG,
           RPL_METHOD_CODE,
           PRD_LVL_CHILD,
           ORG_LVL_CHILD,
           PRF_TECH_KEY,
           RPL_DIST_METHOD,
           RPL_REVIEW_DAYS,
           RPL_PROC_DAYS,
           RPL_SS,
           PMH_SERV_LVL,
           RPL_MIN_STK,
           RPL_MAX_STK,
           PRF_WGT_WEEKS,
           USR_CRE,
           sysdate
        FROM temp_CargaMasiva_ParametrosPMM
        --WHERE ID <=50 --OPCIONAL
        ;

       INSERT INTO TPCARSEM
       (
        RPL_SEQ,
        RPL_SEQ_REG,
        WGT_WEEK,
        WGT_FACTOR,
        USR_CRE,
        FEC_CRE
       )
       SELECT RPL_SEQ, RPL_SEQ_REG, WGT_WEEK, WGT_FACTOR, USR_CRE, FEC_CRE
       FROM EDSR.TEMP_TPCARSEM;

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

        SELECT
            COUNT(*)
        INTO TOTAL_SKUS_CROSSDOCKING
             /*R.RPL_SEQ,
             R.RPL_SEQ_REG,
             R.PRD_LVL_CHILD,
             R.ORG_LVL_CHILD,
             P.PRD_LVL_NUMBER,
             TRIM(O.ORG_LVL_NUMBER) ORG_LVL_NUMBER,
             P.COD_AREA*/
        FROM TPCARPAR_REC_TMP R
       INNER JOIN TPPRDMST P
          ON R.PRD_LVL_CHILD = P.PRD_LVL_CHILD
       INNER JOIN ORGMSTEE O
          ON R.ORG_LVL_CHILD = O.ORG_LVL_CHILD
       WHERE RPL_SEQ = p_secuencia;

        IF TOTAL_SKUS_CROSSDOCKING > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Se encontraron ' || TOTAL_SKUS_CROSSDOCKING || ' SKUs no válidos por el Cross-docking');

            DELETE FROM EDSR.TPCARSEM
            WHERE (RPL_SEQ, RPL_SEQ_REG) IN
                     ( SELECT
                        R.RPL_SEQ,
                        R.RPL_SEQ_REG
                    FROM TPCARPAR_REC_TMP R
                    INNER JOIN TPPRDMST P
                      ON R.PRD_LVL_CHILD = P.PRD_LVL_CHILD
                    INNER JOIN ORGMSTEE O
                      ON R.ORG_LVL_CHILD = O.ORG_LVL_CHILD
                    WHERE RPL_SEQ = p_secuencia);
        END IF;

        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontraron registros');
    END if;
END;

--OSC: 13321 32066
--RAT: 10186 25079
SELECT * FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;
SELECT * FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID DESC;
SELECT COUNT(*) FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE E_SEM8 = 0;
SELECT COUNT(*) FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE E_SEM8 = 1;

SELECT * FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE ID IN (373,374,8916,8999,9359);

--Temporal
SELECT COUNT(1) FROM EDSR.temp_CargaMasiva_ParametrosPMM;
--TEMP_TPCARSEM
SELECT COUNT(1) FROM EDSR.TEMP_TPCARSEM;
--TEMP_PARAMREPOSEM
SELECT COUNT(1) FROM EDSR.TEMP_PARAMREPOSEM;
--TPCARPAR
SELECT COUNT(1) FROM EDSR.TPCARPAR;
--TPCARSEM
SELECT COUNT(1) FROM EDSR.TPCARSEM;


SELECT * FROM EDSR.TPCARSEM;

-- SELECT * FROM EDSR.HPREP8SEMANAS_FULL WHERE SKU = '13322' ORDER BY FEC_ACT_REPORTE DESC;
-- SELECT * FROM EDSR.HPREP8SEMANAS_FULL ORDER BY FEC_ACT_REPORTE DESC;

/*
 Secuencia 46 (10266 OCS 4ta Semana)
 Secuencia 47 (10266 OCS 5ta Semana)
 Secuencia 48 (10266 RAT 5ta Semana)
 Secuencia 49 (3 OCS 6ta Semana)
 Secuencia 50 (10246 OCS 6ta Semana)
 Secuencia 51 (4898 RAT 6ta Semana)
 Secuencia 53 (10246 OCS 7ta Semana)
 Secuencia 54 (4884 RAT 7ta Semana)
 Secuencia 58 (9931 OCS 7ta Semana) 29/01/24
 Secuencia 59 (4883 RAT 7ta Semana) 29/01/24

*/

BEGIN
    EDSR.TP_PKG_REPDIN.SP_CARGA_PARAM_REPO(63,'SISTEMAS');
END;

COMMIT;

/*
TRUNCATE TABLE EDSR.temp_CargaMasiva_ParametrosPMM;
TRUNCATE TABLE EDSR.TEMP_TPCARSEM;
TRUNCATE TABLE EDSR.TEMP_PARAMREPOSEM;
TRUNCATE TABLE EDSR.TPCARSEM;
TRUNCATE TABLE EDSR.TPCARPAR;

DROP SEQUENCE EDSR.TEMP_TPCARPAR_SEQ;
CREATE SEQUENCE EDSR.TEMP_TPCARPAR_SEQ
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE;

COMMIT;
 */

-- Carga Masiva Dinamicos
SELECT COUNT(1) FROM temp_CargaMasiva_ParametrosPMM;
--TEMP_TPCARSEM
SELECT COUNT(1) FROM EDSR.TEMP_TPCARSEM;
--TEMP_PARAMREPOSEM
SELECT COUNT(1) FROM EDSR.TEMP_PARAMREPOSEM;
--TPCARPAR
SELECT COUNT(1) FROM EDSR.TPCARPAR;
--TPCARSEM
SELECT COUNT(*) FROM EDSR.TPCARSEM;

SELECT EDSR.TEMP_TPCARPAR_SEQ.NEXTVAL AS SEC FROM DUAL;

SELECT * FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;

SELECT COUNT(1) FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;
SELECT COUNT(*) FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE E_SEM7= 0;
SELECT COUNT(*) FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE E_SEM7 = 1;
SELECT COUNT(E_SEM1) FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;
SELECT COUNT(E_SEM2) FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;
SELECT COUNT(E_SEM3) FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;
SELECT COUNT(E_SEM4) FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;
SELECT COUNT(E_SEM5) FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;
SELECT COUNT(E_SEM6) FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;

SELECT * FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;
SELECT * FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID DESC;
SELECT COUNT(*) FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE E_SEM6 = 0;
SELECT COUNT(*) FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE E_SEM6 = 1;
SELECT * FROM EDSR.TEMP_TPCARSEM;
SELECT * FROM EDSR.TEMP_PARAMREPOSEM;
SELECT * FROM EDSR.TPCARPAR;
SELECT * FROM EDSR.TPCARSEM;

SELECT RPL_SEQ_REG, COUNT(RPL_SEQ_REG)  FROM EDSR.TPCARSEM
                                       GROUP BY RPL_SEQ_REG
                                       HAVING COUNT(RPL_SEQ_REG) = 5
                                       ORDER BY RPL_SEQ_REG DESC;

SELECT DISTINCT RPL_SEQ_REG FROM EDSR.TPCARSEM ORDER BY RPL_SEQ_REG DESC;

-- VERIFICADOR
DECLARE
    V_MIN NUMBER;
    V_MAX NUMBER;
    V_TOTAL NUMBER;
    V_VERIFICADOR NUMBER := 0;
    V_RPL_SEQ_REG NUMBER := 0;
BEGIN

    SELECT COUNT(RPL_SEQ_REG) INTO V_TOTAL FROM EDSR.TPCARSEM;
    SELECT MIN(RPL_SEQ_REG) INTO V_MIN FROM EDSR.TPCARSEM;
    SELECT MAX(RPL_SEQ_REG) INTO V_MAX FROM EDSR.TPCARSEM;

    DBMS_OUTPUT.PUT_LINE('VERIFICADOR: ' || V_VERIFICADOR);
    DBMS_OUTPUT.PUT_LINE('MIN: ' || V_MIN);
    DBMS_OUTPUT.PUT_LINE('MAX: ' || V_MAX);
    DBMS_OUTPUT.PUT_LINE('TOTAL: ' || V_TOTAL);

    WHILE V_MIN <= V_MAX LOOP

        BEGIN
            SELECT DISTINCT RPL_SEQ_REG INTO V_RPL_SEQ_REG FROM EDSR.TPCARSEM WHERE RPL_SEQ_REG = V_MIN;
            V_VERIFICADOR := V_VERIFICADOR + 1 ;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(V_MIN);
        END;

        V_MIN := V_MIN + 1 ;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('MIN FINAL: ' || V_MIN);
    DBMS_OUTPUT.PUT_LINE('VERIFICADOR: ' || V_VERIFICADOR);

END;

/*
DROP FUNCTION EDSR.S_OBT_PRODUCTO;
DROP FUNCTION EDSR.S_OBT_SUCURSAL;
DROP FUNCTION EDSR.S_OBT_PERFIL;
COMMIT;


TRUNCATE TABLE  EDSR.temp_CargaMasiva_ParametrosPMM;
TRUNCATE TABLE  EDSR.TEMP_TPCARSEM;
TRUNCATE TABLE  EDSR.TEMP_PARAMREPOSEM;
DROP TABLE  EDSR.TEMP_TPCARSEM;
DROP TABLE  EDSR.TEMP_PARAMREPOSEM;
DROP TABLE  EDSR.temp_CargaMasiva_ParametrosPMM;
*/

CREATE TABLE EDSR.temp_CargaMasiva_ParametrosPMM(
    ID NUMBER DEFAULT EDSR.TEMP_TPCARPAR_SEQ.NEXTVAL,
    E_PRODUCTO VARCHAR(20),
    E_TIENDA VARCHAR(20),
    E_PERFIL VARCHAR(20),
    E_METODO_RPL VARCHAR(20),
    E_MIN VARCHAR(20),
    E_MAX VARCHAR(20),
    E_DIAS_REVISION VARCHAR(20),
    E_DIAS_PROCESO VARCHAR(20),
    E_SEMANAS_SR VARCHAR(20),
    E_SERVICIO VARCHAR(20),
    E_SEMANA_VENTA VARCHAR(20),
    E_SEM1 VARCHAR(20),
    E_SEM2 VARCHAR(20),
    E_SEM3 VARCHAR(20),
    E_SEM4 VARCHAR(20),
    E_SEM5 VARCHAR(20),
    E_SEM6 VARCHAR(20),
    E_SEM7 VARCHAR(20),
    E_SEM8 VARCHAR(20),
    E_SEM9 VARCHAR(20),
    E_SEM10 VARCHAR(20),
    E_OBS VARCHAR(20),


    PRD_LVL_NUMBER  VARCHAR2(15), --
    ORG_LVL_NUMBER  NUMBER(12), --
    PRF_DESC        NCHAR(30), --

    RPL_SEQ         NUMBER ,
    RPL_SEQ_REG     NUMBER ,
    RPL_METHOD_CODE NUMBER(3),
    PRD_LVL_CHILD NUMBER(12),
    ORG_LVL_CHILD NUMBER(12),
    PRF_TECH_KEY NUMBER(12),
    RPL_DIST_METHOD VARCHAR2(4),
    RPL_REVIEW_DAYS NUMBER(3),
    RPL_PROC_DAYS   NUMBER(3),
    RPL_SS          NUMBER(3),
    PMH_SERV_LVL    NUMBER(4, 2),
    RPL_MIN_STK     NUMBER(13, 4),
    RPL_MAX_STK     NUMBER(13, 4),
    PRF_WGT_WEEKS   NUMBER(7),
    USR_CRE         VARCHAR2(20)
);

CREATE GLOBAL TEMPORARY TABLE  EDSR.TEMP_TPCARSEM
(
    RPL_SEQ     NUMBER    not null,
    RPL_SEQ_REG NUMBER    not null,
    WGT_WEEK    NUMBER(7) not null,
    WGT_FACTOR  NUMBER(7, 4),
    USR_CRE     VARCHAR2(20),
    FEC_CRE     DATE
) ON commit preserve rows ;

CREATE GLOBAL TEMPORARY TABLE  EDSR.TEMP_PARAMREPOSEM
(
    PRD_LVL_NUMBER VARCHAR2(15),
    WGT_WEEK NUMBER(7) not null,
    WGT_FACTOR NUMBER(7, 4)
) ON commit preserve rows ;

/*
DROP FUNCTION EDSR.S_OBT_PRODUCTO;
DROP FUNCTION EDSR.S_OBT_SUCURSAL;
DROP FUNCTION EDSR.S_OBT_PERFIL;
*/
CREATE OR REPLACE FUNCTION EDSR.S_OBT_PRODUCTO(PPRD_LVL_NUMBER IN VARCHAR2)
RETURN NUMBER
IS
    PPROD_COUNT  NUMBER := 0;
    V_PRD_LVL_CHILD NUMBER := 0;
BEGIN
     SELECT COUNT(PRD.PRD_LVL_CHILD)
       INTO PPROD_COUNT
       FROM TPPRDMST PRD
      WHERE PRD.PRD_LVL_ID = 1
        AND PRD.PRD_STYLE_IND = 'T'
        AND PRD.PRD_LVL_NUMBER = PPRD_LVL_NUMBER;

     IF PPROD_COUNT = 0 THEN
        SELECT PRD.PRD_LVL_CHILD
          INTO V_PRD_LVL_CHILD
          FROM TPPRDMST PRD
         WHERE PRD.PRD_LVL_ID IN (0,1)
           AND PRD.PRD_STYLE_IND = 'F'
           AND PRD.PRD_LVL_NUMBER = PPRD_LVL_NUMBER;
     END IF;

     RETURN V_PRD_LVL_CHILD;

END;

CREATE OR REPLACE FUNCTION EDSR.S_OBT_SUCURSAL(PORG_LVL_NUMBER IN NUMBER)
RETURN NUMBER
IS
    PPROD_COUNT  NUMBER := 0;
    PORG_LVL_CHILD NUMBER := 0;
BEGIN
     SELECT COUNT(ORG.ORG_LVL_CHILD)
     INTO PPROD_COUNT
     FROM ORGMSTEE ORG
     WHERE ORG.ORG_LVL_ID = 1
       AND ORG.ORG_LVL_NUMBER = PORG_LVL_NUMBER;

     IF PPROD_COUNT > 0 THEN
         SELECT ORG.ORG_LVL_CHILD
           INTO PORG_LVL_CHILD
         FROM ORGMSTEE ORG
         WHERE ORG.ORG_LVL_ID = 1
            AND ORG.ORG_LVL_NUMBER = PORG_LVL_NUMBER;
     END IF;

     RETURN PORG_LVL_CHILD;

END;

CREATE OR REPLACE FUNCTION EDSR.S_OBT_PERFIL(PPRF_DESC IN NCHAR)
RETURN NUMBER
IS
    PPROD_COUNT  NUMBER := 0;
    PPRF_TECH_KEY NUMBER := 0;
BEGIN

     SELECT COUNT(PER.PRF_TECH_KEY)
     INTO PPROD_COUNT
     FROM RPLPFHEE PER
     WHERE TRIM(PER.PRF_DESC) = TRIM(PPRF_DESC)
       AND ROWNUM = 1;

     IF PPROD_COUNT > 0 THEN
       SELECT PER.PRF_TECH_KEY
       INTO PPRF_TECH_KEY
       FROM RPLPFHEE PER
      WHERE TRIM(PER.PRF_DESC) = TRIM(PPRF_DESC)
            AND ROWNUM = 1;
     END IF;

     RETURN PPRF_TECH_KEY;

END;

SELECT S_OBT_PRODUCTO('25403') AS PRD_LVL_CHILD FROM DUAL;
SELECT S_OBT_SUCURSAL(103) AS ORG_LVL_CHILD FROM DUAL;
SELECT S_OBT_PERFIL('PERFIL 1') AS PRD_LVL_CHILD FROM DUAL;



/*
SELECT TABLE_OWNER, TABLE_NAME FROM DBA_SYNONYMS
WHERE SYNONYM_NAME = 'ORGMSTEE';

SELECT PRD_LVL_NUMBER,PRD_LVL_CHILD FROM EDSR.TPPRDMST;

SELECT ORG_LVL_NUMBER,ORG_LVL_CHILD FROM ORGMSTEE;
SELECT ORG.ORG_LVL_CHILD,ORG_LVL_NUMBER FROM ORGMSTEE ORG WHERE ORG.ORG_LVL_ID = 1
*/


SELECT * FROM EDSR.TEMP_PARAMREPOSEM ;
INSERT INTO EDSR.TEMP_PARAMREPOSEM TEMP (WGT_WEEK, WGT_FACTOR)
SELECT ROWNUM,MONTO
    FROM (
        SELECT ID,E_SEM1, E_SEM2, E_SEM3, E_SEM4, E_SEM5 FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE ID = 1
    )
UNPIVOT(
     MONTO FOR SEMANA IN (E_SEM1, E_SEM2, E_SEM3, E_SEM4, E_SEM5)
    );


TRUNCATE TABLE EDSR.TEMP_PARAMREPOSEM;
DROP TABLE EDSR.TEMP_PARAMREPOSEM;
SELECT * FROM  EDSR.TEMP_PARAMREPOSEM ORDER BY PRD_LVL_NUMBER;
SELECT * FROM  EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID;

        -- EDSR.TP_PKG_REPDIN.SP_CARGA_PARAM_REPO(p_secuencia,'SISTEMAS');
        -- ELIMINAR Y LOG
        /*
      INSERT INTO TPCARPARLOG
          (RPL_SEQ,
           RPL_SEQ_REG,
           RPL_METHOD_CODE,
           PRD_LVL_CHILD,
           ORG_LVL_CHILD,
           PRF_TECH_KEY,
           RPL_DIST_METHOD,
           RPL_REVIEW_DAYS,
           RPL_PROC_DAYS,
           RPL_SS,
           PMH_SERV_LVL,
           RPL_MIN_STK,
           RPL_MAX_STK,
           PRF_WGT_WEEKS,
           USR_CRE,
           FEC_CRE,
           USR_MOD,
           FEC_MOD)
       SELECT RPL_SEQ,
                 RPL_SEQ_REG,
                 RPL_METHOD_CODE,
                 PRD_LVL_CHILD,
                 ORG_LVL_CHILD,
                 PRF_TECH_KEY,
                 RPL_DIST_METHOD,
                 RPL_REVIEW_DAYS,
                 RPL_PROC_DAYS,
                 RPL_SS,
                 PMH_SERV_LVL,
                 RPL_MIN_STK,
                 RPL_MAX_STK,
                 PRF_WGT_WEEKS,
                 USR_CRE,
                 FEC_CRE,
                 USR_MOD,
                 FEC_MOD
            FROM TPCARPAR
      WHERE RPL_SEQ = p_secuencia;

      INSERT INTO TPCARSEMLOG
      (RPL_SEQ,
       RPL_SEQ_REG,
       WGT_WEEK,
       WGT_FACTOR,
       USR_CRE,
       FEC_CRE,
       USR_MOD,
       FEC_MOD)
      SELECT RPL_SEQ,
             RPL_SEQ_REG,
             WGT_WEEK,
             WGT_FACTOR,
             USR_CRE,
             FEC_CRE,
             USR_MOD,
             FEC_MOD
      FROM TPCARSEM
      WHERE RPL_SEQ = p_secuencia;

      DELETE FROM TPCARSEM WHERE RPL_SEQ = p_secuencia;
      DELETE FROM TPCARPAR WHERE RPL_SEQ = p_secuencia;
      */


--  ANTES DE LAS 2 CARGAS HUBO 2 CARGAS ENTRE SSCR Y SCRIPT  40 PRODUCTOS
--  1ERA CARGA SCRIPT 23:54AM  10227  PRODUCTOS (OCS)
--  2DA CARGA SCRIPT 23:54AM  4820  PRODUCTOS (RAT)

-- 1ERA CARGA (DESDE 13295 HASTA 33094)

TRUNCATE TABLE EDSR.temp_CargaMasiva_ParametrosPMM;
SELECT * FROM EDSR.temp_CargaMasiva_ParametrosPMM;


SELECT * FROM EDSR.temp_CargaMasiva_ParametrosPMM ORDER BY ID DESC;
