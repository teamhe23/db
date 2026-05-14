/*
 DEMON RANCHER he-demon-pubsub-wms-suscriptor => Se registra tal cual es enviado desde el WMS Por medio del tipo, que es el tipo 3 para INVENTORY HISTORY, graba el modelo.
    EDSR.PKG_WMS_GENERAL.SP_INS_WMS_MODELO_REQUEST
    TABLA: WMS_MODELO_REQUEST

 DEMON RANCHER he-demon-wms-registrar-output => Lista
    EDSR.PKG_WMS_GENERAL.SP_INS_INV_HISTORY_LOAD
    TABLA: WMS_INV_HISTORY_LOAD

 KSH: wms_inventory_history.ksh
 Path: /prochp/interfaces/wms/import/ksh
 PKG_WMS_INVENTORY_HISTORY.SP_PROCESO_GENERAL
     TABLAS: WMS_INV_HISTORY_LOAD (Tabla temporal)
             WMS_INV_HISTORY
 */
 /*
 RECORDAR: Todo movimiento genera un INVENTORY para mover el inventario
 CASO: Traslado de mercaderia de la 851 a 101
 Cada INVENTORY HISTORY que sale del WMS, viene en grupos, y cada grupo es un archivo plano cada linea se registra como un INVENTORY HISTORY en la tabla WMS_INV_HISTORY,
 Lo que registra en la tabla WMS_INV_HISTORY es :
    1. Movimientos que se realizaron en el WMS (Es decir los clicks, eventos, etc) (ACTIVITY_CODE: 20)
    2. DESPACHO: Movimiento de inventario basado en Transferencias  (ACTIVITY_CODE: 13) (ACTIVITY_CODE: 10: Manda el carton LPN_NBR avisando el PICKINGX )
            2.1. Revisar el campo REF_VALUE_1, graba la OS, ejm: OS85100005882
            2.2. Revisar el campo LPN_NBR, graba las etiquetas, ejm: BEC85100126120
            2.2. Revisar el campo ITEM_PART_A, graba el SKU, ejm: 10881
            2.2. Revisar el campo ORIG_QTY, graba la cantidad que saldra(despacho), ejm: 4

 MAPEO PIX: La tabla WMS_MAPEO_MOV_INV registra el mapeo PIX
 */
SELECT * FROM orgmstee WHERE org_lvl_child IN(420,419,423);
/*
    ORG_LVL_NUMBER
        101     419
        851     420
 */
SELECT * FROM wms_tipo_integracion_org;
SELECT * FROM WMS_MODELO_REQUEST WHERE ID_TIPO = 3 ORDER BY FEC_REG DESC FETCH FIRST 70 ROWS ONLY;
SELECT * FROM WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('OS85100005882','OS85100005021');
SELECT * FROM WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('OS85100012824');
-- Primer caso
SELECT * FROM WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('OS85100012261');
SELECT * FROM WMS_MODELO_REQUEST WHERE MODELO LIKE '%CMP00000010065%'; -- MOVIO INVENTARIO
SELECT * FROM WMS_MODELO_REQUEST WHERE MODELO LIKE '%CMP00000010072%'; --NADA
SELECT * FROM WMS_MODELO_REQUEST WHERE MODELO LIKE '%CMP00000010071%'; --NADA

------------------------
--  WMS_INV_HISTORY
SELECT rowid,group_nbr,ERR_CODE, CREATE_DATE_INT,DOWNLOAD_DATE_1,
       facility_code,ACTIVITY_CODE,
       REF_VALUE_1,ref_value_2,

       shipment_nbr,LPN_NBR,po_nbr,lock_code,
       item_part_a,adj_qty,ORIG_QTY,reason_code, I.*
FROM WMS_INV_HISTORY I
ORDER BY I.CREATE_DATE_INT DESC
FETCH FIRST 80 ROWS ONLY ;


--OS85100005021	BEC85100126080 CMP00000010065   MOVIO INVENTARIO
--OS85100005882	BEC85100126120 CMP00000010072   NADA
--0S85100003822	BEC85100126120 CMP00000010071   NADA
SELECT rowid,CREATE_DATE_INT,ERR_CODE,DOWNLOAD_DATE_1,
       facility_code,ACTIVITY_CODE, REF_VALUE_1,REF_VALUE_2,
       lock_code,LPN_NBR,ORDER_NBR, I.* FROM WMS_INV_HISTORY I
--UPDATE WMS_INV_HISTORY SET download_date_1 = null, err_code  = null;
where
    --ORDER_NBR = 'CMP00000010065'
    ORDER_NBR = 'TRF00000058252' -- prd
   -- ORDER_NBR = 'TRF00000071972' --prd
   -- LPN_NBR in ('OS85100012261')
   -- LPN_NBR in ('BEC85100126080')
   -- LPN_NBR in ('BEC85100126080','BEC85100126120') --6080:Movio inventario
  --and ACTIVITY_CODE = 13
;
select * from PRDMSTEE where PRD_LVL_NUMBER = '10699';
 select h.trf_number, h.trf_status, d.trf_status, d.PRD_LVL_CHILD,d.TRF_REF_NUMBER
                      from trfhdree h, trfdtlee d
                      where h.trf_number = 58252 AND d.PRD_LVL_CHILD = '100697'
                        --and d.trf_ref_number = r_Mov_Inv(i).order_nbr
                        --and d.prd_lvl_child = v_prd_lvl_child;
;
COMMIT;
SELECT * FROM sqlerree WHERE procedure_name = 'INV_HIST.SP_PROCESO_TIENDA' ORDER BY error_date DESC;
SELECT * FROM sqlerree ORDER BY error_date DESC FETCH FIRST 50 ROWS ONLY ;

SELECT * FROM wms_pikexp_mov_inv;
DECLARE
    HOL NUMBER := 0;
BEGIN
     DBMS_OUTPUT.PUT_LINE('------------------ BEGIN PROCESS ------------------');
     PKG_WMS_INVENTORY_HISTORY.SP_PROCESO_GENERAL;
     COMMIT;
     DBMS_OUTPUT.PUT_LINE('------------------ END PROCESS ------------------');
end;

SELECT * FROM WMS_SHP_LOAD_DTL;
SELECT * FROM TRFSTSCD;
/*
 TABLA: INVTRDEE
 Estos son los codigos, recordar:
    ET: TRF en Tránsito     Este suma
    TT: TRF Enviadas        Este resta
 Tambien estos codigos se usan para mover el inventario y que salga en el reporte JSatelite basada en la
 tabla INVAUDEE en los campos INV_MRPT_CODE y INV_DRPT_CODE

TABLA: INVTRDEE
INV_MRPT_CODE
AJ
CP
DP
DS
ET
MI
OM
OO
OT
PM
RB
TD
TP
TR
TT
VT

 */
SELECT I.* FROM INVTRDEE I WHERE INV_MRPT_CODE IN ('ET','TT');
SELECT DISTINCT INV_MRPT_CODE FROM INVTRDEE;
SELECT DISTINCT inv_drpt_code FROM INVTRDEE;

SELECT DISTINCT cod_maestro FROM wms_mapeo_mov_inv;
SELECT DISTINCT cod_detalle FROM wms_mapeo_mov_inv;

SELECT FACILITY_CODE,ACTIVITY_CODE,cod_maestro,cod_detalle, MAP.* FROM wms_mapeo_mov_inv MAP WHERE FACILITY_CODE = '851';
SELECT DISTINCT cod_maestro FROM wms_mapeo_mov_inv MAP WHERE FACILITY_CODE = '851';
SELECT DISTINCT cod_detalle FROM wms_mapeo_mov_inv MAP WHERE FACILITY_CODE = '851';
-- TR y 10 y 10 salen del WMS_MAPEO_MOV_INV
/*
 vCodMaestro := r_map_inv.cod_maestro;
 vCodDetalle := r_map_inv.cod_detalle;
 */

select m.ind_efecto,
              m.cod_maestro,
              m.cod_detalle,
              m.suc_inv,
              m.ind_req_rcv,
              m.ind_sgn_wms
      from wms_mapeo_mov_inv m
      where m.company_code = 'HESA'
          and m.activity_code = p_activity_code
          and nvl(m.reason_code,' ') = nvl(p_reason_code,' ')
          and nvl(m.ref_value_1,' ') = nvl(p_ref_value_1,' ')
          and nvl(m.ref_value_2,' ') = nvl(p_ref_value_2,' ')
          and nvl(m.lock_code,' ')   = nvl(p_lock_code,' ')
          and m.estado = 1
          and m.facility_code = p_facility_code
      order by m.seq_inv;


-- 41 y 01
select i.inv_trn_code, i.inv_type_code from edsr.invtrdee i
where i.inv_mrpt_code = 'TR' and i.inv_drpt_code = '10';

-- 42	01
select i.inv_trn_code, i.inv_type_code from edsr.invtrdee i
where i.inv_mrpt_code = 'TR' and i.inv_drpt_code = '20';

--SE GRABA EN INVTRNEE en columnas respectivamente TRANS_TRN_CODE y TRANS_TYPE_CODE
SELECT * FROM INVTRNEE;

SELECT * FROM INVAUDEE WHERE TRANS_REF = '10065';

SELECT DISTINCT activity_code FROM wms_mapeo_mov_inv WHERE FACILITY_CODE = 851;
SELECT DISTINCT cod_maestro FROM wms_mapeo_mov_inv;

/*
ET - 10 => 47 y 01      ==> ET y 10
TT - 20 => 42 y 02
 */
SELECT * FROM invtrdee WHERE inv_trn_code = '47' AND inv_type_code IN ('01');
SELECT * FROM wms_mapeo_mov_inv WHERE FACILITY_CODE = 851 and ACTIVITY_CODE = 50;
/*
 WMS_MAPEO_MOV_INV
 ACTIVITY_CODE => 851
4
17
19
22
23
24
25
30
49
50
53

ACTIVITY_CODE => 101
25
23
17


 */

select m.ind_efecto,
              m.cod_maestro,
              m.cod_detalle,
              m.suc_inv,
              m.ind_req_rcv,
              m.ind_sgn_wms, m.*
         from wms_mapeo_mov_inv m
where    m.activity_code = 12
         -- and nvl(m.reason_code,' ') = nvl(null,' ')
         -- ref_value_1 LIKE 'OS%'
         -- and nvl(m.ref_value_2,' ') = nvl(null,' ')
         -- and nvl(m.lock_code,' ')   = nvl(null,' ')
        --  and m.estado = 1
          and m.facility_code = '851'
       order by m.seq_inv;

SELECT * FROM WMS_PIKEXP_MOV_INV ;

SELECT * FROM WMS_MODELO_REQUEST WHERE ID_MODELO = 71667;
SELECT * FROM WMS_INV_HISTORY_LOAD WHERE GROUP_NBR = 355128498;
SELECT INV.DOWNLOAD_DATE_1, INV.ERR_CODE, INV.CREATE_DATE_INT, INV.* FROM WMS_INV_HISTORY INV WHERE GROUP_NBR = 355128498;

SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%WMS_INV_HISTORY%' AND TYPE = 'PACKAGE BODY';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%WMS_INV_HISTORY%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%FROM WMS_INV_HISTORY %';

-- CD
select i.rowid id_reg,
             i.group_nbr,
             i.seq_nbr,
             i.company_code,
             i.activity_code,
             i.reason_code,
             i.ref_value_1,
             i.ref_value_2,
             i.item_part_a prd_lvl_number,
             nvl(nvl(i.adj_qty, i.orig_qty),0) adj_qty,
             i.order_nbr,
             i.create_date  trans_date,
             i.shipment_nbr,
             i.lpn_nbr,
             i.lock_code,
             i.facility_code
       from wms_inv_history i
       where i.download_date_1 is null
         and i.err_code is null
         and i.create_date_int >= trunc(sysdate) - 10
         and exists(
           select 1
           from wms_tipo_integracion_org a
             inner join orgmstee b on b.org_lvl_child = a.org_lvl_child
           where a.id_tipo =  12 --c_tipo_integracion_tienda
             and to_char(b.org_lvl_number) = i.facility_code
         )
       and LPN_NBR in ('BEC85100126080','BEC85100126120')
       order by i.group_nbr, i.seq_nbr;

-- Tienda
 select i.rowid id_reg,
             i.group_nbr,
             i.seq_nbr,
             i.company_code,
             i.activity_code,
             i.reason_code,
             i.ref_value_1,
             i.ref_value_2,
             i.item_part_a prd_lvl_number,
             nvl(nvl(i.adj_qty, i.orig_qty),0) adj_qty,
             i.order_nbr,
             i.create_date  trans_date,
             i.shipment_nbr,
             i.lpn_nbr,
             i.lock_code,
             i.facility_code
       from wms_inv_history i
       where i.download_date_1 is null
         and i.err_code is null
         and i.create_date_int >= trunc(sysdate) - 10
         and exists(
           select *
           from wms_tipo_integracion_org a
             inner join orgmstee b on b.org_lvl_child = a.org_lvl_child
           where a.id_tipo = 13
             and to_char(b.org_lvl_number) = i.facility_code
         )
       order by i.group_nbr, i.seq_nbr;

--Mapeo
select * from wms_mapeo_mov_inv m;

select distinct ACTIVITY_CODE from WMS_MAPEO_MOV_INV where facility_code = 851;
select m.ind_efecto,
              m.cod_maestro,
              m.cod_detalle,
              m.suc_inv,
              m.ind_req_rcv,
              m.ind_sgn_wms,
              m.*
        from wms_mapeo_mov_inv m
        where m.company_code = 'HESA'
          and m.facility_code = 851;
              and m.activity_code = 13

              and nvl(m.reason_code,' ') = nvl(null,' ')
              and nvl(m.ref_value_1,' ') = nvl('OS85100005021',' ')
              and nvl(m.ref_value_2,' ') = nvl(null,' ')
              and nvl(m.lock_code,' ')   = nvl(null,' ')
              and m.estado = 1

        order by m.seq_inv;

SELECT * FROM WMS_MODELO_REQUEST WHERE ID_TIPO = 3;
SELECT SYSDATE, TRUNC(SYSDATE) FROM DUAL WHERE  TRUNC(SYSDATE) = to_date('2024-12-11','YYYY-MM-DD') ;
SELECT * FROM WMS_MODELO_REQUEST WHERE ID_TIPO = 3 AND MODELO LIKE '%|102|HESA|%' AND TRUNC(FEC_REG) = to_date('2024-12-11','YYYY-MM-DD') ORDER BY FEC_REG DESC;
SELECT * FROM WMS_MODELO_REQUEST WHERE ID_MODELO IN (71157,71153);
SELECT * FROM WMS_MODELO_REQUEST WHERE WMS_MODELO_REQUEST.MODELO LIKE '357971183|13|102|HESA|%';

SELECT ID_MODELO,ID_TIPO,IDENTIFICADOR,FEC_REG,FLAG_PROCESADO,FEC_PROCESO,FLAG_ERROR,DESC_ERROR,MESSAGE_ID
FROM WMS_MODELO_REQUEST
WHERE MODELO LIKE '%|101|HESA|%'
    AND IDENTIFICADOR NOT LIKE 'NAC%'
ORDER BY FEC_REG DESC;

SELECT * FROM WMS_INV_HISTORY_LOAD
--WHERE FACILITY_CODE = '102'
ORDER BY CREATE_DATE DESC
FETCH FIRST 50 ROWS ONLY;

SELECT DISTINCT FACILITY_CODE FROM WMS_INV_HISTORY_LOAD INV;
SELECT DISTINCT FACILITY_CODE FROM WMS_INV_HISTORY INV;

select * from ALL_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%WMS_INV_HISTORY%';


SELECT * FROM WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('OS85100005862','OS85100005881');
SELECT ERR_CODE, DOWNLOAD_DATE_1,REF_VALUE_1,LPN_NBR, I.* FROM WMS_INV_HISTORY I ORDER BY CREATE_DATE DESC FETCH FIRST 30 ROWS ONLY ;
SELECT ERR_CODE, DOWNLOAD_DATE_1, I.* FROM WMS_INV_HISTORY I WHERE REF_VALUE_1 IN ('OS85100005882');
SELECT ERR_CODE, DOWNLOAD_DATE_1,REF_VALUE_1,ORDER_NBR, I.* FROM WMS_INV_HISTORY I
WHERE REF_VALUE_1 = 'OS85100011881'
    AND ORDER_NBR IN ('TRF00000056990','TRF00000056996')
;
SELECT * FROM wms_mapeo_mov_inv;
SELECT DISTINCT REASON_CODE FROM wms_mapeo_mov_inv;
SELECT DISTINCT REF_VALUE_1 FROM wms_mapeo_mov_inv;
SELECT DISTINCT REF_VALUE_2 FROM wms_mapeo_mov_inv;
SELECT * FROM wms_mapeo_mov_inv WHERE FACILITY_CODE = 851;

SELECT INV.CREATE_DATE, INV.* FROM WMS_INV_HISTORY INV
ORDER BY INV.CREATE_DATE DESC
FETCH FIRST 50 ROWS ONLY;


