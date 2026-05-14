SELECT ID_TIPO,TIPO_INTEGRACION,HORA_INICIO,HORA_FINAL FROM WMS_TIPO_INTEGRACION;

-- PMG_STAT_CODE Detail
/*
PMG_STAT_CODE   PMG_STAT_NAME
    0     Suspendido
    1     Modo Entrada
    2     Autorz Pend
    3     Aprobado
    4     On Order
    5     Recibo Parcial
    6     Recibo Completo
    7     Cancel
    8     Cambio Rechazado
 */
SELECT * FROM EDSR.PMGSTSCD;

-- Devoluciones
SELECT * FROM B2B_RTV_ENVIO
ORDER BY FEC_REG DESC
FETCH FIRST 50 ROWS ONLY;

-- B2B Logístico
--integración pmm con b2b financiero
select * from edsr.B2B_OC_RCV_ENVIO where pmg_po_number = 111957 and impuesto_fin != '0';
select * from edsr.b2backee2 where b2b_mensaje like '744849%';

select * from edsr.b2backee2 where b2b_tipo_mens = 'QR' order by 1 desc;


SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE FLAG_PROCESADO = '0' OR FLAG_ERROR = '1';
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR = 'NAC000914640';
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MODELO LIKE '%NAC000905648%';
SELECT * FROM EDSR.WMS_RCV_ASN_HDR WHERE SHIPMENT_NBR = 'NAC000905648';

-- Caso BOSCH
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (102272) AND impuesto_fin = '0';

/*************************
  Caso FLORAL
 *************************/
/*
    2024-10-24 12:24:39 (12739524999022342)
    ORA-00001: unique constraint (EDSR.PK_WMS_RCV_ASN_DTL) violated
    ORA-06512: at "EDSR.PKG_WMS_GENERAL", line 327
    ORA-06512: at line 1
*/
SELECT oc.PRIM_ORG_LVL_NUMBER,OC.PMG_STAT_CODE, oc.*
FROM pmghdree oc
WHERE pmg_po_number IN (102272);
 --114116,113407 => NAC000910844
 --112841 => NAC000910325, (paso)
 --112687 => NAC000910273  (paso)
 --114360 => NAC000911470  (paso y llego al B2B)
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000910844'); --No pasa
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MESSAGE_ID IN ('12739524999022342'); --No pasa
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000910325','NAC000910273'); -- 112841,112687 paso
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000910325'); -- 112841 paso
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000910273'); -- 112687 paso
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000911470'); --paso y llego al B2B
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE ID_MODELO = 54964;
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE ID_MODELO = 54968;
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE ID_MODELO = 60847; --NAC000911470
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE FLAG_ERROR = 1; --
-- Observar que 53824 y 54688 son iguales. Registrados en meses diferentes
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE ID_MODELO IN (53824,54688,57672); --
SELECT DISTINCT ID_TIPO FROM EDSR.WMS_MODELO_REQUEST; --1,2,3
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE modelo LIKE '%114360%';
SELECT * FROM EDSR.HP_SUC_VTEX;

-- Cada 5 minutos la tabla WMS_MODELO_REQUEST se convierte en WMS_RCV_ASN_HDR y WMS_RCV_ASN_DTL
SELECT HDR.CREATE_DATE,HDR.DOWNLOAD_DATE_1, HDR.* FROM WMS_RCV_ASN_HDR HDR ORDER BY HDR.CREATE_DATE DESC FETCH FIRST 10 ROWS ONLY;

SELECT HDR.HDR_GROUP_NBR,HDR.CREATE_DATE,HDR.DOWNLOAD_DATE_1,HDR.LOAD_NBR,HDR.ERR_CODE,ERR.ERR_DESC, HDR.*
FROM WMS_RCV_ASN_HDR HDR
    LEFT JOIN EDSR.WMS_ERROR_INT ERR ON HDR.ERR_CODE = ERR.ERR_CODE
WHERE SHIPMENT_NBR IN ('NAC000910844','NAC000910325','NAC000910273','NAC000911470');

SELECT DTL.ERR_CODE,ERR.ERR_DESC, DTL.*
FROM WMS_RCV_ASN_DTL DTL
    LEFT JOIN EDSR.WMS_ERROR_INT ERR ON DTL.ERR_CODE = ERR.ERR_CODE
WHERE HDR_GROUP_NBR IN (6962);

SELECT * FROM ORGMSTEE;
SELECT c.caldat, c.* FROM caldayee c; --2024-11-13
SELECT m.trf_manifest_id, m.* FROM TRFMFHEE m; -- 344 rows (OS85100008901)


-- B2B Logistico
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (129832) AND impuesto_fin = '0';

select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (112841,112687) AND impuesto_fin = '0';

SELECT DTL.* FROM WMS_RCV_ASN_DTL DTL WHERE HDR_GROUP_NBR IN(6922) ;
select * from TP_IMP_RCV_OC A;
select * from HPSDISESSIONTMP;
select * from TP_IMP_RCV_OC;
select * from sdircvhdi;


SELECT oc.PRIM_ORG_LVL_NUMBER,OC.PMG_STAT_CODE, oc.*
FROM pmghdree oc
WHERE pmg_po_number IN (114116,113407);

SELECT dtl.pmg_status, dtl.* FROM EDSR.pmgdtlee dtl where PMG_PO_NUMBER in (114116);

-- EDSR.PKG_WMS_SHIPMENT_VERIFICATION.sp_verification_oc
-- Agrega los pendientes de WMS_RCV_ASN_HDR
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000910844');

SELECT HDR.HDR_GROUP_NBR,HDR.SHIPMENT_NBR,HDR.FACILITY_CODE,HDR.MANIFEST_NBR, HDR.CUST_FIELD_2
     ,HDR.SHIPMENT_TYPE,HDR.DOWNLOAD_DATE_1
     ,HDR.ERR_CODE,ERR.ERR_DESC, HDR.*
FROM WMS_RCV_ASN_HDR HDR
    LEFT JOIN EDSR.WMS_ERROR_INT ERR ON HDR.ERR_CODE = ERR.ERR_CODE
WHERE SHIPMENT_NBR IN ('NAC000910844');

select count(1)
        from wms_rcv_asn_hdr h
        where h.shipment_nbr = 'NAC000910844'
          and h.hdr_group_nbr <> 6955
          and h.err_code is not null;

SELECT * FROM dba_profiles WHERE resource_name = 'SESSIONS_PER_USER';
SELECT * FROM dba_profiles WHERE resource_name = 'CONNECT_TIME';
SELECT * FROM dba_profiles WHERE resource_name = 'IDLE_TIME';


SELECT DTL.ERR_CODE,ERR.ERR_DESC, DTL.*
FROM WMS_RCV_ASN_DTL DTL
    LEFT JOIN EDSR.WMS_ERROR_INT ERR ON DTL.ERR_CODE = ERR.ERR_CODE
WHERE HDR_GROUP_NBR IN (6963);

SELECT  h.rowid,
        h.hdr_group_nbr,
        h.shipment_nbr,
        h.facility_code                     as org_lvl_number,
        substr(trim(h.manifest_nbr), 1, 20) as rcv_doc_number,
        --h.shipped_date,
        trim(h.cust_field_2)                as num_cita
FROM wms_rcv_asn_hdr h
WHERE (
        h.shipment_type is null
        or
        h.shipment_type in ('PRE', 'NAC', 'COM')
      )
    AND h.shipment_nbr NOT IN (SELECT m.trf_manifest_id FROM TRFMFHEE m)
    --AND h.shipment_nbr NOT IN (SELECT L.LOAD_MANIFEST_NBR FROM WMS_SHP_LOAD_HDR L)
    AND substr(h.shipment_nbr, 1, 2) != 'OS'
    AND h.download_date_1 IS NULL
    AND h.err_code is null;

SELECT substr('NAC000910844', 1, 2) FROM DUAL;

select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (114116,113407) AND impuesto_fin = '0';

/*
 B2B LOGISTICO
 La tabla B2B_OC_RCV_ENVIO      se alimenta de   RCVSSHEE (r), RCVSSDEE (d), PMGHDREE (oc)
 los campos pmg_po_number   => d.pmg_po_number
            rcv_session_id  => r.rcv_session_id
            rcv_date,       => d.rcv_date
            num_despacho,   => 0
            flg_wms         => '0'
 Por defecto el impuesto_fin es 0

 La tabla B2B_OC_RCV_ENVIO_DET  se alimenta de   RCVSSDEE, ORGMSTEE, PRDMSTEE

  B2B FINANCIERO
 La tabla B2B_OC_RCV_ENVIO      se alimenta de   RCVSSDEE (a), RCVTXSEE (b)
 los campos pmg_po_number,  => a.pmg_po_number,
            rcv_session_id, => a.rcv_session_id,
            rcv_date,       => a.rcv_date,
            num_despacho,   => p_num_despacho,
            flg_wms,        => p_flg_wms,
            fec_proc_log,   => to_date('19000101','yyyymmdd'),
            impuesto_fin    => fn_obtener_impuesto_fin(nvl(b.txs_rate,0)) as tipo
 */
--TP_PKG_ARCHIVOS_B2B
/*
 B2B_OC_RCV_ENVIO:
TP_PKG_ARCHIVOS_B2B
WMS_IMP_RCV_OC_PROC


 WMS_RCV_ASN_HDR:
 PKG_WMS_INVENTORY_HISTORY,
 PKG_WMS_GENERAL,
 PKG_WMS_SHIPMENT_VERIFICATION,
 TP_PKG_REPORTES,
 TP_PKG_TURBO_ENTRY,
 PKG_WMS_ORDER_VERIFICATION
 */
-- TP_PKG_ARCHIVOS_B2B, WMS_IMP_RCV_OC_PROC(procedure)
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%B2B_OC_RCV_ENVIO%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%TP_IMP_RCV_OC%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%WMS_MODELO_REQUEST%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%TP_IMP_RCV_OC%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%HPB2BINV%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%WMS_RCV_ASN_HDR%' AND NAME= 'PKG_WMS_SHIPMENT_VERIFICATION';
SELECT DISTINCT NAME FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%B2B_OC_RCV_ENVIO%';
-- B2B Logistico
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (114116,113407,112841,112687,114360) AND impuesto_fin = '0';

select * from edsr.B2B_OC_RCV_ENVIO RCV
    WHERE pmg_po_number IN (112687,112841) AND impuesto_fin != '0';


Select distinct t.pmg_po_number,
                          t.org_lvl_number,
                          t.rcv_doc_number,
                          t.rcv_date,
                          t.NUM_DESP_B2B,
                          'NO' as detraccion,
                          'SINDTR' as COD_DTR
            from TP_IMP_RCV_OC T
           where t.rcv_batch_id = par_rcv_batch_id;

--112463
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (112463) AND impuesto_fin = '0';

--B2B Financiero
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (112463) AND impuesto_fin != '0';




/*************************
  Caso PLASTICOS RIMAX S.A.S. (851)
 *************************/
SELECT * FROM EDSR.PMGHDREE WHERE PMG_PO_NUMBER = 109919;
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000909980');
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MESSAGE_ID IN ('12414004637286809'); --ORA-01013: user requested cancel of current operation (FEC_PROCESO => 2024-09-27 20:07:00)

-- B2B Logistico
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (109919) AND impuesto_fin = '0';

--B2B Financiero
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (111957) AND impuesto_fin != '0';

/*************************
  Caso PROMESA
 *************************/
SELECT * FROM EDSR.PMGHDREE WHERE PMG_PO_NUMBER = 111957;
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000909980');
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MESSAGE_ID IN ('12285477691783367');
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MESSAGE_ID IN ('12283773670082527');

-- B2B Logistico
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (111957) AND impuesto_fin = '0';

--112463
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (111957) AND impuesto_fin = '0';

--B2B Financiero
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (111957) AND impuesto_fin != '0';


/****************************************
  Caso SABANDO MENDOZA LENA ELIANA
 ****************************************/
SELECT * FROM EDSR.PMGHDREE WHERE PMG_PO_NUMBER = 113004;
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000910441');
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MESSAGE_ID IN ('12584639076075034');

-- B2B Logistico
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (113004) AND impuesto_fin = '0' -- AND RCV_SESSION_ID = 752606
;

SELECT MAX(RCV_SESSION_ID) FROM B2B_OC_RCV_ENVIO; -- 752949 (EL QUE SE ENVIO 752570)

SELECT * FROM B2B_OC_ENVIO;



SELECT * FROM B2B_OC_CANCEL_ENVIO;

SELECT PMG_PO_NUMBER,COUNT(PMG_PO_NUMBER) FROM B2B_OC_RCV_ENVIO
WHERE impuesto_fin = '0'
GROUP BY PMG_PO_NUMBER
HAVING COUNT(PMG_PO_NUMBER) >= 2
ORDER BY PMG_PO_NUMBER DESC
;

SELECT * FROM EDSR.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (112942) AND impuesto_fin = '0';

--B2B Financiero
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (113004) AND impuesto_fin != '0';

/*************************
  Caso 	ENKADOR SA
 *************************/
 /*
 * Cuando llega con Correlativo repetido
ORA-00001: unique constraint (EDSR.PK_WMS_RCV_ASN_DTL) violated
ORA-06512: at "EDSR.PKG_WMS_GENERAL", line 327
ORA-06512: at line 1
  */
SELECT * FROM EDSR.PMGHDREE WHERE PMG_PO_NUMBER = 111822;
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000909958');
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MESSAGE_ID IN ('12159850717430017'); -- FEC_PROCESO => 2024-09-17 07:55:06 -> 2024-10-02 16:34:48
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MESSAGE_ID IN ('12292727592282435'); -- FEC_PROCESO => 2024-09-17 08:00:15 -> 2024-10-02 16:39:56

SELECT * FROM EDSR.WMS_RCV_ASN_HDR WHERE SHIPMENT_NBR IN ('NAC000909958');
SELECT * FROM EDSR.WMS_RCV_ASN_DTL WHERE HDR_GROUP_NBR IN (6177);

SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE FLAG_ERROR IN ('1');

/*
 RCVSSNCL,RCVADDIM_DCJ,RCVADDIM,RCVSSDU2,DSDSSNCL,RCVADDIM_CVJ
 */
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT INTO RCVSSDEE%';
SELECT DISTINCT NAME FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT INTO RCVSSDEE%';
SELECT * FROM rcvssdee WHERE PMG_PO_NUMBER = 111822;
SELECT * FROM rcvssdee WHERE PMG_PO_NUMBER = 111957;
select * from edsr.B2B_OC_RCV_ENVIO RCV WHERE pmg_po_number IN (111957) AND impuesto_fin = '0';
select distinct
         a.pmg_po_number,
         a.rcv_session_id,
         a.rcv_date,
         -- p_num_despacho,
         -- p_flg_wms,
         to_date('19000101','yyyymmdd') -- Luego se va a actualizar
         -- ,fn_obtener_impuesto_fin(nvl(b.txs_rate,0)) as tipo
  from edsr.rcvssdee a
    left join edsr.rcvtxsee b on b.rcv_dtl_tech_key = a.rcv_dtl_tech_key
      and b.rcv_session_id = a.rcv_session_id
 where  a.pmg_po_number  = 111957
        --and a.rcv_session_id = p_rcv_session_id
 ;






-- B2B Logistico
SELECT * FROM edsr.B2B_OC_RCV_ENVIO RCV WHERE pmg_po_number IN (111822) AND impuesto_fin = '0';
SELECT * FROM edsr.B2B_OC_RCV_ENVIO RCV  WHERE NUM_DESPACHO IN (909958);
SELECT * FROM edsr.B2B_OC_RCV_ENVIO RCV ORDER BY FEC_REG DESC;

--B2B Financiero
SELECT * FROM edsr.B2B_OC_RCV_ENVIO RCV WHERE pmg_po_number IN (111822) AND impuesto_fin != '0';



--Sino sale
SELECT * FROM EDSR.PMGHDREE WHERE PMG_PO_NUMBER IN (112463); --112188

SELECT PMG_PO_NUMBER, PMG_USER,PMG_EFFECT_DATE FROM EDSR.PMGHDREE
         ORDER BY PMG_EFFECT_DATE DESC
         FETCH FIRST 50 ROWS ONLY;




-- Caso Promesa
SELECT * FROM EDSR.PMGHDREE WHERE PMG_PO_NUMBER IN (107771);

-- Etiqueta <b> Numero de Despacho
SELECT * FROM EDSR.B2B_OC_RCV_ENVIO
  --UPDATE edsr.B2B_OC_RCV_ENVIO SET FEC_PROC_LOG = null
    WHERE pmg_po_number IN (108902) AND impuesto_fin = '0';

--NAC000908275
SELECT * FROM EDSR.WMS_MODELO_REQUEST
--UPDATE EDSR.WMS_MODELO_REQUEST SET FEC_PROCESO = NULL, FLAG_PROCESADO = '0' , FLAG_ERROR = '0'
WHERE ID_MODELO = 35303 and  FLAG_ERROR = '1';


select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (107771) AND impuesto_fin = '0';

--UPDATE edsr.B2B_OC_RCV_ENVIO SET FEC_PROC_LOG = null, NUM_DESPACHO = 0 WHERE pmg_po_number IN (107771) AND impuesto_fin = '0';



SELECT * FROM tpsucrep  where cod_pro = 'OC';


SELECT /*+ rule*/ V.AUDIT_NUMBER "Auditoria", V.TRANS_SESSION "Sesión", TRUNC(V.POSTED_DATE_TIME) "Fecha Proceso", V.TRANS_DATE "Fecha Transaccion", P.DES_AREA "Area", P.DES_LIN "Línea", O.ORG_LVL_NUMBER "Sucursal", V.TRANS_REF "Número Referencia", V.TRANS_REF2 "Número Referencia 2", V.INV_MRPT_CODE "Maestro Reporte", V.INV_DRPT_CODE "Detalle Reporte", D.INV_DRPT_DESC "Movimiento", V.INV_EFF_QTY "Efecto Inventario", V.INV_EFF_CST "Efecto Costo", P.PRD_LVL_NUMBER "Sku", P.PRD_FULL_NAME "Descripción", V.TRANS_QTY "Cantidad", V.TRANS_COST "Costo", V.TRANS_RETL "Precio", V.TRANS_EXT_COST "Costo Ext", V.TRANS_EXT_RETL "Precio Ext", H.TRANS_USER "Usuario"
, V.PROC_SOURCE "Proceso"FROM EDSR.INVAUDEE V
INNER JOIN EDSR.ORGMSTEE O
ON V.TRANS_ORG_CHILD = O.ORG_LVL_CHILD
INNER JOIN EDSR.TPPRDMST P
ON V.TRANS_PRD_CHILD = P.PRD_LVL_CHILD
INNER JOIN EDSR.INVAHREE H
ON V.TRANS_SESSION = H.TRANS_SESSION
INNER JOIN EDSR.INVTRDEE D
ON V.INV_MRPT_CODE = D.INV_MRPT_CODE
AND V.INV_DRPT_CODE = D.INV_DRPT_CODE
WHERE TO_CHAR(V.POSTED_DATE_TIME,'YYYYMMDD') >= '20240901'
AND TO_CHAR(V.POSTED_DATE_TIME,'YYYYMMDD') <= '20240931'
AND ('0' IN ('0') OR v.INV_MRPT_CODE IN ('0'))
AND ('0' IN ('0') OR v.INV_DRPT_CODE IN ('0'))
AND O.ORG_LVL_NUMBER = CASE WHEN 0 = 0 THEN O.ORG_LVL_NUMBER ELSE 0 END
AND TO_CHAR(v.TRANS_DATE,'YYYYMMDD') >= CASE WHEN TO_CHAR('0') = '0' THEN TO_CHAR(v.TRANS_DATE,'YYYYMMDD') ELSE TO_CHAR('20240931') END
AND TO_CHAR(v.TRANS_DATE,'YYYYMMDD') <= CASE WHEN TO_CHAR('0') = '0' THEN TO_CHAR(v.TRANS_DATE,'YYYYMMDD') ELSE TO_CHAR('20240931') END
;

-- Archivos ACK en /prochp/interfaces/b2b/import/in/
-- Buscar por # Recepcion, # OC
SELECT * FROM EDSR.B2BACKEE2 WHERE B2B_MENSAJE LIKE '748816%'ORDER BY 1 DESC;
SELECT * FROM EDSR.B2BACKEE2 ORDER BY 1 DESC;

SELECT * FROM EDSR.WMS_ASN_HDR WHERE HDR_GROUP_NBR IN ();
SELECT * FROM EDSR.WMS_ASN_DTL WHERE PO_NBR = '';

SELECT * FROM EDSR.WMS_RCV_ASN_HDR WHERE WMS_RCV_ASN_HDR.SHIPMENT_NBR = 'NACXXXX';


-- CITAS
-- EDSR.PKG_WMS_APPOINTMENT
/*
Proveedor: ECUADOR FLORAL SAECAFLOR CIA. LTDA.
Despacho: 908008
Flujo: Todos
Estado: Agendada

OC: 107285, 107361
 */

SELECT  TO_DATE('2024-05-30', 'YYYYMMDD') FROM DUAL;
SELECT  TO_DATE(sysdate, 'YYYY-MM-DD') FROM DUAL;
SELECT SYSDATE FROM DUAL;
SELECT SYSDATE, TO_DATE(sysdate, 'DD-MM-YYYY') FROM DUAL;
SELECT  TO_DATE('2024-05-30', 'YYYY-MM-DD') AS FECHA FROM dual;
SELECT FEC_REG,TO_CHAR(FEC_REG, 'YYYY-MM-DD'), TO_CHAR(FEC_REG,'YYYYMMDD') , TO_DATE(FEC_REG) FROM EDSR.WMS_CITA_ENVIO ORDER BY FEC_REG DESC;

SELECT * FROM EDSR.WMS_CITA_ENVIO WHERE TO_CHAR(FEC_REG,'YYYYMMDD') = '20240606';
SELECT * FROM EDSR.WMS_CITA_ENVIO WHERE TO_DATE(FEC_REG) = TO_DATE('2024-06-06','YYYY-MM-DD');

-- APPT_NBR: Numero de DESPACHO tambien puede ser LOAD_NBR
SELECT * FROM EDSR.WMS_CITA_ENVIO WHERE APPT_NBR = '908016'; -- CHALLENGER INDUSTRIAL S.A.
SELECT * FROM EDSR.WMS_CITA_ENVIO WHERE APPT_NBR = '908008'; -- ECUADOR FLORAL SAECAFLOR CIA. LTDA.
SELECT ID_WMS, FEC_PROCESADO,FACILITY_CODE, ACTION_CODE, FEC_REG,APPT_NBR,LOAD_NBR, CARRIER_INFO,ROUND(ESTIMATED_UNITS) FROM EDSR.WMS_CITA_ENVIO
--UPDATE EDSR.WMS_CITA_ENVIO SET FEC_PROCESADO = null, ID_WMS = null
WHERE APPT_NBR = '908008';

-- Montos No Recepcionados Logistico
-- 4: OnOrder | 5: ReciboParcial | 6: ReciboCompleto | 7: Cancel

-- ASN: NAC000909982 (112152) (PRODUCTOS METALURGICOS S.A. PROMESA)
SELECT oc.PRIM_ORG_LVL_NUMBER,OC.PMG_STAT_CODE, oc.* FROM pmghdree oc WHERE pmg_po_number IN (112152);
SELECT * FROM PMGDTLEE WHERE PMG_PO_NUMBER IN (112152);
SELECT * FROM RCVSSDEE WHERE PMG_PO_NUMBER IN (112152);
    SELECT * FROM WMS_MODELO_REQUEST WHERE MESSAGE_ID = '12172150268801958'; --111388 (FEC_PROCESO => 2024-09-10 18:08:43)
    SELECT HDR.DOWNLOAD_DATE_1, HDR.ERR_CODE, HDR.* FROM WMS_RCV_ASN_HDR HDR WHERE SHIPMENT_NBR = 'NAC000909982'; -- (DOWNLOAD_DATE_1 => 2024-09-10 18:10:02)
    SELECT * FROM EDSR.B2B_OC_RCV_ENVIO  WHERE pmg_po_number IN (112152) AND impuesto_fin = '0'; -- (FEC_PROC_LOG => 2024-09-10 18:40:02)

-- ASN Entrada: NAC000909504 (110899,110753)
 SELECT oc.PRIM_ORG_LVL_NUMBER,OC.PMG_STAT_CODE, oc.* FROM pmghdree oc WHERE pmg_po_number IN (110899,110753);

SELECT oc.PRIM_ORG_LVL_NUMBER,OC.PMG_STAT_CODE, oc.* FROM pmghdree oc WHERE pmg_po_number IN (111388);
SELECT * FROM PMGDTLEE WHERE PMG_PO_NUMBER IN (111388);
SELECT * FROM RCVSSDEE WHERE PMG_PO_NUMBER IN (111388);
    SELECT * FROM WMS_MODELO_REQUEST WHERE MESSAGE_ID = '12172150268801958'; --111388 (FEC_PROCESO => 2024-09-10 18:08:43)
    SELECT HDR.DOWNLOAD_DATE_1, HDR.ERR_CODE, HDR.* FROM WMS_RCV_ASN_HDR HDR WHERE SHIPMENT_NBR = 'NAC000909794'; -- (DOWNLOAD_DATE_1 => 2024-09-10 18:10:02)
    SELECT * FROM EDSR.B2B_OC_RCV_ENVIO  WHERE pmg_po_number IN (111388) AND impuesto_fin = '0'; -- (FEC_PROC_LOG => 2024-09-10 18:40:02)


 -- Extraigo el MODELO, y reemplazo los números que se repiten
 SELECT * FROM WMS_TIPO_MODELO_REQUEST;
 SELECT * FROM WMS_MODELO_REQUEST WHERE IDENTIFICADOR = 'NAC000909504';
 SELECT * FROM WMS_MODELO_REQUEST WHERE MESSAGE_ID = '12044432034516357'; --110899,110753


SELECT * FROM EDSR.B2B_OC_ENVIO WHERE pmg_po_number IN (110899);
SELECT * FROM EDSR.B2B_OC_ENVIO WHERE pmg_po_number IN (111388);
SELECT * FROM EDSR.B2B_OC_RCV_ENVIO
  --UPDATE edsr.B2B_OC_RCV_ENVIO SET FEC_PROC_LOG = null
    WHERE pmg_po_number IN (110899) AND impuesto_fin = '0';

-- 5759,5716,5721 => NAC000909504
SELECT HDR.DOWNLOAD_DATE_1, HDR.ERR_CODE, HDR.* FROM WMS_RCV_ASN_HDR HDR
-- UPDATE WMS_RCV_ASN_HDR SET DOWNLOAD_DATE_1 = NULL, ERR_CODE = NULL
WHERE SHIPMENT_NBR = 'NAC000909504' and HDR_GROUP_NBR IN (5759);

SELECT * FROM PMGHDREE WHERE PMG_PO_NUMBER IN (110899);
SELECT * FROM PMGDTLEE WHERE PMG_PO_NUMBER IN (110899);
SELECT * FROM RCVSSDEE WHERE PMG_PO_NUMBER IN (110899);

SELECT * FROM PMGHDREE WHERE PMG_PO_NUMBER IN (110753);
SELECT * FROM PMGDTLEE WHERE PMG_PO_NUMBER IN (110753);
SELECT * FROM RCVSSDEE WHERE PMG_PO_NUMBER IN (110753);

SELECT * FROM EDSR.B2B_OC_RCV_ENVIO
  --UPDATE edsr.B2B_OC_RCV_ENVIO SET FEC_PROC_LOG = null
    WHERE pmg_po_number IN (110899) AND impuesto_fin = '0';

SELECT * FROM EDSR.B2B_OC_RCV_ENVIO
  --UPDATE edsr.B2B_OC_RCV_ENVIO SET FEC_PROC_LOG = null
    WHERE pmg_po_number IN (110753) AND impuesto_fin = '0';


SELECT  * FROM WMS_RCV_ASN_HDR
-- UPDATE WMS_RCV_ASN_HDR SET SHIPMENT_NBR = 'NAC000909504XXX'
WHERE SHIPMENT_NBR = 'NAC000909504XXX' and HDR_GROUP_NBR IN (5716,5721);
COMMIT;
--ORDER BY DOWNLOAD_DATE_1 DESC;

SELECT  * FROM WMS_RCV_ASN_HDR WHERE LOAD_NBR = '909504'; -- DESPACHO
SELECT  * FROM WMS_RCV_ASN_DTL WHERE HDR_GROUP_NBR = 5759;
SELECT  * FROM WMS_RCV_ASN_DTL WHERE HDR_GROUP_NBR = 5716;
SELECT  * FROM WMS_RCV_ASN_DTL WHERE HDR_GROUP_NBR = 5721;
SELECT * FROM WMS_ERROR_INT;
    --38,UNA DE LAS OCs YA SE ENCUENTRA RECIBIDA O VENCIDA,
    --32,REGISTRO SE ENCUENTRA DUPLICADO,



select distinct
             d.pmg_po_number,
             r.rcv_session_id,
             d.rcv_date,
             0,
             '0'
      from rcvsshee r
        inner join rcvssdee d on d.rcv_session_id = r.rcv_session_id
        inner join pmghdree oc on oc.pmg_po_number = d.pmg_po_number
      where r.rcv_session_sts in (1,2)
        and not exists (
                        select 1
                        from b2b_oc_rcv_envio b2b
                        where b2b.rcv_session_id = r.rcv_session_id
                          and b2b.pmg_po_number  = d.pmg_po_number
                       )
        and oc.cntry_lvl_child in (select to_number(param_value) from chlparam where param_code = 'PAIS');

-- 7 CANCELADO
-- 4 PENDIENTE
SELECT * FROM EDSR.PMGHDREE WHERE PMG_PO_NUMBER IN (108902);
SELECT * FROM EDSR.PMGHDREE WHERE PMG_PO_NUMBER IN (110320);


SELECT * FROM EDSR.WMS_MODELO_REQUEST ORDER BY FEC_REG DESC;
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE FLAG_ERROR = '1';
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR  LIKE '%909296%';
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MODELO LIKE '%909296%' ORDER BY FEC_REG DESC;

SELECT * FROM EDSR.WMS_RCV_ASN_HDR WHERE SHIPMENT_NBR  LIKE '%908008';
SELECT * FROM EDSR.WMS_RCV_ASN_DTL;

-- EDSR.PKG_WMS_GENERAL
-- EDSR.PK_WMS_RCV_ASN_DTL
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE ID_MODELO = 32966 AND ID_TIPO = 2;

/*
BEGIN
UPDATE EDSR.WMS_MODELO_REQUEST SET FLAG_PROCESADO = '0', MODELO = '[H1]NAC000909296|101|HESA|||NAC|909296||||||236|20240806000000|1||909296||||20240808000000
[H2]45||0|0|30583|30583|||||||0|0|0||||2||110320||MERCA|0||||||||||10||||||
[H2]35|LPN10100077462|93.247|1175814|30578|30578|||||||0|0|0||||18||110320||MERCA|18|20251212000000|||||||||12||||||
[H2]36|LPN10100077462|93.247|1175814|30581|30581|||||||0|0|0||||4||110320||MERCA|4|20251212000000|||||||||3||||||
[H2]37|LPN10100077462|93.247|1175814|30582|30582|||||||0|0|0||||3||110320||MERCA|3|20251212000000|||||||||13||||||
[H2]38|LPN10100077462|93.247|1175814|30583|30583|||||||0|0|0||||6||110320||MERCA|6|20251212000000|||||||||10||||||
[H2]39|LPN10100077462|93.247|1175814|30584|30584|||||||0|0|0||||1||110320||MERCA|1|20251212000000|||||||||2||||||
[H2]40|LPN10100077462|93.247|1175814|30585|30585|||||||0|0|0||||1||110320||MERCA|1|20251212000000|||||||||5||||||
[H2]41|LPN10100077462|93.247|1175814|30586|30586|||||||0|0|0||||5||110320||MERCA|5|20251212000000|||||||||14||||||
[H2]42|LPN10100077462|93.247|1175814|30587|30587|||||||0|0|0||||4||110320||MERCA|4|20251212000000|||||||||7||||||
[H2]43|LPN10100077462|93.247|1175814|30589|30589|||||||0|0|0||||9||110320||MERCA|9|20251212000000|||||||||6||||||
[H2]44|LPN10100077462|93.247|1175814|30592|30592|||||||0|0|0||||2||110320||MERCA|2|20251212000000|||||||||16||||||
[H2]1|LPN10100077461|112.48|854064.3|30542|30542|||||||0|0|0||||10||110191||MERCA|10||||||||||1||||||
[H2]2|LPN10100077461|112.48|854064.3|30594|30594|||||||0|0|0||||7||110191||MERCA|7||||||||||2||||||
[H2]3|LPN10100077461|112.48|854064.3|30598|30598|||||||0|0|0||||6||110191||MERCA|6||||||||||3||||||
[H2]4|LPN10100077461|112.48|854064.3|30603|30603|||||||0|0|0||||7||110191||MERCA|7||||||||||4||||||
[H2]5|LPN10100077461|112.48|854064.3|30608|30608|||||||0|0|0||||5||110191||MERCA|5||||||||||5||||||
[H2]6|LPN10100077461|112.48|854064.3|30611|30611|||||||0|0|0||||1||110191||MERCA|1||||||||||6||||||
[H2]7|LPN10100077461|112.48|854064.3|30613|30613|||||||0|0|0||||7||110191||MERCA|7||||||||||7||||||
[H2]8|LPN10100077461|112.48|854064.3|30617|30617|||||||0|0|0||||4||110191||MERCA|4||||||||||8||||||
[H2]9|LPN10100077461|112.48|854064.3|30631|30631|||||||0|0|0||||7||110191||MERCA|7||||||||||9||||||
[H2]10|LPN10100077461|112.48|854064.3|30633|30633|||||||0|0|0||||5||110191||MERCA|5||||||||||10||||||
[H2]11|LPN10100077461|112.48|854064.3|30635|30635|||||||0|0|0||||1||110191||MERCA|1||||||||||11||||||
[H2]12|LPN10100077461|112.48|854064.3|30636|30636|||||||0|0|0||||6||110191||MERCA|6||||||||||12||||||
[H2]13|LPN10100077461|112.48|854064.3|30643|30643|||||||0|0|0||||1||110191||MERCA|1||||||||||13||||||
[H2]14|LPN10100077461|112.48|854064.3|30645|30645|||||||0|0|0||||3||110191||MERCA|3||||||||||14||||||
[H2]15||0|0|30648|30648|||||||0|0|0||||9||110191||MERCA|0||||||||||15||||||
[H2]16|LPN10100077461|112.48|854064.3|30654|30654|||||||0|0|0||||1||110191||MERCA|1||||||||||16||||||
[H2]17|LPN10100077461|112.48|854064.3|30662|30662|||||||0|0|0||||7||110191||MERCA|7||||||||||17||||||
[H2]18|LPN10100077461|112.48|854064.3|30665|30665|||||||0|0|0||||6||110191||MERCA|6||||||||||18||||||
[H2]19|LPN10100077461|112.48|854064.3|30679|30679|||||||0|0|0||||2||110191||MERCA|2|20260101000000|||||||||19||||||
[H2]20|LPN10100077461|112.48|854064.3|30687|30687|||||||0|0|0||||28||110191||MERCA|28|20260101000000|||||||||20||||||
[H2]21|LPN10100077461|112.48|854064.3|30689|30689|||||||0|0|0||||11||110191||MERCA|11|20260101000000|||||||||21||||||
[H2]22||0|0|32109|32109|||||||0|0|0||||1||110191||MERCA|0||||||||||22||||||
[H2]23|LPN10100077461|112.48|854064.3|32110|32110|||||||0|0|0||||1||110191||MERCA|1||||||||||23||||||
[H2]24||0|0|32111|32111|||||||0|0|0||||5||110191||MERCA|0||||||||||24||||||
[H2]25||0|0|32116|32116|||||||0|0|0||||2||110191||MERCA|0||||||||||25||||||
[H2]26||0|0|32118|32118|||||||0|0|0||||2||110191||MERCA|0||||||||||26||||||
[H2]27||0|0|32120|32120|||||||0|0|0||||3||110191||MERCA|0||||||||||27||||||
[H2]28||0|0|32122|32122|||||||0|0|0||||5||110191||MERCA|0||||||||||28||||||
[H2]29|LPN10100077462|93.247|1175814|30568|30568|||||||0|0|0||||6||110320||MERCA|6|20251212000000|||||||||15||||||
[H2]30|LPN10100077462|93.247|1175814|30570|30570|||||||0|0|0||||4||110320||MERCA|4|20251212000000|||||||||4||||||
[H2]31|LPN10100077462|93.247|1175814|30571|30571|||||||0|0|0||||1||110320||MERCA|1|20251212000000|||||||||1||||||
[H2]32|LPN10100077462|93.247|1175814|30573|30573|||||||0|0|0||||4||110320||MERCA|4|20251212000000|||||||||8||||||
[H2]33|LPN10100077462|93.247|1175814|30576|30576|||||||0|0|0||||3||110320||MERCA|3|20251212000000|||||||||11||||||
[H2]34|LPN10100077462|93.247|1175814|30577|30577|||||||0|0|0||||10||110320||MERCA|10|20251212000000|||||||||9||||||'
WHERE ID_MODELO = 44733 AND ID_TIPO = 2;
COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;

 */


procedure sp_sel_modelo_request_pendiente(
    modelos        out t_cursor
)
is
begin

open modelos for
  select id_modelo,
         id_tipo,
         modelo
  from wms_modelo_request
  where flag_procesado = '0';
end;
/*
ID_WMS	    FEC_PROCESADO	    FACILITY_CODE	ACTION_CODE	FEC_REG	            APPT_NBR	LOAD_NBR	CARRIER_INFO                        	ROUND(ESTIMATED_UNITS)
12692609	2024-05-27 17:03:44	101	            CREATE	    2024-05-27 17:00:01	908008	    908008	    ECUADOR FLORAL SAECAFLOR CIA. LTDA.	    385

 */

SELECT FEC_REG,TO_CHAR(FEC_REG, 'YYYY-MM-DD')
FROM EDSR.WMS_CITA_ENVIO
WHERE TO_DATE(FEC_REG)  BETWEEN TO_DATE('2024-06-06', 'YYYY-MM-DD') AND TO_DATE('2024-06-06', 'YYYY-MM-DD')
ORDER BY FEC_REG DESC;

SELECT ID_CITA FROM EDSR.WMS_CITA_ENVIO WHERE TO_DATE(FEC_REG, 'YYYY-MM-DD') = TO_DATE('2024-05-30', 'YYYY-MM-DD');
SELECT count(ID_CITA) FROM EDSR.WMS_CITA_ENVIO WHERE FEC_REG = sysdate -7;
SELECT * FROM EDSR.WMS_CITA_ENVIO ORDER BY FEC_REG DESC;
SELECT * FROM EDSR.WMS_CITA_ENVIO ORDER BY FEC_REG DESC;



CREATE OR REPLACE package body EDSR.PKG_WMS_APPOINTMENT is

  procedure sp_sel_pendientes(
    citas                 out t_cursor
  )
  as
  begin

    open citas for
      select id_cita, appt_nbr
      from wms_cita_envio
      where fec_procesado is null;
  end;

  procedure sp_get_cita(
    p_id_cita           number,
    cabecera            out t_cursor
  )
  as
  begin

    open cabecera for
      select facility_code,
             company_code,
             appt_nbr,
             load_nbr,
             dock_type,
             action_code,
             preferred_dock_nbr,
             planned_start_ts,
             duration,
             estimated_units,
             carrier_info,
             trailer_nbr,
             load_type
      from wms_cita_envio
      where id_cita = p_id_cita;
  end;

  procedure sp_upd_envio(
    p_id_cita             number,
    p_xml_request         clob,
    p_json_response       clob,
    p_flg_error           char,
    p_mensaje             varchar2
  )
  is
  begin

    update wms_cita_envio
      set  fec_procesado = sysdate,
           xml_request   = p_xml_request,
           json_response = p_json_response,
           flg_error     = p_flg_error,
           mensaje       = substr(p_mensaje, 0, 200)
    where id_cita   = p_id_cita;

    commit;
  end;

  procedure sp_sel_validar_existe_en_wms(
    citas                out t_cursor
  )
  is
  begin

    open citas for
      select id_cita,
             appt_nbr
      from wms_cita_envio
      where fec_procesado >= trunc(sysdate-1)
        and flg_error = '0'
        and id_wms is null;
  end;

  procedure sp_upd_id_wms(
    p_id_cita           number,
    p_id_wms            number
  )
  is
  begin

    update wms_cita_envio
      set  id_wms = p_id_wms
    where id_cita = p_id_cita;

    commit;
  end;

end PKG_WMS_APPOINTMENT;
