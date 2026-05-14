/*
	419	101	GYE ORELLANA
	423	102	UIO GRANADOS
*/
SELECT RPL_MIN_STK,RPL_MAX_STK, LPM.* 
FROM EPMM.RPLPMHEE LPM
WHERE ORG_LVL_NUMBER = 101 AND
PRD_LVL_NUMBER = '19520'
;

SELECT * FROM EPMM.RPLSCHEE FETCH FIRST 20 ROWS ONLY;
SELECT * FROM EPMM.RPLSCDEE FETCH FIRST 20 ROWS ONLY;
SELECT * FROM EPMM.RPLPMHEE FETCH FIRST 20 ROWS ONLY; --PRODUCTOS MIN y MAX
SELECT * FROM EPMM.RPLMMXEE FETCH FIRST 20 ROWS ONLY;
SELECT * FROM EPMM.RPLWGTEE FETCH FIRST 20 ROWS ONLY;
SELECT * FROM EPMM.RPLPMOEE FETCH FIRST 20 ROWS ONLY;

select e.org_lvl_number sucursal,
		e.prd_lvl_number sku,
		h.prf_wgt_weeks semanas
		e.rpl_min_stk min,
       	e.rpl_max_stk max       
  from EPMM.rplpmhee e,
       EDSR.tpprdmst f,
       EPMM.whsprdee g,
       (select distinct f.pmh_tech_key, f.prf_wgt_weeks from EPMM.RPLWGTEE f) h,
       EPMM.rplmthcd s,
       EPMM.rpldmtcd d,
       epmm.RPLPFHEE pe
 where (select x.caldat from EPMM.caldayee x) between e.rpl_begdate and
       e.rpl_enddate
   and e.prd_lvl_child = f.prd_lvl_child
   and e.prd_lvl_child = g.prd_lvl_child
   and g.org_lvl_child in
       (select to_number(trim(param_value))
          from EPMM.chlparam
         where param_code in ('CENTRODIS'))
   and e.rpl_method_code = s.rpl_method_code
   and e.rpl_dist_method = d.dmt_code
   and e.pmh_tech_key = h.pmh_tech_key
   AND e.PRF_TECH_KEY= pe.PRF_TECH_KEY
   

--JSatelite
select f.cod_area,
       f.des_area,
       f.cod_dpto,
       f.des_dpto,
       e.prd_lvl_number SKU,
       f.prd_full_name SKU_DES,
       f.cod_prv,
       f.des_prv,
       f.des_est,
       f.des_proce Procedencia,
       e.org_lvl_number SUC,
       e.org_name_full SUC_DES,
       g.trf_dist_pak PARAMETRO_CD,
       s.rpl_desc, --
       d.dmt_desc,
       pe.PRF_DESC PERFIL,
       e.rpl_min_stk MIN,
       e.rpl_max_stk MAX,
       e.rpl_enddate FECHA_FIN,
       e.rpl_review_days DIAS_REV,
       e.rpl_proc_days DIAS_PROC,
       h.prf_wgt_weeks SEMANAS,
       e.rpl_ss SEMANAS_SR,
       (select WGT_FACTOR
          from EPMM.RPLWGTEE
         WHERE PMH_TECH_KEY = e.pmh_tech_key
           AND WGT_WEEK = 4) AS SEM4,
       (select WGT_FACTOR
          from EPMM.RPLWGTEE
         WHERE PMH_TECH_KEY = e.pmh_tech_key
           AND WGT_WEEK = 3) AS SEM3,
       (select WGT_FACTOR
          from EPMM.RPLWGTEE
         WHERE PMH_TECH_KEY = e.pmh_tech_key
           AND WGT_WEEK = 2) AS SEM2,
       (select WGT_FACTOR
          from EPMM.RPLWGTEE
         WHERE PMH_TECH_KEY = e.pmh_tech_key
           AND WGT_WEEK = 1) AS SEM1
  from EPMM.rplpmhee e,
       EDSR.tpprdmst f,
       EPMM.whsprdee g,
       (select distinct f.pmh_tech_key, f.prf_wgt_weeks from EPMM.RPLWGTEE f) h,
       EPMM.rplmthcd s,
       EPMM.rpldmtcd d,
       epmm.RPLPFHEE pe
 where (select x.caldat from EPMM.caldayee x) between e.rpl_begdate and
       e.rpl_enddate
   and e.prd_lvl_child = f.prd_lvl_child
   and e.prd_lvl_child = g.prd_lvl_child
   and g.org_lvl_child in
       (select to_number(trim(param_value))
          from EPMM.chlparam
         where param_code in ('CENTRODIS'))
   and e.rpl_method_code = s.rpl_method_code
   and e.rpl_dist_method = d.dmt_code
   and e.pmh_tech_key = h.pmh_tech_key
   AND e.PRF_TECH_KEY= pe.PRF_TECH_KEY
   /*
   AND F.COD_AREA IN decode('0', '0', F.COD_AREA, '0')
   and f.prd_lvl_number in (decode(0, 0, f.prd_lvl_number,0))
   and e.org_lvl_number in (decode(0, 0, e.org_lvl_number,0)
   */
;