
select P.prd_lvl_number "SKU",
       P.VPC_CASE_PACK_ID "Case Pack",
       P.prd_full_name "Producto",
       P.DES_EST "Estado",
       cod_div "Cod. Division",
       des_div "Division",
       cod_area "Cod. Area",
       des_area "Area",
       cod_dpto "Cod. depto",
       des_dpto "Departamento",
       cod_lin "Cod. Linea",
       des_lin "Linea",
       des_marca "Marca",
       cod_tipmar "Tipo de Marca",
       cod_prv "Cod. Proveedor",
       des_prv "Proveedor",
       des_proce "Procedencia",
       cod_bar "Código de barras Primario",
       LPAD(upc.prd_upc, 14, 0) "GTIN",
       DECODE(afecto, 'F', 'SI', 'NO') "Afecto a IGV",
       des_tipneg "Tipo de Negociación",
       DECODE(flag_serv, 'F', 'NO', null, 'NO', 'SI') "Es servicio",
       des_serv "Servicio",
       des_tipman "Tipo de manejo",
       DECODE(flag_bigtck, null, 'NO', 'F', 'NO', 'SI') "Es Big Ticket",
       des_bigtck "Big Ticket",
       dist_qty "Dist. qty",
       p.des_ptoprecio "Punto de Precio",
       p.des_umi "Unidad de Medida de Inventario",
       p.des_umc "Unidad de Medida de Compra",
       p.des_umv "Unidad de Medida de Venta",
       NVL(b.value, 0) AS CANT_M2_CAJA,
       c.vpc_case_width Ancho,
       c.vpc_case_len largo,
       c.vpc_case_height alto,
       c.vpc_case_width * c.vpc_case_len * c.vpc_case_height VOLUMEN,
       c.case_cube_uom "UND MEDIDA VOLUMNEN",
       c.vpc_case_gross_wgt peso_bruto,
       c.vpc_case_WGT_UOM "UND MEDIDA PESO",
       p.fec_cre fecha_creacion,
       (SELECT MAX(EFFECT_DATE)
          FROM EPMM.PRDSTEEE
         WHERE PRD_LVL_CHILD = p.prd_lvl_child) "ULTIMO CAMBIO ESTADO",
       p.liquidacion,
       p.preciazo,
       des_bigtck_vtex "Big Ticket VTEX",
       p.cod_surtido "Codigo Surtido",
       DECODE(NVL(attr_inf.prd_lvl_child, 0), 0, 'NO', 'SI') "PRODUCTO INFALTABLE",
       p.FLAG_ECOM_RETIRO_TDA "VTEX RETIRO EN TIENDA",
       COD_SURTIDO "CODIGO SURTIDO",
       ATR_LONG_TAIL "SUB ATRIBUTO",
       nvl(edsr.fn_get_atrib(p.prd_lvl_number, '161'), 'NO') "EXPRESS RETAIL",
       --nvl(edsr.fn_get_atrib(p.prd_lvl_number, '162'), 'NO') "EXPRESS ECOMMERCE",
       (select nvl(max(x2.atr_code), 'NO')
        from epmm.basatpee x1
          inner join epmm.basacdee x2 on x2.atr_cod_tech_key = x1.atr_cod_tech_key
        where x1.prd_lvl_child = p.prd_lvl_child
          and x1.atr_hdr_tech_key = 162) as "EXPRESS ECOMMERCE",
       P.PERECIBLE,
       ATR_TOP_2K     "COD. ATRIBUTO TOP2K",
       DES_ATR_TOP_2K "DESC. ATRIBUTO TOP2K",
       c.VPC_CASE_STD_PACK "MASTER PACK",
       edsr.fnu_get_producto_iva(p.prd_lvl_child)||'%' "% IVA"
  from edsr.tpprdmst p
  LEFT JOIN epmm.vpcprdee c
    ON c.vpc_prd_tech_key = p.vpc_prd_tech_key
   and c.vpc_tech_key = p.vpc_tech_key
  LEFT JOIN epmm.BASVALEE b
    ON b.tech_key1 = p.prd_lvl_child
   AND b.FIELD_CODE = 'CP'
   AND b.ENTITY_NAME = 'PRDMSTEE'
  LEFT JOIN epmm.basatpee attr_inf
    on attr_inf.prd_lvl_child = p.prd_lvl_child
   and attr_inf.atr_typ_tech_key = 21
   and attr_inf.atr_hdr_tech_key = 158
   and attr_inf.atr_cod_tech_key = 2919
  LEFT JOIN epmm.PRDUPCEE upc
    on p.prd_lvl_child = upc.prd_lvl_child
   and upc.vpc_primary_flag = 'T'
 WHERE nvl(p.cod_div, '') = decode(upper('@DIVISION@'), '0', nvl(p.cod_div, ''), upper('@DIVISION@'))
   and nvl(p.cod_area, '') = decode(upper('@AREA@'), '0', nvl(p.cod_area, ''), upper('@AREA@'))
   and nvl(p.cod_prv, '*') = decode(upper('@PROVEEDOR@'), '0', nvl(p.cod_prv, '*'), upper('@PROVEEDOR@'))
   and p.cod_proce = DECODE(NVL('@Procedencia(N=NACIONAL/I=IMPORTADO)@', '0'), 'N', 'NACIONAL', 'I', 'IMPORTADO', p.cod_proce)


