/*******************************************************************************
                            TRANSFERENCIAS
********************************************************************************/
SELECT * FROM WMS_ORDER_HDR_ENVIO  ORDER BY FEC_REG DESC FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_PARAMETROS FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_PIKEXP_MOV_INV FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_PURCHASEORDER_ENVIO FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_RCV_ASN_DTL FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_RCV_ASN_HDR FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_RET_MOTIVO FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_RETORNOS FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_SHP_LOAD_DTL FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_SHP_LOAD_HDR FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_STORE_ENVIO FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_TIPO_INTEGRACION FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_TIPO_INTEGRACION_ORG FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_TIPO_INTERFAZ FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_TIPO_MODELO_REQUEST FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_TRF_OC_FEC_PRED FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_VENDOR_ENVIO FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WMS_VENDOR_ENVIO_ANT FETCH FIRST 10 ROWS ONLY;
/*
ORG_LVL_NUMBER => ORG_LVL_CHILD
101 => 419
102 => 423
851 => 420

 transferencia de tienda 101 a 102

    50926   SI VIAJO    (851 => 101)
    50925   NO VIAJO    (101 => 102)

*/
SELECT ORG.ORG_LVL_NUMBER, ORG.* FROM ORGMSTEE ORG WHERE ORG.ORG_LVL_NUMBER IN (101,851,102);
--SELECT * FROM TRFHDREE WHERE TRF_SHIP_LOC = 419 AND TRF_REC_LOC = 420 ORDER BY TRF_ENTRY_DATE DESC;

SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%TRFHDREE%';
SELECT OWNER,NAME, TYPE FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%TRFHDREE%' GROUP BY OWNER,NAME, TYPE;
SELECT OWNER,NAME, TYPE FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%TRFHDREE%' AND NAME LIKE 'PKG_%' GROUP BY OWNER,NAME, TYPE;
SELECT * FROM TRFHDREE WHERE TRF_NUMBER IN (50692,50926,50925);

SELECT * FROM TRFHDREE ORDER BY TRF_ENTRY_DATE DESC;
SELECT * FROM TRFHDREE WHERE TRF_SHIP_DATE IS NULL;
SELECT * FROM TRFDTLAE WHERE TRF_SHIP_DATE IS NULL;
SELECT * FROM TRFHDRAE WHERE TRF_SHIP_DATE IS NULL;
SELECT * FROM TRFSTCEE;
SELECT * FROM TRFSTLEE;
SELECT * FROM TRFSTSCD;

SELECT * FROM TRFDTLEE;
SELECT * FROM wms_tipo_integracion_org;
SELECT * FROM wms_tipo_interfaz;
select * from wms_parametros parwhere WHERE parwhere.cod_par = 'COD_RAZ_REASIG';

SELECT * FROM ORGMSTEE WHERE ORG_LVL_NUMBER IN (101,102,851);
SELECT PARAM_VALUE FROM CHLPARAM WHERE PARAM_CODE = 'SUCTDA';
SELECT C.ORG_LVL_NUMBER, C.*
                FROM ORGMSTEE C
               WHERE C.ORG_LVL_NUMBER = 801;
SELECT * FROM TRFSTSCD;
select sdi.trf_number,sdi.download_date_1,trf.Trf_rls_pick_date,sdi.trf_type_code, sdi.action_code ,sdi.from_loc, trf.trf_status,sdi.reference, sdi.from_loc, sdi.*
from sditrfdte sdi
    inner join trfhdree trf on sdi.trf_number = trf.trf_number
where trf.TRF_NUMBER IN (10043);
;
--c_trf_type_id_1         constant number(2) := 1;
--c_tipo_int_trf_tda_tda  constant number(3) := 15;
--c_trf_est_pickeo        constant number(2) := 3;

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



select sdi.trf_number,sdi.download_date_1,trf.Trf_rls_pick_date,sdi.trf_type_code, sdi.action_code ,
       sdi.from_loc, trf.trf_status,sdi.reference, sdi.from_loc, sdi.*
from sditrfdte sdi
    inner join trfhdree trf on sdi.trf_number = trf.trf_number
where trf.TRF_NUMBER IN (10043,10045);

BEGIN
    EDSR.TP_TRF_CD_PICKED_PROC_SMS;
END;

SELECT * FROM sqlerree
ORDER BY ERROR_DATE DESC
FETCH FIRST 10 ROWS ONLY;


select distinct sditrfdte.trf_number, caldat
from sditrfdte, trfhdree, caldayee
--<CVJ-20180827>
--where sditrfdte.trf_type_code in (3, 4, 7, 8)
where sditrfdte.trf_type_code in (1)
--</CVJ-20180827>>

         and trfhdree.trf_number = sditrfdte.trf_number
         and trfhdree.trf_status = 1
         and download_date_1 is null--;
-- <DCJ 05/11/2018> Solo SMS
         --and sditrfdte.from_loc in (517) -- pase SMS 517
         --and sditrfdte.from_loc in (517, 503, 512, 516) -- pase SMS 503, 512, 516 12/02/2019
         --and sditrfdte.from_loc in (517, 503, 512, 516, 501, 502, 523) -- pase SMS 501, 502, 523 06/03/2019
         --and sditrfdte.from_loc in (517, 503, 512, 516, 501, 502, 523, 528) -- pase SMS 528 11/03/2019
         --and sditrfdte.from_loc in (517, 503, 512, 516, 501, 502, 523, 528, 404, 506, 507, 514, 504, 505, 511, 524, 509, 520) -- pase SMS 08/03/2019
         and sditrfdte.from_loc in (
              SELECT B.ORG_LVL_NUMBER
                FROM ORGMSTEE B
               WHERE B.ORG_LVL_ID = 1
                 AND B.Org_Is_Store = 'T'
                 -- No incluye Vta Institucional
                 --AND B.ORG_LVL_NUMBER NOT IN (603, 641)
               START WITH B.ORG_LVL_CHILD IN
                          (SELECT PARAM_VALUE FROM CHLPARAM WHERE PARAM_CODE = 'SUCTDA')
              CONNECT BY PRIOR B.ORG_LVL_CHILD = B.ORG_LVL_PARENT
         ) -- DCJ 26/08/2019 TODAS LAS TIENDAS
         and sditrfdte.to_loc in (
              SELECT B.ORG_LVL_NUMBER
                FROM ORGMSTEE B
               WHERE B.ORG_LVL_ID = 1
                 AND B.Org_Is_Store = 'T'
                 -- No incluye Vta Institucional
                 --AND B.ORG_LVL_NUMBER NOT IN (603, 641)
               START WITH B.ORG_LVL_CHILD IN
                          (SELECT PARAM_VALUE FROM CHLPARAM WHERE PARAM_CODE = 'SUCTDA')
              CONNECT BY PRIOR B.ORG_LVL_CHILD = B.ORG_LVL_PARENT
              /*UNION
              -- Marketng
              SELECT C.ORG_LVL_NUMBER
                FROM ORGMSTEE C
               WHERE C.ORG_LVL_NUMBER = 801*/)

              /*UNION
            -- Solo algunas tiendas
              select distinct sditrfdte.trf_number, caldat
                from sditrfdte, trfhdree, caldayee
              where sditrfdte.trf_type_code in (1)
                and trfhdree.trf_number = sditrfdte.trf_number
                and trfhdree.trf_status = 1
                and download_date_1 is null
                and sditrfdte.to_loc = 803
                and sditrfdte.from_loc in (503)*/
      ;

SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%TRF_STATUS = 3%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%TRF_STATUS IN%3%';

/*************************** END TRANSFERENCIAS *********************************/