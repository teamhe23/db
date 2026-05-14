SELECT * FROM EDSR.TP_DAD_OC_CTRL;

SELECT DISTINCT PMG_BUYER FROM EDSR.tpimpocc;
SELECT * FROM EDSR.TP_DAD_OC_LOG ORDER BY fec_cre desc;
SELECT * FROM EDSR.TP_DAD_OC_LOG WHERE CONFIRMED_AT != 1;
SELECT * FROM EDSR.pmghdree
ORDER BY PMG_EFFECT_DATE DESC;

SELECT FEC_CRE,PMG_EXT_PO_NUM,PMG_PO_NUMBER, TIC.* FROM edsr.tpimpocc  TIC 
WHERE PMG_BUYER IN ('JDAUSERRPL')
ORDER BY TIC.FEC_CRE DESC
--FETCH FIRST 2 ROWS only;


--CONSULTAS LUEGO DE CREAR LA OC POR LA API http://10.239.4.206:31712/api/ws-services/purchaseOrder
SELECT * FROM EDSR.TP_DAD_OC_LOG ORDER BY fec_cre desc;
SELECT FEC_CRE,PMG_EXT_PO_NUM,PMG_PO_NUMBER, TIC.* FROM edsr.tpimpocc  TIC
WHERE PMG_EXT_PO_NUM IN ('2200000038067-1');
ORDER BY TIC.FEC_CRE DESC;

SELECT PMG_EXT_PO_NUM,PMG_PO_NUMBER, PMG.* FROM edsr.pmghdree PMG
WHERE PMG_EXT_PO_NUM IN ('2200000038067-1'); --2200000038067-1

SELECT * FROM EDSR.pmghdree WHERE PMG_PO_NUMBER IN (102366);
SELECT * FROM EDSR.pmgdtlee WHERE PMG_PO_NUMBER IN (102366);

--CONSULTA POR OC
select
   'HESA' companyCode,
   h.PMG_EXT_PO_NUM dispatchNumber,
   h.pmg_po_number purchaseOrder,
   h.pmg_user buyer,
   t.pmg_type_name orderType,
   c.dmt_desc distributionMethod,
   h.curr_code currency,
   v.vpc_apt_desc term,
   to_number(to_char(h.pmg_cncl_by_date, 'yyyymmdd')) cancelDate,
   s.org_lvl_number entityCodeDestinity,
   s.org_name_full entityDescriptionDestinity,
   des_dpto descDepartment,
   cod_dpto cod_dpto,
   h.pmg_ship_date pmgshipdate,
   p.prd_lvl_number sku,
   trim(p.vpc_case_pack_id) codeProdProvider,
   d.pmg_sell_cost cost
 from pmghdree h
 inner join pmgotpee t
   on h.pmg_type_code = t.pmg_type_code
 inner join rpldmtcd c
   on h.dmt_code = c.dmt_code
 inner join vpcaptee v
   on h.vpc_apt_key = v.vpc_apt_key
 inner join orgmstee s
   on s.org_lvl_child = h.prim_org_lvl_child
 inner join pmgdtlee d
   on d.pmg_po_number = h.pmg_po_number
 inner join tpprdmst p
   on p.prd_lvl_child = d.prd_lvl_child
 where h.pmg_po_number = 102366;


--DEMON:
SELECT
   DISTINCT
   'HESA' AS COMPANYCODE,
   h.PMG_EXT_PO_NUM AS DISPATCHNUMBER,
   h.pmg_po_number AS PURCHASEORDER,
   h.pmg_user AS BUYER,
   t.pmg_type_name AS ORDERTYPE,
   c.dmt_desc AS DISTRIBUTIONMETHOD,
   h.curr_code AS CURRENCY,
   v.vpc_apt_desc AS TERM,
   TO_CHAR(h.pmg_cncl_by_date, 'yyyymmdd') AS CANCELDATE,
   s.org_lvl_number AS ENTITYCODEDESTINITY,
   s.org_name_full AS ENTITYDESCRIPTIONDESTINITY,
   p.des_dpto AS DESCDEPARTMENT,
   p.cod_dpto AS CODEDEPARTMENT,
   h.pmg_ship_date AS PMGSHIPDATE,
   p.prd_lvl_number AS SKU,
   TRIM(p.vpc_case_pack_id) AS CODEPRODPROVIDER,
   d.pmg_sell_cost AS COST,
   l.CONFIRMED_AT AS CONFIRMED_AT,
   l.RESPONSE_CODE,
   l.RESPONSE_MESSAGE
FROM pmghdree h
INNER JOIN pmgotpee t ON h.pmg_type_code = t.pmg_type_code
INNER JOIN rpldmtcd c ON h.dmt_code = c.dmt_code
INNER JOIN vpcaptee v ON h.vpc_apt_key = v.vpc_apt_key
INNER JOIN orgmstee s ON s.org_lvl_child = h.prim_org_lvl_child
INNER JOIN pmgdtlee d ON d.pmg_po_number = h.pmg_po_number
INNER JOIN tpprdmst p ON p.prd_lvl_child = d.prd_lvl_child
INNER JOIN TP_DAD_OC_LOG l ON TRIM(l.NUM_DOC) = TRIM(h.PMG_EXT_PO_NUM) AND NVL(l.CONFIRMED_AT,0) = 0
 --where h.pmg_po_number = 102366;
;

--sql generado por app:
SELECT DISTINCT
   'HESA' AS COMPANYCODE,
   h.PMG_EXT_PO_NUM AS DISPATCHNUMBER,
   h.pmg_po_number AS PURCHASEORDER,
   h.pmg_user AS BUYER,
   t.pmg_type_name AS ORDERTYPE,
   c.dmt_desc AS DISTRIBUTIONMETHOD,
   h.curr_code AS CURRENCY,
   v.vpc_apt_desc AS TERM,
   TO_CHAR(h.pmg_cncl_by_date, 'yyyymmdd') AS CANCELDATE,
   s.org_lvl_number AS ENTITYCODEDESTINITY,
   s.org_name_full AS ENTITYDESCRIPTIONDESTINITY,
   p.des_dpto AS DESCDEPARTMENT,
   p.cod_dpto AS CODEDEPARTMENT,
   h.pmg_ship_date AS PMGSHIPDATE,
   p.prd_lvl_number AS SKU,
   TRIM(p.vpc_case_pack_id) AS CODEPRODPROVIDER,
   d.pmg_sell_cost AS COST
FROM EDSR.pmghdree h
INNER JOIN EDSR.pmgotpee t ON h.pmg_type_code = t.pmg_type_code
INNER JOIN EDSR.rpldmtcd c ON h.dmt_code = c.dmt_code
INNER JOIN EDSR.vpcaptee v ON h.vpc_apt_key = v.vpc_apt_key
INNER JOIN EDSR.orgmstee s ON s.org_lvl_child = h.prim_org_lvl_child
INNER JOIN EDSR.pmgdtlee d ON d.pmg_po_number = h.pmg_po_number
INNER JOIN EDSR.tpprdmst p ON p.prd_lvl_child = d.prd_lvl_child
INNER JOIN EDSR.TP_DAD_OC_LOG l ON l.NUM_DOC = h.PMG_EXT_PO_NUM
                               AND NVL(l.CONFIRMED_AT,0) = 0
;

--cambios BD

SELECT * FROM dba_source
WHERE upper(TEXT) LIKE '%INTO TP_DAD_OC_LOG%'

SELECT * FROM EDSR.TP_DAD_OC_LOG ORDER BY FEC_CRE DESC;
SELECT * FROM EDSR.TP_DAD_OC_LOG WHERE NUM_DOC= '2200000659163-1';

SELECT DISTINCT UTL_RAW.CAST_TO_VARCHAR2(REQ_JSON)
FROM EDSR.TP_DAD_OC_LOG DAD
WHERE NUM_DOC IN ('2200000645395-1','2200000643728-1');

UPDATE EDSR.TP_DAD_OC_LOG SET CONFIRMED_AT = 1 WHERE CONFIRMED_AT = 0;
COMMIT;
ALTER TABLE EDSR.TP_DAD_OC_LOG
  ADD (CONFIRMED_AT NUMBER(1) DEFAULT 0 NOT NULL);

ALTER TABLE EDSR.TP_DAD_OC_LOG
  ADD CONSTRAINT CK_TP_DAD_OC_LOG_CONFAT
  CHECK (CONFIRMED_AT IN (0,1));

ALTER TABLE EDSR.TP_DAD_OC_LOG 
  ADD (REQ_JSON BLOB);

  -- Acelera el JOIN h.PMG_EXT_PO_NUM = NUM_DOC
CREATE INDEX IDX_TP_DAD_OC_LOG_NUMDOC
  ON EDSR.TP_DAD_OC_LOG (NUM_DOC);

-- Acelera el filtro por pendientes (CONFIRMED_AT = 0) junto con el NUM_DOC
CREATE INDEX IDX_TP_DAD_OC_LOG_NUMDOC_CONF
  ON EDSR.TP_DAD_OC_LOG (NUM_DOC, CONFIRMED_AT);


