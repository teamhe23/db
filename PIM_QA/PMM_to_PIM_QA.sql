SELECT * FROM PIM_PRODUCTO_DATA_PMM;
SELECT SKU_PROVEEDOR, PIM.* FROM PIM_PRODUCTO_DATA_PMM PIM where ID_PIM = 'HESA_TEST_40004';

UPDATE EDSR.PIM_PRODUCTO_DATA_PMM
SET  sku_proveedor = TRIM('EL010083')
    /*estadoProducto = TRIM(REG.prd_status)
    , dun14 = TRIM(REG.dun14)
    , razon_social = TRIM(REG.vendor_name)
    , codigo_proveedor = TRIM(REG.vendor_number)
    , umi = TRIM(REG.umi)
    , ean = TRIM(REG.ean)
    , umv = TRIM(REG.VPC_CASE_QTY_UOM)
    , sku_proveedor = TRIM(REG.sku_proveedor)
    , tipo_surtido = TRIM(REG.tipo_surtido)*/
WHERE ID_PIM = TRIM('HESA_TEST_40004');
COMMIT;
