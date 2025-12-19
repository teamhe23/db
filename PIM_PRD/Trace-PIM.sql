SELECT SYSDATE FROM DUAL;
SELECT * FROM PIM_ATRIBUTO;
SELECT COUNT(*) FROM PIM_ATRIBUTO;
SELECT COD_ATRIBUTO, NOMBRE_ATRIB_PIM FROM PIM_ATRIBUTO ORDER BY COD_ATRIBUTO ;

SELECT ID_MODELO, CONTENIDO, ID_TIPO, FEC_CREACION, FLG_PROCESADO, FEC_PROCESO, FLG_ERROR, MENSAJE FROM PIM_MODELO
WHERE ID_TIPO = 1
ORDER BY  FEC_CREACION DESC
FETCH FIRST 10 ROWS ONLY;
SELECT * FROM EDSR.PIM_MODELO M WHERE TRUNC(FEC_CREACION) = TRUNC(SYSDATE) and ID_TIPO IN (1,2) ORDER BY FEC_CREACION DESC FETCH FIRST 50 ROWS ONLY;
SELECT * FROM EDSR.PIM_MODELO M WHERE TRUNC(FEC_CREACION) = TRUNC(SYSDATE) and ID_TIPO IN (1) ORDER BY FEC_CREACION DESC;
SELECT * FROM EDSR.PIM_MODELO M WHERE TRUNC(FEC_CREACION) = TRUNC(SYSDATE) and ID_TIPO IN (2) ORDER BY FEC_CREACION DESC;
SELECT * FROM EDSR.PIM_MODELO M WHERE TRUNC(FEC_CREACION) = TRUNC(SYSDATE) and ID_TIPO IN (3) ORDER BY FEC_CREACION DESC;

/*
*/
SELECT * FROM EDSR.PIM_MODELO M WHERE CONTENIDO LIKE '%HESA_44240%';
SELECT * FROM EDSR.PIM_MODELO M WHERE CONTENIDO LIKE '%HESA_44080%';
SELECT * FROM EDSR.PIM_MODELO M WHERE CONTENIDO LIKE '%HESA_44081%';
SELECT * FROM EDSR.PIM_MODELO M WHERE CONTENIDO LIKE '%HESA_44074%';
SELECT * FROM EDSR.PIM_MODELO M WHERE CONTENIDO LIKE '%HESA_44084%';
SELECT * FROM EDSR.PIM_MODELO M WHERE CONTENIDO LIKE '%HESA_44085%';
SELECT * FROM EDSR.PIM_MODELO M WHERE CONTENIDO LIKE '%HESA_44086%';
SELECT * FROM EDSR.PIM_MODELO M WHERE CONTENIDO LIKE '%HESA_44087%';

SELECT * FROM prdmstee PRD WHERE TRIM(PRD.PRD_NAME_FULL) = trim('CIZALLA ÁNGULO RECTO P/LLAVE IMPACT 18V/20V DEWALT');
SELECT * FROM prdmstee PRD WHERE TRIM(PRD.PRD_NAME_FULL) = trim('BASURERO COCINA C/SENSOR 42L ACERO INOXIDABLE ');


SELECT * FROM EDSR.PIM_PRODUCTO M WHERE ID_MODELO = 1131481;
SELECT * FROM EDSR.PIM_PRODUCTO_ATRIB M WHERE ID_PIM_PROD = 3035;

SELECT * FROM EDSR.PIM_MODELO M WHERE CONTENIDO LIKE '%HESA_43649%';
SELECT COUNT(*) FROM EDSR.PIM_MODELO M WHERE TRUNC(FEC_CREACION) = TRUNC(SYSDATE) and ID_TIPO IN (3) ORDER BY FEC_CREACION DESC;


SELECT * FROM EDSR.PIM_MODELO M WHERE TRUNC(FEC_CREACION) = TRUNC(SYSDATE) and ID_TIPO IN (4) ORDER BY FEC_CREACION DESC;
SELECT * FROM EDSR.PIM_MODELO M WHERE TRUNC(FEC_CREACION) >= TRUNC(SYSDATE-2) and ID_TIPO IN (2) ORDER BY FEC_CREACION DESC;
-- desde PMM hacia PIM
SELECT * FROM EDSR.PIM_MODELO M WHERE ID_MODELO = 12877;

SELECT * FROM EDSR.PIM_MODELO M WHERE ID_TIPO IN (2) AND FLG_PROCESADO = '0' ORDER BY FEC_CREACION DESC;
SELECT * FROM EDSR.PIM_MODELO M WHERE ID_TIPO IN (3) AND FLG_PROCESADO = '0' ORDER BY FEC_CREACION DESC;
SELECT * FROM EDSR.PIM_MODELO M WHERE ID_TIPO IN (4) AND FLG_PROCESADO = '0' ORDER BY FEC_CREACION DESC;
-- 19/09/2024 => Miguel va a validar el ID_MODELO 4860, queda PENDIENTE
UPDATE PIM_MODELO SET FLG_PROCESADO = '1' WHERE ID_MODELO IN (4860,4523,4525,4532,4534,4541,4543,4550,4552);
SELECT COUNT(*) FROM EDSR.PIM_MODELO M WHERE ID_TIPO IN (4) AND FLG_PROCESADO = '1' ORDER BY FEC_CREACION DESC;
SELECT * FROM EDSR.PIM_MODELO M WHERE ID_TIPO IN (4) AND FLG_PROCESADO = '0' ORDER BY FEC_CREACION DESC;

--VALORES NULL
SELECT *
FROM EDSR.PIM_MODELO
WHERE ID_TIPO IN (4) AND FLG_PROCESADO = '0'
  AND JSON_VALUE(MENSAJE, '$.CodAtributo') = 'UNIDAD_DE_MEDIDA_DE_INVENTARIO_UMI'
  AND JSON_VALUE(MENSAJE, '$.valorAtributo') IS NULL;


SELECT COUNT(*) FROM EDSR.PIM_MODELO M WHERE ID_TIPO IN (4) AND FLG_PROCESADO = '0' ORDER BY FEC_CREACION DESC;
select s.org_lvl_child,
             org.org_lvl_number,
             org.org_name_full
      from gre_establecimiento s
        inner join orgmstee org on org.org_lvl_child = s.org_lvl_child
      order by org.org_lvl_number;

--****************
-- MODELO
--****************
SELECT * FROM PRDMSTEE WHERE PRD_LVL_NUMBER IN ('39341','39343','39344','39345','39331','39332','39333','39334');
SELECT * FROM PIM_MODELO WHERE CONTENIDO LIKE '%%';
SELECT * FROM PIM_MODELO WHERE CONTENIDO LIKE '%HESA_44079%'; --HESA_43172
SELECT * FROM PIM_MODELO WHERE CONTENIDO LIKE '%BOTELLA TOMATODO PLOMO 500ML ACE INOX.%'; --HESA_43173
SELECT * FROM PIM_MODELO WHERE CONTENIDO LIKE '%REPOSTERO RCT JGO 7 PZCS MULTICOLOR PLAST WR.%'; --HESA_43174
SELECT * FROM PIM_MODELO WHERE CONTENIDO LIKE '%BOTELLA TOMATODO%';
--MODELO
SELECT * FROM EDSR.PIM_MODELO M WHERE CONTENIDO LIKE '%HESA_43642%';
SELECT jt.IdPim,jt.Nombre,jt.EAN,jt.TipoEAN,jt.DUN14, T.* FROM PIM_MODELO t
            ,JSON_TABLE( t.contenido, '$.productos[*]' COLUMNS (IdPim VARCHAR2(50) PATH '$.IdPim',
                                                                Nombre VARCHAR2(100) PATH '$.NombreProducto',
                                                                EAN VARCHAR2(20) PATH '$.EAN',
                                                                TipoEAN VARCHAR2(20) PATH '$.TipoCodigoEAN',
                                                                DUN14 VARCHAR2(20) PATH '$.DUN14') ) jt
WHERE T.ID_TIPO = 1 AND jt.IdPim IN ('HESA_44079','HESA_44080','HESA_44081','HESA_44074','HESA_44084','HESA_44085','HESA_44086','HESA_44087')
--AND FLG_ERROR = '1'
ORDER BY JT.IdPim
;

--****************
-- MODELO SKU
--****************
--Con el CLOB 11 s 403 ms
--Sin el CLOB 371 ms
--SKU
SELECT JSON_VALUE(CONTENIDO, '$.id_pim') as ID_PIM, '=>', JSON_VALUE(CONTENIDO, '$.sku') as SKU, JSON_VALUE(CONTENIDO, '$.descripcion')
      --, PIM.*
FROM PIM_MODELO PIM
WHERE PIM.ID_TIPO = 2
      AND JSON_VALUE(CONTENIDO, '$.id_pim') IN ('HESA_43687')
;

SELECT PIM.ID_MODELO,PIM.ID_TIPO, JSON.IdPim,'=>',JSON.Sku,JSON.Mensaje, PIM.CONTENIDO, PIM.FEC_CREACION FROM PIM_MODELO PIM
         ,JSON_TABLE(PIM.CONTENIDO,
             '$' COLUMNS (
                    IdPim  VARCHAR2(15)  PATH '$.id_pim',
                    Sku VARCHAR2(8) PATH '$.sku',
                    Mensaje VARCHAR2(250) PATH '$.mensaje'
                    )
            ) JSON
WHERE PIM.ID_TIPO = 2
  AND JSON.IdPim IN  ('HESA_43384');

SELECT * FROM PIM_PRODUCTO WHERE ID_PIM IN ('HESA_43079');
SELECT * FROM PIM_PRODUCTO_ATRIB WHERE ID_PIM IN ('HESA_41305');
--FUMIGADORA MANUAL SHINE 20l (MT-139)
SELECT PRD.AFECTO, PRD.* FROM tpprdmst PRD WHERE PRD_LVL_NUMBER IN ('36192');
SELECT PRD.* FROM PRDMSTEE PRD WHERE PRD_LVL_NUMBER IN ('36192');

SELECT * FROM BASVALEE;

SELECT * FROM PIM_ATRIBUTO WHERE ATR_TYP_TECH_KEY IS NOT NULL  ORDER BY COD_ATRIBUTO;
 SELECT
     COD_ATRIBUTO,
        'V_BATCH_NUM',
        ROWNUM,
        'V_PRD_LVL_NUMBER',
        0,
        ATR_TYP_TECH_KEY,
        ATR_HDR_TECH_KEY,
        ID,
        'A',
        1
      FROM PIM_PRODUCTO_ATRIB
      WHERE ID_PIM_PROD = 1347
        AND ATR_TYP_TECH_KEY IS NOT NULL
      ORDER BY COD_ATRIBUTO;

--tpprdmst
SELECT PRD.AFECTO, PRD.* FROM tpprdmst PRD WHERE PRD_LVL_NUMBER = '38084';
--prdmstee
SELECT PRD.* FROM prdmstee PRD WHERE PRD_LVL_NUMBER = '38084';
SELECT * FROM prdmstee PRD WHERE TRIM(PRD.PRD_NAME_FULL) = trim('BASURERO COCINA C/SENSOR 42L ACERO INOXIDABLE ');
--****************
-- --REPORT SKU GENERADOS HOY
--****************

SELECT *
FROM EDSR.PIM_MODELO
WHERE ID_TIPO IN (2)
    AND FEC_CREACION >= TRUNC(SYSDATE)
    AND FEC_CREACION < TRUNC(SYSDATE) + INTERVAL '1' DAY
    AND JSON_VALUE(CONTENIDO, '$.mensaje') != '0';


SELECT *
FROM EDSR.PIM_MODELO
WHERE ID_TIPO IN (2)
    AND JSON_VALUE(CONTENIDO, '$.id_pim') IN ('HESA_41609')
    --IN ('HESA_41576','HESA_41577','HESA_41578','HESA_41579','HESA_41580','HESA_41581','HESA_41582','HESA_41583','HESA_41585','HESA_41586','HESA_41587','HESA_41588','HESA_41589','HESA_41590','HESA_41591','HESA_41592','HESA_41593','HESA_41594','HESA_41595','HESA_41596','HESA_41597','HESA_41598','HESA_41599','HESA_41600','HESA_41601')
;

------------------------------------------------------------------------------------------------------------
SELECT p.prd_lvl_child, trim(p.prd_lvl_number) prd_lvl_number, trim(p.prd_name_full) prd_name_full
     --campos nuevos
     , TO_CHAR(est.PRD_STATUS_DESC) prd_status, to_char(dun.prd_upc) dun14, prov.vendor_name, to_char(prov.vendor_number) vendor_number
     , vpc.INV_UOM UMI, to_char(ean.prd_upc) ean, vpc.VPC_CASE_QTY_UOM, vpc.VPC_CASE_PACK_ID sku_proveedor
     , tipo_surt.ATR_CODE tipo_surtido
     FROM prdmstee p
     inner join (select e.PRD_LVL_CHILD, e.prd_status, des.PRD_STATUS_DESC,
           row_number() over(partition by PRD_LVL_CHILD order by EFFECT_DATE desc) rn
           from PRDSTEEE e INNER JOIN EDSR.PRDSTSEE des on des.PRD_STATUS = e.PRD_STATUS) est
       on est.PRD_LVL_CHILD = p.PRD_LVL_CHILD and est.rn = 1
     left join PRDUPCEE dun on dun.PRD_LVL_CHILD = p.PRD_LVL_CHILD and dun.upc_type = 14 and dun.active_flag ='T'
     left join PRDUPCEE ean on EAN.PRD_LVL_CHILD = p.PRD_LVL_CHILD and EAN.upc_type IN (7,8,12,13) and EAN.default_flag ='T'
     left join vpcprdee vpc on dun.vpc_prd_tech_key = vpc.vpc_prd_tech_key
     left join vpcmstee prov on vpc.vpc_tech_key = prov.vpc_tech_key
     left join basatpee des_atr on p.PRD_LVL_CHILD = des_atr.PRD_LVL_CHILD and atr_hdr_tech_key = 141
     left join basacdee tipo_surt on des_atr.ATR_COD_TECH_KEY = tipo_surt.ATR_COD_TECH_KEY
where p.PRD_LVL_NUMBER  = '25707';

-- 24/09/2024
-- HESA_41688
-- MEJORA CORRECION EN EL ORDEN VALIDACION EN PIM INTEGRACION
SELECT * FROM prdmstee V WHERE TRIM(V.PRD_NAME_FULL) = trim('ESPONJA DE BAÑO SURTIDO');
SELECT * FROM prdmstee V WHERE TRIM(V.PRD_NAME_FULL) LIKE trim('LANA%FV%ETERBOARD%9%M2%'); --LANA FV ETERBOARD 9 M2 (7.5mX1.2mX3.5¿)
SELECT * FROM prdmstee V WHERE TRIM(V.PRD_NAME_FULL) LIKE trim('LANA FV ETERBOARD 9 M2 (7.5mX1.2mX3.5¿)'); --LANA FV ETERBOARD 9 M2 (7.5mX1.2mX3.5¿)

-- Caso cuando ya existe el producto creado, verificar si el sku esta asignado a otro ID_PIM EN PIM_PRODUCTO
    SELECT * FROM prdmstee V WHERE TRIM(V.PRD_NAME_FULL) = trim('AIRE ACONDICIONADO 3600BTU ALTA EFICIENCIA');
    SELECT * FROM PIM_PRODUCTO WHERE PRD_LVL_NUMBER IN ('36603');
    SELECT * FROM TPPRDMST V WHERE PRD_LVL_NUMBER IN ('36291');
    SELECT * FROM TPPRDMST V WHERE PRD_LVL_NUMBER IN ('36932');

DECLARE
    V_ID_PIM_PROD INTEGER := 82;
    V_RESULT INTEGER;
BEGIN
    PKG_PIM_INTEGRACION.SP_CREAR_PRODUCTO(V_ID_PIM_PROD,V_RESULT);
    DBMS_OUTPUT.PUT_LINE('ID_PIM_PROD: ' || V_ID_PIM_PROD);
    DBMS_OUTPUT.PUT_LINE('RESULT: ' || V_RESULT);
END;

-- 1) Lista de Tramas para procesarlo en PIM_PRODUCTO y PIM_PRODUCTO_ATRIB
SELECT * FROM PIM_MODELO WHERE ID_TIPO = 1 ORDER BY  FEC_CREACION DESC;
SELECT ID_MODELO, ID_TIPO, FEC_CREACION, FLG_PROCESADO, FEC_PROCESO, FLG_ERROR, MENSAJE FROM PIM_MODELO WHERE ID_TIPO = 1 ORDER BY  FEC_CREACION DESC;
SELECT * FROM PIM_MODELO
--UPDATE EDSR.PIM_MODELO SET FLG_PROCESADO = '0'
WHERE ID_MODELO IN (784,783,782,781) AND ID_TIPO = 1 ;

    --Listar
    SELECT ID_MODELO, TO_CLOB(TO_NCLOB(CONTENIDO)) CONTENIDO
    FROM EDSR.PIM_MODELO
    WHERE ID_TIPO = 1 and FLG_PROCESADO = '0' and FLG_ERROR = '0'
    ORDER BY FEC_CREACION;

-- 2) Lista de Productos para Crear en PMM
SELECT * FROM edsr.Pim_Producto ORDER BY FEC_CREACION DESC;
SELECT * FROM edsr.Pim_Producto
--UPDATE edsr.Pim_Producto SET  FLG_PROCESADO = '0',  FEC_PROCESO = NULL
WHERE ID_PIM_PROD IN (813);
--ATRIBUTOS
SELECT * FROM PIM_PRODUCTO_ATRIB WHERE ID_PIM_PROD IN (84);

    --Listar
    SELECT pp.ID_PIM_PROD, pp.DESCRIPCION
    FROM edsr.Pim_Producto pp
        inner join edsr.pim_modelo pm on pm.id_modelo = pp.id_modelo
    WHERE pp.FEC_PROCESO IS NULL and pp.FLG_PROCESADO = '0'
        and pm.id_tipo = 1
    ORDER BY pp.ID_PIM_PROD;

-- 3) Lista de tramas para enviar el SKU hacia PIM
SELECT * FROM edsr.pim_modelo WHERE CONTENIDO LIKE '%HESA_40067%' ORDER BY FEC_PROCESO DESC;
SELECT * FROM edsr.pim_modelo WHERE ID_TIPO = 2 ORDER BY FEC_CREACION DESC;
SELECT * FROM edsr.PIM_MODELO WHERE ID_MODELO = 1871;
SELECT * FROM edsr.PIM_PRODUCTO WHERE ID_MODELO = 1821;
SELECT * FROM edsr.PIM_PRODUCTO WHERE ID_PIM = 'HESA_40068';
SELECT * FROM edsr.PIM_PRODUCTO_ATRIB WHERE ID_PIM_PROD = 87;
SELECT ID_MODELO, ID_TIPO, FEC_CREACION, FLG_PROCESADO, FEC_PROCESO, FLG_ERROR, MENSAJE FROM PIM_MODELO WHERE ID_TIPO = 2 ORDER BY  FEC_CREACION DESC;



SELECT * FROM edsr.pim_modelo
--UPDATE edsr.pim_modelo SET  FLG_PROCESADO = '1'
WHERE ID_TIPO = 2 AND ID_MODELO IN (542,540,541) ;

    --Listar
    SELECT
     FEC_CREACION,Id_Modelo, Id_Tipo, TO_CLOB(TO_NCLOB(CONTENIDO)) CONTENIDO
    FROM edsr.pim_modelo
    WHERE id_tipo = 2 and FLG_PROCESADO = '0'
    ORDER BY FEC_CREACION DESC;



-- UPDATE PIM hacia PMM
-- Listar Pendientes
    SELECT * FROM PIM_MODELO_TIPO;
    SELECT * FROM PIM_ATRIBUTO;
    SELECT * FROM PIM_MODELO WHERE ID_TIPO = 3;
    SELECT * FROM PIM_PRODUCTO WHERE ID_MODELO IN (1872,1873,1874,1875,1778);
    SELECT * FROM PIM_PRODUCTO_ATRIB WHERE PIM_PRODUCTO_ATRIB.ID_PIM_PROD IN (81,94,95,96,97);

-- UPDATE PMM hacia PIM
-- Listar Pendientes
    SELECT * FROM PIM_MODELO WHERE ID_TIPO = 4 ORDER BY FEC_CREACION DESC;
    SELECT * FROM PIM_MODELO WHERE ID_TIPO = 4 AND MENSAJE LIKE '%HESA_40155%' ORDER BY FEC_CREACION DESC;
    SELECT * FROM PIM_MODELO WHERE ID_TIPO = 4 AND FLG_PROCESADO = '0' AND FEC_PROCESO IS NULL;

    --CORRECION
    SELECT * FROM PIM_MODELO
    --UPDATE PIM_MODELO SET FEC_CREACION = SYSDATE , FLG_PROCESADO = '1'
    WHERE ID_MODELO IN (2353,2362,2736);


-- Existencias
-- Proveedor:
SELECT * FROM VPCMSTEE V WHERE TRIM(V.VENDOR_NUMBER) = trim('0992328983001');
SELECT * FROM VPCMSTEE V WHERE VENDOR_NAME LIKE '%HOMECENTERS%ECUATORIANOS%';
SELECT * FROM VPCMSTEE V WHERE TRIM(V.VENDOR_NUMBER) = trim('1793194511001');

-- producto
SELECT * FROM prdmstee V WHERE PRD_LVL_CHILD = '112795';
SELECT * FROM prdmstee V WHERE TRIM(V.PRD_NAME_FULL) = trim('SERVICIO ARMADO PROMOCIONAL');

-- Case Pack o el SKU PROVEEDOR
 SELECT V.VPC_TECH_KEY
 FROM VPCMSTEE V
    WHERE V.VENDOR_NUMBER = RPAD('1792497434001', 15, ' ');

--Codigo Barra
SELECT * FROM VPCUPCEE;
SELECT * FROM BASATYEE; --TIPOS DE ATRIBUTOS
SELECT * FROM BASAHREE; --SUB TIPO DE ATRIBUTOS
SELECT * FROM BASACDEE; --CÓDIGO DE ATRIBUTO

SELECT * FROM APPAPPEE; --APLICACIÓN
SELECT * FROM BASAAXEE; --ATRIBUTOS/APLICACIÓN

SELECT * FROM BASATPEE; --Prod. asignados a atributos
SELECT * FROM BASATBEE; --Prod. asignados a atributos


--SkuProveedor
SELECT * FROM VPCPRDEE CP
    WHERE CP.VPC_TECH_KEY = 14488
    AND CP.VPC_CASE_PACK_ID = RPAD('POLT002*', 25, ' ');

-- CODIGO EAN
/*
22/10/2024
CONSIDERAR SOLO LOS QUE ESTAN COMO EAN PRINCIPAL
PRD_PRIMARY_FLAG = 'T'   => Significa que es el principal y el que sale en el reporte JSatelite Maestro de Productos
PRD_UPC => EAN
*/
SELECT DISTINCT UPC_TYPE FROM PRDUPCEE; --8,12,13,14

SELECT PRD.PRD_LVL_NUMBER, EAN.* FROM PRDUPCEE EAN INNER JOIN PRDMSTEE PRD ON PRD.PRD_LVL_CHILD = EAN.PRD_LVL_CHILD
                                 ORDER BY PRD_LVL_NUMBER DESC
--WHERE PRD_UPC IN ('7862131453819','7862131453826','7862131453802','2500000344237')
;

SELECT PRD.PRD_LVL_NUMBER, EAN.PRD_UPC
FROM PRDUPCEE EAN
    INNER JOIN PRDMSTEE PRD ON PRD.PRD_LVL_CHILD = EAN.PRD_LVL_CHILD
order by prd.PRD_LVL_NUMBER DESC;

--295 skus de 306
SELECT
    EAN.PRD_UPC, COUNT(EAN.PRD_UPC)
FROM PRDUPCEE EAN
    INNER JOIN PRDMSTEE PRD ON PRD.PRD_LVL_CHILD = EAN.PRD_LVL_CHILD
--WHERE PRD.PRD_LVL_NUMBER IN ('36538','36621','36622','36623','32474','32476','32478','32481','32499','32504','32502','27242','27259','27243','27260','27244','27261','27245','27262','27263','27257','27265','27268','27267','27266','27246','27247','27252','27248','27253','27249','27254','27255','27258','27256','27264','27269','27250','27286','27288','27287','27110','27107','27134','27130','27137','27140','27139','27142','27143','27284','27127','27133','27159','27147','27138','27128','27131','27141','27119','27132','27118','27120','27126','27144','27145','27146','27136','27125','27289','27124','27129','27117','27154','27151','27163','27123','27158','27115','27152','27116','27153','27149','27161','27162','27121','27122','27156','27157','27114','27148','27160','27155','32578','27215','27217','27208','27224','27210','27204','27211','27213','27201','27214','27226','27216','27203','27227','27207','27200','27228','27206','27197','27198','27199','27225','27212','27189','27186','27192','27187','27104','27196','27190','27188','27202','27195','27105','27218','27220','27221','27222','27223','27234','27167','27168','27171','27172','27173','27178','27179','27180','27238','27239','27240','27185','27165','27166','27170','27177','27236','27237','27184','27164','27169','27175','27176','27182','27183','27111','27112','27113','27229','27135','27367','27363','27360','27366','27358','27174','27241','27368','27191','27230','27285','27355','27326','27325','27300','27327','27339','27321','27349','27181','27194','27103','27102','27231','27219','27232','27301','27290','27293','27292','27291','27294','27303','27205','27209','35489','35490','35644','32202','27350','27342','27341','27333','27317','27373','27354','27338','27364','27370','27357','27374','27332','27309','27369','27365','27314','27310','27386','27315','27330','27347','27311','27316','27312','27385','27384','27299','27313','27340','27302','27323','27361','27362','27381','27351','27348','27382','27379','27336','27352','27383','27334','27380','27324','27353','27337','27335','27320','27328','27305','27329','27306','27322','27307','27331','27308','27343','27304','27345','27344','27371','27372','27376','27359','27318','27377','27378','27319','27346','27297','27295','27298','27296','27375','27251','27233','27193','27270','27273','27106','27281','27271','27274','27277','27282','27275','27279','27280','27272','27276','27278','27283','35492','35493','35491','27387','27109','27235','32204','32203','27108','27150')
GROUP BY EAN.PRD_UPC
HAVING COUNT(PRD_UPC) > 1
;
SELECT
    PRD.PRD_LVL_NUMBER, EAN.PRD_UPC, EAN.VPC_PRIMARY_FLAG --, COUNT(EAN.PRD_UPC) --EAN.*
FROM PRDUPCEE EAN
    INNER JOIN PRDMSTEE PRD ON PRD.PRD_LVL_CHILD = EAN.PRD_LVL_CHILD
--WHERE PRD.PRD_LVL_NUMBER IN ('36538','36621','36622','36623','32474','32476','32478','32481','32499','32504','32502','27242','27259','27243','27260','27244','27261','27245','27262','27263','27257','27265','27268','27267','27266','27246','27247','27252','27248','27253','27249','27254','27255','27258','27256','27264','27269','27250','27286','27288','27287','27110','27107','27134','27130','27137','27140','27139','27142','27143','27284','27127','27133','27159','27147','27138','27128','27131','27141','27119','27132','27118','27120','27126','27144','27145','27146','27136','27125','27289','27124','27129','27117','27154','27151','27163','27123','27158','27115','27152','27116','27153','27149','27161','27162','27121','27122','27156','27157','27114','27148','27160','27155','32578','27215','27217','27208','27224','27210','27204','27211','27213','27201','27214','27226','27216','27203','27227','27207','27200','27228','27206','27197','27198','27199','27225','27212','27189','27186','27192','27187','27104','27196','27190','27188','27202','27195','27105','27218','27220','27221','27222','27223','27234','27167','27168','27171','27172','27173','27178','27179','27180','27238','27239','27240','27185','27165','27166','27170','27177','27236','27237','27184','27164','27169','27175','27176','27182','27183','27111','27112','27113','27229','27135','27367','27363','27360','27366','27358','27174','27241','27368','27191','27230','27285','27355','27326','27325','27300','27327','27339','27321','27349','27181','27194','27103','27102','27231','27219','27232','27301','27290','27293','27292','27291','27294','27303','27205','27209','35489','35490','35644','32202','27350','27342','27341','27333','27317','27373','27354','27338','27364','27370','27357','27374','27332','27309','27369','27365','27314','27310','27386','27315','27330','27347','27311','27316','27312','27385','27384','27299','27313','27340','27302','27323','27361','27362','27381','27351','27348','27382','27379','27336','27352','27383','27334','27380','27324','27353','27337','27335','27320','27328','27305','27329','27306','27322','27307','27331','27308','27343','27304','27345','27344','27371','27372','27376','27359','27318','27377','27378','27319','27346','27297','27295','27298','27296','27375','27251','27233','27193','27270','27273','27106','27281','27271','27274','27277','27282','27275','27279','27280','27272','27276','27278','27283','35492','35493','35491','27387','27109','27235','32204','32203','27108','27150')
WHERE PRD.PRD_LVL_NUMBER IN ('25707')
AND EAN.PRD_UPC IN (
        SELECT PRD_UPC
        FROM PRDUPCEE
        WHERE PRD_LVL_CHILD = PRD.PRD_LVL_CHILD
        GROUP BY PRD_UPC
        HAVING COUNT(DISTINCT PRD_LVL_CHILD) > 1
    )
GROUP BY PRD.PRD_LVL_NUMBER--, EAN.PRD_UPC;

;
--******************
--      Marca
--******************
--Redcliffs Outdoor
SELECT * FROM PIM_PRODUCTO WHERE ID_PIM = 'HESA_41613';
SELECT * FROM PIM_PRODUCTO_ATRIB WHERE ID_PIM_PROD = 1659;

select trim(VALOR) from PIM_PRODUCTO_ATRIB
where COD_ATRIBUTO = 'Marca' AND ID_PIM_PROD = 1659 ;

SELECT ATR_CODE as Codigo, ' => ',  ATR_CODE_DESC as Descripcion
FROM basacdee
WHERE atr_hdr_tech_key  in (105) AND EXISTS (
    SELECT 1
    FROM dual
    WHERE ASCII(SUBSTR(atr_code_desc, LEVEL, 1)) BETWEEN 97 AND 122
    CONNECT BY LEVEL <= LENGTH(atr_code_desc)
);


select *
--into V_COD_ATR
from basacdee
where atr_hdr_tech_key  in (105)-- select ATR_HDR_TECH_KEY from PIM_ATRIBUTO where cod_atributo = 'Marca'
    AND REGEXP_INSTR(atr_code_desc, '[a-z]') > 0
    --AND NOT REGEXP_LIKE(TRIM(atr_code_desc), '^[^a-z]*$')
   -- and atr_code_desc LIKE 'RE%' OR ATR_CODE LIKE 'RED%'
    --and atr_code_desc LIKE '%RED%CLIFFS%OUTDOOR%'
   -- and atr_code_desc = upper('Redcliffs Outdoor');
;
select trim(bas.atr_code), bas.*
--into V_COD_ATR
from basacdee bas
    where atr_hdr_tech_key  in (select ATR_HDR_TECH_KEY from PIM_ATRIBUTO
                             where cod_atributo = 'Marca')
            and atr_code_desc = ' Coghlan''s';

select * from basacdee bas where bas.ATR_CODE_DESC LIKE '%MONICA%HOMES%COLLECTION';
select * from basacdee bas where bas.ATR_CODE_DESC LIKE '%MONICA%';

-- Atributos
SELECT * FROM  basahree WHERE app_func = 'PRD' ;
SELECT * FROM  basahree WHERE app_func = 'PRD' AND ATR_HEADER_DESC LIKE '%REND%';
SELECT * FROM  basahree WHERE  ATR_HEADER_DESC LIKE '%RE%';
-- Especificos y Categoria
SELECT * FROM  basahree ORDER BY  ATR_HEADER_DESC DESC;

--Campos Adicionales
SELECT * FROM SDIVALMSI;
SELECT BSV.* FROM basvalee BSV WHERE TECH_KEY1 = '';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT)  LIKE '%SDIVALMSI%' AND OWNER = 'EDSR';


SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT)  LIKE '%SDIVALMSI%';

SELECT PRD.PRD_LVL_NUMBER, BSV.* FROM basvalee BSV INNER JOIN TPPRDMST PRD ON PRD.PRD_LVL_CHILD = BSV.TECH_KEY1;


SELECT * FROM EDSR.PIM_MODELO WHERE ID_MODELO IN (12303,12303,12312,12312,12321,12321,12922,12922,12984,12984,23625,23625,23626,23626,23630,23630,33461,33461,33462,33462,33463,33463,33464,33464,33465,33465,33466,33466,33467,33467,33468,33468,33469,33469,33470,33470,33471,33471,33472,33472,33473,33473,33474,33474,33475,33475,33476,33476,33477,33477,33478,33478,33479,33479,33480,33480,33481,33481,33482,33482,33483,33483,33484,33484,33485,33485,33486,33486,33487,33487,33488,33488,33489,33489,33490,33490)
;
-- Listar ATRIBUTOS DIFERENTES ENTRE PMM y PIM SNAPSHOT
SELECT PIM.Id_Modelo,
       PIM.Id_Tipo,
       TO_CLOB(TO_NCLOB(PIM.MENSAJE)) MENSAJE
FROM edsr.PIM_MODELO PIM
WHERE PIM.ID_TIPO = 4 AND PIM.FLG_PROCESADO = 0
ORDER BY PIM.FEC_CREACION ASC;

-- OBTENER DIFERENCIAS ENTRE PMM y PIM SNAPSHOT
SELECT B.ID_PIM, A.prd_lvl_child, A.prd_lvl_number, A.prd_name_full,
               A.prd_status,         CASE WHEN NVL(TRIM(A.prd_status), 'XX') <> NVL(TRIM(B.estadoProducto), 'XX')        THEN 1 ELSE 0 END  status_diff,
               A.dun14,              CASE WHEN NVL(TRIM(A.dun14), 'XX') <> NVL(TRIM(B.dun14), 'XX')                      THEN 1 ELSE 0 END  dun14_diff,
               A.vendor_name,        CASE WHEN NVL(TRIM(A.vendor_name), 'XX') <> NVL(TRIM(B.razon_social), 'XX')         THEN 1 ELSE 0 END  vendor_name_diff,
               A.vendor_number,      CASE WHEN NVL(TRIM(A.vendor_number), 'XX') <> NVL(TRIM(B.codigo_proveedor), 'XX')   THEN 1 ELSE 0 END  vendor_number_diff,
               A.UMI,                CASE WHEN NVL(TRIM(A.UMI), 'XX') <> NVL(TRIM(B.UMI), 'XX')                          THEN 1 ELSE 0 END  UMI_diff,
               A.ean,                CASE WHEN NVL(TRIM(A.ean), 'XX') <> NVL(TRIM(B.ean), 'XX')                          THEN 1 ELSE 0 END  ean_diff,
               A.VPC_CASE_QTY_UOM,   CASE WHEN NVL(TRIM(A.VPC_CASE_QTY_UOM), 'XX') <> NVL(TRIM(B.umv), 'XX')             THEN 1 ELSE 0 END  VPC_CASE_QTY_UOM_diff,
               A.sku_proveedor,      CASE WHEN NVL(TRIM(A.sku_proveedor), 'XX') <> NVL(TRIM(B.sku_proveedor), 'XX')      THEN 1 ELSE 0 END  sku_proveedor_diff,
               A.tipo_surtido,       CASE WHEN NVL(TRIM(A.tipo_surtido), 'XX') <> NVL(TRIM(B.tipo_surtido), 'XX')        THEN 1 ELSE 0 END  tipo_surtido_diff
FROM (
     SELECT p.prd_lvl_child, trim(p.prd_lvl_number) prd_lvl_number, trim(p.prd_name_full) prd_name_full
     --campos nuevos
     , TO_CHAR(est.PRD_STATUS_DESC) prd_status, to_char(dun.prd_upc) dun14, prov.vendor_name, to_char(prov.vendor_number) vendor_number
     , vpc.INV_UOM UMI, to_char(ean.prd_upc) ean, vpc.VPC_CASE_QTY_UOM, vpc.VPC_CASE_PACK_ID sku_proveedor
     , tipo_surt.ATR_CODE tipo_surtido
     FROM prdmstee p
     inner join (select e.PRD_LVL_CHILD, e.prd_status, des.PRD_STATUS_DESC,
           row_number() over(partition by PRD_LVL_CHILD order by EFFECT_DATE desc) rn
           from PRDSTEEE e INNER JOIN EDSR.PRDSTSEE des on des.PRD_STATUS = e.PRD_STATUS) est
       on est.PRD_LVL_CHILD = p.PRD_LVL_CHILD and est.rn = 1
     left join PRDUPCEE dun on dun.PRD_LVL_CHILD = p.PRD_LVL_CHILD and dun.upc_type = 14 and dun.active_flag ='T'
     left join PRDUPCEE ean on EAN.PRD_LVL_CHILD = p.PRD_LVL_CHILD and EAN.upc_type IN (7,8,12,13) and EAN.default_flag ='T'
     left join vpcprdee vpc on dun.vpc_prd_tech_key = vpc.vpc_prd_tech_key
     left join vpcmstee prov on vpc.vpc_tech_key = prov.vpc_tech_key
     left join basatpee des_atr on p.PRD_LVL_CHILD = des_atr.PRD_LVL_CHILD and atr_hdr_tech_key = 141
     left join basacdee tipo_surt on des_atr.ATR_COD_TECH_KEY = tipo_surt.ATR_COD_TECH_KEY
) A --SELECT DE PMM CON LA DATA ACTUALIZADA

INNER JOIN (
      SELECT ID_PIM, PRD_LVL_CHILD, PRD_LVL_NUMBER, prd_name_full, estadoProducto, dun14, razon_social, codigo_proveedor
      , umi, ean, umv, sku_proveedor, tipo_surtido
      FROM EDSR.PIM_PRODUCTO_DATA_PMM

) B --SELECT DE LA TABLA PIM_PRODUCTO_DATA_PMM (DATA SNAPSHOT)
ON A.prd_lvl_child = B.prd_lvl_child
WHERE NVL(TRIM(A.prd_status), 'XX') <> NVL(TRIM(B.estadoProducto), 'XX')
      OR NVL(TRIM(A.dun14), 'XX') <> NVL(TRIM(B.dun14), 'XX')
      OR NVL(TRIM(A.vendor_name), 'XX') <> NVL(TRIM(B.razon_social), 'XX')
      OR NVL(TRIM(A.vendor_number), 'XX') <> NVL(TRIM(B.codigo_proveedor), 'XX')
      OR NVL(TRIM(A.UMI), 'XX') <> NVL(TRIM(B.UMI), 'XX')
      OR NVL(TRIM(A.ean), 'XX') <> NVL(TRIM(B.ean), 'XX')
      OR NVL(TRIM(A.VPC_CASE_QTY_UOM), 'XX') <> NVL(TRIM(B.umv), 'XX')
      OR NVL(TRIM(A.sku_proveedor), 'XX') <> NVL(TRIM(B.sku_proveedor), 'XX')
      OR NVL(TRIM(A.tipo_surtido), 'XX') <> NVL(TRIM(B.tipo_surtido), 'XX');



SELECT * FROM EDSR.basahree M ORDER BY ATR_HEADER_DESC DESC ;
SELECT * FROM EDSR.basahree M WHERE ATR_HEADER_DESC LIKE '%AFEC%';

SELECT  DECODE('T', 'F', 'SI', 'NO') FROM DUAL;
-- 37255 se creo 7 octubre, 16 octubre se descubrio.
SELECT PRD.AFECTO, PRD.* FROM tpprdmst PRD WHERE PRD_LVL_NUMBER IN ('37255'); -- antes salia como si afecta(F). NO afecta IVA (T)
-- hoy 25/11
SELECT PRD.AFECTO, PRD.* FROM tpprdmst PRD WHERE PRD_LVL_NUMBER IN ('38113');-- NO AFECTO IVA
SELECT PRD.AFECTO, PRD.* FROM tpprdmst PRD WHERE PRD_LVL_NUMBER IN ('38097');-- SI AFECTO IVA

--Viernes 22/11
SELECT PRD.AFECTO, PRD.* FROM tpprdmst PRD WHERE PRD_LVL_NUMBER IN ('38083');-- SI AFECTO IVA


SELECT PRD.* FROM PRDMSTEE PRD WHERE PRD_LVL_NUMBER IN ('36192');
SELECT PRD.* FROM TPPRDMST PRD WHERE PRD_LVL_NUMBER IN ('37255');

SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%TPPRDMST%';

select P.prd_lvl_number "SKU",
       DECODE(P.afecto, 'F', 'SI', 'NO') "Afecto a IGV",
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
       --nvl(edsr.fn_get_atrib(p.prd_lvl_number, '161'), 'NO') "EXPRESS RETAIL",
       'EXPRESS RETAIL',
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
--WHERE P.PRD_LVL_NUMBER IN ('36192');
WHERE P.AFECTO IN ('T');

--Total   => AFECTO IGV
--25787 => F , significa que SI esta afecto
--458   => T , significa que NO esta afecto