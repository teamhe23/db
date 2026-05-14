SELECT * FROM WMS_SHP_LOAD_HDR ORDER BY HDR_GROUP_NBR DESC;
SELECT DOWNLOAD_DATE_1, ERR_CODE,H.* 
FROM WMS_SHP_LOAD_HDR H 
WHERE 
	--LOAD_MANIFEST_NBR IN ('NAC000923636')
	LOAD_MANIFEST_NBR LIKE '%13721%'
;

--('OS85100023802','OS85100023781','OS85100023461','OS85100023441','OS85100023701')
--RECEPCIONES DE NACIONAL
--NAC000923636 (139074)
--NAC000923595 (138605)
--NAC000923639 ()
SELECT err_code, rcv.* FROM edsr.wms_rcv_asn_hdr rcv 
WHERE LOAD_NBR = '923636';
--detalle recepción
SELECT err_code, dtl.* FROM EDSR.wms_rcv_asn_dtl dtl 
WHERE HDR_GROUP_NBR = 20057 
ORDER BY dtl.err_code desc;

-- esto es TRF buscar pareecido
SELECT * FROM epmm.sdircvhdi s ORDER BY RCV_DATE_SES_OPN ;

SELECT * FROM epmm.SDIRCVDTI s ORDER BY s.DATE_CREATED DESC;
SELECT * FROM epmm.SDIRCVDTI WHERE RCV_SESSION_ID IN (769792,769879,769950);

SELECT * FROM epmm.SDIRCVDTI s
WHERE s.RCV_DOC_NUMBER  = 'NAC000923636'
ORDER BY s.DATE_CREATED DESC
;

SELECT * FROM epmm.TPPRDMST;
SELECT * FROM epmm.VPCMSTEE v
LEFT JOIN TPPRDMST p ON p.VPC_TECH_KEY  = v.VPC_TECH_KEY
WHERE p.PRD_LVL_NUMBER IN ('40573');

--Si el motivo es DUPLICADO: ve las filas conflictivas en VPCPRDEE
-- Reemplaza :VPC_KEY y :PACK_NORM con valores de la salida anterior
SELECT v.vpc_tech_key,
       v.vpc_case_pack_id,
       v.prd_lvl_child,
       v.eaches_per_inner,
       v.sll_units_per_inner,
       v.number_of_inners,
       v.vpc_case_wgt, v.vpc_case_wgt_uom,
       v.vpc_case_gross_wgt,
       v.DATE_LAST_ORDER,
       v.VPC_ACTIVE_FLAG
FROM   epmm.vpcprdee v
WHERE  v.vpc_tech_key = 14264
  AND  UPPER(TRIM(REGEXP_REPLACE(v.vpc_case_pack_id,'\.+$',''))) = '170A'
ORDER  BY NVL(VPC_ACTIVE_FLAG,'N') DESC,
          NVL(DATE_LAST_ORDER, DATE '1900-01-01') DESC,
          ROWID DESC;


--Lista tus 6 filas problemáticas con contexto y dueños posibles:
WITH d AS (
  SELECT ROWID AS d_rid,
         d.*,
         UPPER(TRIM(REGEXP_REPLACE(d.vpc_case_pack_id,'\.+$',''))) AS pack_norm,
         CASE WHEN REGEXP_LIKE(d.prd_lvl_number,'^\s*-?\d+(\.\d+)?\s*$')
              THEN TO_NUMBER(d.prd_lvl_number) END AS prd_num
  FROM   epmm.sdircvdti d
),
prd AS (  -- PRD_LVL_NUMBER -> VPC_TECH_KEY esperado
  SELECT t.prd_lvl_number AS prd_num,
         t.vpc_tech_key   AS vpc_key_from_prd
  FROM   epmm.tpprdmst t
),
cat AS (  -- Conteo por (VPC_TECH_KEY, pack_norm)
  SELECT p.vpc_tech_key,
         UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$',''))) AS pack_norm,
         COUNT(*) AS cnt
  FROM   epmm.vpcprdee p
  GROUP  BY p.vpc_tech_key,
           UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$','')))
),
owners AS ( -- quiénes poseen el pack (VPC_TECH_KEY y vendor)
  SELECT UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$',''))) AS pack_norm,
         p.vpc_tech_key,
         m.vendor_number
  FROM   epmm.vpcprdee p
  LEFT   JOIN epmm.vpcmstee m ON m.vpc_tech_key = p.vpc_tech_key
  GROUP  BY UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$',''))),
           p.vpc_tech_key, m.vendor_number
),
owners_agg AS ( -- agrego en una sola línea
  SELECT pack_norm,
         LISTAGG('VPC='||vpc_tech_key||' (VENDOR='||NVL(TO_CHAR(vendor_number),'?')||')', '; ') 
           WITHIN GROUP (ORDER BY vpc_tech_key) AS posibles_duenos
  FROM   owners
  GROUP  BY pack_norm
)
SELECT d.rcv_doc_number,
       d.batch_num,
       d.prd_num                 AS prd_lvl_number,
       d.vpc_case_pack_id,
       d.pack_norm,
       p.vpc_key_from_prd        AS vpc_tech_key_esperado,
       NVL(c.cnt,0)              AS filas_en_vpcprdee_para_esperado,
       CASE
         WHEN c.cnt IS NULL OR c.cnt = 0 THEN 'NO-PERTENECE (PRD+PACK no existe para VPC esperado)'
         WHEN c.cnt > 1                   THEN 'DUPLICADO (ORA-01422 riesgo)'
       END AS motivo,
       oa.posibles_duenos        AS pack_propietarios_posibles,
       d.d_rid                   AS staging_rowid
FROM   d
LEFT JOIN prd p   ON p.prd_num      = d.prd_num
LEFT JOIN cat c   ON c.vpc_tech_key = p.vpc_key_from_prd
                 AND c.pack_norm    = d.pack_norm
LEFT JOIN owners_agg oa ON oa.pack_norm = d.pack_norm
WHERE  (c.cnt IS NULL OR c.cnt = 0 OR c.cnt > 1)
ORDER  BY motivo DESC, d.rcv_doc_number, d.vpc_case_pack_id, d.prd_num;


--VALIDA A QUIEN LES PERTENECE:
WITH d AS (
  SELECT DISTINCT
         UPPER(TRIM(REGEXP_REPLACE(d.vpc_case_pack_id,'\.+$',''))) AS pack_norm
  FROM   epmm.sdircvdti d
  -- opcional: WHERE d.rcv_doc_number = 'NAC000923636'
),
owners AS (
  SELECT UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$',''))) AS pack_norm,
         p.vpc_tech_key
  FROM   epmm.vpcprdee p
  GROUP  BY UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$',''))),
           p.vpc_tech_key
)
SELECT d.pack_norm,
       o.vpc_tech_key,
       m.vendor_number
FROM   d
JOIN   owners o ON o.pack_norm = d.pack_norm
LEFT  JOIN epmm.vpcmstee m ON m.vpc_tech_key = o.vpc_tech_key
ORDER BY d.pack_norm, o.vpc_tech_key;


--VALIDA LOS QUE GENERAN ERROR:
WITH d AS (
  SELECT ROWID d_rid, d.*,
         UPPER(TRIM(REGEXP_REPLACE(d.vpc_case_pack_id,'\.+$',''))) AS pack_norm
  FROM   epmm.sdircvdti d
  WHERE  d.rcv_doc_number = 'NAC000923636' -- opcional
),
vend AS (
  SELECT vendor_number, vpc_tech_key
  FROM   epmm.vpcmstee
)
SELECT d.rcv_doc_number, d.vendor_number, d.inner_pk_tech_key,
       d.vpc_case_pack_id, d.pack_norm, v.vpc_tech_key, d.d_rid
FROM   d
JOIN   vend v ON v.vendor_number = d.vendor_number
LEFT JOIN epmm.vpcprdee p
       ON p.vpc_tech_key = v.vpc_tech_key
      AND UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$',''))) = d.pack_norm
--WHERE  p.vpc_tech_key IS NULL     -- ← NO pertenece a ese proveedor
ORDER  BY d.rcv_doc_number, d.vpc_case_pack_id;

SELECT * FROM TPPRDMST t ;
SELECT * FROM EPMM.vpcprdee ;

WITH d AS (
  SELECT ROWID AS d_rid,
         d.*,
         UPPER(TRIM(REGEXP_REPLACE(d.vpc_case_pack_id,'\.+$',''))) AS pack_norm,
         CASE WHEN REGEXP_LIKE(d.prd_lvl_number,'^\s*-?\d+(\.\d+)?\s*$')
              THEN TO_NUMBER(d.prd_lvl_number)
         END AS prd_num
  FROM   epmm.sdircvdti d
),
prd AS (
  SELECT t.prd_lvl_number AS prd_num,
         t.vpc_tech_key   AS vpc_key_from_prd
  FROM   epmm.tpprdmst t
),
cat AS (
  SELECT p.vpc_tech_key,
         UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$',''))) AS pack_norm,
         COUNT(*) AS cnt
  FROM   epmm.vpcprdee p
  GROUP  BY p.vpc_tech_key,
           UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$','')))
)
SELECT d.rcv_doc_number,
       d.batch_num,
       d.prd_num            AS prd_lvl_number,
       d.vpc_case_pack_id,
       d.pack_norm,
       p.vpc_key_from_prd   AS vpc_tech_key_esperado,
       NVL(c.cnt, 0)        AS filas_en_vpcprdee_para_esperado,
       CASE
         WHEN c.cnt IS NULL OR c.cnt = 0 THEN 'NO-PERTENECE (pack no existe para VPC esperado)'
         WHEN c.cnt > 1                   THEN 'DUPLICADO (ORA-01422 riesgo)'
       END AS motivo,
       d.d_rid              AS staging_rowid
FROM   d
LEFT JOIN prd p
       ON p.prd_num = d.prd_num
LEFT JOIN cat c
       ON c.vpc_tech_key = p.vpc_key_from_prd
      AND c.pack_norm    = d.pack_norm
WHERE  (c.cnt IS NULL OR c.cnt = 0 OR c.cnt > 1)
ORDER  BY motivo DESC, d.rcv_doc_number, d.vpc_case_pack_id, d.prd_num;


WITH d AS (
  SELECT ROWID AS d_rid,
         d.*,
         -- Normaliza el pack del staging (quita puntos finales, TRIM, UPPER)
         UPPER(TRIM(REGEXP_REPLACE(d.vpc_case_pack_id,'\.+$',''))) AS pack_norm,
         -- Convierte PRD_LVL_NUMBER a num si viene texto
         CASE WHEN REGEXP_LIKE(d.prd_lvl_number,'^\s*-?\d+(\.\d+)?\s*$')
              THEN TO_NUMBER(d.prd_lvl_number)
         END AS prd_num
  FROM   epmm.sdircvdti d
  -- Opcional: filtra por documento, lote o fechas
  WHERE d.rcv_doc_number = 'NAC000923636'
),
prd AS (  -- PRD_LVL_NUMBER -> VPC_TECH_KEY esperado
  SELECT t.prd_lvl_number      AS prd_num,
         t.vpc_tech_key        AS vpc_key_from_prd
  FROM   epmm.tpprdmst t
),
cat AS (  -- Conteo por (VPC_TECH_KEY, pack_norm)
  SELECT p.vpc_tech_key,
         UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$',''))) AS pack_norm,
         COUNT(*) AS cnt
  FROM   epmm.vpcprdee p
  GROUP  BY p.vpc_tech_key,
           UPPER(TRIM(REGEXP_REPLACE(p.vpc_case_pack_id,'\.+$','')))
)
SELECT d.rcv_doc_number,
       d.batch_num,
       d.prd_num            AS prd_lvl_number,
       d.vpc_case_pack_id,
       d.pack_norm,
       p.vpc_key_from_prd   AS vpc_tech_key_esperado,
       NVL(c.cnt, 0)        AS filas_en_vpcprdee_para_esperado,
       CASE
         WHEN c.cnt IS NULL OR c.cnt = 0 THEN 'Posible ORA-01403 (PRD+PACK no existe para VPC esperado)'
         WHEN c.cnt = 1                   THEN 'OK (1 fila)'
         WHEN c.cnt > 1                   THEN 'ORA-01422 RIESGO (duplicado para VPC esperado)'
       END AS diagnostico,
       d.d_rid              AS staging_rowid
FROM   d
LEFT JOIN prd p
       ON p.prd_num = d.prd_num
LEFT JOIN cat c
       ON c.vpc_tech_key = p.vpc_key_from_prd
      AND c.pack_norm    = d.pack_norm
ORDER  BY d.rcv_doc_number, d.vpc_case_pack_id, d.prd_num;


 SELECT *
FROM EPMM.rcvdtycd
WHERE default_flag = 'T';

SELECT vpc_tech_key, vpc_case_pack_id, COUNT(*) AS cnt
FROM   EPMM.vpcprdee
GROUP  BY vpc_tech_key, vpc_case_pack_id
HAVING COUNT(*) > 1;


SELECT * FROM EPMM.sdircdrej
--WHERE PMG_PO_NUMBER = 138605
ORDER BY DATE_CREATED DESC
;



WITH d AS (
  SELECT d.ROWID AS d_rid,
         d.*,
         UPPER(TRIM(REGEXP_REPLACE(d.vpc_case_pack_id, '\.+$',''))) AS pack_norm
  FROM   epmm.sdircvdti d
  WHERE  d.rcv_doc_number = 'NAC000923636'
),
a AS (
  SELECT d.d_rid, d.tech_key, d.inner_pk_tech_key, d.vendor_number,
         d.vpc_case_pack_id, d.pack_norm, d.rcv_doc_number, d.rcv_doc_type,
         m.vpc_tech_key AS cand_vpc_tech_key, 'A_VENDOR' AS source_key
  FROM   d
  JOIN   epmm.vpcmstee m ON m.vendor_number = d.vendor_number
),
b AS (
  SELECT d.d_rid, d.tech_key, d.inner_pk_tech_key, d.vendor_number,
         d.vpc_case_pack_id, d.pack_norm, d.rcv_doc_number, d.rcv_doc_type,
         CASE WHEN REGEXP_LIKE(d.inner_pk_tech_key,'^\s*-?\d+(\.\d+)?\s*$')
              THEN TO_NUMBER(d.inner_pk_tech_key)
         END AS cand_vpc_tech_key, 'B_INNER_PK' AS source_key
  FROM   d
  WHERE  d.inner_pk_tech_key IS NOT NULL
),
cand AS (
  SELECT * FROM a
  UNION ALL
  SELECT * FROM b
),
cat_dups AS (
  SELECT vpc_tech_key,
         UPPER(TRIM(REGEXP_REPLACE(vpc_case_pack_id, '\.+$',''))) AS pack_norm
  FROM   epmm.vpcprdee
  GROUP  BY vpc_tech_key,
           UPPER(TRIM(REGEXP_REPLACE(vpc_case_pack_id, '\.+$','')))
  HAVING COUNT(*) > 1
)
SELECT c.source_key,
       c.rcv_doc_number,
       c.rcv_doc_type,
       c.vendor_number,
       c.inner_pk_tech_key,
       c.cand_vpc_tech_key    AS vpc_tech_key,
       c.vpc_case_pack_id,
       c.pack_norm,
       c.d_rid                AS staging_rowid
FROM   cand c
JOIN   cat_dups x
  ON   x.vpc_tech_key = c.cand_vpc_tech_key
 AND   x.pack_norm    = c.pack_norm
ORDER  BY c.source_key, c.vpc_case_pack_id, c.cand_vpc_tech_key;





SELECT DISTINCT 
  d.tech_key,
  d.inner_pk_tech_key,
  d.vpc_case_pack_id,
  UPPER(TRIM(REGEXP_REPLACE(d.vpc_case_pack_id, '\.+$', ''))) AS vpc_case_pack_id_norm
FROM epmm.sdircvdti d
WHERE d.rcv_doc_number = 'NAC000923636';

-- ¿Existen múltiples headers para ese documento?
SELECT DISTINCT rcv_doc_number, rcv_doc_type
FROM epmm.sdircvdti
WHERE rcv_doc_number = 'NAC000923636';

SELECT COUNT(*) cnt
FROM epmm.sdircvdti
WHERE rcv_doc_number = 'NAC000923636'
  AND (rcv_doc_type = '[NULL]' OR batch_num = '[NULL]');








SELECT * FROM B2B_OC_RCV_ENVIO WHERE pmg_po_number = '139074';

SELECT * FROM sqlerree WHERE procedure_name = 'RCVADDIM' ORDER BY error_date desc;

SELECT DISTINCT LOAD_MANIFEST_NBR FROM WMS_SHP_LOAD_HDR WHERE LOAD_MANIFEST_NBR not LIKE 'SE%' ;

SELECT FLAG_PROCESADO,FEC_PROCESO, IDENTIFICADOR, MODELO.ID_TIPO 
, MODELO.* 
FROM EDSR.WMS_MODELO_REQUEST MODELO 
WHERE MODELO.MODELO LIKE '%NAC000923636%'
	--AND ID_TIPO = 1
ORDER BY FEC_REG DESC
FETCH FIRST 20 ROWS ONLY;

SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE  ID_MODELO IN (141845,141841);
/*
ID_MODELO
141845
141841
 */

--Cabecera
--REIMPULSO: Al KSH: /prochp/interfaces/wms/import/ksh/wms_shipped_loads.ksh
SELECT DOWNLOAD_DATE_1, ERR_CODE,H.* FROM WMS_SHP_LOAD_HDR H 
--UPDATE EDSR.WMS_SHP_LOAD_HDR SET DOWNLOAD_DATE_1 = NULL, ERR_CODE = null
WHERE HDR_GROUP_NBR IN (1675);
COMMIT;
--detalle (Eliminar la transferencia con CODIGO 24)
SELECT HDR_GROUP_NBR,ORDER_NBR,D.ITEM_ALTERNATE_CODE,D.ERR_CODE,OB_LPN_NBR,PALLET_NBR, D.* 
FROM WMS_SHP_LOAD_DTL D
WHERE HDR_GROUP_NBR IN (1675)
ORDER BY LINE_NBR;