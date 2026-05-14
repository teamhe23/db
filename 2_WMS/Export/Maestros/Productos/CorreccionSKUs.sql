SELECT ROWID,FLG_ERROR, item.* FROM EDSR.WMS_ITEM_ENVIO item WHERE PRD_LVL_CHILD = 100869 ORDER BY FEC_REG  DESC;

--************************************************************************************************************************
--1. REIMPULSO (EDSR.PKG_WMS_MAESTROS.SP_REIMPULSAR_ITEM)
--************************************************************************************************************************
SELECT COUNT(1) FROM EDSR.WMS_ITEM_ENVIO item WHERE item.FLG_ERROR = '1' AND TRAN_TYPE = 'A';
SELECT COUNT(1) FROM EDSR.WMS_ITEM_ENVIO item WHERE FEC_PROCESADO IS NULL;
SELECT * FROM EDSR.WMS_ITEM_ENVIO wie WHERE wie.PRD_LVL_CHILD IN (114093,115217,107578,115285,115568,107561,115216,107406,107403,106940,121697,121765,121767,121771,121709)
;

SELECT
	--item.ROWID, item.PRD_LVL_CHILD, FEC_REG, TRAN_TYPE
	--item.rowid, item.*
	item.ROWID, prd_lvl_child, fec_reg, fec_procesado, id_wms,MENSAJE
 	--count(1)
FROM EDSR.WMS_ITEM_ENVIO item 
--UPDATE EDSR.WMS_ITEM_ENVIO SET FLG_ERROR = '0'
WHERE FLG_ERROR = '1'
	AND TRAN_TYPE = 'A' 
	AND MENSAJE = '{"success":false,"response":{"message":"Error loading stage data. "}}'
	AND ID_WMS IS NOT NULL
	AND FEC_REG >= TO_DATE('2026-01-01', 'YYYY-MM-DD')
	--AND FEC_REG >= TO_DATE('2025-01-01', 'YYYY-MM-DD')
ORDER BY FEC_REG
;

--EDSR.PKG_WMS_MAESTROS.SP_REIMPULSAR_ITEM
UPDATE EDSR.WMS_ITEM_ENVIO SET FEC_PROCESADO = NULL
WHERE FLG_ERROR = '1' 
	AND TRAN_TYPE = 'A'
	AND MENSAJE = '{"success":false,"response":{"message":"Error loading stage data. "}}'
;

--************************************************************************************************************************
--2. LISTAR ERRORES PARA CORRECCIÓN DE SKU AUTOMATICO: A:CREATE | C:UPDATE (EDSR.PKG_WMS_MAESTROS.SP_CORRECCION_ITEM)
--************************************************************************************************************************
SELECT * FROM EDSR.WMS_ITEM_ENVIO WHERE PRD_LVL_CHILD IN (128643,122871,126401); -- 34164	40377	37886

SELECT ROWID, item.* FROM EDSR.WMS_ITEM_ENVIO item
WHERE TRAN_TYPE = 'C'
	AND PRD_LVL_CHILD IN (	SELECT DISTINCT PRD_LVL_CHILD
							FROM EDSR.WMS_ITEM_ENVIO 
							WHERE FEC_PROCESADO IS NOT NULL
							AND FLG_ERROR = '1'
							AND MENSAJE = '{"success":false,"response":{"message":"Error loading stage data. "}}'
							AND TRAN_TYPE = 'A'
							AND prd_lvl_child IN (SELECT DISTINCT prd_lvl_child FROM EDSR.WMS_ITEM_ENVIO WHERE TRAN_TYPE = 'C')
						)
ORDER BY FEC_REG DESC
--FETCH FIRST 1 ROWS ONLY
;

--************************************************************************************************************************
--3. REPORTE DE SKUS PARA ATENCION DEL USUARIO (EDSR.PKG_WMS_MAESTROS.SP_LISTAR_ITEM_ERROR)
--************************************************************************************************************************
--(34164,40377,37886,38557,36439,35915)
SELECT 
	--wms.*
	 distinct prd.prd_lvl_number
	/*
	wms.FEC_REG, wms.prd_lvl_child,
    prd.prd_lvl_number AS SKU,
    cp.vpc_case_len AS unit_length,
    cp.vpc_case_width AS unit_width,
    cp.vpc_case_height AS unit_height,
    cp.vpc_case_gross_wgt AS unit_weight
    */
FROM EDSR.wms_item_envio wms
INNER JOIN tpprdmst prd 
    ON prd.prd_lvl_child = wms.prd_lvl_child 
AND wms.FLG_ERROR = '1' 
AND wms.TRAN_TYPE = 'A' 
AND wms.MENSAJE = '{"success":false,"response":{"message":"Error loading stage data. "}}'
INNER JOIN prdupcee upc 
    ON upc.prd_lvl_child = prd.prd_lvl_child 
   AND upc.prd_primary_flag = 'T'
   AND NVL(upc.prd_upc, 0) > 0
LEFT JOIN vpcprdee cp 
    ON cp.vpc_prd_tech_key = prd.vpc_prd_tech_key
LEFT JOIN whsprdee whs 
    ON whs.org_lvl_child = '420'
   AND whs.prd_lvl_child = prd.prd_lvl_child
WHERE cp.vpc_case_len IS NULL
   OR cp.vpc_case_width IS NULL
   OR cp.vpc_case_height IS NULL
   OR cp.vpc_case_gross_wgt IS NULL
--ORDER BY wms.FEC_REG DESC
;

--QUERY CORRECTOR:
UPDATE EDSR.WMS_ITEM_ENVIO t
SET TRAN_TYPE = 'A',
    TEXT_RESQUEST = REPLACE(TEXT_RESQUEST, 'UPDATE', 'CREATE'),
    JSON_RESPONSE = NULL,
    FEC_PROCESADO = null
WHERE ROWID IN (
    SELECT rid
    FROM (
        SELECT ROWID AS rid,
               ROW_NUMBER() OVER (PARTITION BY PRD_LVL_CHILD ORDER BY FEC_REG DESC) AS rn
        FROM EDSR.WMS_ITEM_ENVIO
        WHERE TRAN_TYPE = 'C'
          AND PRD_LVL_CHILD IN (
              SELECT PRD_LVL_CHILD
              FROM EDSR.WMS_ITEM_ENVIO 
              WHERE FEC_PROCESADO IS NOT NULL
                AND FLG_ERROR = '1'
                AND MENSAJE = '{"success":false,"response":{"message":"Error loading stage data. "}}'
                AND TRAN_TYPE = 'A'
                AND PRD_LVL_CHILD IN (
                    SELECT DISTINCT PRD_LVL_CHILD 
                    FROM EDSR.WMS_ITEM_ENVIO 
                    WHERE TRAN_TYPE = 'C'
                )
          )
    )
    WHERE rn = 1
);
COMMIT;



declare
V_COMPANY_COD        VARCHAR2(4);
    V_ORG_CHILD_CD       NUMBER(12);
    V_FLAG_ITEM          CHAR(1);
  BEGIN
    
    V_COMPANY_COD := PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('COD_EMPR');
    V_ORG_CHILD_CD:= PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('ID_CD');
    V_FLAG_ITEM   := PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('FLG_ITEM');
    
    dbms_output.put_line('V_COMPANY_COD: '|| V_COMPANY_COD);
    dbms_output.put_line('V_ORG_CHILD_CD: '|| V_ORG_CHILD_CD);
    dbms_output.put_line('V_FLAG_ITEM: '|| V_FLAG_ITEM);
  END;
    
    
    SELECT ID_TIPO,
             TIPO_INTEGRACION,
             HORA_INICIO,
             HORA_FINAL
      FROM WMS_TIPO_INTEGRACION;