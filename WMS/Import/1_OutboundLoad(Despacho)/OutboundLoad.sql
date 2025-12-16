
/*
    1. Cloud Function:
        https://us-west1-prd-promartec-sistemas-wms.cloudfunctions.net/he-wms-outbound-load
    2. Pub/Sub
    3. RANCHER DEMON: he-ti-demon-pubsub-wms-suscriptor (Siempre)
        (EDSR.PKG_WMS_GENERAL.SP_INS_WMS_MODELO_REQUEST)
        INSERT INTO WMS_MODELO_REQUEST (P_ID_MODELO,P_ID_TIPO,P_MODELO,P_MESSAGE_ID)
            1: outbound-load (OUTBOUND LOAD)
            2: verificacion_asn
            3: inventory_history
            4: order_crossdock

    4. RANCHER DEMON: he-demon-wms-registrar-output (Cada 5 min)
        4.1. Selecciona todos los pendientes, sin importar el tipo
        (EDSR.PKG_WMS_GENERAL.sp_sel_modelo_request_pendiente)
        SELECT * FROM WMS_MODELO_REQUEST (flag_procesado = '0')


        4.2. Para este caso, selecciona el tipo 3 (inventory history), y registra todo el modelo del WMS en columnas divididas por |
        (EDSR.PKG_WMS_GENERAL.SP_INS_SHP_LOAD_HDR)
        INSERT INTO WMS_SHP_LOAD_HDR


     5. PMM KSH: wms_shipped_loads.ksh (Diario, Cada 5min de 7pm a 10pm)
        (edsr.PKG_WMS_OUTBOUND_LOAD.sp_proceso_general)
        5.1: .SP_PROCESAR_TRF => Carga pendientes de la tabla WMS_SHP_LOAD_HDR y WMS_SHP_LOAD_DTL
            5.1.1.  sp_procesar_cab =>
                    Verifica si hay duplicados (err 32)
                    Verifica si existe la tienda (orgmstee)
                    Verifica que load_manifest_nbr sea NO NULL

            5.1.2.  sp_procesar_det =>
                    Verifica EXISTENCIA PRODUCTO
                    Verifica si existe la tienda (orgmstee)
                    Extrae de ORDER_NBR el TRF y consulta en TRFDTLEE
                    Evalua de TRF_STATUS (TRFDTLEE) que no sea ni 0 ni 5
            5.1.3.


        5.2: .SP_PROCESAR_RTV =>
            Proceso inserta movimientos de inventario en PMM a partir de la interface
            inventory_history de WMS. Los registros son procesados segun el Mapeo de PIX.
            SELECT * FROM WMS_INV_HISTORY
            SELECT * FROM WMS_MAPEO_MOV_INV
            ...

        5.3: sp_proceso_tienda => LO MISMO QUE sp_proceso_cd con alguna variantes
 */
/*
 RECORDAR: Todo movimiento genera un INVENTORY para mover el inventario
 CASO: Traslado de mercaderia de la 851 a 101
 El Outbound que es el DESPACHO o SALIDA de la mercadería genera un INVENTORY HISTORY (851)
 El ASN Entrada es la RECEPCION o LLEGADA de la mercaderia genera un INVENTORY HISTORY (101)
 */
-- OK : OS85100012521
-- BAD: OS85100011881, OS85100011921
SELECT * FROM WMS_MODELO_REQUEST ORDER BY FEC_REG DESC FETCH FIRST 30 ROWS ONLY ;
SELECT * FROM WMS_MODELO_REQUEST
WHERE MODELO LIKE '%OS85100004627%'
    AND FEC_REG <= SYSDATE --TO_dATE('2025-01-01', 'YYYY-MM-DD')
    AND FEC_REG >= TO_dATE('2025-01-01', 'YYYY-MM-DD')
;

SELECT * FROM WMS_MODELO_REQUEST ORDER BY FEC_REG DESC FETCH FIRST 30 ROWS ONLY ;
SELECT * FROM WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('OS85100005862','OS85100005881');
SELECT * FROM WMS_SHP_LOAD_HDR ORDER BY CREATE_DATE DESC FETCH FIRST 20 ROWS ONLY ;
SELECT * FROM WMS_ERROR_INT; --ERRORES

--57995
SELECT HDR.ERR_CODE, ERR.ERR_DESC, DOWNLOAD_DATE_1, HDR.* FROM WMS_SHP_LOAD_HDR HDR
         LEFT JOIN WMS_ERROR_INT ERR ON ERR.ERR_CODE = HDR.ERR_CODE
WHERE LOAD_MANIFEST_NBR IN ('OS85100010561')
    --ERR.ERR_CODE = 24;
;

SELECT d.HDR_GROUP_NBR,d.LINE_NBR,d.SEQ_NBR, h.DOWNLOAD_DATE_1, d.err_code, h.load_manifest_nbr,h.hdr_group_nbr, d.ORDER_NBR,d.ITEM_ALTERNATE_CODE,d.SHIPPED_QTY,D.ob_lpn_nbr carton_number, d.*
FROM wms_shp_load_hdr h
        INNER JOIN wms_shp_load_dtl d on h.hdr_group_nbr = d.hdr_group_nbr
WHERE h.LOAD_MANIFEST_NBR = 'OS85100010561';-- h.hdr_group_nbr = 609
--WHERE ORDER_NBR = 'TRF000000';-- h.hdr_group_nbr = 609
;

--REIMPULSAR
SELECT DOWNLOAD_DATE_1, ERR_CODE, H.* FROM wms_shp_load_hdr H
--UPDATE WMS_SHP_LOAD_HDR SET download_date_1 = null, err_code = null
WHERE HDR_GROUP_NBR = 952;
COMMIT;


SELECT HDR_GROUP_NBR,ORDER_NBR,D.ITEM_ALTERNATE_CODE,D.ERR_CODE, D.* FROM wms_shp_load_dtl D
--DELETE WMS_SHP_LOAD_DTL
WHERE HDR_GROUP_NBR = 952 and ORDER_NBR = 'TRF00000058252' and item_alternate_code = '13918' ;



SELECT * FROM trfhdree WHERE TRF_NUMBER = 58252;
SELECT TRF_STATUS,p.PRD_LVL_NUMBER
FROM trfdtlee d inner join PRDMSTEE p on d.PRD_LVL_CHILD = p.PRD_LVL_CHILD
WHERE d.TRF_NUMBER = 58252 and PRD_LVL_NUMBER IN ('13918','11026','10699','10753','10646','14098','10697','10701');



COMMIT;

SELECT * FROM SDIRTVDTI;
SELECT * FROM TP_IMP_TRF_CD;

 select d.TRF_STATUS, d.*
          from trfdtlee d
          where d.trf_number    = 57680
            --and d.prd_lvl_child = v_prd_lvl_child
            and d.trf_qty_req   != 0;


SELECT * FROM tp_imp_trf_cd;