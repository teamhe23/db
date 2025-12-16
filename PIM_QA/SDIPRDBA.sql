SELECT   ROWID, batch_num, prd_lvl_number, tran_type,
         prd_lvl_parent, prd_lvl_id, prd_name_full, prd_targetgm,
         prd_style_ind, prd_status, prd_inh_val, prd_pdh_name_1,
         prd_pdd_code_1, prd_pdh_name_2, prd_pdd_code_2,
         prd_pdh_name_3, prd_pdd_code_3, date_created, prd_uom_size,
         prd_sll_uom, prd_comp_uom, prd_conv_qty, prd_cross_dock,
         imp_dss_flag, vendor_number,                   -- log 14358
         alt_sll_uom_1, alt_sll_uom_2,
         var_weight_item, var_weight_type, prd_sku_type,
         prd_shrink_rate, prd_waste_code, sll_uom_1_rate,
         sll_uom_2_rate, prd_size_uom,                       --20664
         mandatory_plu,          --23299
         prc_link_id, fill_color, package_type,        --29467
         unit_height, unit_width, unit_depth,          --29467
         manufacturer, package_size, unit_of_measure,      --29467
         tray_quantity, tray_height, tray_width, tray_depth, --29467
         case_quantity, case_height, case_width, case_depth  ,matching_key_value,--29467
         cont_type,cont_mult,prd_ref    --ENH713812 (R-06220) --PMM29452
FROM sdiprdmsi
WHERE batch_num =  decode(1153,0,batch_num,1153)---------700586
    AND tran_type = 'A'
    AND download_date_1 IS NULL
ORDER BY prd_lvl_id DESC;


 SELECT prd_lvl_id, prd_lvl_nmbr_rqd FROM prdctlee;

SELECT *
FROM prdmstee
WHERE prd_lvl_number = '32635'
 AND prd_lvl_id IN (0, 1);