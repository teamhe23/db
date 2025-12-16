SELECT TABLE_OWNER, TABLE_NAME FROM DBA_SYNONYMS
WHERE SYNONYM_NAME = 'CHLPRCE2';

SELECT * FROM ALL_SYNONYMS
WHERE SYNONYM_NAME = 'CHLPRCE2';

select * from EPMM.CHLPRCE2 where PRODUCT_NUMBER in ('33481','30315','32938') ;
select * From EDSR.TPPRDMST where PRD_LVL_NUMBER in ('33481','30315','32938');
select * from EDSR.ORGMSTEE;
select * from EDSR.HPRANGOPRECIO where prd_lvl_child in (119209, 121692, 122220) ;
select * From EDSR.BASVALEE;
select * From EDSR.INVBALEE where prd_lvl_child in (119209, 121692, 122220) ;


select * From EDSR.IFH_SUR_TPSURMST; -- vacia
select * From EDSR.IFH_PROMO_MED;-- vacia

SELECT  TC.SUCURSAL,
			     TC.ID_CAMPANA,
			     TC.Des_Campana,
			     LPAD(TRIM(R.SKU), 9, 0) SKU,
			     R.PRECIO,
			     R.RANGO1 CANTIDAD1,
			     R.PRECIO1,
			     R.RANGO2 CANTIDAD2,
			     R.PRECIO2,
			     R.INICIO,
			     R.FIN,
			     SUBSTR(R.DESCRIPCION,0,40) AS DESC_PROMO
FROM EDSR.HPRANGOPRECIO R
    INNER JOIN edsr.dpc_tienda_campana TC ON TC.SUCURSAL = R.SUCURSAL
WHERE R.INICIO = TRUNC(SYSDATE);


SELECT DISTINCT C.ORG_LVL_NUMBER AS COD_SUC,
                B.COD_AREA,
                B.DES_AREA,
                A.PRODUCT_NUMBER AS SKU,
                B.PRD_FULL_NAME AS PRODUCTO,
                C.ORG_NAME_FULL AS SUCURSAL,
                MAX(A.PRC_FROM_DATE) AS FEC_INI_VIG,
                A.PRC_PRICE AS PRECIO,
                D.RANGO1,
                D.PRECIO1,
                D.RANGO2,
                D.PRECIO2,
                NVL(F.VALUE, 0) AS CANT_M2_CAJA,
                B.LIQUIDACION,
                B.PRECIAZO,
                G.ON_HAND_QTY AS OH,
                /*EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_log(A.PRD_LVL_CHILD,
                                                       A.ORG_LVL_CHILD) AS COSTO_UNI,
                EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_cp(A.PRD_LVL_CHILD,
                                                      A.ORG_LVL_CHILD) AS COSTO_CP,
                EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_cp(A.PRD_LVL_CHILD, 0) AS COSTO_CADENA,*/
                B.DES_EST AS ESTADO,
                OBJ.DATE_SALIDA AS FECHA_FIN
  FROM EDSR.CHLPRCE2 A
INNER JOIN EDSR.TPPRDMST B
    ON b.prd_lvl_child = a.prd_lvl_child
   --AND RTRIM(b.cod_area) = 0decode('@COD_AREA 0=TODOS@', 0, RTRIM(b.cod_area), '@COD_AREA 0=TODOS@')
INNER JOIN EDSR.ORGMSTEE C
    ON c.org_lvl_child = a.org_lvl_child
  LEFT JOIN EDSR.HPRANGOPRECIO D
    ON d.org_lvl_child = a.org_lvl_child
   AND d.prd_lvl_child = a.prd_lvl_child
  LEFT JOIN EDSR.IFH_PROMO_MED E
    ON e.org_lvl_number = a.org_lvl_number
   AND RTRIM(e.prd_lvl_number) = RTRIM(a.product_number)
  LEFT JOIN EDSR.BASVALEE F
    ON f.tech_key1 = b.prd_lvl_child
   AND f.FIELD_CODE = 'CP'
   AND f.ENTITY_NAME = 'PRDMSTEE'
  LEFT JOIN EDSR.INVBALEE G
    ON g.org_lvl_child = a.org_lvl_child
   AND g.prd_lvl_child = a.prd_lvl_child
   AND g.inv_type_code = '01'
  LEFT JOIN EDSR.IFH_SUR_TPSURMST obj
    on (obj.prd_lvl_child = a.prd_lvl_child and
       obj.org_lvl_child = a.org_lvl_child)
   AND 1 = 0
   --where A.PRODUCT_NUMBER=''
/* WHERE DECODE(@SUCURSAL 0=TODOS@, 0, C.ORG_LVL_NUMBER, @SUCURSAL 0=TODOS@)0 = C.ORG_LVL_NUMBER
   AND (@LISTA_DE_PRODUCTOS 0=TODOS@ = 0 OR RTRIM(A.PRODUCT_NUMBER) IN (@LISTA_DE_PRODUCTOS 0=TODOS@))
   AND (CASE
          WHEN 'S' = UPPER('@SOLO_TRIPRECIOS_(S/N)@') THEN
           d.prd_lvl_child
          ELSE
           a.prd_lvl_child
        END) IS NOT NULL*/
GROUP BY C.ORG_LVL_NUMBER,
          B.COD_AREA,
          B.DES_AREA,
          A.PRODUCT_NUMBER,
          B.PRD_FULL_NAME,
          C.ORG_NAME_FULL,
          A.PRC_PRICE,
          D.RANGO1,
          D.PRECIO1,
          D.RANGO2,
          D.PRECIO2,
          NVL(F.VALUE, 0),
          B.LIQUIDACION,
          B.PRECIAZO,
          G.ON_HAND_QTY,
          /*EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_log(A.PRD_LVL_CHILD,
                                                 A.ORG_LVL_CHILD),
          EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_cp(A.PRD_LVL_CHILD,
                                                A.ORG_LVL_CHILD),
          --EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_cp(A.PRD_LVL_CHILD, 0),*/
          B.DES_EST,
          OBJ.DATE_SALIDA
ORDER BY C.ORG_LVL_NUMBER, A.PRODUCT_NUMBER;



