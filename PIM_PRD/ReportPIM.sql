/*
Por favor valídale el proceso que se ejecuta en el mantenedor
para consumir el siguiente SP HP_ECU_TURBO_ENTRY_WEB y que inserta en la tabla SELECT * FROM EDSR.PRD_TE_WEB.

*/

SELECT * FROM EDSR.PRD_TE_WEB;
SELECT DISTINCT COMPRADOR FROM EDSR.PRD_TE_WEB; -- null,Comercial,Servicios,
SELECT DISTINCT reemplaza FROM EDSR.PRD_TE_WEB; -- null,No,No (NO),Si (SI),
SELECT DISTINCT sku_reemplaza FROM EDSR.PRD_TE_WEB; -- null,No,No (NO),Si (SI),
SELECT DISTINCT web FROM EDSR.PRD_TE_WEB; -- null,B2C & B2B,B2B,
SELECT DISTINCT cod_sunat FROM EDSR.PRD_TE_WEB; -- null,No,No (NO),Si (SI),
SELECT DISTINCT cobro_prod_new FROM EDSR.PRD_TE_WEB; -- null,NO,Si (SI),No (NO),No, (Camila Sanipatin, Dilan Colloauzo)
SELECT DISTINCT afec_igv FROM EDSR.PRD_TE_WEB; -- null,Si (T),Si,SI,No (F),
SELECT DISTINCT moneda FROM EDSR.PRD_TE_WEB; -- null,Si (T),Si,SI,No (F),
SELECT DISTINCT qty_mp FROM EDSR.PRD_TE_WEB; -- null,Si (T),Si,SI,No (F),
SELECT DISTINCT tipo_mp FROM EDSR.PRD_TE_WEB; -- null,1,Bolsa,Bulto,CAJA,Caja,Ecuador,Paleta,Pallet,Rollo,Saco,Un,Unidad,bulto,caja,funda,
SELECT DISTINCT tipo_emp FROM EDSR.PRD_TE_WEB; -- null,BALDE,BLISTER,Blister,Bolsa,Bulk 10 unid,Bulto,CAJA,CAJA INNER,CARTON,Caja,FUNDA,Funda,Paleta,Pallet,Producto Unitario,Producto unitario,TARRINA,TARRO,Unitario,bolsa,caja,kit,producto unitario,
SELECT DISTINCT PAIS_ORIGEN FROM EDSR.PRD_TE_WEB; -- null
SELECT DISTINCT pais_proc FROM EDSR.PRD_TE_WEB; -- null,ALEMANIA,Alemania,Argentina,BRASIL,Brasil,CHINA,COLOMBIA,Canadá,Chile,China,Colombia,Costa Rica,ECUADOR,EEUU,ESTADOS UNIDOS,Ecuador,El Salvador,España,Estados Unidos,Francia,Holanda,Hungría,India,Italia,México,Pakistán,Panama,Panamá,Países Bajos,Peru,Perú,Poland,Polonia,República Checa,Singapur,Suecia,TURQUIA,Taiwan,Turquía,USA,United States,Uruguay,Vietnam,china,colombia,estados unidos,
SELECT DISTINCT pais_manuf FROM EDSR.PRD_TE_WEB; -- null,Hasta 64 paises,
SELECT DISTINCT color_sec FROM EDSR.PRD_TE_WEB; -- null,Hasta 62 colores,
SELECT DISTINCT color FROM EDSR.PRD_TE_WEB; -- null, (Hasta 124 colores)
SELECT DISTINCT modelo FROM EDSR.PRD_TE_WEB; -- null,
SELECT DISTINCT tip_prd FROM EDSR.PRD_TE_WEB; -- null,
SELECT DISTINCT tip_prd FROM EDSR.PRD_TE_WEB; -- null,
SELECT DISTINCT sub_tip_prd FROM EDSR.PRD_TE_WEB; -- null,
SELECT DISTINCT tipo_marca FROM EDSR.PRD_TE_WEB; -- null,PROVEEDOR,PROPIA,
SELECT DISTINCT tipo_neg FROM EDSR.PRD_TE_WEB; -- null,PROVEEDOR,PROPIA,
SELECT DISTINCT tipo_neg FROM EDSR.PRD_TE_WEB; -- null,PROVEEDOR,PROPIA,


SELECT SEQ_PRD_ECU.NEXTVAL
--INTO V_ID_REG
FROM DUAL;

SELECT id_reg,
       desc_sku,--PIM
       comprador,
       reemplaza,sku_reemplaza,
       cluster_surtido,web,cod_sunat,cobro_prod_new,afec_igv,
       tipo_surtido,umi,umv,cod_linea,
       proveedor, --PIM (EAN)
       pre_unit,costo --PIM (PrecioUnitario)
       ,moneda  -- EXCEL, no se envia
       ,qty_mp
       ,sku_prv, --PIM (SkuProveedor)
        ean,--PIM (EAN)
        tipo_ean,--PIM (TipoCodigoEAN)
        dun14, --PIM (DUN14)
        material, -- No sale en el PMM
        marca,  --PIM (Marca)
        tip_vta, --EXCEL, no envia
        tip_prd, -- PENDIENTE
        sub_tip_prd, -- PENDIENTE
        modelo,-- PENDIENTE (Texto Libre)
        color,  --PENDIENTE (Hasta 124 colores)
        color_sec, --PENDIENTE (Hasta 62 colores)
        incluye,-- PENDIENTE (Texto Libre)
        num_piezas, --PIM (NumeroPiezas)
        garantia, -- PENDIENTE
        caracteristicas, -- PENDIENTE (Texto Libre)
        recom_uso,  -- PENDIENTE (Texto Libre)
        observaciones, -- PENDIENTE (Texto Libre)
        advert_uso, -- PENDIENTE (Texto Libre)
        pais_manuf, -- PENDIENTE PAIS (64 PAISES)
        PAIS_ORIGEN, -- NULL
        pais_proc, -- PENDIENTE
        tipo_mp, -- PIM (TipoMasterpack)
        tipo_emp,-- PENDIENTE
        perecible, --PIM (Perecible)
        prod_peligroso,--EXCEL, no envia
        alt_unid_log, --PIM (AlturaUnidadLogistica)
        anc_unid_log, --PIM (AnchoUnidadLogistica)
        prof_unid_log,  --PIM (ProfundidadUnidadLogistica)
        peso_unid_log, --PIM (PesoUnidadLogistica)
        alt_prod, -- PENDIENTE
        anc_prod, -- PENDIENTE
        prof_prod, -- PENDIENTE
        peso_prod, --PIM (PesoProducto)
        tipo_neg, -- NULL
        tipo_marca, --PIM (TipoNegociacion)
        id_carga, -- PENDIENTE
        error, -- NULL
        desc_error, -- NULL
        DOWNLOAD_DATE
FROM EDSR.PRD_TE_WEB ORDER BY DOWNLOAD_DATE DESC;




SELECT * FROM EDSR.PRD_TE_WEB WHERE SKU IS NOT NULL ORDER BY FECHA_INICIO_P DESC;