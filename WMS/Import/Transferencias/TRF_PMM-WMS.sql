--Tiendas y CD
SELECT ORG.ORG_LVL_NUMBER, ORG.* FROM ORGMSTEE ORG WHERE ORG.ORG_LVL_NUMBER IN (101,851,102);
--Estados
SELECT * FROM TRFSTSCD;
/*
ORG_LVL_NUMBER => ORG_LVL_CHILD
         101   =>   419
         102   =>   423
         851   =>   420

-- ESTADOS
0	00.En Trabajo
1	01.Aprobada
3	03.Enviada a Pickeo


TRANSFERENCIA DE TIENDA 101 A 102
    TRFHDREE:       Tabla de transferencias
    TRF_SHIP_LOC:   Localidad de Envío
    TRF_REC_LOC:    Localidad Recibo

EDSR.PKG_WMS_ORDER.sp_carga_trf_tda_a_tda
*/

SELECT TRF.TRF_STATUS, TRF.* FROM TRFHDREE TRF
WHERE TRF_SHIP_LOC = 419 AND TRF_REC_LOC = 423
    AND TRF_NUMBER IN ('57309','57310','57311','57312','57313')
ORDER BY TRF_ENTRY_DATE DESC;

--DEJAR EN ESTADO 'PICKEADA' (TRF_STATUS=3) A TODAS LAS TRANSFERENCIAS
BEGIN
    EDSR.TP_TRF_CD_PICKED_PROC_SMS;
END;

--SE ENVIA A WMS
--he-ti-demon-wms-order
--https://rancher.oechsle.pe/dashboard/c/c-th9w7/explorer/apps.deployment/he-ti-wms/he-ti-demon-wms-order#pods



SELECT TRF.TRF_STATUS, TRF.* FROM TRFHDREE TRF WHERE TRF.TRF_NUMBER IN (55888);
select
    --id_order_hdr, order_nbr,
    *
      from wms_order_hdr_envio
      where TRF_NUMBER IN (55888)
          --fec_procesado is null
        --and id_tipo = p_id_tipo
;
--
/*
 2024-12-02T16:54:53.220014607Z       Transferencias de tienda a tienda

2024-12-02T16:54:53.787722531Z      Cargar orders
ORA-01400: cannot insert NULL into ("EDSR"."WMS_ORDER_HDR_ENVIO"."ORDER_TYPE")
ORA-06512: at "EDSR.PKG_WMS_ORDER", line 768
ORA-06512: at "EDSR.PKG_WMS_ORDER", line 768
ORA-06512: at "EDSR.PKG_WMS_ORDER", line 40
ORA-06512: at line 1
 */
/*
 tp_trf_cd_picked_proc_sms;
 sp_carga_trf_tda_a_tda;
 */
SELECT par.val_par, PAR.* FROM wms_parametros par WHERE par.cod_par IN ('COD_EMPR','COD_RAZ_NORMAL') ;

--EDSR.PKG_WMS_ORDER.SP_CARGA_TRF_TDA_A_TDA
--LISTAR PENDIENTES
select sdi.trf_number,
              trf.trf_prior_id,
              min(sdi.audit_number) as audit_number
from sditrfdte sdi
    inner join trfhdree trf ON trf.trf_number = sdi.trf_number
where sdi.action_code = '00'
    and sdi.trf_type_code IN (1) --c_trf_type_id_1
    and sdi.from_loc in (
                          select x2.org_lvl_number
                          from wms_tipo_integracion_org x
                            inner join orgmstee x2 on x2.org_lvl_child = x.org_lvl_child
                          where x.id_tipo = 15 --c_tipo_int_trf_tda_tda
                        )
    and sdi.download_date_1 is null
    and trf.trf_status = 3 --c_trf_est_pickeo
    and sdi.reference NOT LIKE 'WMS%'
group by sdi.trf_number,
            trf.trf_prior_id;

-- *********************************

    select tor.pref_int, tor.tip_wms
     -- into v_ord_prefijo_tnor, v_order_type_tnor
    from wms_tipo_interfaz tor
    where tor.cod_int = 'TRF_TDA_SMS';
select distinct
    trf.trf_prior_id,
             'v_id_order_hdr',
             'c_tipo_int_trf_tda_tda',
             sdi.from_loc,
             'HESA',
             decode(trf.trf_prior_id,'10','TTD','v_ord_prefijo') || sdi.from_loc || 'C' || lpad(to_char(trf.trf_number), 10, '0'),
             decode(trf.trf_prior_id,'10','TTD','v_order_type'),
             sysdate,
             sdi.to_loc,
             'CREATE',
             trf.trf_number
      from trfhdree trf
        inner join sditrfdte sdi on sdi.trf_number = trf.trf_number
      where
          --trf.trf_number = trf_reg.trf_number
        --and sdi.audit_number = trf_reg.audit_number and

        sdi.action_code = '00'
        and sdi.download_date_1 is null
        and sdi.to_loc = '102'
        AND trf.trf_prior_id <> 10
;