/*
419	101	GYE ORELLANA
423	102	UIO GRANADOS
420	851	CD GUAYAQUIL

RTV_STATUS_ID	RTV_STS_DESC
0	Trabajo
1	Autorización pendiente
2	Autorizado
3	Liberado para recoger
4	Recogido
5	Despachado
6	Completado
7	En Manifiesto
8	Cancelado
10	Trabajo en tienda
11	Despachado en tienda

 */

 /*
  10253,10274
  */
SELECT ORG_LVL_CHILD, ORG_LVL_NUMBER, ORG_NAME_FULL FROM ORGMSTEE WHERE ORG_LVL_NUMBER IN (101,102,851);
SELECT * FROM RTVSSDEE;
--Estados RTV
SELECT * FROM RTVSTSCD;

-- vpc_tech_key: CodigoProveedor:1790541282001 (GUTIERREZ NAVAS SU FERRETERIA CIA. LTD)
select rtv_number,rtv_status,vpc_tech_key, RTV.* from rtvhdree RTV where RTV_NUMBER IN ('10274','10253');
select vpc.cntry_lvl_child, vpc.* from vpcmstee VPC WHERE VPC_TECH_KEY = '14472';

select fec_procesado, RTV.* from b2b_rtv_envio RTV where RTV_NUMBER IN ('10274','10253'); --where fec_procesado is null


select rtv.rtv_number
from rtvhdree rtv
    inner join vpcmstee vpc on vpc.vpc_tech_key = rtv.vpc_tech_key
where rtv.rtv_status = 6
    and not exists(select 1 from b2b_rtv_envio b2b where b2b.rtv_number = rtv.rtv_number)
    and vpc.cntry_lvl_child in (select to_number(param_value) from chlparam where param_code = 'PAIS');