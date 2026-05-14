/*
    1. Cloud Function:
        https://us-west1-prd-promartec-sistemas-wms.cloudfunctions.net/he-wms-outbound-load
    2. Pub/Sub
    3. RANCHER DEMON: he-ti-demon-pubsub-wms-suscriptor (Siempre)
        (EDSR.PKG_WMS_GENERAL.SP_INS_WMS_MODELO_REQUEST)
        INSERT INTO WMS_MODELO_REQUEST (P_ID_MODELO,P_ID_TIPO,P_MODELO,P_MESSAGE_ID)
            1: outbound-load
            2: verificacion_asn (ASN)
            3: inventory_history
            4: order_crossdock

    4. RANCHER DEMON: he-demon-wms-registrar-output (Cada 5 min)
        4.1. Selecciona todos los pendientes, sin importar el tipo
        (EDSR.PKG_WMS_GENERAL.sp_sel_modelo_request_pendiente)
        SELECT * FROM WMS_MODELO_REQUEST (flag_procesado = '0')


        4.2. Para este caso, selecciona el tipo 2 (Verificacion ASN), y registra todo el modelo del WMS en columnas divididas por |
        (EDSR.PKG_WMS_GENERAL.SP_INS_SHP_LOAD_HDR)
        INSERT INTO WMS_RCV_ASN_HDR

    RECORDAR:
        ASN NACIONALES comienzan con NAC....
        
        EDSR.PKG_WMS_SHIPMENT_VERIFICATION
        SP: sp_verification_oc

 */

--Estados:
select * from epmm.pmgstscd where pmg_stat_code IN (4,6,7);

SELECT * FROM WMS_MODELO_REQUEST ORDER BY FEC_REG FETCH FIRST 50 ROWS ONLY ;
SELECT * FROM WMS_MODELO_REQUEST WHERE ID_MODELO = 99411;

/**
 * 
 * CASOS:
 * OC 149456 => NAC000928739
 * OC 120787 => NAC000914760
 */
--155059
SELECT ERR_CODE,HDR.* FROM WMS_RCV_ASN_HDR HDR WHERE SHIPMENT_NBR IN ('NAC000931376') ;
SELECT DTL.ERR_CODE, DTL.* FROM WMS_RCV_ASN_DTL DTL WHERE DTL.HDR_GROUP_NBR = 26888;


-- B2B FINANCIERO
SELECT RCV.FEC_PROC_FIN, RCV.* FROM edsr.B2B_OC_RCV_ENVIO RCV
--UPDATE edsr.B2B_OC_RCV_ENVIO SET FEC_PROC_FIN = NULL
--WHERE pmg_po_number IN (10253,10274) AND impuesto_fin != '0';
WHERE pmg_po_number IN (155059) AND impuesto_fin != '0'; --2025-05-12 12:05:01.000
COMMIT;

-- B2B Logistico
select FEC_PROC_LOG,RCV.* from edsr.B2B_OC_RCV_ENVIO RCV
--UPDATE edsr.B2B_OC_RCV_ENVIO SET FEC_PROC_LOG = null
WHERE pmg_po_number IN (155059) AND impuesto_fin = '0';
COMMIT;

-- CONSULTA OC
SELECT PMG.PRIM_ORG_LVL_number, PMG.PMG_PO_NUMBER,PMG.PMG_STAT_CODE,STS.PMG_STAT_NAME, PMG.VPC_TECH_KEY ProveedorID
,TRIM(VPC.VENDOR_NUMBER) VENDOR_NUMBER,VPC.VENDOR_NAME,PMG_CNCL_BY_DATE
, PMG.* 
FROM EPMM.PMGHDREE PMG 
	INNER JOIN EPMM.VPCMSTEE VPC ON VPC.VPC_TECH_KEY = PMG.VPC_TECH_KEY
	LEFT JOIN epmm.pmgstscd STS ON STS.PMG_STAT_CODE = PMG.PMG_STAT_CODE
WHERE PMG.PMG_PO_NUMBER IN (150938);
COMMIT;
