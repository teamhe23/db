SELECT * FROM ORGMSTEE;
BEGIN
    IF LENGTHB('nombRe') > 5 THEN
        DBMS_OUTPUT.PUT_LINE('La longitud en bytes es mayor que 5');
    ELSE
        DBMS_OUTPUT.PUT_LINE('La longitud en bytes es 5 o menos');
    END IF;
END;


------------------------------------------------------------------------------------------------------------
-- (1) MASIVO: Así se actualiza el STOCK (EDSR.HP_PKG_DAD_STOCK.sp_procesar_masivo)
------------------------------------------------------------------------------------------------------------
MERGE INTO HP_DAD_STOCK_MAESTRO SM
USING (SELECT PRD_LVL_CHILD,QTY
       FROM HP_B2B_VEV_S
      WHERE STS = 'Activo') VEV
ON (VEV.PRD_LVL_CHILD = SM.PRD_LVL_CHILD AND SM.ORG_LVL_CHILD IS NULL)
WHEN MATCHED THEN
UPDATE
   SET SM.CANTIDAD = DECODE(SM.FLAG_SERV,'T',999999,VEV.QTY);

------------------------------------------------------------------------------------------------------------
-- (2)  MASIVO: Alimentacion tabla HE_DAD_VEV_STOCK_ACTUAL desde HP_DAD_STOCK_MAESTRO (EDSR.HP_PKG_DAD_STOCK.sp_procesar_masivo (actualizar_stock_incremental))
------------------------------------------------------------------------------------------------------------

begin
    execute immediate 'TRUNCATE TABLE HE_DAD_VEV_STOCK_ACTUAL';
end;
delete HE_DAD_VEV_STOCK_ACTUAL;
insert into HE_DAD_VEV_STOCK_ACTUAL
        (org_lvl_child,
         org_lvl_number,
         prd_lvl_child,
         prd_lvl_number,
         org_is_store,
         cod_bigtck,
         flag_serv,
         cantidad)
select org_lvl_child,
       org_lvl_number,
       prd_lvl_child,
       prd_lvl_number,
       org_is_store,
       cod_bigtck,
       flag_serv,
       cantidad
 from hp_dad_stock_maestro
 WHERE ORG_LVL_CHILD is null;

------------------------------------------------------------------------------------------------------------
--(3) INCREMENTAL: Actualizar los stocks de la tabla (EDSR.HP_PKG_DAD_STOCK.sp_procesar_dif_stock_inc)
------------------------------------------------------------------------------------------------------------
/*
  21555 =>  1000  1500
  21575 => 	30    150
  21573 => 	30    0         60
  21578 => 	60    186
  21576 => 	40    39
 */
SELECT * FROM HP_B2B_VEV_S;
SELECT STOCK.PRD_LVL_NUMBER AS SKU,
       STOCK.FLG_DIFERENCIA AS DIF,
       STOCK.CANTIDAD_ANT AS ANT,
       STOCK.OPERATION,
       STOCK.DIFERENCIA AS DIF,
       STOCK.CANTIDAD AS CANT,
       VEV.QTY as VEV,
       STOCK.*
FROM HE_DAD_VEV_STOCK_ACTUAL STOCK
    INNER JOIN HP_B2B_VEV_S VEV ON (STOCK.PRD_LVL_CHILD = VEV.PRD_LVL_CHILD
    AND STOCK.ORG_LVL_NUMBER = VEV.COD_PRV)
ORDER BY STOCK.FLG_DIFERENCIA DESC;

MERGE INTO EDSR.HE_DAD_VEV_STOCK_ACTUAL STOCK
USING EDSR.HP_B2B_VEV_S VEV
ON (STOCK.PRD_LVL_CHILD = VEV.PRD_LVL_CHILD
    AND STOCK.ORG_LVL_NUMBER = VEV.COD_PRV)
WHEN MATCHED THEN
    UPDATE SET
        STOCK.DIFERENCIA = ABS(NVL(STOCK.CANTIDAD, 0) - NVL(VEV.QTY, 0)),
        STOCK.CANTIDAD = NVL(VEV.QTY, 0),
        STOCK.CANTIDAD_ANT = NVL(STOCK.CANTIDAD, 0),
        STOCK.OPERATION = CASE
                            WHEN NVL(VEV.QTY, 0) > NVL(STOCK.CANTIDAD, 0) THEN 'ADD'
                            WHEN NVL(VEV.QTY, 0) < NVL(STOCK.CANTIDAD, 0) THEN 'SUBTRACT'
                            ELSE STOCK.OPERATION -- Si no ha habido cambio, mantener el valor original de OPERATION
                          END,
        STOCK.FLG_DIFERENCIA = 'T'
    WHERE STOCK.CANTIDAD <> VEV.QTY
;

------------------------------------------------------------------------------------------------------------
--(4) INCREMENTAL: Enviar al CURSOR para que la API DaD lo envie (EDSR.HP_PKG_DAD_STOCK.sp_leer_dif_stock_inc)
------------------------------------------------------------------------------------------------------------
SELECT 'HESA' || '-' || org_lvl_number as entityCode,
    OPERATION as operationType,
    DIFERENCIA as quantity,
    PRD_LVL_NUMBER as skuCode,
    ORG_LVL_NUMBER
FROM HE_DAD_VEV_STOCK_ACTUAL
WHERE FLG_DIFERENCIA = 'T'
    AND FLG_PROCESADO = 'F'
;

------------------------------------------------------------------------------------------------------------
--(5) INCREMENTAL: Actualizar FLG a 'T' que indica que se envio correctamente al DaD (EDSR.HP_PKG_DAD_STOCK.sp_marcar_dif_stock_inc)
------------------------------------------------------------------------------------------------------------
BEGIN
	IF LENGTHB('851') > 5 THEN
        /*update HE_DAD_VEV_STOCK_ACTUAL
	       set FLG_PROCESADO = 'T', DOWNLOAD_DATE = sysdate
	    where PRD_LVL_NUMBER = 'p_sku'
	       and org_lvl_number = 'p_suc';*/
	    DBMS_OUTPUT.PUT_LINE('VEV');
    ELSE
       /* update HP_DAD_STOCK_DIFF
	       set FLG_PROCESADO = 'T'
	    where PRD_LVL_NUMBER = 'p_sku'
	       and org_lvl_number = 'p_suc';*/
	     DBMS_OUTPUT.PUT_LINE('REGULARES');
    END IF;
  end;

--VALIDACIONES
SELECT * FROM HPB2BINV;
SELECT * FROM HP_B2B_VEV_S;
SELECT * FROM HE_DAD_VEV_STOCK_ACTUAL;

/*
    DDL: Creacion tabla exclusiva de STOCK VEV para INCREMENTAL
*/

DROP TABLE HE_DAD_VEV_STOCK_ACTUAL;

CREATE TABLE EDSR.HE_DAD_VEV_STOCK_ACTUAL (
    ORG_LVL_CHILD NUMBER(12,0),
    ORG_LVL_NUMBER VARCHAR2(15),
    PRD_LVL_CHILD NUMBER(12,0)  NOT NULL,
    PRD_LVL_NUMBER VARCHAR2(15),
    ORG_IS_STORE CHAR(1),
    COD_BIGTCK VARCHAR2(10),
    FLAG_SERV VARCHAR2(1),
    CANTIDAD NUMBER(11,4),
    CANTIDAD_ANT NUMBER,
    DIFERENCIA NUMBER,
	FLG_DIFERENCIA CHAR(1) DEFAULT 'F', --T o F
	OPERATION VARCHAR2(10),
    DOWNLOAD_DATE DATE DEFAULT null,
    FLG_PROCESADO CHAR(1) DEFAULT 'F'
);