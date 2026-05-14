/*
--------------------------------------------------------------
                    CARGAS DE WMS EN PMM
                    wms_shipped_loads.ksh
                5,15,25,35,45,55 6-22 * * *
--------------------------------------------------------------
EJECUTA: EDSR.PKG_WMS_OUTBOUND_LOAD.sp_proceso_general

--------------------------------------------------------------
                    VERIFICACIONES DE ASN
                wms_shipment_verification.ksh
                0,10,20,30,40,50 5-22 * * *
--------------------------------------------------------------
EJECUTA: EDSR.PKG_WMS_SHIPMENT_VERIFICATION.sp_proceso_general
        WMS_SHP_LOAD_HDR

*/


select tpi.tip_wms, tpi.*
from wms_tipo_interfaz tpi
where tpi.des_int = 'ASN'
and tpi.tip_int in ('DEVOLUCION_CD', 'DIST_FRANCHISE');
/*
 Falla en integración de en la verificación de la ASN OS10100000041, esta carga corresponde a una transferencia de 101 a 102. la verificación se realizó el 23/11/2024, según las revisiones de las interfaces de salida, esto se procesó correctamente en WMS, pero el inventario no se ha movido en PMM. Se intento nuevamente enviar la interfaz de verificación ayer 28/11/2024 pero no tuvo éxito, su ayuda con la revisión, pues tenemos $21K de mercadería que no ha viajado de Orellana a Granados, descuadrando los stocks 
 */
-- Si paso con exito: OS10100000021

select * from wms_rcv_asn_hdr WHERE SHIPMENT_NBR LIKE 'OS%' ORDER BY CREATE_DATE DESC FETCH FIRST 10 ROWS ONLY ;

SELECT * FROM WMS_ERROR_INT;


-- PRIMERA TABLA
SELECT ID_MODELO, ID_TIPO, IDENTIFICADOR, FEC_REG FROM  WMS_MODELO_REQUEST WHERE IDENTIFICADOR IS NULL;
SELECT * FROM wms_modelo_request
WHERE
    ID_TIPO = 2 AND
    --MODELO LIKE '[H1]OS%' AND
    IDENTIFICADOR IN ('OS85100012261')
    --FEC_REG < TO_DATE('2024-11-24','YYYY-MM-DD') AND FEC_REG >= TO_DATE('2024-11-23','YYYY-MM-DD')
--FETCH FIRST 10 ROWS ONLY
;


SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%WMS_SHP_LOAD_HDR%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%UPDATE%WMS_SHP_LOAD_HDR%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '% WMS_RCV_ASN_HDR %';
SELECT * FROM EDSR.WMS_SHP_LOAD_HDR ;
SELECT * FROM WMS_ERROR_INT ;


SELECT * FROM WMS_SHP_LOAD_HDR
WHERE LOAD_MANIFEST_NBR LIKE 'OS85100012261%'
ORDER BY CREATE_DATE DESC
;
SELECT HC.CREATE_DATE, HC.ERR_CODE, ERR.ERR_DESC ,HC.load_manifest_nbr, HC.*
FROM    WMS_SHP_LOAD_HDR HC
    LEFT JOIN WMS_ERROR_INT ERR ON ERR.ERR_CODE = HC.ERR_CODE
WHERE  HC.LOAD_MANIFEST_NBR IN ('OS85100012162');

SELECT dtl.err_code, dtl.* FROM WMS_SHP_LOAD_DTL dtl WHERE HDR_GROUP_NBR = 950; --OS85100012162

SELECT CREATE_DATE, dtl.err_code, HDR.HDR_GROUP_NBR,HDR.LOAD_MANIFEST_NBR, dtl.*
FROM WMS_SHP_LOAD_DTL dtl INNER JOIN WMS_SHP_LOAD_HDR HDR ON HDR.HDR_GROUP_NBR = DTL.HDR_GROUP_NBR
WHERE DTL.err_code = 24;

select m.trf_manifest_id, m.* from edsr.trfmfhee m where TRF_MANIFEST_ID  IN ('OS85100012261');
select m.* from edsr.trfmfhee m WHERE TRF_SHIP_LOC = '419' AND TRF_REC_LOC = '423' ORDER BY TRF_CREATE_DATE DESC FETCH FIRST 800 ROWS ONLY ;
select m.* from edsr.TRFMFPEE m where TRF_MANIFEST_KEY  IN (119919);

/*
 HDR_GROUP_NBR => 7632 , 7709
 SHIPMENT_NBR => OS10100000041 , OS10100000021
 */

     --sobrantes grabar en repositorio
      --obtener lo que no se envio en la carga(sobrantes en el asn)
        select 1 id_reg_det,
             2 seq_nbr,
             asn.shipment_nbr,
             asn.lpn_nbr,
             asn.item_alternate_code prd_lvl_number,
             asn.received_qty quantity,
             'SOBRANTE' tipo,
             trim(leading '0' from(case
                         when substr(dc.order_nbr, 1, 3) = 'TTD' then
                          substr(dc.order_nbr, 8)
                         else
                          substr(dc.order_nbr, 5)
                       end)) trf,
             dc.order_nbr
       from WMS_SHP_LOAD_DTL dc
       inner join WMS_SHP_LOAD_HDR hc on hc.hdr_group_nbr = dc.hdr_group_nbr
       right join (select ha.shipment_nbr,
                          da.seq_nbr,
                          da.lpn_nbr,
                          da.item_alternate_code,
                          da.received_qty,
                          ha.download_date_1
                     from WMS_RCV_ASN_DTL da
                    inner join WMS_RCV_ASN_HDR ha
                       on ha.hdr_group_nbr = da.hdr_group_nbr
                    where ha.hdr_group_nbr = 7632) asn
           on asn.shipment_nbr = hc.load_manifest_nbr
           and asn.lpn_nbr = dc.ob_lpn_nbr
           and asn.item_alternate_code = dc.item_alternate_code

       where asn.shipment_nbr = 'OS10100000041'
        -- and hc.load_manifest_nbr is null
        -- and asn.download_date_1 is null
         and not exists
       (select *
                from wms_order_hdr oh
               inner join wms_order_dtl od
                  on od.hdr_group_nbr = oh.hdr_group_nbr
               where oh.order_nbr = dc.order_nbr);
;
-- UNION ALL
select  1 id_reg_det,
        2 seq_nbr,
         carga.load_manifest_nbr,
         carga.lpn_nbr,
         carga.prd_lvl_number,
         asn.shipped_qty - asn.received_qty quantity,
         'FALTA_UNID' tipo,
         carga.trf,
         carga.order_nbr
from (select hc.load_manifest_nbr,
                     dc.ob_lpn_nbr lpn_nbr,
                     dc.item_alternate_code prd_lvl_number,
                     sum(dc.shipped_qty) quantity,
                     trim(leading '0' from(case
                                 when substr(dc.order_nbr, 1, 3) = 'TTD' then
                                  substr(dc.order_nbr, 8)
                                 else
                                  substr(dc.order_nbr, 5)
                               end)) trf,
                     dc.order_nbr
                from wms_shp_load_dtl dc
               inner join wms_shp_load_hdr hc
                  on hc.hdr_group_nbr = dc.hdr_group_nbr
               where hc.load_manifest_nbr = 'OS10100000041'
                 and hc.err_code = 0 --aqui
                 and substr(dc.order_nbr, 1, 3) not in
                     ('BTC', 'TVO', 'RET', 'CON', 'DED', 'BTP')
               group by hc.load_manifest_nbr,
                        ob_lpn_nbr,
                        dc.item_alternate_code,
                        trim(leading '0' from(case
                                    when substr(dc.order_nbr, 1, 3) = 'TTD' then
                                     substr(dc.order_nbr, 8)
                                    else
                                     substr(dc.order_nbr, 5)
                                  end)),
                        dc.order_nbr) CARGA
       inner join (select ha.shipment_nbr,
                          da.seq_nbr,
                          da.lpn_nbr lpn_nbr,
                          da.item_alternate_code,
                          da.shipped_qty,
                          da.received_qty
                     from wms_rcv_asn_dtl da
                    inner join wms_rcv_asn_hdr ha
                       on ha.hdr_group_nbr = da.hdr_group_nbr
                    where ha.hdr_group_nbr = 7632) asn
          on asn.shipment_nbr = carga.load_manifest_nbr
         and asn.lpn_nbr = carga.lpn_nbr
         and asn.item_alternate_code = carga.prd_lvl_number
       where asn.shipped_qty - asn.received_qty > 0
;
-- UNION ALL
select 1 id_reg_det,
             2 seq_nbr,
             hc.load_manifest_nbr,
             dc.ob_lpn_nbr lpn_nbr,
             dc.item_alternate_code prd_lvl_number,
             sum(dc.shipped_qty) quantity,
             decode(asn.shipment_nbr, null, 'FALTANTE', 'NORMAL') tipo,
             trim(leading '0' from(case
                         when substr(dc.order_nbr, 1, 3) = 'TTD' then
                          substr(dc.order_nbr, 8)
                         else
                          substr(dc.order_nbr, 5)
                       end)) trf,
             dc.order_nbr
        from wms_shp_load_dtl dc
       inner join wms_shp_load_hdr hc
          on hc.hdr_group_nbr = dc.hdr_group_nbr
        left join (select ha.shipment_nbr,
                          da.seq_nbr,
                          da.lpn_nbr lpn_nbr,
                          da.item_alternate_code,
                          da.received_qty
                     from wms_rcv_asn_dtl da
                    inner join wms_rcv_asn_hdr ha
                       on ha.hdr_group_nbr = da.hdr_group_nbr
                    where ha.hdr_group_nbr = 7632) asn
          on asn.shipment_nbr = hc.load_manifest_nbr
         and asn.lpn_nbr = dc.ob_lpn_nbr
         and asn.item_alternate_code = dc.item_alternate_code
       where hc.load_manifest_nbr = 'OS10100000041'
         and hc.err_code = 0
         and asn.shipment_nbr is null
         and substr(dc.order_nbr, 1, 3) not in
             ('BTC', 'TVO', 'RET', 'CON', 'DED', 'BTP')
       group by hc.load_manifest_nbr,
                ob_lpn_nbr,
                dc.item_alternate_code,
                decode(asn.shipment_nbr, null, 'FALTANTE', 'NORMAL'),
                trim(leading '0' from(case
                            when substr(dc.order_nbr, 1, 3) = 'TTD' then
                             substr(dc.order_nbr, 8)
                            else
                             substr(dc.order_nbr, 5)
                          end)),
                dc.order_nbr;

--Verificacion de errores
select e.DATE_CREATED, e.download_date_1, e.error_code, e.carton_number, e.prd_lvl_number, e.*
from epmm.sditrfdti e
ORDER BY e.DATE_CREATED DESC;

select e.error_date, e.procedure_name, e.*
from epmm.sqlerree e
where procedure_name = 'sp_verificacion_carga_cd_tienda'
ORDER BY e.error_date DESC;



select m.trf_manifest_id from edsr.trfmfhee m;
/*
 TDA
TAL
TDT
TME
TDA
TDP
FRA

 */
-- Listar pendientes
 select h.rowid,
             h.hdr_group_nbr,
             h.shipment_nbr,
             h.facility_code AS to_loc,
             h.shipment_type,
             h.shipped_date
      from wms_rcv_asn_hdr h
      where
          h.shipment_type IN
             (
              select tpi.tip_wms
                from wms_tipo_interfaz tpi
              where tpi.des_int = 'ASN'
                and tpi.tip_int in ('DEVOLUCION_CD', 'DIST_FRANCHISE')
             ) and
         h.download_date_1 IS NULL
        and h.err_code is null
    --and  SHIPMENT_NBR IN ('OS10100000041','OS10100000021');
        ;

select m.trf_manifest_id, m.* from edsr.trfmfhee m where TRF_MANIFEST_ID  IN ('OS10100000041','OS10100000021');
select m.* from edsr.trfmfhee m where TRF_MANIFEST_ID  IN ('OS10100000041','OS10100000021');
select m.* from edsr.trfmfhee m ORDER BY TRF_CREATE_DATE DESC FETCH FIRST 800 ROWS ONLY ;
select m.* from edsr.trfmfhee m WHERE TRF_SHIP_LOC = '419' AND TRF_REC_LOC = '423' ORDER BY TRF_CREATE_DATE DESC FETCH FIRST 800 ROWS ONLY ;

SELECT trf_number FROM trfrfxee
WHERE trf_rcv_ref_number = '';
SELECT * FROM EPMM.trfdrcee;

SELECT (SEQ.LAST_NUMBER - 1) AS SEQUENCE_NOW, SEQ.LAST_NUMBER  , SEQ.* FROM DBA_SEQUENCES SEQ WHERE SEQUENCE_NAME = 'TRF_MANIFEST_KEY';
SELECT (SEQ.LAST_NUMBER - 1) AS SEQUENCE_NOW, SEQ.LAST_NUMBER  , SEQ.* FROM DBA_SEQUENCES SEQ WHERE SEQUENCE_OWNER = 'EPMM' AND SEQUENCE_NAME LIKE 'TRF%';
SELECT (SEQ.LAST_NUMBER - 1) AS SEQUENCE_NOW, SEQ.LAST_NUMBER  , SEQ.* FROM DBA_SEQUENCES SEQ WHERE SEQUENCE_NAME = '%TRF%MANIFEST%KEY%' ;
SELECT (SEQ.LAST_NUMBER - 1) AS SEQUENCE_NOW, SEQ.LAST_NUMBER  , SEQ.* FROM DBA_SEQUENCES SEQ ;

DECLARE
BEGIN

END;
insert into edsr.trfmfhee (TRF_MANIFEST_KEY, TRF_MANIFEST_ID, TRF_SHIP_LOC, TRF_REC_LOC, TRF_PRD_ASN, TRF_CAR_ASN, TRF_CREATE_DATE, TRF_SHIP_DATE, TRF_REC_DATE, TRF_CLOSE_DATE, TRF_CAR_ID, TRF_MANIFEST_STS, TOT_CHG_EFFECT, TOT_ALW_EFFECT, ALW_CHG_FLAG, TOT_CHG_LUMP_SUM, TOT_ALW_LUMP_SUM)
values (119827, 'OS10100000041', 419, 423, 'F', 'T', DATE '2024-12-04', DATE '2024-12-04', DATE '2024-12-04', null, 1, 5, 0.00000, 0.00000, null, null, null);


SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%TRFMFHEE%';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%UPDATE%TRFMFHEE%';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%TRF_MANIFEST_STS%=%';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%TRFDTLIM%';


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
        and substr(h.facility_code, 1, 1) <> '8';

-- Procesar
 select o.org_lvl_number, h.trf_status
        --  into v_from_loc, v_sts_trf
        from trfhdree h
          inner join orgmstee o on o.org_lvl_child = h.trf_ship_loc
        where h.trf_number = v_num_trf;

select * from wms_rcv_asn_hdr WHERE  SHIPMENT_NBR IN ('OS10100000041');
SELECT substr('OS10100000041', 4) FROM DUAL;
select * from WMS_RCV_ASN_DTL WHERE  HDR_GROUP_NBR = '7881';
select * from trfhdree WHERE TRF_NUMBER = 55872;
select * from trfhdree WHERE TRF_SHIP_LOC = '419' AND TRF_REC_LOC = '423';
--PMM Recepción Completa: 54771
--PMM enviado a Pickeo: 55877
select trf.download_date_1, trf.* from trfhdree trf WHERE TRF_NUMBER IN  (55877, 54771) ORDER BY TRF_NUMBER DESC;
select sdi.download_date_1, sdi.action_code , sdi.trf_type_code, sdi.* from sditrfdte sdi WHERE TRF_NUMBER IN  (55877, 54771) ORDER BY TRF_NUMBER DESC;

select HDR.TRF_NUMBER, HDR.order_type, HDR.*
from wms_order_hdr_envio HDR
WHERE TRF_NUMBER IN (55877, 54771)
ORDER BY FEC_REG DESC FETCH FIRST 20 ROWS ONLY ;

/*
trf_number  trf_prior_id    audit_number
57695	        10	        4584795933
57313	        64	        4584112651
57312	        64	        4584112652
57311	        64	        4584112649
57310	        64	        4584112650
57309	        64	        4584112648
 */


SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%WMS_RCV_ASN%'