select * from edsr.hp_vtex_promocion WHERE HP_VTEX_PROMOCION.COD_PROMOCION IN (1283,1281);
select * from edsr.hp_vtex_promocion WHERE HP_VTEX_PROMOCION.ID_PROMOCION IN (3138);
select * from edsr.hp_vtex_promocion_tienda WHERE  ID_PROMOCION IN (1291,1293);
select * from edsr.hp_vtex_promocion_sku WHERE PRD_LVL_NUMBER = '10196';

select * from edsr.HP_SUC_VTEX;
select * from edsr.HP_VTEX_PROMO_DPC_FINAL;
select COUNT(*) from edsr.HP_VTEX_PROMO_DPC_FINAL;
select * from edsr.HP_VTEX_PROMO_DPC_FINAL WHERE PRD_LVL_NUMBER = '14740';

SELECT * FROM PRDMSTEE WHERE PRD_LVL_NUMBER = '14970';

SELECT * FROM EDSR.HP_VTEX_PRODUCTO WHERE PRD_LVL_CHILD  = 104880;

/* */
--insert into EDSR.HP_VTEX_PRODUCTO
select prd_lvl_child
from edsr.tpprdmst prd
where  prd.prd_lvl_number in ('21551') and not exists(select 1 from EDSR.HP_VTEX_PRODUCTO x where x.prd_lvl_child = prd.prd_lvl_child);
COMMIT;

-- STOCK
SELECT * FROM TPPRDMST WHERE PRD_LVL_NUMBER = '21551';
SELECT * FROM INVBALEE WHERE PRD_LVL_CHILD = '110876';

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