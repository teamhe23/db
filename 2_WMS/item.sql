select wms.prd_lvl_child,
             wms.fec_reg,
             /*company_code*/
             'HESA' as company_code,
             /*item_alternate_code*/
             prd.prd_lvl_number as item_alternate_code,
             /*part_a*/
             prd.prd_lvl_number as part_a,
             /*part_b*/
             null as part_b,
             /*part_c*/
             null as part_c,
             /*part_d*/
             null as part_d,
             /*part_e*/
             null as part_e,
             /*part_f*/
             null as part_f,
             /*pre_pack_code*/
             null as pre_pack_code,
             /*action_code*/
             decode(wms.tran_type, 'A', 'CREATE', 'UPDATE') as action_code,
             /*description*/
             prd.prd_full_name as description,
             /*barcode*/
             pkg_wms_general.fn_formatear_barcode(upc.prd_upc, upc.upc_type) as barcode,
             /*unit_cost*/
             '0' as unit_cost,
             /*unit_length*/
             to_char(DECODE('T', 'F', 1, cp.vpc_case_len)) as unit_length, --V_FLAG_ITEM
             /*unit_width*/
             to_char(DECODE('T', 'F', 1, cp.vpc_case_width)) as unit_width,
             /*unit_height*/
             to_char(DECODE('T', 'F', 1, cp.vpc_case_height)) as unit_height,
             /*unit_weight*/
             to_char(DECODE('T', 'F', 1, cp.vpc_case_gross_wgt)) as unit_weight,
             /*unit_volume*/
             to_char(DECODE('T', 'F', 1, cp.vpc_case_len * cp.vpc_case_width * cp.vpc_case_height)) as unit_volume,
             /*hazmat*/
             'false' as hazmat,
             /*recv_type*/
             null as recv_type,
             /*ob_lpn_type*/
             null as ob_lpn_type,
             /*catch_weight_method*/
             null as catch_weight_method,
             /*order_consolidation_attr*/
             null as order_consolidation_attr,
             /*season_code*/
             null as season_code,
             /*brand_code*/
             null as brand_code,
             /*cust_attr_1*/
             prd.despacho as cust_attr_1,
             /*cust_attr_2*/
             substr(TRIM(prd.cod_prv) || ' - ' || TRIM(prd.des_prv), 1, 30) as cust_attr_2,
             /*retail_price*/
             '1' as retail_price,
             /*net_cost*/
             '1' as net_cost,
             /*currency_code*/
             null as currency_code,
             /*std_pack_qty*/
             to_char(DECODE('T', 'F', whs.trf_dist_pak, 1)) as std_pack_qty,
             /*std_pack_length*/
             to_char(DECODE('T', 'F', 1, 0)) as std_pack_length,
             /*std_pack_width*/
             to_char(DECODE('T', 'F', 1, 0)) as std_pack_width,
             /*std_pack_height*/
             to_char(DECODE('T', 'F', 1, 0)) as std_pack_height,
             /*std_pack_weight*/
             to_char(DECODE('T', 'F', 1, 0)) as std_pack_weight,
             /*std_pack_volume*/
             to_char(DECODE('T', 'F', 1, 0)) as std_pack_volume,
             /*std_case_qty*/
             to_char(nvl(DECODE('T', 'F', null, whs.trf_dist_pak), 0)) as std_case_qty,
             /*max_case_qty*/
             '1' as max_case_qty,
             /*std_case_length*/
             DECODE('T', 'F', '1', '0') as std_case_length,
             /*std_case_width*/
             DECODE('T', 'F', '1', '0') as std_case_width,
             /*std_case_height*/
             DECODE('T', 'F', '1', '0') as std_case_height,
             /*std_case_weight*/
             DECODE('T', 'F', '1', '0') as std_case_weight,
             /*std_case_volume*/
             DECODE('T', 'F', '1', '0') as std_case_volume,
             /*dimension1*/
             '1' as dimension1,
             /*dimension2*/
             '1' as dimension2,
             /*dimension3*/
             '1' as dimension3,
             /*hierarchy1_code*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.cod_div)) as hierarchy1_code,
             /*hierarchy1_description*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.des_div)) as hierarchy1_description,
             /*hierarchy2_code*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.cod_area)) as hierarchy2_code,
             /*hierarchy2_description*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.des_area)) as hierarchy2_description,
             /*hierarchy3_code*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.cod_dpto)) as hierarchy3_code,
             /*hierarchy3_description*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.des_dpto)) as hierarchy3_description,
             /*hierarchy4_code*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.cod_lin)) as hierarchy4_code,
             /*hierarchy4_description*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.des_lin)) as hierarchy4_description,
             /*hierarchy5_code*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.cod_stl)) as hierarchy5_code,
             /*hierarchy5_description*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.des_stl)) as hierarchy5_description,
             /*group_code*/
             null as group_code,
             /*group_description*/
             null as group_description,
             /*external_style*/
             trim(pkg_wms_general.fn_omitir_caracteres(prd.cod_stl)) as external_style,
             /*vas_group_code*/
             null as vas_group_code,
             /*short_descr*/
             null as short_descr,
             /*putaway_type*/
             trim(pkg_wms_general.fn_omitir_caracteres(pkg_wms_general.fn_Retorna_Atributos(prd.prd_lvl_child,'TYPOPER','HDRTIPALM'))) as putaway_type,
             /*conveyable*/
             'false' as conveyable,
             /*stackability_code*/
             trim(pkg_wms_general.fn_omitir_caracteres(pkg_wms_general.fn_Retorna_Atributos(prd.prd_lvl_child,'TYPOPER','HDRAPIABIL'))) as stackability_code,
             /*sortable*/
             'false' as sortable,
             /*min_dispatch_uom*/
             null as min_dispatch_uom,
             /*product_life*/
             DECODE(TRIM(prd.perecible),'SI','180','0') as product_life,
             /*percent_acceptable_product_life*/
             DECODE(TRIM(prd.perecible),'SI','100','0') as percent_acceptable_product_life,
             /*lpns_per_tier*/
             null as lpns_per_tier,
             /*tiers_per_pallet*/
             null as tiers_per_pallet,
             /*velocity_code*/
             null as velocity_code,
             /*req_batch_nbr_flg*/
             null as req_batch_nbr_flg,
             /*req_serial_nbr_flg*/
             null as req_serial_nbr_flg,
             /*regularity_code*/
             null as regularity_code,
             /*harmonized_tariff_code*/
             null as harmonized_tariff_code,
             /*harmonized_tariff_description*/
             null as harmonized_tariff_description,
             /*full_oblpn_type*/
             null as full_oblpn_type,
             /*case_oblpn_type*/
             null as case_oblpn_type,
             /*pack_oblpn_type*/
             null as pack_oblpn_type,
             /*description_2*/
             null as description_2,
             /*description_3*/
             null as description_3,
             /*invn_attr_a_tracking*/
             '0' as invn_attr_a_tracking
      from wms_item_envio wms
        inner join tpprdmst prd on prd.prd_lvl_child = wms.prd_lvl_child
        inner join prdupcee upc on upc.prd_lvl_child = prd.prd_lvl_child and upc.prd_primary_flag = 'T'
          and nvl(upc.prd_upc, 0) > 0
        left join vpcprdee cp on cp.vpc_prd_tech_key = prd.vpc_prd_tech_key
        left join whsprdee whs on whs.org_lvl_child = V_ORG_CHILD_CD and whs.prd_lvl_child = prd.prd_lvl_child
      where wms.fec_procesado is null
        and rownum <= 500;




declare
    V_COMPANY_COD        VARCHAR2(4);
    V_ORG_CHILD_CD       NUMBER(12);
    V_FLAG_ITEM          CHAR(1);
begin
    V_COMPANY_COD := PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('COD_EMPR');
    V_ORG_CHILD_CD:= PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('ID_CD');
    'T'   := PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('FLG_ITEM');

    DBMS_OUTPUT.PUT_LINE(V_COMPANY_COD);    -- HESA
    DBMS_OUTPUT.PUT_LINE(V_ORG_CHILD_CD);   -- 420
    DBMS_OUTPUT.PUT_LINE(V_FLAG_ITEM);      -- T
end;
--FN_OBTENER_VALOR_PARAM
SELECT par.val_par, PAR.*
FROM wms_parametros par
WHERE par.cod_par = 'FLG_ITEM';


    select prd.PRD_LVL_NUMBER, wms.*
      from wms_item_envio wms
        inner join tpprdmst prd on prd.prd_lvl_child = wms.prd_lvl_child
        inner join prdupcee upc on upc.prd_lvl_child = prd.prd_lvl_child and upc.prd_primary_flag = 'T'
          and nvl(upc.prd_upc, 0) > 0
        left join vpcprdee cp on cp.vpc_prd_tech_key = prd.vpc_prd_tech_key
       -- left join whsprdee whs on whs.org_lvl_child = 420 and whs.prd_lvl_child = prd.prd_lvl_child
      where prd.PRD_LVL_NUMBER = '35777';

SELECT  * FROM PRDMSTEE WHERE PRD_LVL_NUMBER = '35777'; --124475
SELECT  * FROM PRDMSTEE WHERE PRD_LVL_NUMBER = '10018'; --100019
SELECT A.PRD_LVL_CHILD,
       A.*
       --,MIN(A.TRAN_TYPE) AS TRAN_TYPE
      FROM TPEPRDAE A
      WHERE
          --A.ESTADO in (0)AND
          A.PRD_LVL_CHILD = '124475' AND
           A.TRAN_TYPE IN ('A', 'C')
          -- and  TO_CHAR(A.DOWNLOAD_DATE_1, 'YYYYMMDD')  = '20241127'
      ORDER BY DOWNLOAD_DATE_1 DESC
FETCH FIRST 100 ROW ONLY;
      --GROUP BY A.PRD_LVL_CHILD;


SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%TPEPRDAE%';