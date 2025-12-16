-- 10931 (Codigo Promocion DPC)
SELECT * FROM HP_VTEX_PROMOCION;
SELECT DISTINCT DESC_PROMOCION FROM HP_VTEX_PROMOCION;
SELECT * FROM HP_VTEX_PROMOCION WHERE DESC_PROMOCION LIKE '%CR%';
SELECT * FROM HP_VTEX_PROMOCION_TIENDA;
SELECT * FROM HP_VTEX_PROMOCION_SKU;

-- DIFERENCIAS_PRECIOS
SELECT * FROM HP_VTEX_CARGA_PRECIOS_DIFF;
SELECT * FROM hp_prc_cad_vig_fec;
SELECT * FROM hp_vtex_promo_dpc_final;

-- PRECIOS a enviar a VTEX
SELECT * FROM HP_VTEX_PRICE_FIXED;
SELECT * FROM HP_VTEX_PRICE VP WHERE VP.SKU IN ('10047',
'10048',
'10049',
'10050',
'10051',
'10052',
'10053',
'10054',
'10055')
ORDER BY VP.SKU;
/**/

--VALIDACION
SELECT VP.SKU, VPF.VALUE, VPF.LISTPRICE --, VPF.*
FROM HP_VTEX_PRICE_FIXED VPF
    INNER JOIN HP_VTEX_PRICE VP ON VPF.IDPRICE = VP.IDPRICE
WHERE VP.SKU IN ('18700')
ORDER BY VP.SKU;

-- Proceso que se inserta en HP_VTEX_CARGA_PRECIOS_DIFF
select distinct
           vt.vtex_id as suc_vtex,
           prc.org_lvl_number,
           prc.prd_lvl_number,
           null fec_ini,
           null fec_fin,
           nvl(nvl(nvl(cr.precio_credito,prc.prc_vig_suc),prc.prc_eti_cad),v.prc_price) prc_price,
           nvl(nvl(cr.precio_credito,prc.prc_eti_cad),v.prc_price) prc_price_list
from edsr.hp_prc_cad_vig_fec prc
  inner join edsr.HP_VTEX_PRODUCTO vp on vp.prd_lvl_child = prc.prd_lvl_child
  inner join edsr.orgmstee org on prc.org_lvl_child = org.org_lvl_child
  inner join HP_SUC_VTEX vt on vt.org_lvl_child = org.org_lvl_child
  left join chlprce2 v on prc.PRD_LVL_CHILD = V.PRD_LVL_CHILD
    and v.org_lvl_child = prc.org_lvl_child
  left join (
              select x.cod_tienda, to_number(x.item_code) item_code, min(x.precio_credito) as precio_credito
              from ifh_credito_directo x
              group by x.cod_tienda, to_number(x.item_code)
            ) cr on cr.cod_tienda = prc.org_lvl_number and cr.item_code = prc.prd_lvl_number
where vt.estado = 1
  and nvl(nvl(prc.prc_vig_suc,prc.prc_eti_cad),v.prc_price) is not null;


-- Proceso que se inserta en hp_vtex_promo_dpc_final
select res.cod_tienda,
           res.prd_lvl_number,
           res.id_promocion,
           res.fec_inicio,
           res.fec_final,
           min(res.precio) as precio
    from (
      select first_value(p.id_promocion) over(partition by pt.cod_tienda, pp.prd_lvl_number order by 4) as id_promocion,
             pt.cod_tienda,
             pp.prd_lvl_number,
             case
               when p.tipo = 'PRF' then p.valor
               when p.tipo = 'PRC' then pmm.prc_price - (pmm.prc_price * (p.valor / 100))
               else 0
             end as precio,
             first_value(p.fec_inicio) over(partition by pt.cod_tienda, pp.prd_lvl_number order by 4) as fec_inicio,
             first_value(p.fec_final) over(partition by pt.cod_tienda, pp.prd_lvl_number order by 4) as fec_final
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
             res.fec_final;