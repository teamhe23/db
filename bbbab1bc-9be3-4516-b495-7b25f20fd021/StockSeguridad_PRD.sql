--EDSR.PKG_VTEX_INTEGRACION_STOCK.SP_PROC_STOCK_PRINCIPAL SP_STOCK_SEGURIDAD

   /*
      1.- Todos los centros de distribución contarán con stock de seguridad de 1 unidad.
      2.- Los productos de cualquier área que tengan un precio con iva superior a usd 450 contarán con stock de seguridad de 1 unidad.
      3.- La tienda contará con stock de seguridad de 2 unidades excepto en los productos que tengan precio con iva superior a usd 450 que tienen su propia regla.
      4.- Todo sku que se encuentre en estado ¿long tail¿ no contará con stock de seguridad, es decir 0 unidades.

      13/03/2024
      5.- Los productos del area ELECTROHOGAR de marca INDURAMA no debe aplicarse NINGUNA regla de SEGURIDAD

      02/04/2024
      Se esta comentando la regla:
            WHEN SRC.ES_INDURAMA IS NOT NULL THEN T.CANTIDAD - V_PRD_MARC_1

      03/04/2024
      6.- Los productos del area ELECTROHOGAR de marca ELECTROLUX no debe aplicarse NINGUNA regla de SEGURIDAD

      10/04/2024 11:59pm
      Se esta comentando la regla:
            WHEN SRC.ES_INDURAMA IS NOT NULL THEN T.CANTIDAD - V_PRD_MARC_1

    */

    PROCEDURE SP_STOCK_SEGURIDAD
    IS
        V_CD                EDSR.vtex_stock_seguridad_config.VALOR_CONFIG%TYPE;
        V_TDA               EDSR.vtex_stock_seguridad_config.VALOR_CONFIG%TYPE;
        V_TDA_01_SS         EDSR.vtex_stock_seguridad_config.VALOR_CONFIG%TYPE;
        V_PRD_PRC_01        EDSR.vtex_stock_seguridad_config.VALOR_CONFIG%TYPE;
        --V_PRD_MARC_1        EDSR.vtex_stock_seguridad_config.VALOR_CONFIG%TYPE;
    BEGIN

        BEGIN
            /*
            SELECT VALOR_CONFIG
            INTO V_PRD_MARC_1
            FROM EDSR.vtex_stock_seguridad_config WHERE COD_CONFIG = 'PRD_MARC_1';
             */

            SELECT VALOR_CONFIG
            INTO V_CD
            FROM EDSR.vtex_stock_seguridad_config WHERE COD_CONFIG = 'CD_SS';

            SELECT VALOR_CONFIG
            INTO V_TDA
            FROM EDSR.vtex_stock_seguridad_config WHERE COD_CONFIG = 'TDA_SS';

            SELECT VALOR_CONFIG
            INTO V_TDA_01_SS
            FROM EDSR.vtex_stock_seguridad_config WHERE COD_CONFIG = 'TDA_01_SS';

            SELECT VALOR_CONFIG
            INTO V_PRD_PRC_01
            FROM EDSR.vtex_stock_seguridad_config WHERE COD_CONFIG = 'PRD_PRC_01';

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Tabla EDSR.vtex_stock_seguridad_config NO CONFIGURADA');

            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(SQLERRM);

        END;

        MERGE INTO EDSR.VTEX_STOCK_ACTUAL T
        USING (
            SELECT T.ORG_LVL_NUMBER,
                   T.PRD_LVL_NUMBER,
                   T.CANTIDAD,
                   T1.ORG_IS_STORE AS ES_CD,
                   T2.ORG_IS_STORE AS ES_TIENDA,
                   --T4.PRD_LVL_NUMBER AS ES_ELECTROLUX,
                   MAX(PRC.PRC_PRICE) AS PRICE
            FROM EDSR.VTEX_STOCK_ACTUAL T
                LEFT JOIN EDSR.orgmstee T1 ON T1.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND T1.org_lvl_id = 1 AND T1.ORG_IS_STORE = 'F'
                LEFT JOIN EDSR.orgmstee T2 ON T2.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND T2.org_lvl_id = 1 AND T2.ORG_IS_STORE = 'T'
                --LEFT JOIN EDSR.tpprdmst T4 ON T4.prd_lvl_number = T.PRD_LVL_NUMBER AND T4.COD_AREA = 'A22' AND T4.COD_MARCA = 'ELECTROLUX'
                LEFT JOIN EDSR.TPPRDMST PRD ON PRD.prd_lvl_number = T.PRD_LVL_NUMBER
                LEFT JOIN EDSR.CHLPRCE2 PRC ON PRC.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND PRC.PRD_LVL_CHILD = PRD.PRD_LVL_CHILD
            GROUP BY T.ORG_LVL_NUMBER, T.PRD_LVL_NUMBER, T.CANTIDAD,T1.ORG_IS_STORE,T2.ORG_IS_STORE
            /*,T4.PRD_LVL_NUMBER*/
        ) SRC
        ON (T.ORG_LVL_NUMBER = SRC.ORG_LVL_NUMBER AND T.PRD_LVL_NUMBER = SRC.PRD_LVL_NUMBER )
        WHEN MATCHED THEN UPDATE
            SET T.CANTIDAD = GREATEST(
                CASE
                    /*WHEN SRC.ES_ELECTROLUX IS NOT NULL THEN
                        T.CANTIDAD - V_PRD_MARC_1*/
                    WHEN SRC.ES_CD IS NOT NULL THEN
                        T.CANTIDAD - V_CD
                    WHEN SRC.ES_TIENDA IS NOT NULL THEN
                        CASE WHEN SRC.PRICE <= V_PRD_PRC_01  THEN
                            T.CANTIDAD - V_TDA
                        ELSE
                            T.CANTIDAD - V_TDA_01_SS
                        END
                ELSE
                    T.CANTIDAD
                END, 0 );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
            ROLLBACK;
    END;



-- consultas

--Actual
SELECT * FROM EDSR.vtex_stock_actual   WHERE PRD_LVL_NUMBER = '10128';
--Anterior
SELECT * FROM EDSR.vtex_stock_anterior  WHERE PRD_LVL_NUMBER = '10128';
--Diferencia
SELECT * FROM EDSR.vtex_stock_diff WHERE PRD_LVL_NUMBER = '10128';

--VTEX
-- Se ejecuta cada 5 minutos
SELECT * FROM edsr.VTEX_STOCK_CAB WHERE session_id = '25599'; -- 4457
SELECT * FROM edsr.VTEX_STOCK_CAB WHERE session_id = '25600'; -- 4

-- STOCK PMM
SELECT * FROM edsr.INVBALEE WHERE PRD_LVL_CHILD = 100129; -- 4
SELECT * FROM edsr.INVTYPEE; -- 4

-- AREAS
select prd.cod_area, prd.* from edsr.tpprdmst prd where PRD_LVL_NUMBER IN ('12810','12807','12818','12817','24378','16781','16792','32636') -- cod_area = 'A05';

SELECT * FROM edsr.INVBALEE WHERE PRD_LVL_CHILD = 114809; -- 4
SELECT * FROM edsr.TPPRDMST WHERE PRD_LVL_NUMBER = '10128'; -- 4
SELECT * FROM edsr.TPPRDMST WHERE PRD_LVL_NUMBER = '25599'; -- 4



SELECT T.ORG_LVL_NUMBER,
       T.PRD_LVL_NUMBER,
       ROUND(INV.ON_HAND_QTY) AS CANTIDAD_PMM,
       T.CANTIDAD AS CANTIDAD_ACTUAL,
       ROUND(INV.ON_HAND_QTY - T.CANTIDAD) AS DIFF,
       T1.ORG_IS_STORE AS ES_CD,
       T2.ORG_IS_STORE AS ES_TIENDA,
       MAX(PRC.PRC_PRICE) AS PRICE
FROM EDSR.VTEX_STOCK_ACTUAL T
    INNER JOIN EDSR.TPPRDMST PRD ON PRD.prd_lvl_number = T.PRD_LVL_NUMBER
    INNER JOIN EDSR.ORGMSTEE ORG ON ORG.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER
    LEFT JOIN EDSR.orgmstee T1 ON T1.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND T1.org_lvl_id = 1 AND T1.ORG_IS_STORE = 'F'
    LEFT JOIN EDSR.orgmstee T2 ON T2.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND T2.org_lvl_id = 1 AND T2.ORG_IS_STORE = 'T'
    LEFT JOIN EDSR.INVBALEE INV ON INV.PRD_LVL_CHILD = PRD.PRD_LVL_CHILD AND INV.ORG_LVL_CHILD = ORG.ORG_LVL_CHILD
    LEFT JOIN EDSR.CHLPRCE2 PRC ON PRC.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND PRC.PRD_LVL_CHILD = PRD.PRD_LVL_CHILD
WHERE T.PRD_LVL_NUMBER = '10128' AND INV.INV_TYPE_CODE = '01'
GROUP BY T.ORG_LVL_NUMBER, T.PRD_LVL_NUMBER, T.CANTIDAD,T1.ORG_IS_STORE,T2.ORG_IS_STORE,INV.ON_HAND_QTY;

