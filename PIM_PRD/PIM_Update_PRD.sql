/*
 pases pendientes:
 PASE PENDIENTE 1 (Creado: 11/07/2024 16:34pm)
 ENVIADO: NO (Actualizado: 11/07/2024 16:34pm)

    INSERT INTO EDSR.PIM_MODELO_TIPO (ID_TIPO, TIPO) VALUES (4, 'Actualización de atributos de PMM');
 */
SELECT * FROM PIM_MODELO WHERE ID_TIPO IN (3); -- Cambios de PIM a PIM
SELECT * FROM PIM_MODELO WHERE ID_TIPO IN (4); -- Cambios de PMM a PIM
--DELETE PIM_MODELO WHERE ID_TIPO = 4;
SELECT * FROM PIM_PRODUCTO ORDER BY FEC_CREACION DESC;
SELECT * FROM PIM_PRODUCTO_ATRIB WHERE ID_PIM_PROD = 796;
SELECT * FROM PIM_MODELO_TIPO;
SELECT * FROM PIM_ATRIBUTO;

-- FVC_OBTENER_EAN
SELECT trim(upper(VALOR))
      FROM PIM_PRODUCTO_ATRIB
      WHERE ID_PIM_PROD = 796
        AND COD_ATRIBUTO   = 'TipoEan';

        select UPC_TYPE
        from PRDUCDEE
        where trim(upper(UPC_TYPE_DESC)) = 'EAN/UPC 13';

SELECT * FROM PRDUCDEE;

SELECT DISTINCT ID_TIPO FROM PIM_MODELO WHERE ID_TIPO IN (3);;

SELECT * FROM PIM_PRODUCTO_DATA_PMM WHERE PRD_LVL_NUMBER IN ('36035'); --1250000036035(7: Digito Verificador)
-- EAN:
/*
    12
    14  DUN14
    13
    8
*/
SELECT EAN.* FROM PRDUPCEE EAN WHERE PRD_LVL_CHILD IN ('124704');
SELECT DISTINCT UPC_TYPE FROM PRDUPCEE;

-- REGISTRA_DUN14: SP que registra DUN14
-- REGISTRA EN LAS TABLAS: SDIPRDUPI, SDIVPCUPI (ID EN COMUN ES: V_BATCH_NUM, es cargado en SP: CARGA_PRD_VARIABLE, con el SEQUENCE: SEQ_TE_LOD_ATR.NEXTVAL)
     IF V_DUN14 IS NULL THEN
        SELECT COD_BAR_ND || TP_PKG_GEN_FUNCIONES.SP_DIGITO_VERIFICADOR(COD_BAR_ND)
        --INTO V_DUN14
        FROM (
            SELECT '125' || LPAD('36035', 10, '0') AS COD_BAR_ND
            FROM DUAL
        );
     END IF;


/*********************************************************************************************************
                                            FLUJO PIM A PMM
 *********************************************************************************************************/
BEGIN
 -- 0. Se lista los ID_PIM_PROD
    SELECT ID_MODELO, ID_TIPO, FLG_PROCESADO, FEC_PROCESO,FEC_CREACION FROM PIM_MODELO order by FEC_CREACION DESC;
    SELECT * FROM PIM_MODELO WHERE ID_TIPO = 3;
    SELECT * FROM PIM_MODELO WHERE ID_MODELO = 1255;
    SELECT * FROM PIM_PRODUCTO_ATRIB WHERE ID_PIM = 'HESA_40065';

    SELECT P.PRD_LVL_NUMBER, P.PRD_LVL_CHILD, P.* FROM PIM_PRODUCTO P order by P.FEC_CREACION DESC;
    SELECT P.PRD_LVL_NUMBER, P.PRD_LVL_CHILD,P.* FROM PIM_PRODUCTO P WHERE P.ID_PIM_PROD = 521;
    SELECT P.PRD_LVL_NUMBER, P.PRD_LVL_CHILD,P.* FROM PIM_PRODUCTO P WHERE P.PRD_LVL_NUMBER IS NOT NULL;
    SELECT P.PRD_LVL_NUMBER, P.PRD_LVL_CHILD,P.* FROM PIM_PRODUCTO_DATA_PMM P WHERE P.PRD_LVL_NUMBER IS NOT NULL;

-- SP: SP_GET_PRODUCTOS_PENDIENTES
    SELECT pp.ID_PIM_PROD, pp.DESCRIPCION --,pp.*
      FROM edsr.Pim_Producto pp
        inner join edsr.pim_modelo pm on pm.id_modelo = pp.id_modelo
      WHERE pp.FEC_PROCESO IS NULL and pp.FLG_PROCESADO = '0'
        and pm.id_tipo = 3
      ORDER BY pp.ID_PIM_PROD;

-- SP: SP_MODIFICAR_PRODUCTO_ATRIBUTO
    SELECT * FROM PIM_MODELO ORDER BY FEC_CREACION DESC;
    SELECT * FROM PIM_PRODUCTO ORDER BY FEC_CREACION DESC;
    SELECT * FROM PIM_PRODUCTO_ATRIB ORDER BY ID_PIM_PROD DESC ;
    SELECT * FROM PIM_PRODUCTO_ATRIB WHERE ID_PIM IN ('HESA_40065');
 -- 1. Extraccion del SKU en PIM_PRODUCTO (prd_lvl_number) (con su ID_PIM_PROD) (V_SKU)
     SELECT trim(PRD_LVL_NUMBER) FROM PIM_PRODUCTO WHERE ID_PIM_PROD = 81;
 -- 2. Extraccion del CHILD del PRDMSTEE (prd_lvl_child) (con el SKU del PIM_PRODUCTO) (P_PRD_LVL_CHILD)
     SELECT prd_lvl_child fROM prdmstee WHERE trim(prd_lvl_number) = '36284';
 -- 3. SELECT SEQ_TE_LOD_ATR.NEXTVAL INTO V_BATCH_NUM FROM DUAL; (V_BATCH_NUM)
 -- 4. INSERT en SDIPRDATI el siguiente SELECT:
     SELECT
	    'V_BATCH_NUM',
	    ROWNUM,
	    'V_SKU',
	    0,
	    ATR_TYP_TECH_KEY,
	    ATR_HDR_TECH_KEY,
	    ID,
	    'C',
	    1
	FROM PIM_PRODUCTO_ATRIB
	WHERE ID_PIM_PROD = 81 AND ATR_TYP_TECH_KEY IS NOT NULL;
 -- 5. Extraccion del ID_PIM en PIM_PRODUCTO (ID del PIM) (con su P_ID_PIM_PROD)
 -- 6. SDIATIBA(V_BATCH_NUM, 'F', 0, V_SKU);
 -- 7. Verificacion ERROR en tabla SDIPRDATI con:
     SELECT SUBSTR(SDI.ERROR_CODE || ' - ' || ERR.REJ_DESC, 0, 4000)
          INTO V_MSG_ERROR
     FROM SDIPRDATI SDI
          INNER JOIN SDIREJCD ERR ON SDI.ERROR_CODE = ERR.REJ_CODE
     WHERE SDI.BATCH_NUM = V_BATCH_NUM
          AND ROWNUM = 1
          AND SDI.ERROR_CODE IS NOT NULL
          AND SDI.ERROR_CODE > 0;

  --DEBUG: SP_MODIFICAR_PRODUCTO_ATRIBUTO
  DECLARE
      P_ID_PIM_PROD NUMBER := 81;
      P_PRD_LVL_CHILD NUMBER;
  BEGIN
    EDSR.PKG_PIM_INTEGRACION.SP_MODIFICAR_PRODUCTO_ATRIBUTO(P_ID_PIM_PROD,P_PRD_LVL_CHILD);
    DBMS_OUTPUT.PUT_LINE('P_ID_PIM_PROD: ' || P_ID_PIM_PROD);
    DBMS_OUTPUT.PUT_LINE('P_PRD_LVL_CHILD: ' || P_PRD_LVL_CHILD);
  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
  END;
END;
/*********************************************************************************************************
                                            FLUJO PMM A PIM
 *********************************************************************************************************/
BEGIN
-- SP_GET_MODIFICACIONES_PMM
SELECT ID_MODELO, ID_TIPO, FEC_CREACION, FLG_PROCESADO, FEC_PROCESO, FLG_ERROR, MENSAJE FROM PIM_MODELO ORDER BY  FEC_CREACION DESC;
SELECT * FROM PIM_MODELO WHERE ID_TIPO = 4;
SELECT COUNT(*) FROM PIM_MODELO WHERE ID_TIPO = 4;
--DELETE PIM_MODELO WHERE ID_TIPO = 4; COMMIT;
--UPDATE PIM_PRODUCTO_DATA_PMM SET EAN = '', DUN14 = ''; COMMIT;

SELECT * FROM PIM_MODELO WHERE TO_CHAR(FEC_CREACION, 'yyyymmdd') = TO_CHAR(sysdate, 'yyyymmdd');
SELECT TO_CHAR(sysdate, 'yyyymmdd') FROM DUAL;
SELECT * FROM PIM_MODELO WHERE ID_TIPO = 4 AND FLG_PROCESADO = 0 ORDER BY ID_MODELO DESC;
SELECT * FROM PIM_MODELO
--UPDATE PIM_MODELO SET FLG_PROCESADO = '1'
WHERE ID_MODELO IN ('1483','1482','1481','1480','1479','1478','1477','1476','1475','1474','1473','1472','1471','1470','1469','1468','1467','1466','1465','1464','1463','1462','1461','1460','1459','1458','1457','1456','1455','1454','1453','1452','1451','1450','1449','1448','1447','1446','1445','1444','1443','1442','1441','1440','1439','1438','1437','1436','1435','1434','1433','1432','1431','1430','1429','1428','1427','1426','1425','1424','1423','1422','1421','1420','1419','1418','1417','1416','1415','1414','1413','1412','1411','1410','1409','1408','1407','1406','1405','1404','1403','1402','1401','1400','1399','1398','1397','1396','1395','1394','1393','1392','1391','1390','1389','1388','1387','1386','1385','1384','1383','1382','1381','1380','1379','1378','1377','1376','1375','1374','1373','1372','1371','1370','1369','1368','1367','1366','1365','1364','1363','1362','1361','1360','1359','1358','1357','1356','1355','1354','1353','1352','1351','1350','1349','1348','1347','1346','1345','1344','1343','1342','1341','1340','1339','1338','1337','1336','1335','1334','1333','1332','1331','1330','1329','1328','1327','1326','1325','1324','1323','1322','1321','1320','1319','1318','1317','1316','1315','1314','1313','1312','1311','1310','1309','1308','1307','1306','1305','1304','1303','1302','1301','1300','1299','1298','1297','1296','1295','1294','1293','1292','1291','1290','1289','1288','1287','1286','1285','1284','1283','1282','1281','1280','1279','1278','1277','1276','1275','1274','1273','1272','1271','1270','1269','1268','1267','1266','1265','1264','1263','1262','1261','1260','1259','1258','1257','1256','1255','1254','1253','1252','1251','1250','1249','1248','1247','1246','1245','1244','1243','1242','1241','1240','1239','1238','1237','1236','1235','1234','1233','1232','1231','1230','1229','1228','1227','1226','1225','1224','1223','1222','1221','1220','1219','1218','1217','1216','1215','1214','1213','1212','1211','1210','1209','1208','1207','1206','1205','1204','1203','1202','1201','1200','1199','1198','1197','1196','1195','1194','1193','1192','1191','1190','1189','1188','1187','1186','1185','1184','1183','1182','1181','1180','1179','1178','1177','1176','1175','1174','1173','1172','1171','1170','1169','1168','1167','1166','1165','1164','1163','1162','1161','1160','1159','1158','1157','1156','1155','1154','1153','1152','1151','1150','1149','1148','1147','1146','1145','1144','1143','1142','1125','1124','1123','1122','1121','1120','1119','1118','1117','1116','1115','1114','1113','1112','1111','1110','1109','1108','1107','1106','1105','1104','1103','1102','1101','1100','1099','1098','1097','1096','1095','1094','1093','1092','1091','1090','1089','1088','1087','1086','1085','1084','1083','1082','1081','1080','1079','1078','1077','1076','1075','1074','1073','1072','1071','1070','1069','1068','1067','1066','1065','1064','1063','1062','1061','1060','1059','1058','1057','1056','1055','1054','1053','1052','1051','1050','1049','1048','1047','1046','1045','1044','1043','1042','1041','1040','1039','1038','1037','1036','1035','1034','1033','1032','1031','1030','1029','1028','1027','1026','1025','1024','1023','1022','1021','1020','1019','1018','1017','1016','1015','1014','1013','1012','1011','1010','1009','1008','1007','1006','1005','1004','1003','1002','1001','1000','999','998','997','996','995','994','993','992','991','990','989','988','987','986','985','984','983','982','981','980','979','978','977','976','975','974','973','972','971','970','969','968','967','966','965','964','963','962','961','960','959','958','957','956','955','954','953','952','951','950','949','948','947','946','945','944','943','942','941','940','939','938','937','936','935','934','933','932','931','930','929','928','927','926','925','924','923','922','921','920','919','918','917','916','915','914','913','912','911','910','909','908','907','906','905','904','903','902','901','900','899','898','897','896','895','894','893','892','891','890','889','888','887','886','885','884','883','882','881','880','879','878','877','876','875','874','873','872','871','870','869','868','867','866','865','864','863','862','861','860','859','858','857','856','855','854','853','852','851','850','849','848','847','846','845','844','843','842','841','840','839','838','837','836','835','834','833','832','831','830','829','828','827','826','825','824','823','822','821','820','751','750','749','748','747','746','745','744','743','742','741','740','739','738','737','736','735','734','733','732','731','730','729','728','727','726','725','724','723','722','721','720','719','718','717','716','715','714','713','712','711','710','709','708','707','706','705','704','703','702','701','700','699','698','697','696','695','694','693','692','691','690','689','688','687','686','685','684','683','682','681','680','671','670','669','668','667','666','665','664','663','662','661','660','659','658','657','656','655','654','653','652','651','650','649','648','647','646','645','644','643','642','641','640','639','638','637','636','635','634','633','632','631','630','629','628','627','626','625','624','623','622','621','620','619','618','609','608','607','606','605','604','603','602','601','600','599','598','597','596','595','594','593','592','591','590','589','588','587','586','585','584','583','582','581','580','579','578','577','576','575','574','565','564','563','562','561','560','559','558','557','554','553','552','551','550','549','548','547','546');
COMMIT;
/*
 Listar envios de CAMBIOS DE PMM a PIM
 */
SELECT PIM.Id_Modelo, PIM.Id_Tipo, TO_CLOB(TO_NCLOB(PIM.MENSAJE)) MENSAJE
FROM edsr.PIM_MODELO PIM
WHERE PIM.ID_TIPO = 4 and PIM.FLG_PROCESADO = 0
ORDER BY PIM.FEC_CREACION ASC;
/*
HESA_TEST_40012
HESA_TEST_40013
 */

SELECT * FROM PIM_MODELO
-- UPDATE PIM_MODELO SET FLG_PROCESADO = '0'
WHERE MENSAJE LIKE '%HESA_40050%';
COMMIT;
SELECT * FROM PIM_MODELO WHERE MENSAJE LIKE '%HESA_40050%';
SELECT * FROM PIM_MODELO WHERE MENSAJE LIKE '%HESA_TEST_40013%';

/*
 Cuando ya envio exitosamente
 */

UPDATE PIM_MODELO
SET flg_procesado = '1', Mensaje = 'OK', FEC_PROCESO = sysdate
WHERE ID_TIPO = 2 AND ID_MODELO = in_id_Modelo;

DECLARE
    V_CURSOR SYS_REFCURSOR;
BEGIN
    EDSR.PKG_PIM_INTEGRACION.SP_GET_MODIFICACIONES_PMM(V_CURSOR);
    SP_GEN_LOG('V_CURSOS: ' || V_CURSOR);
end;

SELECT * FROM PIM_MODELO WHERE ID_TIPO IN (3); -- Cambios de PIM a PIM
SELECT * FROM PIM_MODELO WHERE ID_TIPO IN (4); -- Cambios de PMM a PIM
--DELETE PIM_MODELO WHERE ID_TIPO = 4;
SELECT * FROM PIM_PRODUCTO ORDER BY FEC_CREACION DESC;
SELECT * FROM PIM_PRODUCTO_ATRIB WHERE ID_PIM_PROD = 796;
SELECT * FROM PIM_PRODUCTO_DATA_PMM WHERE ID_PIM_PROD = 796;

select e.PRD_LVL_CHILD, e.prd_status,
       row_number() over(partition by PRD_LVL_CHILD order by EFFECT_DATE desc) rn,E.*
from PRDSTEEE e;

SELECT * FROM PIM_PRODUCTO_DATA_PMM;
-- Actualizando los codigos en EstadoProducto
UPDATE PIM_PRODUCTO_DATA_PMM P
SET P.ESTADOPRODUCTO = (SELECT PRD_STATUS_DESC FROM PRDSTSEE WHERE PRD_STATUS = P.ESTADOPRODUCTO);

SELECT DISTINCT  PRD_STATUS FROM PRDMSTEE;
SELECT * FROM PRDSTEEE; -- CODIGOS
SELECT * FROM PRDSTSEE ORDER BY PRD_STATUS; -- CODIGOS DESCRIPCION

SELECT PRD.PRD_STATUS, DES.PRD_STATUS_DESC  FROM PRDSTSEE DES
    --INNER JOIN EDSR.B2BSTSEQ B2B on PRDSTSEE.PRD_STATUS = B2B.PRD_STATUS
    INNER JOIN EDSR.PRDSTEEE PRD on DES.PRD_STATUS = PRD.PRD_STATUS;

SELECT DISTINCT  PRD_STATUS FROM PRDSTEEE;
SELECT * FROM PRDSTEAH;

SELECT e.PRD_LVL_CHILD, e.prd_status, des.PRD_STATUS_DESC,
       ROW_NUMBER() OVER(PARTITION BY PRD_LVL_CHILD ORDER BY EFFECT_DATE DESC) AS rn
FROM PRDSTEEE e
INNER JOIN EDSR.PRDSTSEE des on des.PRD_STATUS = e.PRD_STATUS;

END;
/*
DUN14,,37705152065788
EAN,,7705152065787

 */
SELECT * FROM PIM_MODELO WHERE ID_TIPO IN (1) ORDER BY ID_MODELO DESC;
SELECT * FROM PIM_PRODUCTO WHERE  ID_PIM = 'HESA_40002';
SELECT * FROM PIM_PRODUCTO_ATRIB WHERE  ID_PIM = 'HESA_40008';
SELECT * FROM PIM_PRODUCTO_ATRIB WHERE  ID_PIM = 'HESA_40008';
SELECT ID_PIM, PRD_LVL_CHILD, PRD_LVL_NUMBER, prd_name_full, estadoProducto, dun14, razon_social, codigo_proveedor
        , umi, ean, umv, sku_proveedor, tipo_surtido
FROM EDSR.PIM_PRODUCTO_DATA_PMM ORDER BY ID_PIM DESC;
SELECT * FROM PIM_MODELO WHERE ID_TIPO IN (4) AND MENSAJE LIKE '%HESA_40008%';
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
    WHERE PRD_LVL_NUMBER = '36098';


-- SP_GET_MODIFICACIONES_PMM
SELECT * FROM PIM_MODELO WHERE
SELECT * FROM PIM_PRODUCTO ORDER BY FEC_CREACION DESC;
SELECT * FROM PIM_PRODUCTO_ATRIB WHERE  ID_PIM IN ('HESA_40063','HESA_40064','HESA_40065');
SELECT * FROM PIM_PRODUCTO_DATA_PMM WHERE ID_PIM IN ('HESA_40063','HESA_40064','HESA_40065');
SELECT B.ID_PIM, A.*
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

--DE LA LISTA, INSERTA ATRIBUTO POR ATRIBUTO POR CADA HESA_XXXXXX
  INSERT INTO PIM_MODELO(
  ID_MODELO,
  ID_TIPO,
  MENSAJE,
  MESSAGE_ID
)
VALUES(
  SEQ_PIM_MODELO.NEXTVAL,
  C_TIPO_ACTUALIZA_RESP,
  to_clob('{ "id_pim": "' ||  TRIM(REG.Id_Pim) ||
          '", "CodAtributo":"TIPO_DE_SURTIDO", "valorAtributo": "'
          || TRIM(REG.tipo_surtido) || '"}'), 'Resp PMM'
);


--ACTUALIZA SNAPSHOT
UPDATE EDSR.PIM_PRODUCTO_DATA_PMM
SET estadoProducto = TRIM(REG.prd_status)
    , dun14 = TRIM(REG.dun14)
    , razon_social = TRIM(REG.vendor_name)
    , codigo_proveedor = TRIM(REG.vendor_number)
    , umi = TRIM(REG.umi)
    , ean = TRIM(REG.ean)
    , umv = TRIM(REG.VPC_CASE_QTY_UOM)
    , sku_proveedor = TRIM(REG.sku_proveedor)
    , tipo_surtido = TRIM(REG.tipo_surtido)
WHERE ID_PIM = TRIM(REG.ID_PIM);