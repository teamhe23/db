--movimientos
select o.org_lvl_number tda,
       p.prd_lvl_number sku,
       it.inv_type_code || ' - ' || it.inv_type_desc inventario,
       i.inv_eff_bal balance,
       i.inv_mrpt_code || i.inv_drpt_code cod_mov,
       i.proc_source, 
       decode(i.inv_eff_qty,'+',1,'-',-1,0) * i.trans_qty as qty,
       i.trans_cost as cost_unit,
       decode(i.inv_eff_cst,'+',1,'-',-1,0) * i.trans_ext_cost cost_total,
       i.trans_date, i.posted_date_time,
       i.trans_ref, i.trans_ref2,
       i.audit_number, i.trans_session,
       h.trans_user, h.trans_audited,
       i.inv_mrpt_code || ' - ' || tm.inv_mrpt_desc mrpt_code,
       i.inv_drpt_code || ' - ' || td.inv_drpt_desc drpt_code,
       (SELECT D.RSL_DEF_DESC || ' (' || D.RSL_LIN_DEF_KEY || ')'
             FROM edsr.RSLLNTEE R, edsr.RSLLNDEE D
        WHERE R.INV_MRPT_CODE=I.INV_MRPT_CODE
        AND R.INV_DRPT_CODE=I.INV_DRPT_CODE
         AND R.RSL_LIN_DEF_KEY=D.RSL_LIN_DEF_KEY
         AND ROWNUM=1) "Lin RSL"
from epmm.invaudee i
  inner join epmm.invtypee it on it.inv_type_code = i.trans_type_code
  inner join epmm.invahree h on h.trans_session = i.trans_session
  inner join epmm.invtrmee tm on tm.inv_mrpt_code = i.inv_mrpt_code
  inner join epmm.invtrdee td on td.inv_mrpt_code = i.inv_mrpt_code and td.inv_drpt_code = i.inv_drpt_code
  inner join edsr.tpprdmst p on p.prd_lvl_child = i.trans_prd_child
  inner join epmm.orgmstee o on o.org_lvl_child = i.trans_org_child
where p.prd_lvl_number = '11587'
  and (i.inv_eff_qty in ('+','-') or i.inv_eff_cst in ('+','-'))
  --and i.trans_org_child in (366)
  and i.trans_Ref = '270634'
  --and i.trans_Ref2 = 'OS95400404417'
  --and i.trans_date >= to_date('20251001','YYYYMMDD')
order by i.audit_number
