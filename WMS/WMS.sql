-- Listar para CREAR OC
select  wms.pmg_po_number,wms.audit_number, wms.id_tipo,wms.fec_procesado,wms.* from wms_purchaseorder_envio wms
--UPDATE wms_purchaseorder_envio wms SET wms.fec_procesado = null
where wms.id_tipo = 4
    --and wms.fec_procesado is null
    AND wms.PMG_PO_NUMBER in (101074,101073,101072)
;
select  wms.pmg_po_number,
              wms.audit_number
      from wms_purchaseorder_envio wms
      where wms.id_tipo       = 4
        and wms.fec_procesado is null;

select  wms.pmg_po_number,
              wms.audit_number
      from wms_purchaseorder_envio wms
      where wms.id_tipo       = v_tipo_create
        and wms.fec_procesado is null;


SELECT sdi.DOWNLOAD_DATE_1, sdi.* FROM sdipmghde sdi WHERE sdi.PMG_PO_NUMBER in (101074,101073,101072) ;
SELECT dte.PRD_LVL_NUMBER, dte.DOWNLOAD_DATE_1, dte.* FROM sdipmgdte dte WHERE dte.PMG_PO_NUMBER in (101072) ; -- 4544695515
SELECT dte.PRD_LVL_NUMBER, dte.DOWNLOAD_DATE_1, dte.* FROM sdipmgdte dte WHERE dte.PMG_PO_NUMBER in (101073) ; -- 4544695520
SELECT dte.PRD_LVL_NUMBER, dte.DOWNLOAD_DATE_1, dte.* FROM sdipmgdte dte WHERE dte.PMG_PO_NUMBER in (101074) ; -- 4544695845

SELECT PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('COD_EMPR') FROM DUAL; --HESA
SELECT PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('FLG_ITEM') FROM DUAL; --T

select /*po_nbr*/
             sdi.pmg_po_number as po_nbr,
             /*facility_code*/
             sdi.org_lvl_number as facility_code,
             /*company_code*/
             'HESA' as company_code,
             /*vendor_code*/
             trim(sdi.vendor_number) as vendor_code,
             /*action_code*/
             'CREATE' as action_code,
             /*ord_date*/
             to_char(sdi.pmg_release_date, 'yyyy-mm-dd') as ord_date,
             /*ref_nbr*/
             sdi.dmt_code as ref_nbr,
             /*po_type*/
             sdi.pmg_type_code as po_type,
             /*delivery_date*/
             to_char(sdi.pmg_exp_rct_date, 'yyyy-mm-dd') as delivery_date,
             /*dept_code*/
             (
              select decode('T','F',prd.cod_dpto,prd.cod_area)
              FROM sdipmgdte dtl
                inner join tpprdmst prd on dtl.prd_lvl_child = prd.prd_lvl_child
              where dtl.pmg_po_number = sdi.pmg_po_number
                and ROWNUM = 1
             ) as dept_code,
             /*ship_date*/
             to_char(sdi.pmg_exp_rct_date, 'yyyy-mm-dd') as ship_date,
             /*cancel_date*/
             to_char(sdi.pmg_cncl_by_date, 'yyyy-mm-dd') as cancel_date,
             /*cust_field_1*/
             pkg_wms_general.fn_omitir_caracteres(trim(sdi.pmg_lc_number)) as cust_field_1,
             /*cust_field_2*/
             null as cust_field_2,
             /*cust_field_3*/
             null as cust_field_3,
             /*cust_field_4*/
             null as cust_field_4,
             /*cust_field_5*/
             null as cust_field_5
      from wms_purchaseorder_envio wms
        inner join sdipmghde sdi on sdi.pmg_po_number = wms.pmg_po_number
          and sdi.audit_number = wms.audit_number
      where wms.pmg_po_number = 101072
        and wms.audit_number = 4544695515;


select distinct
             /*seq_nbr*/
             rownum as seq_nbr,
             /*action_code*/
             'CREATE' as action_code,
             /*item_alternate_code*/
             trim(det.prd_lvl_number) as item_alternate_code,
             /*item_part_a*/
             trim(det.prd_lvl_number) as item_part_a,
             /*item_part_b*/
             null as item_part_b,
             /*item_part_c*/
             null as item_part_c,
             /*item_part_d*/
             null as item_part_d,
             /*item_part_e*/
             null as item_part_e,
             /*item_part_f*/
             null as item_part_f,
             /*pre_pack_code*/
             null as pre_pack_code,
             /*pre_pack_ratio*/
             null as pre_pack_ratio,
             /*pre_pack_total_units*/
             '0' as pre_pack_total_units,
             /*ord_qty*/
             det.pmg_sell_qty as ord_qty,
             /*unit_cost*/
             '1' as unit_cost,
             /*vendor_item_code*/
             null as vendor_item_code,
             /*internal_misc_n1*/
             null as internal_misc_n1,
             /*internal_misc_a1*/
             null as internal_misc_a1,
             /*unit_retail*/
             det.pmg_sell_qty as unit_retail,
             /*cust_field_1*/
             null as cust_field_1,
             /*cust_field_2*/
             null as cust_field_2,
             /*cust_field_3*/
             null as cust_field_3,
             /*cust_field_4*/
             null as cust_field_4,
             /*cust_field_5*/
             null as cust_field_5,
             /*pre_pack_ratio_seq*/
             null as pre_pack_ratio_seq
      from wms_purchaseorder_envio wms
        inner join sdipmghde sdi on sdi.pmg_po_number = wms.pmg_po_number
          and sdi.audit_number = wms.audit_number
        inner join sdipmgdte det on det.pmg_po_number = sdi.pmg_po_number
          and det.tran_type = sdi.tran_type
          and det.org_lvl_child = sdi.org_lvl_child
      where wms.pmg_po_number = 101072
        and wms.audit_number = 4544695515;