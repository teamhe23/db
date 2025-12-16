SELECT * FROM EDSR.WMS_LOG_INTEGRACION_OC WHERE ID_TIPO = 7 AND IDENTIFICADOR = '1784863';
-- OC CANCELADAS
--estado 4 es pendiente de recepción (OnOrder)
--campo PMG_CNCL_BY_DATE es la fecha de vencimiento de la OC
-- Header
SELECT SDI.DATE_CREATED, SDI.* FROM EDSR.sdipmghde SDI ORDER BY SDI.DATE_CREATED DESC FETCH FIRST 100 ROWS ONLY ;
SELECT sdi.DATE_CREATED, sdi.* FROM EDSR.sdipmghde sdi ORDER BY PMG_PO_NUMBER DESC FETCH FIRST 100 ROWS ONLY ;

BEGIN
    epmm.DATAMAN123('PMG', 'HDR', 'SDI'); -- Cabecera
    epmm.DATAMAN123('PMG', 'DTL', 'SDI'); -- Detalle
    epmm.DATAMAN123('PMG', 'ALL', 'SDI'); -- Distribucion
END;

 

SELECT * FROM EDSR.sdipmghde
where pmg_po_number IN (101994,101995,101996,101997,101998,101999,102000,102001,102002,102003); --102
--where pmg_po_number IN (101984,101985,101986,101987,101988,101989,101990,101991,101992,101993); --101

select oc.PMG_CNCL_BY_DATE,oc.PMG_CNCL_BY_DATE,oc.PMG_STAT_CODE, oc.* from edsr.pmghdree oc where pmg_po_number IN (101492) ;
-- Detalle
SELECT PRD.PRD_LVL_NUMBER, DTL.* FROM EDSR.PMGDTLEE DTL INNER JOIN PRDMSTEE PRD ON DTL.PRD_LVL_CHILD = PRD.PRD_LVL_CHILD where DTL.pmg_po_number IN (101492) ;
SELECT SDI.PMG_CANCEL_DATE, SDI.* FROM EDSR.sdipmghde SDI where pmg_po_number IN (101492) ;

select P.fec_procesado, P.id_wms, P.* from edsr.wms_purchaseorder_envio P ORDER BY FEC_REG DESC FETCH FIRST 10 ROWS ONLY ;
select P.fec_procesado, P.id_wms, P.* from edsr.wms_purchaseorder_envio P
--actualizar para ponerlo como pendiente y vuelva a enviar la interfaz
--update edsr.wms_purchaseorder_envio set fec_procesado = null, id_wms = null
where pmg_po_number IN (101934) and ID_TIPO = 4; --: CREATE:4 | UPDATE:16
COMMIT;

-- Envio de OC a B2B Logistico
BEGIN
    TP_PKG_ARCHIVOS_B2B.sp_genera_archivo_xml_oc;
END;
SELECT DISTINCT SHD.PMG_PO_NUMBER, 'NUEVO' AS TIPO
FROM SDIPMGHDE SHD
    INNER JOIN PMGHDREE OC ON SHD.PMG_PO_NUMBER = OC.PMG_PO_NUMBER
WHERE SHD.DOWNLOAD_DATE IS NULL
    AND SHD.PMG_STAT_CODE = 4
    AND OC.PMG_STAT_CODE <> 7
--and oc.cntry_lvl_child in (select to_number(param_value) from chlparam where param_code = 'PAIS')
union all
select shd.pmg_po_number, 'ACTUALIZAR' AS TIPO
from sdipmghde shd
    inner join pmghdree oc on oc.pmg_po_number = shd.pmg_po_number
where shd.download_date_1 is null
    and shd.tran_type = 'C'
    and shd.pmg_stat_code = 4
    and oc.pmg_stat_code != 7
    --and oc.cntry_lvl_child in (select to_number(param_value) from chlparam where param_code = 'PAIS')
    and exists(select 1 from b2b_oc_envio x where x.pmg_po_number = oc.pmg_po_number and fec_procesado is not null and flg_error = '0');

 select * from edsr.b2b_oc_envio b ORDER BY FEC_REG DESC FETCH FIRST 20 ROWS ONLY ;
 select * from edsr.b2b_oc_envio b where b.fec_procesado is null;
 select b.pmg_po_number || ':' || b.nombre_archivo from edsr.b2b_oc_envio b where b.fec_procesado is null;

SELECT TO_DATE('2024-06-21 13:52:04', 'YYYY-MM-DD HH24:MI:SS') FROM dual;
-- reimpoulso de creacion de skus
SELECT * FROM EDSR.WMS_ITEM_ENVIO
--UPDATE EDSR.WMS_ITEM_ENVIO WMS SET FEC_PROCESADO = NULL
WHERE PRD_LVL_CHILD IN ('119685') AND TRAN_TYPE = 'A' AND FEC_REG = TO_DATE('2024-06-21 13:52:04', 'YYYY-MM-DD HH24:MI:SS') ;
COMMIT;

SELECT PRD_LVL_NUMBER, PRD_LVL_CHILD FROM EDSR.PRDMSTEE WHERE PRD_LVL_NUMBER IN ('35680','35678')  ;
SELECT PRD_LVL_NUMBER, PRD_LVL_CHILD FROM EDSR.PRDMSTEE WHERE PRD_LVL_NUMBER IN ('35067','35014')  ;

select P.fec_procesado, P.id_wms, P.* from edsr.wms_purchaseorder_envio P
--actualizar para ponerlo como pendiente y vuelva a enviar la interfaz
--update edsr.wms_purchaseorder_envio set fec_procesado = null, id_wms = null
where pmg_po_number IN (101073) and ID_TIPO = 4; --4: CREATE 16: UPDATE
COMMIT;

select P.fec_procesado, P.id_wms, P.* from edsr.wms_purchaseorder_envio P
--actualizar para ponerlo como pendiente y vuelva a enviar la interfaz
--update edsr.wms_purchaseorder_envio set fec_procesado = null, id_wms = null
where pmg_po_number IN (107038,106998) and ID_TIPO = 16; --4: CREATE 16: UPDATE
COMMIT;

ROLLBACK;



/*
rancher
https://rancher.promart.pe/p/c-2lcgr:p-9pgzm/workload/deployment:he-ti-wms:he-ti-demon-wms-purchaseorder
tiene menú contextual
 */

-- 3319
SELECT * FROM edsr.cartel_dp
where codigo_promocion=3364;
SELECT p.ATR_CODE, p.* FROM EPMM.SDIPRDATI p;
--PMM
-- Mensajes
select * from pmgstscd where pmg_stat_code IN (4,6,7);
-- OC (pmg_po_number)
select oc.PRIM_ORG_LVL_NUMBER,OC.PMG_STAT_CODE, oc.* from pmghdree oc where pmg_po_number IN (108902);
select oc.PMG_EFFECT_DATE,oc.PRIM_ORG_LVL_NUMBER, oc.* from pmghdree oc order by oc.PMG_EFFECT_DATE DESC;


SELECT WPE.VPC_TECH_KEY ProveedorID, WPE.* FROM EDSR.PMGHDREE WPE WHERE PMG_PO_NUMBER = 101072;
SELECT DTL.* FROM EDSR.PMGDTLEE DTL WHERE PMG_PO_NUMBER = 101072;
-- PROVEEDOR
SELECT WPE.VENDOR_NUMBER CodigoProveedor_TurboEntry, WPE.* FROM EDSR.VPCMSTEE WPE WHERE VPC_TECH_KEY = 14482;
SELECT WPE.VENDOR_NUMBER CodigoProveedor_TurboEntry, WPE.* FROM EDSR.VPCMSTEE WPE WHERE VENDOR_NUMBER = '1792318769001';

--ASN: Indicar al WMS algo llegara.
/*
    Mercaderia por OC
    Mercaderia por Transferencia
 */

--integración WMS con PMM => recepción OC
select * from edsr.wms_rcv_asn_dtl where po_nbr = '101073';
select * from edsr.wms_rcv_asn_hdr where hdr_group_nbr in (203);
select * from edsr.wms_rcv_asn_hdr where SHIPMENT_NBR = 'NAC000905778';
select * from edsr.wms_error_int;



--integración pmm con b2b logistico
select RCV.FEC_PROC_LOG, RCV.* from edsr.B2B_OC_RCV_ENVIO RCV
--UPDATE edsr.B2B_OC_RCV_ENVIO SET FEC_PROC_LOG = null
WHERE pmg_po_number IN (101073) AND impuesto_fin = '0';

-- Si no sale en B2B_OC_RCV_ENVIO => Verificar el PMG_STAT_CODE, si es 7 => Turbo Entry => Reapertura de OC, Sino Continuar...
SELECT HDR.PMG_STAT_CODE, HDR.* FROM PMGHDREE HDR WHERE PMG_PO_NUMBER IN (101073);

-- WMS => ASN de Entrada  => Verificar el ASN: NAC___(908075) ():Numero de despacho, ___ = 000 => NAC000908075
SELECT * FROM WMS_MODELO_REQUEST WHERE IDENTIFICADOR like '%NAC%';

SELECT * FROM EDSR.B2BACKEE2 WHERE B2B_MENSAJE LIKE '744828%'ORDER BY 1 DESC;
SELECT * FROM EDSR.B2BACKEE2 ORDER BY 1 DESC;

-- Cambiar IVA
-- PORCENTAJES IVA - CODIGOS SAP
SELECT * FROM EDSR.B2B_IMPUESTO_SAP;
-- 105353 (IVA CORRECTO 5%), 105168 (IVA CORRECTO 15%)
SELECT * FROM PMGHDREE WHERE PMG_PO_NUMBER = 105168;
SELECT * FROM RCVSSDEE WHERE PMG_PO_NUMBER = 105353;
SELECT * FROM RCVTXSEE WHERE RCV_DTL_TECH_KEY IN (5375883, 5375884, 5375885, 5375886, 5375887, 5375888) AND TXS_RATE = 15;

SELECT * FROM EDSR.B2B_OC_RCV_ENVIO WHERE PMG_PO_NUMBER IN (105353) AND IMPUESTO_FIN = '4';
SELECT * FROM EDSR.B2B_OC_RCV_ENVIO WHERE PMG_PO_NUMBER IN (105168) AND IMPUESTO_FIN = '3';

-- Revisar si hubo respuestas desde el B2B Financiero (ACK DEL B2B FINANCIERO)
SELECT * FROM EDSR.B2BACKEE2 WHERE B2B_MENSAJE LIKE '748003%'; -- EL 'B2B_MENSAJE' ES EL CAMPO 'RCV_SESSION_ID' DE LA TABLA 'B2B_OC_RCV_ENVIO'
SELECT * FROM EDSR.B2BACKEE2 WHERE B2B_MENSAJE LIKE '747966%';


BEGIN
    --UPDATE edsr.B2B_OC_RCV_ENVIO SET FEC_PROC_LOG = null
    --WHERE pmg_po_number = 104533 AND impuesto_fin = '0';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION: ' || SQLERRM) ;
        ROLLBACK ;
END;

/*
 1 obtener el numero de la recepcion de la OC B2B_OC_RCV_ENVIO (RCV_SESSION_ID)
 2. /prochp/interfaces/b2b/export/out.log/log en esta ruta buscar el RCV_SESSION_ID, Si hay archivo signica que si lo envio
 3. /prochp/interfaces/b2b/import /in.log o /in BUSCAR POR  RCV_SESSION_ID  o NUM_DESPACHO  (archivos con RE_, significa respuesta) (IAP ESS no es)
 4. Sino hacer un update para reenviar el interfaz porque el B2B no lo ha PROCESADO (Verificar en el B2B el monto despachado debe pasar al monto ...)
 5. Si sigue pendiente Enviar Correo al equipo soporte BBR, con el OC, Numeero Recepcion (campo RCV_SESSION_ID) y adjuntar el xml (campo XML_DATA_LOG)que se esta enviando.
 */


--integración pmm con b2b financiero
select * from edsr.B2B_OC_RCV_ENVIO where pmg_po_number = 101073 and impuesto_fin != '0';
select * from edsr.b2backee2 where b2b_mensaje like '744849%';

select * from edsr.b2backee2 where b2b_tipo_mens = 'QR' order by 1 desc;


SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE FLAG_PROCESADO = '0' OR FLAG_ERROR = '1';
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR = 'NAC000905648';
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MODELO LIKE '%NAC000905648%';
SELECT * FROM EDSR.WMS_RCV_ASN_HDR WHERE SHIPMENT_NBR = 'NAC000905648';


/*
EDSR.WMS_VENDOR_ENVIO

EDSR.WMS_BARCODE_ENVIO

EDSR.WMS_PURCHASEORDER_ENVIO

EDSR.WMS_MODELO_REQUEST

EDSR.WMS_SHP_LOAD_HDR

EDSR.WMS_RCV_ASN_HDR

EDSR.WMS_INV_HISTORY

EDSR.WMS_INV_HISTORY_LOAD

EDSR.WMS_ORDER_HDR_ENVIO

EDSR.WMS_CITA_ENVIO

EDSR.WMS_ASN_HDR

EDSR.WMS_ASN_HDR_ENVIO

 */

-- SE LE ENVIA AL API PARA CREAR EL ORDER
SELECT * FROM EDSR.WMS_ORDER_HDR_ENVIO WHERE TRF_NUMBER =19923;

-- REENVIO DE INTERFACE DE CREACION DE PRODUCTO (ITEM)
SELECT * FROM EDSR.WMS_ITEM_ENVIO WMS
-- UPDATE EDSR.WMS_ITEM_ENVIO WMS SET FEC_PROCESADO = NULL
WHERE WMS.PRD_LVL_CHILD = '124508' AND TRAN_TYPE = 'A';



SELECT PRD.PRD_LVL_NUMBER, PRD.PRD_LVL_CHILD, PRD.PRD_NAME_FULL FROM EDSR.WMS_ITEM_ENVIO WMSITEM INNER JOIN PRDMSTEE PRD ON PRD.PRD_LVL_NUMBER = PRD.PRD_LVL_NUMBER
WHERE PRD.PRD_LVL_NUMBER = '35812';

SELECT PRD_LVL_CHILD FROM TPPRDMST WHERE PRD_LVL_NUMBER = 32550;

-- PMM
SELECT TRF.TRF_QTY_REQ, TRF.* FROM TRFDTLEE TRF WHERE TRF_NUMBER = 19923 AND PRD_LVL_CHILD = '121307' ;
SELECT TRF.TRF_QTY_REQ, TRF.* FROM TRFDTLEE TRF WHERE TRF_NUMBER = 19923 AND PRD_LVL_CHILD  IN ('102218','105065');
SELECT PRD_LVL_NUMBER,PRD_LVL_CHILD FROM TPPRDMST WHERE PRD_LVL_NUMBER IN ('12232','15149');

DECLARE
    V_NUMBER NUMBER;
    TF_CURSOR SYS_REFCURSOR;
    TF_CURSOR2 SYS_REFCURSOR;
BEGIN
    SELECT 25 INTO V_NUMBER FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('V_NUMBER' || V_NUMBER);
    EDSR.PKG_WMS_ORDER.SP_GET_ORDER(V_NUMBER,TF_CURSOR,TF_CURSOR2);
END;