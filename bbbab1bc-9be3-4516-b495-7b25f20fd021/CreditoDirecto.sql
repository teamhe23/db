/*

UPDATE edsr.ifh_credito_directo
SET precio_pmm = (SELECT min(prc.prc_price)
                  FROM edsr.chlprce2 prc
                    INNER JOIN edsr.tpprdmst prd on prd.prd_lvl_child = prc.prd_lvl_child
                  WHERE prd.prd_lvl_number = LTRIM(edsr.ifh_credito_directo.item_code, '0')
                    AND prc.org_lvl_number = edsr.ifh_credito_directo.COD_TIENDA);


SELECT * FROM edsr.ifh_credito_directo
--UPDATE edsr.ifh_credito_directo SET precio_credito = 0 , precio_pmm = 0
--UPDATE edsr.ifh_credito_directo SET precio_credito = ROUND(precio_pmm *  ((100 - ifh_credito_directo.porc_dscto)/100),2);
WHERE precio_credito IS NULL OR PRECIO_CREDITO IS NULL;

 */

 SELECT * FROM edsr.ifh_credito_directo WHERE ITEM_CODE = '10126';