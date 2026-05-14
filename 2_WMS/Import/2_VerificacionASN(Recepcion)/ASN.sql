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
        ASN IMPORTADAS comienzan con OS.....

 */
/*
 RECORDAR: Todo movimiento genera un INVENTORY para mover el inventario
 CASO: Traslado de mercaderia de la 851 a 101
 El Outbound que es el DESPACHO o SALIDA de la mercadería genera un INVENTORY HISTORY (851)
 El ASN Entrada es la RECEPCION o LLEGADA de la mercaderia genera un INVENTORY HISTORY (101)
 */

SELECT * FROM WMS_MODELO_REQUEST ORDER BY FEC_REG FETCH FIRST 50 ROWS ONLY ;
SELECT * FROM WMS_MODELO_REQUEST WHERE ID_MODELO = 99411;

SELECT * FROM WMS_MODELO_REQUEST WHERE ID_TIPO = 2 AND MODELO NOT LIKE '[H1]NAC%' ORDER BY FEC_REG DESC FETCH FIRST 50 ROWS ONLY ;
SELECT * FROM WMS_MODELO_REQUEST WHERE ID_TIPO = 2 AND MODELO LIKE '[H1]OS%' ORDER BY FEC_REG DESC FETCH FIRST 50 ROWS ONLY ;

SELECT * FROM WMS_MODELO_REQUEST WHERE ID_TIPO = 2 AND MODELO LIKE '%OS85100015322%' ORDER BY FEC_REG DESC FETCH FIRST 50 ROWS ONLY ;

SELECT * FROM WMS_MODELO_REQUEST WHERE ID_TIPO = 2 AND MODELO LIKE '%905089%' ORDER BY FEC_REG DESC FETCH FIRST 50 ROWS ONLY ;

SELECT * FROM WMS_ERROR_INT;
SELECT * FROM PMGSTSCD;

SELECT * FROM WMS_RCV_ASN_HDR ORDER BY CREATE_DATE DESC FETCH FIRST 50 ROWS ONLY;

/*
 * OS85100015321 => 2025-04-04 10:46:13.000
 * OS85100015322 => 2025-04-04 08:30:56.000
 */
SELECT HDR.* FROM WMS_RCV_ASN_HDR HDR WHERE SHIPMENT_NBR IN ('OS85100025121') ;
SELECT DTL.ERR_CODE, DTL.* FROM WMS_RCV_ASN_DTL DTL WHERE DTL.HDR_GROUP_NBR = 1181;

SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%B2B_OC_RCV_ENVIO%';

SELECT m.trf_manifest_id, M.* FROM TRFMFHEE m  ORDER BY TRF_MANIFEST_KEY DESC;
SELECT m.trf_manifest_id, M.* FROM TRFMFHEE m  ORDER BY TRF_CREATE_DATE DESC;
SELECT m.trf_manifest_id, M.* FROM TRFMFHEE m WHERE m.trf_manifest_id LIKE '%OS85100015701%';

SELECT * FROM TRFSTSEE;

SELECT m.trf_manifest_id, M.* FROM TRFMFHEE m WHERE m.trf_manifest_id LIKE '%OS85100025121%';
SELECT m.trf_manifest_id, M.* FROM TRFMFHEE m WHERE m.trf_manifest_id LIKE '%OS85100015321%'; --2025-04-04 00:00:00.000
SELECT m.trf_manifest_id, M.* FROM TRFMFHEE m WHERE m.trf_manifest_id LIKE '%OS85100015603%'; --2025-04-04 00:00:00.000
SELECT m.trf_manifest_id, M.* FROM TRFMFHEE m WHERE m.trf_manifest_id LIKE '%OS85100015621%'; --2025-04-04 00:00:00.000

SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%TRFMFHEE%';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%WMS_ORDER_HDR';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%SP_INS_ORDER_HDR%';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%TRFDTLIM%';

SELECT DOWNLOAD_DATE_1, ERR_CODE, HDR.* FROM WMS_RCV_ASN_HDR HDR
WHERE substr(HDR.shipment_nbr, 1, 2) != 'OS'
ORDER BY HDR.DOWNLOAD_DATE_1 DESC
;

 select h.rowid         as id_reg_cab,
             h.shipment_nbr,
             h.facility_code as to_loc,
             h.shipped_date,
             h.hdr_group_nbr
      from edsr.wms_rcv_asn_hdr h
      where h.shipment_type is null
        and h.shipment_nbr in (select m.trf_manifest_id from edsr.trfmfhee m)
        and h.download_date_1 is null
        and h.err_code is null
        and substr(h.facility_code, 1, 1) <> '8'
         AND h.shipment_nbr = 'NAC000905089'
;

SELECT * FROM wms_order_hdr FETCH FIRST 1 ROWS ONLY;
SELECT count(*) FROM wms_order_hdr;
select distinct
             oh.rowid,
             oh.hdr_group_nbr,
             oh.order_nbr,
             oh.facility_code,
             oh.dest_facility_code
      from wms_order_hdr oh
        inner join wms_order_dtl od on oh.hdr_group_nbr = od.hdr_group_nbr
        left join wms_rcv_asn_hdr ra on od.shipment_nbr = ra.shipment_nbr
      where oh.download_date_1 is null
        and oh.err_code is null
        and nvl(ra.err_code, -1) = 0
        and ra.download_date_1 is not null
        and od.ord_qty > 0
        and exists ( 
                     select 1
                     from wms_rcv_asn_dtl b
                     where b.hdr_group_nbr = ra.hdr_group_nbr
                       and b.lpn_nbr = od.req_cntr_nbr
                       and b.item_part_a = od.item_part_a
                       and b.received_qty > 0
                   );

--DETALLE ASN
SELECT DTL.PO_NBR, DTL.*
FROM WMS_RCV_ASN_DTL DTL
WHERE DTL.HDR_GROUP_NBR = 10038
;

-- OC
SELECT * FROM PMGHDREE WHERE PMG_PO_NUMBER IN (120382,120138,120139);
/*
 CASO PRD
 OS85100012261
 */
SELECT CREATE_DATE, ERR_CODE, HDR.* FROM WMS_RCV_ASN_HDR HDR WHERE SHIPMENT_NBR = 'OS85100012261';




SELECT CREATE_DATE, ERR_CODE, HDR.* FROM WMS_RCV_ASN_HDR HDR WHERE ERR_CODE  > 0 ORDER BY hdr.CREATE_DATE DESC;
SELECT ERR_CODE, DTL.* FROM WMS_RCV_ASN_DTL DTL WHERE HDR_GROUP_NBR = 9397;

SELECT CREATE_DATE, ERR_CODE, HDR.* FROM WMS_RCV_ASN_HDR HDR WHERE SHIPMENT_NBR = 'OS85100012823';
SELECT ERR_CODE, DTL.* FROM WMS_RCV_ASN_DTL DTL WHERE HDR_GROUP_NBR = 9897;

SELECT CREATE_DATE, ERR_CODE, HDR.* FROM WMS_RCV_ASN_HDR HDR WHERE SHIPMENT_NBR = 'OS85100012541';
SELECT ERR_CODE, DTL.* FROM WMS_RCV_ASN_DTL DTL WHERE HDR_GROUP_NBR = 9692;