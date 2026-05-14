
/*
    1. Cloud Function:
        https://us-west1-prd-promartec-sistemas-wms.cloudfunctions.net/he-wms-inventory-history
    2. Pub/Sub
    3. RANCHER DEMON: he-ti-demon-pubsub-wms-suscriptor (Siempre)
        (EDSR.PKG_WMS_GENERAL.SP_INS_WMS_MODELO_REQUEST)
        INSERT INTO WMS_MODELO_REQUEST (P_ID_MODELO,P_ID_TIPO,P_MODELO,P_MESSAGE_ID)
            1: outbound-load
            2: verificacion_asn
            3: inventory_history (INVENTORY HISTORY)
            4: order_crossdock

    4. RANCHER DEMON: he-demon-wms-registrar-output (Cada 5 min)
        4.1. Selecciona todos los pendientes, sin importar el tipo
        (EDSR.PKG_WMS_GENERAL.sp_sel_modelo_request_pendiente)
        SELECT * FROM WMS_MODELO_REQUEST (flag_procesado = '0')


        4.2. Para este caso, selecciona el tipo 3 (inventory history), y registra todo el modelo del WMS en columnas divididas por |
        (EDSR.PKG_WMS_GENERAL.SP_INS_INV_HISTORY_LOAD)
        INSERT INTO WMS_INV_HISTORY_LOAD


     5. PMM KSH: wms_inventory_history.ksh (Diario, Cada 5min de 7pm a 10pm)
        (pkg_wms_inventory_history.sp_proceso_general)
        5.1: sp_procesa_load => Carga pendientes de la tabla WMS_INV_HISTORY_LOAD => WMS_INV_HISTORY


        5.2: sp_proceso_cd =>
            Proceso inserta movimientos de inventario en PMM a partir de la interface
            inventory_history de WMS. Los registros son procesados segun el Mapeo de PIX.
            SELECT * FROM WMS_INV_HISTORY
            SELECT * FROM WMS_MAPEO_MOV_INV
            ...

        5.3: sp_proceso_tienda => LO MISMO QUE sp_proceso_cd con alguna variantes
 */

SELECT * FROM WMS_MODELO_REQUEST WHERE ID_TIPO = '3' ORDER BY FEC_REG DESC FETCH FIRST 50 ROWS ONLY;

--Registra DEMON he-demon-wms-registrar-output (RANCHER)
--    INSERT INTO WMS_INV_HISTORY_LOAD

SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%WMS_INV_HISTORY_LOAD%';

SELECT distinct FACILITY_CODE fROM EDSR.WMS_INV_HISTORY_LOAD L;
SELECT * FROM wms_inv_history where FACILITY_CODE = '102';
SELECT * FROM wms_tipo_integracion_org;
SELECT * FROM orgmstee;

SELECT
    L.ID_HISTORY_LOAD,L.*
    --DISTINCT ID_HISTORY_LOAD
FROM EDSR.WMS_INV_HISTORY_LOAD L
WHERE L.CH_DUPLICADO = '0';

select 1
from wms_tipo_integracion_org a
    inner join orgmstee b on b.org_lvl_child = a.org_lvl_child
where a.id_tipo = 12 --c_tipo_integracion_cd
    and to_char(b.org_lvl_number) = 102;

SELECT distinct FACILITY_CODE FROM wms_inv_history;
 SELECT L.ID_HISTORY_LOAD,L.CH_DUPLICADO, L.*
      FROM EDSR.WMS_INV_HISTORY_LOAD L
      WHERE L.CH_DUPLICADO = '0';