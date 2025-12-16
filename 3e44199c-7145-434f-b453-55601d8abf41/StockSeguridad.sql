-- SELECT * FROM EDSR.vtex_stock_seguridad_config
-- SELECT * FROM EDSR.vtex_stock_actual
-- SELECT * FROM EDSR.temp_vtex_stock_actual

-- Tabla Confiuración
SELECT * FROM EDSR.vtex_stock_seguridad_config;
-- INSERT INTO EDSR.vtex_stock_seguridad_config (COD_CONFIG, DES_CONFIG, VALOR_CONFIG) VALUES ('TDA_TDC_SS','Stock seguridad TDA Area Tendencia - Cantidad', 4);
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

    --PROCEDURE SP_STOCK_SEGURIDAD
    --IS
    DECLARE -- BORRAR ESTA LINEA Y DESCOMENTAR LAS 2 DE ARRIBA PARA EL STOCK_SEGURIDAD PRODUCCION
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
                  -- T4.PRD_LVL_NUMBER AS ES_ELECTROLUX,
                   MAX(PRC.PRC_PRICE) AS PRICE
            FROM EDSR.VTEX_STOCK_ACTUAL T
                LEFT JOIN EDSR.orgmstee T1 ON T1.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND T1.org_lvl_id = 1 AND T1.ORG_IS_STORE = 'F'
                LEFT JOIN EDSR.orgmstee T2 ON T2.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND T2.org_lvl_id = 1 AND T2.ORG_IS_STORE = 'T'
               -- LEFT JOIN EDSR.tpprdmst T4 ON T4.prd_lvl_number = T.PRD_LVL_NUMBER AND T4.COD_AREA = 'A22' AND T4.COD_MARCA = 'ELECTROLUX'
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
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PRUEBAS
SELECT * FROM EDSR.vtex_stock_actual;
-- TRUNCATE TABLE EDSR.vtex_stock_actual;
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES  ('101', '14923', 0);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '14924', 2);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '14925', 4);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '14926', 5);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('851', '14925', 2);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('851', '14928', 1);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('851', '14929', 1);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('851', '14930', 0);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '11195', 5);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '11194', 4);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '11193', 3);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '11192', 2);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '10135', 1);
-- MARCA INDURAMA
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '10145', 3);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '21587', 3);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '21588', 3);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '21589', 3);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '21590', 3);
-- MARCA ELECTROLUX
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '19732', 5);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '19738', 5);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '26582', 5);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '19735', 5);
INSERT INTO EDSR.vtex_stock_actual (ORG_LVL_NUMBER, PRD_LVL_NUMBER, CANTIDAD)
VALUES ('101', '19733', 5);
COMMIT;
SELECT * FROM EDSR.vtex_stock_actual;

SELECT * FROM EDSR.temp_vtex_stock_actual ORDER BY ORG_LVL_NUMBER, PRD_LVL_NUMBER;

SELECT * FROM VTEX_STOCK_ACTUAL;
-- PKG_VTEX_INTEGRACION_STOCK
SELECT GREATEST(2,0) FROM DUAL;

DECLARE
  CURSOR CUR_StockActual IS
    SELECT * FROM VTEX_STOCK_ACTUAL;

BEGIN

  FOR v_registro IN CUR_StockActual
  LOOP
        DBMS_OUTPUT.PUT_LINE(v_registro.CANTIDAD);
  END LOOP;

END;

SELECT * FROM VTEX_STOCK_ACTUAL;
SELECT * FROM EDSR.temp_vtex_stock_actual;

SELECT * FROM EDSR.vtex_stock_actual where prd_lvl_number in (24804);
SELECT * FROM EDSR.vtex_stock_anterior where prd_lvl_number in (24804);
SELECT * FROM EDSR.vtex_stock_diff where prd_lvl_number in (24804);

/*
1.- Todos los centros de distribución contarán con stock de seguridad de 1 unidad
2.- Todas las tiendas contarán con stock de seguridad de 4 unidades
3.- Todo sku de tienda que pertenezca al área de tendencias contará con 4 unidades de stock de seguridad
4.- Todo sku que se encuentre en el estado long tail no contará con stock de seguridad, es decir 0 unidades

-- Nuevas reglas
1.- Todos los centros de distribución contarán con stock de seguridad de 1 unidad.
2.- Los productos de cualquier área que tengan un precio con iva superior a usd 450 contarán con stock de seguridad de 1 unidad.
3.- La tienda contará con stock de seguridad de 3 unidades excepto en los productos que tengan precio con iva superior a usd 450 que tienen su propia regla.
4.- Todo sku de tienda que pertenezca al área tendencias contará con 2 unidades de stock de seguridad.
5.- Todo sku que se encuentre en estado “long tail” no contará con stock de seguridad, es decir 0 unidades.

Nuevas reglas
18/01/2024
1.- Todos los centros de distribución contarán con stock de seguridad de 1 unidad.
2.- Los productos de cualquier área que tengan un precio con iva superior a usd 450 contarán con stock de seguridad de 1 unidad.
3.- La tienda contará con stock de seguridad de 2 unidades excepto en los productos que tengan precio con iva superior a usd 450 que tienen su propia regla.
4.- Todo sku que se encuentre en estado “long tail” no contará con stock de seguridad, es decir 0 unidades.

13/03/2024
5.- Los productos del area ELECTROHOGAR en los que estan los productos ELECTROHOGAR  no debe aplicarse NINGUNA regla de SEGURIDAD

03/04/2024
6.- Los productos del area ELECTROHOGAR de marca ELECTROLUX no debe aplicarse NINGUNA regla de SEGURIDAD
*/

-- Aplicación de nuevas reglas: 18/01/2024
SELECT * FROM EDSR.vtex_stock_actual;
SELECT * FROM EDSR.CHLPRCE2;
SELECT * FROM EDSR.vtex_stock_seguridad_config;

-- REGLA 2
INSERT INTO EDSR.VTEX_STOCK_SEGURIDAD_CONFIG (COD_CONFIG, DES_CONFIG, VALOR_CONFIG)
VALUES ('TDA_01_SS', 'Stock seguridad TDA PrecioFinal superior 450', '1');

INSERT INTO EDSR.VTEX_STOCK_SEGURIDAD_CONFIG (COD_CONFIG, DES_CONFIG, VALOR_CONFIG)
VALUES ('PRD_PRC_01', 'Producto con Precio superior a 450 USD', '450');

UPDATE EDSR.VTEX_STOCK_SEGURIDAD_CONFIG SET COD_CONFIG = 'TDA_01_SS' WHERE COD_CONFIG = 'TDA_450_SS';
COMMIT;

-- REGLA 3
UPDATE EDSR.vtex_stock_seguridad_config
    SET VALOR_CONFIG = 2
WHERE COD_CONFIG = 'TDA_SS';
COMMIT;

-- REGLA 5
select PRD.COD_AREA,PRD.COD_MARCA, PRD.COD_DIV, PRD.* from edsr.tpprdmst PRD where PRD.prd_lvl_number  IN ('21563', '24377', '24378','21551','21595','21568','21553');
select PRD.COD_AREA,PRD.COD_MARCA, PRD.* from edsr.tpprdmst PRD where PRD.COD_AREA = 'A22' AND PRD.COD_MARCA = 'INDURAMA';

-- REGLA 6
select PRD.COD_AREA,PRD.COD_MARCA, PRD.COD_DIV, PRD.* from edsr.tpprdmst PRD where PRD.prd_lvl_number  IN ('19731', '26586', '30518','32931','32929','19727','19726');
select PRD.COD_AREA,PRD.COD_MARCA, PRD.* from edsr.tpprdmst PRD where PRD.COD_AREA = 'A22' AND PRD.COD_MARCA = 'ELECTROLUX';

INSERT INTO EDSR.VTEX_STOCK_SEGURIDAD_CONFIG (COD_CONFIG, DES_CONFIG, VALOR_CONFIG)
VALUES ('PRD_MARC_1', 'Producto de Marca Indurama del area ELECTRO HOGAR', '0');

DECLARE
    V_NUM NUMBER;
    V_CHAR VARCHAR2(10);
BEGIN
    SELECT 10 INTO V_NUM FROM DUAL;
    SELECT '5' INTO V_CHAR FROM DUAL;

    BEGIN
        DBMS_OUTPUT.PUT_LINE('RESULT: ' || V_NUM - V_CHAR);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('>> EXCEPTION: ' || sqlerrm);
    END;
END;

SELECT * FROM EDSR.VTEX_STOCK_ACTUAL;
SELECT * FROM EDSR.TPPRDMST;
SELECT * FROM EDSR.ORGMSTEE;

--SELECT STOCK.ORG_LVL_NUMBER,STOCK.PRD_LVL_NUMBER,PRC.PRC_PRICE
SELECT STOCK.PRD_LVL_NUMBER, MAX(PRC.PRC_PRICE) PRICE
FROM EDSR.VTEX_STOCK_ACTUAL STOCK
    INNER JOIN EDSR.TPPRDMST MST ON STOCK.PRD_LVL_NUMBER = MST.PRD_LVL_NUMBER
    --INNER JOIN EDSR.ORGMSTEE ORG ON STOCK.PRD_LVL_NUMBER = ORG.ORG_LVL_NUMBER
    INNER JOIN EDSR.CHLPRCE2 PRC ON PRC.PRD_LVL_CHILD = MST.PRD_LVL_CHILD AND PRC.ORG_LVL_NUMBER = STOCK.ORG_LVL_NUMBER
GROUP BY STOCK.PRD_LVL_NUMBER;


SELECT * FROM EDSR.vtex_stock_actual
--UPDATE EDSR.vtex_stock_actual SET CANTIDAD = 0
WHERE ORG_LVL_NUMBER = '101' AND PRD_LVL_NUMBER = '24804';

SELECT * FROM EDSR.vtex_stock_actual;

SELECT * FROM edsr.orgmstee where org_lvl_id = 1;

-- Tabla Confiuración
SELECT * FROM EDSR.vtex_stock_seguridad_config;
-- INSERT INTO EDSR.vtex_stock_seguridad_config (COD_CONFIG, DES_CONFIG, VALOR_CONFIG) VALUES ('TDA_TDC_SS','Stock seguridad TDA Area Tendencia - Cantidad', 4);

-- ANTES
SELECT * FROM EDSR.temp_vtex_stock_actual;


-- edsr.PKG_VTEX_INTEGRACION_STOCK

--AHORA
SELECT * FROM EDSR.temp_vtex_stock_actual;

 --(1) CentroDistribucion
select * from edsr.orgmstee where org_lvl_id = 1 AND ORG_IS_STORE = 'F';

 --(2) Tiendas
select * from edsr.orgmstee where org_lvl_id = 1 AND ORG_IS_STORE = 'T';

 --(3) SKU de TENDENCIAS
select * from edsr.tpprdmst where cod_area = 'A05';


select DISTINCT PRD.COD_AREA,PRD.DES_AREA from edsr.tpprdmst PRD WHERE PRD.COD_AREA = 'A22' ORDER BY PRD.COD_AREA;

select * from edsr.tpprdmst where prd_lvl_number = '14928' and cod_area = 'A05';
select * from edsr.tpprdmst where prd_lvl_number = '14929' and cod_area = 'A05';

-- STOCK_SEGURIDAD
select * from edsr.vtex_stock_seguridad_config;

-- SKUs AREA TENDENCIAS
select * from edsr.tpprdmst where cod_area = 'A05';

-- AREA TENDENCIAS
select * from edsr.prdmstee where prd_lvl_number = 'A05';

-- ESTADO Long Tail
select * from edsr.prdstsee where prd_status = 6;


DROP TABLE EDSR.temp_vtex_stock_actual;
CREATE GLOBAL TEMPORARY TABLE EDSR.temp_vtex_stock_actual
(
    ORG_LVL_NUMBER VARCHAR2(15)        ,
    PRD_LVL_NUMBER VARCHAR2(15)         ,
    CANTIDAD       NUMBER(7)            ,
    DOWNLOAD_DATE  DATE default sysdate
) ON COMMIT PRESERVE ROWS ;



SELECT T.ORG_LVL_NUMBER, T.PRD_LVL_NUMBER, T.CANTIDAD,
               T1.ORG_IS_STORE AS ES_CD,
               T2.ORG_IS_STORE AS ES_TIENDA,
              -- T3.PRD_LVL_CHILD AS ES_TENDENCIA,
               MAX(PRC.PRC_PRICE) AS PRICE
        FROM EDSR.temp_vtex_stock_actual T
            LEFT JOIN EDSR.orgmstee T1 ON T1.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND T1.org_lvl_id = 1 AND T1.ORG_IS_STORE = 'F'
            LEFT JOIN EDSR.orgmstee T2 ON T2.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND T2.org_lvl_id = 1 AND T2.ORG_IS_STORE = 'T'
           -- LEFT JOIN EDSR.tpprdmst T3 ON T3.prd_lvl_number = T.PRD_LVL_NUMBER AND T3.cod_area = 'A05'
            LEFT JOIN EDSR.TPPRDMST PRD ON PRD.prd_lvl_number = T.PRD_LVL_NUMBER
            LEFT JOIN EDSR.CHLPRCE2 PRC ON PRC.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND PRC.PRD_LVL_CHILD = PRD.PRD_LVL_CHILD
        GROUP BY T.ORG_LVL_NUMBER, T.PRD_LVL_NUMBER, T.CANTIDAD,T1.ORG_IS_STORE,T2.ORG_IS_STORE --,T3.PRD_LVL_CHILD
ORDER BY ORG_LVL_NUMBER, PRD_LVL_NUMBER;



CREATE INDEX idx_temp_vtex_stock_actual
ON temp_vtex_stock_actual(ORG_LVL_NUMBER, PRD_LVL_NUMBER);

DROP INDEX idx_temp_vtex_stock_actual;

--Actual
SELECT * FROM EDSR.vtex_stock_actual ;
--Anterior
SELECT * FROM EDSR.vtex_stock_anterior;
--Diferencia
SELECT * FROM EDSR.vtex_stock_diff;


-- 22/03/2024  PROBAR PASE DE PRODUCCION OK

DECLARE
        V_CD                EDSR.vtex_stock_seguridad_config.VALOR_CONFIG%TYPE;
        V_TDA               EDSR.vtex_stock_seguridad_config.VALOR_CONFIG%TYPE;
        V_TDA_01_SS         EDSR.vtex_stock_seguridad_config.VALOR_CONFIG%TYPE;
        V_PRD_PRC_01        EDSR.vtex_stock_seguridad_config.VALOR_CONFIG%TYPE;
        V_PRD_MARC_1        EDSR.vtex_stock_seguridad_config.VALOR_CONFIG%TYPE;
    BEGIN

        BEGIN
            SELECT VALOR_CONFIG
            INTO V_PRD_MARC_1
            FROM EDSR.vtex_stock_seguridad_config WHERE COD_CONFIG = 'PRD_MARC_1';

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

        MERGE INTO EDSR.temp_vtex_stock_actual T
        USING (
            SELECT T.ORG_LVL_NUMBER,
                   T.PRD_LVL_NUMBER,
                   T.CANTIDAD,
                   T1.ORG_IS_STORE AS ES_CD,
                   T2.ORG_IS_STORE AS ES_TIENDA,
                   T4.PRD_LVL_NUMBER AS ES_INDURAMA,
                   MAX(PRC.PRC_PRICE) AS PRICE
            FROM EDSR.temp_vtex_stock_actual T
                LEFT JOIN EDSR.orgmstee T1 ON T1.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND T1.org_lvl_id = 1 AND T1.ORG_IS_STORE = 'F'
                LEFT JOIN EDSR.orgmstee T2 ON T2.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND T2.org_lvl_id = 1 AND T2.ORG_IS_STORE = 'T'
                LEFT JOIN EDSR.tpprdmst T4 ON T4.prd_lvl_number = T.PRD_LVL_NUMBER AND T4.COD_AREA = 'A22' AND T4.COD_MARCA = 'INDURAMA'
                LEFT JOIN EDSR.TPPRDMST PRD ON PRD.prd_lvl_number = T.PRD_LVL_NUMBER
                LEFT JOIN EDSR.CHLPRCE2 PRC ON PRC.ORG_LVL_NUMBER = T.ORG_LVL_NUMBER AND PRC.PRD_LVL_CHILD = PRD.PRD_LVL_CHILD
            GROUP BY T.ORG_LVL_NUMBER, T.PRD_LVL_NUMBER, T.CANTIDAD,T1.ORG_IS_STORE,T2.ORG_IS_STORE,T4.PRD_LVL_NUMBER
        ) SRC
        ON (T.ORG_LVL_NUMBER = SRC.ORG_LVL_NUMBER AND T.PRD_LVL_NUMBER = SRC.PRD_LVL_NUMBER )
        WHEN MATCHED THEN UPDATE
            SET T.CANTIDAD = GREATEST(
                CASE
                    WHEN SRC.ES_INDURAMA IS NOT NULL THEN
                        T.CANTIDAD - V_PRD_MARC_1
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