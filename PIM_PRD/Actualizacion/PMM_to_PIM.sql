--PRDMSTEE
SELECT * FROM PRDMSTEE WHERE PRD_LVL_CHILD IN (111463);
SELECT cod_bar EAN, PRD.* FROM TPPRDMST PRD WHERE PRD_LVL_CHILD IN (111463);
--SELECT * FROM PRDSTSEE;
--PIM_PRODUCTO_DATA_PMM
SELECT * FROM PIM_PRODUCTO_DATA_PMM WHERE PRD_LVL_CHILD = 125347;
--DUN14
select PRD_LVL_CHILD , count(*) FROM PRDUPCEE GROUP BY PRD_LVL_CHILD HAVING count(*) >= 7 ORDER BY PRD_LVL_CHILD DESC;
/*
SKU: 27848 | DUN14 : 10039800126556
SKU: 27848 | EAN: 8888021201475

SKU: 22141| DUN14 : 17860000009669
SKU: 22141| EAN: 7860000002250
 */
--DUN14
SELECT PRD_LVL_CHILD, prd_upc, upc_type, active_flag,PRD_PRIMARY_FLAG,VPC_PRIMARY_FLAG,DEFAULT_FLAG, DUN.*
FROM PRDUPCEE DUN
WHERE PRD_LVL_CHILD = 111463 AND upc_type = 14; -- and dun.active_flag ='T' and VPC_PRIMARY_FLAG = 'T';
--EAN
SELECT PRD_LVL_CHILD, prd_upc, upc_type, active_flag,PRD_PRIMARY_FLAG,VPC_PRIMARY_FLAG,DEFAULT_FLAG, DUN.*
FROM PRDUPCEE DUN
WHERE PRD_LVL_CHILD = 111463 AND upc_type IN (7,8,12,13) ; --and dun.active_flag ='T' and VPC_PRIMARY_FLAG = 'T';

SELECT * FROM PIM_PRODUCTO_DATA_PMM WHERE PRD_LVL_NUMBER = 37230;
--MATRIZ
SELECT B.ID_PIM,
       A.prd_lvl_child,
       A.prd_lvl_number,
       A.prd_name_full,
       A.prd_status,
       CASE WHEN NVL(TRIM(A.prd_status), 'XX') <> NVL(TRIM(B.estadoProducto), 'XX') THEN 1 ELSE 0 END status_diff,
       A.dun14,
       B.dun14 AS                                                                                     BDUN14,
       CASE WHEN NVL(TRIM(A.dun14), 'XX') <> NVL(TRIM(B.dun14), 'XX') THEN 1 ELSE 0 END               dun14_diff,
       A.vendor_name,
       CASE WHEN NVL(TRIM(A.vendor_name), 'XX') <> NVL(TRIM(B.razon_social), 'XX') THEN 1 ELSE 0 END  vendor_name_diff,
       A.vendor_number,
       CASE
           WHEN NVL(TRIM(A.vendor_number), 'XX') <> NVL(TRIM(B.codigo_proveedor), 'XX') THEN 1
           ELSE 0 END                                                                                 vendor_number_diff,
       A.UMI,
       CASE WHEN NVL(TRIM(A.UMI), 'XX') <> NVL(TRIM(B.UMI), 'XX') THEN 1 ELSE 0 END                   UMI_diff,
       A.ean,
       B.EAN   AS                                                                                     BEAN,
       CASE WHEN NVL(TRIM(A.ean), 'XX') <> NVL(TRIM(B.ean), 'XX') THEN 1 ELSE 0 END                   ean_diff,
       A.VPC_CASE_QTY_UOM,
       CASE
           WHEN NVL(TRIM(A.VPC_CASE_QTY_UOM), 'XX') <> NVL(TRIM(B.umv), 'XX') THEN 1
           ELSE 0 END                                                                                 VPC_CASE_QTY_UOM_diff,
       A.sku_proveedor,
       B.sku_proveedor                                                                                bsku_proveedor,
       CASE
           WHEN NVL(TRIM(A.sku_proveedor), 'XX') <> NVL(TRIM(B.sku_proveedor), 'XX') THEN 1
           ELSE 0 END                                                                                 sku_proveedor_diff,
       A.tipo_surtido,
       CASE WHEN NVL(TRIM(A.tipo_surtido), 'XX') <> NVL(TRIM(B.tipo_surtido), 'XX') THEN 1 ELSE 0 END tipo_surtido_diff
FROM (SELECT p.prd_lvl_child
           , trim(p.prd_lvl_number)       prd_lvl_number
           , trim(p.prd_name_full)        prd_name_full
           --campos nuevos
           , TO_CHAR(est.PRD_STATUS_DESC) prd_status
           , to_char(dun.prd_upc)         dun14
           , prov.vendor_name
           , to_char(prov.vendor_number)  vendor_number
           , vpc.INV_UOM                  UMI
           , to_char(ean.prd_upc)         ean
           , vpc.VPC_CASE_QTY_UOM
           , vpc.VPC_CASE_PACK_ID         sku_proveedor
           , tipo_surt.ATR_CODE           tipo_surtido
      FROM prdmstee p
               inner join (select e.PRD_LVL_CHILD,
                                  e.prd_status,
                                  des.PRD_STATUS_DESC,
                                  row_number() over (partition by PRD_LVL_CHILD order by EFFECT_DATE desc) rn
                           from PRDSTEEE e
                                    INNER JOIN EDSR.PRDSTSEE des on des.PRD_STATUS = e.PRD_STATUS) est
                          on est.PRD_LVL_CHILD = p.PRD_LVL_CHILD and est.rn = 1
               left join PRDUPCEE dun
                         on dun.PRD_LVL_CHILD = p.PRD_LVL_CHILD and DUN.upc_type = 14 and DUN.VPC_PRIMARY_FLAG = 'T'
               left join PRDUPCEE ean on EAN.PRD_LVL_CHILD = p.PRD_LVL_CHILD and EAN.upc_type IN (7, 8, 12, 13) and
                                         EAN.PRD_PRIMARY_FLAG = 'T'
               left join vpcprdee vpc on dun.vpc_prd_tech_key = vpc.vpc_prd_tech_key
               left join vpcmstee prov on vpc.vpc_tech_key = prov.vpc_tech_key
               left join basatpee des_atr on p.PRD_LVL_CHILD = des_atr.PRD_LVL_CHILD and atr_hdr_tech_key = 141
               left join basacdee tipo_surt on des_atr.ATR_COD_TECH_KEY = tipo_surt.ATR_COD_TECH_KEY
      WHERE p.PRD_STATUS NOT IN (3)) A --SELECT DE PMM CON LA DATA ACTUALIZADA

         INNER JOIN (SELECT ID_PIM
                          , PRD_LVL_CHILD
                          , PRD_LVL_NUMBER
                          , prd_name_full
                          , estadoProducto
                          , dun14
                          , razon_social
                          , codigo_proveedor
                          , umi
                          , ean
                          , umv
                          , sku_proveedor
                          , tipo_surtido
                     FROM EDSR.PIM_PRODUCTO_DATA_PMM) B --SELECT DE LA TABLA PIM_PRODUCTO_DATA_PMM (DATA SNAPSHOT)
                    ON A.prd_lvl_child = B.prd_lvl_child
WHERE NVL(TRIM(A.prd_status), 'XX') <> NVL(TRIM(B.estadoProducto), 'XX')
   OR NVL(TRIM(A.dun14), 'XX') <> NVL(TRIM(B.dun14), 'XX')
   OR NVL(TRIM(A.vendor_name), 'XX') <> NVL(TRIM(B.razon_social), 'XX')
   OR NVL(TRIM(A.vendor_number), 'XX') <> NVL(TRIM(B.codigo_proveedor), 'XX')
   OR NVL(TRIM(A.UMI), 'XX') <> NVL(TRIM(B.UMI), 'XX')
   OR NVL(TRIM(A.ean), 'XX') <> NVL(TRIM(B.ean), 'XX')
   OR NVL(TRIM(A.VPC_CASE_QTY_UOM), 'XX') <> NVL(TRIM(B.umv), 'XX')
   OR NVL(TRIM(A.sku_proveedor), 'XX') <> NVL(TRIM(B.sku_proveedor), 'XX')
   OR NVL(TRIM(A.tipo_surtido), 'XX') <> NVL(TRIM(B.tipo_surtido), 'XX')
;
