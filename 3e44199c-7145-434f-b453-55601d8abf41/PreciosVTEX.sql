select * from edsr.hp_vtex_promocion WHERE HP_VTEX_PROMOCION.COD_PROMOCION IN (1283,1281);
select * from edsr.hp_vtex_promocion_tienda WHERE  ID_PROMOCION IN (1291,1293);
select * from edsr.hp_vtex_promocion_sku WHERE PRD_LVL_NUMBER = '10196';

select * from edsr.HP_SUC_VTEX;
select * from edsr.HP_VTEX_PROMO_DPC_FINAL;

SELECT * FROM PRDMSTEE WHERE PRD_LVL_NUMBER = '10196';

SELECT * FROM EDSR.HP_VTEX_PRODUCTO WHERE PRD_LVL_CHILD  = 100197;

/* */
--insert into EDSR.HP_VTEX_PRODUCTO
select prd_lvl_child
from edsr.tpprdmst prd
where  prd.prd_lvl_number in ('11828',
'11829',
'10195',
'137589',
'137588',
'137590',
'137591',
'137593',
'90002',
'137600') and not exists(select 1 from EDSR.HP_VTEX_PRODUCTO x where x.prd_lvl_child = prd.prd_lvl_child);
COMMIT;



 select res.cod_tienda,
           res.prd_lvl_number,
           res.id_promocion,
           res.fec_inicio,
           res.fec_final,
           min(res.precio) as precio
    from (
      select
          first_value(p.id_promocion) over(partition by pt.cod_tienda, pp.prd_lvl_number order by 4) as id_promocion,
             pt.cod_tienda,
             pp.prd_lvl_number,
             case
               when p.tipo = 'PRF' then p.valor
               when p.tipo = 'PRC' then pmm.prc_price - (pmm.prc_price * (p.valor / 100))
               else 0
             end as precio,
             first_value(p.fec_inicio) over(partition by pt.cod_tienda, pp.prd_lvl_number order by 4) as fec_inicio,
             first_value(p.fec_final) over(partition by pt.cod_tienda, pp.prd_lvl_number order by 4) as fec_final,
            p.VALOR
      from edsr.hp_vtex_promocion p
        inner join edsr.hp_vtex_promocion_tienda pt on pt.id_promocion = p.id_promocion
        inner join edsr.hp_vtex_promocion_sku pp on pp.id_promocion = p.id_promocion
        inner join edsr.hp_vtex_carga_precios_diff pmm on pmm.org_lvl_number = pt.cod_tienda and pmm.prd_lvl_number = pp.prd_lvl_number
      where pp.tipo = 'I'
    ) res
    group by res.id_promocion,
             res.cod_tienda,
             res.prd_lvl_number,
             res.fec_inicio,
             res.fec_final
 ;



-- PASO 3
-- EDSR.PKG_VTEX_INTEGRACION_PRECIOS.HP_VTEX_CARGA_PRECIOS_DIFF
-- EXECUTE IMMEDIATE 'TRUNCATE TABLE HP_VTEX_CARGA_PRECIOS_DIFF';

/*
 INSERT INTO EDSR.HP_VTEX_CARGA_PRECIOS_DIFF(
      ID_SUC_VTEX,
      ORG_LVL_NUMBER,
      PRD_LVL_NUMBER,
      FEC_INI,
      FEC_FIN,
      PRC_PRICE,
      PRC_PRICE_LIST
    )
 */
    select distinct
           vt.vtex_id as suc_vtex,
           prc.org_lvl_number,
           prc.prd_lvl_number,
           null fec_ini,
           null fec_fin,
           nvl(nvl(prc.prc_vig_suc,prc.prc_eti_cad),v.prc_price) prc_price,
           nvl(prc.prc_eti_cad,v.prc_price) prc_price_list
    from edsr.hp_prc_cad_vig_fec prc
        inner join edsr.HP_VTEX_PRODUCTO vp on vp.prd_lvl_child = prc.prd_lvl_child
        inner join edsr.orgmstee org on prc.org_lvl_child = org.org_lvl_child
        inner join HP_SUC_VTEX vt on vt.org_lvl_child = org.org_lvl_child
        left join chlprce2 v on prc.PRD_LVL_CHILD = V.PRD_LVL_CHILD
        and v.org_lvl_child = prc.org_lvl_child
    where vt.estado = 1
      and nvl(nvl(prc.prc_vig_suc,prc.prc_eti_cad),v.prc_price) is not null;