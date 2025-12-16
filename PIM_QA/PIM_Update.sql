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
 -- 0. Se lista los ID_PIM_PROD
    SELECT ID_MODELO, ID_TIPO, FLG_PROCESADO, FEC_PROCESO,FEC_CREACION FROM PIM_MODELO order by FEC_CREACION DESC;
    SELECT * FROM PIM_MODELO WHERE ID_TIPO = 3;
    SELECT * FROM PIM_MODELO WHERE ID_MODELO = 1255;
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
 -- 1. Extraccion del SKU en PIM_PRODUCTO (prd_lvl_number) (con su ID_PIM_PROD)
 -- 2. Extraccion del CHILD del PRDMSTEE (prd_lvl_child) (con el SKU del PIM_PRODUCTO)
 -- 3. SELECT SEQ_TE_LOD_ATR.NEXTVAL INTO V_BATCH_NUM FROM DUAL;
 -- 4. INSERT en SDIPRDATI el siguiente SELECT:
     SELECT
        ID_PIM,
        ROWNUM,
        ID_PIM_PROD,
        0,
        ATR_TYP_TECH_KEY,
        ATR_HDR_TECH_KEY,
        ID,
        'C',
        1
    FROM PIM_PRODUCTO_ATRIB WHERE ID IS NOT NULL;
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
      P_ID_PIM_PROD NUMBER := 799;
      P_PRD_LVL_CHILD NUMBER;
  BEGIN
    EDSR.PKG_PIM_INTEGRACION.SP_MODIFICAR_PRODUCTO_ATRIBUTO(P_ID_PIM_PROD,P_PRD_LVL_CHILD);
    SP_GEN_LOG('P_ID_PIM_PROD: ' || P_ID_PIM_PROD);
    SP_GEN_LOG('P_PRD_LVL_CHILD: ' || P_PRD_LVL_CHILD);
  EXCEPTION
    WHEN OTHERS THEN
        SP_GEN_LOG('ERROR: ' || SQLERRM);
  END;

/*********************************************************************************************************
                                            FLUJO PMM A PIM
 *********************************************************************************************************/
-- SP_GET_MODIFICACIONES_PMM

SELECT ID_MODELO, ID_TIPO, FEC_CREACION, FLG_PROCESADO, FEC_PROCESO, FLG_ERROR, MENSAJE FROM PIM_MODELO WHERE ID_TIPO = 4 ORDER BY  FEC_CREACION DESC;
SELECT * FROM PIM_MODELO WHERE ID_TIPO = 4;
SELECT COUNT(*) FROM PIM_MODELO WHERE ID_TIPO = 4;
--DELETE PIM_MODELO WHERE ID_TIPO = 4; COMMIT;
--UPDATE PIM_PRODUCTO_DATA_PMM SET EAN = '', DUN14 = ''; COMMIT;

SELECT * FROM PIM_MODELO WHERE TO_CHAR(FEC_CREACION, 'yyyymmdd') = TO_CHAR(sysdate, 'yyyymmdd');

SELECT TO_CHAR(sysdate, 'yyyymmdd') FROM DUAL;

/*
 Listar envios de CAMBIOS DE PMM a PIM
 */
SELECT PIM.Id_Modelo, PIM.Id_Tipo, TO_CLOB(TO_NCLOB(PIM.MENSAJE)) MENSAJE FROM edsr.PIM_MODELO PIM
-- UPDATE edsr.PIM_MODELO PIM SET PIM.FLG_PROCESADO = '1'
WHERE PIM.ID_TIPO = 4 and PIM.FLG_PROCESADO = 0
ORDER BY PIM.FEC_CREACION ASC;
COMMIT;
/*
HESA_TEST_40012
HESA_TEST_40013
 */

SELECT * FROM PIM_MODELO
-- UPDATE PIM_MODELO SET FLG_PROCESADO = '0'
WHERE MENSAJE LIKE '%HESA_TEST_40012%';
COMMIT;
SELECT * FROM PIM_MODELO WHERE MENSAJE LIKE '%HESA_TEST_40012%';
SELECT * FROM PIM_MODELO WHERE MENSAJE LIKE '%HESA_TEST_40013%';


--QUERY PARA ACTUALIZAR UN CLOB
SELECT * FROM PIM_MODELO WHERE MENSAJE LIKE '%HESA_TEST_100194%';
SELECT TO_CLOB(MENSAJE), LENGTH(MENSAJE) FROM PIM_MODELO WHERE MENSAJE LIKE '%HESA_TEST_100194%';
SELECT ID_MODELO, mensaje FROM PIM_MODELO WHERE MENSAJE LIKE '%HESA_TEST_100194%' AND ID_MODELO = 2058;
DECLARE
    v_clob CLOB;
    v_json JSON_OBJECT_T;
    V_ValorFinal VARCHAR2(9000);
BEGIN
    -- Asigna tu CLOB a v_clob (por ejemplo, mediante una consulta)
   --SELECT TO_CLOB(MENSAJE) INTO v_clob FROM PIM_MODELO WHERE MENSAJE LIKE '%HESA_TEST_100194%' AND ID_MODELO = 2059;
   SELECT JSON_OBJECT_T.PARSE(MENSAJE) INTO v_json FROM PIM_MODELO WHERE MENSAJE LIKE '%HESA_TEST_100194%' AND ID_MODELO = 2059;


    -- Convierte el CLOB en un objeto JSON, Accede al atributo (.GET_STRING) y Actualiza (.PUT)
    v_json := JSON_OBJECT_T.PARSE(v_clob);
    v_json.PUT('valorAtributo', TRIM(v_json.GET_STRING('valorAtributo')));

    V_ValorFinal := v_json.TO_STRING();
    UPDATE PIM_MODELO SET MENSAJE = V_ValorFinal  WHERE MENSAJE LIKE '%HESA_TEST_100194%' AND ID_MODELO = 2059;
    DBMS_OUTPUT.PUT_LINE( v_json.TO_STRING());
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE( CHR(10));
        SP_GEN_LOG(CHR(10));
        SP_GEN_LOG('ERROR CODIGO: ' || SQLCODE);
        SP_GEN_LOG('ERROR MSG: ' || SQLERRM);
END;

SELECT ID_PIM, PRD_LVL_CHILD, PRD_LVL_NUMBER, prd_name_full, estadoProducto, dun14, razon_social, codigo_proveedor
                  , umi, ean, umv, sku_proveedor, tipo_surtido
FROM EDSR.PIM_PRODUCTO_DATA_PMM WHERE ID_PIM IN ('HESA_TEST_40012','HESA_TEST_40013');

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


-- SP_GET_MODIFICACIONES_PMM
BEGIN
    DECLARE
          CURSOR CUR_ENVIO_PMM IS
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

            BEGIN
              --C_TIPO_ACTUALIZA_RESP
              FOR REG IN CUR_ENVIO_PMM LOOP

                INSERT INTO PIM_MODELO(
                  ID_MODELO,
                  ID_TIPO,
                  MENSAJE,
                  MESSAGE_ID
                )
                VALUES(
                  SEQ_PIM_MODELO.NEXTVAL,
                  4,
                  to_clob('{ "id_pim": "' ||  TRIM(REG.Id_Pim) ||
                          '", "CodAtributo":"ESTADO_DEL_PRODUCTO_PMM", "valorAtributo": "'
                          || REG.prd_status || '"}'), 'Resp PMM'
                );

                INSERT INTO PIM_MODELO(
                  ID_MODELO,
                  ID_TIPO,
                  MENSAJE,
                  MESSAGE_ID
                )
                VALUES(
                  SEQ_PIM_MODELO.NEXTVAL,
                  4,
                  to_clob('{ "id_pim": "' ||  TRIM(REG.Id_Pim) ||
                          '", "CodAtributo":"DUN14", "valorAtributo": "'
                          || REG.dun14 || '"}'), 'Resp PMM'
                );

                INSERT INTO PIM_MODELO(
                  ID_MODELO,
                  ID_TIPO,
                  MENSAJE,
                  MESSAGE_ID
                )
                VALUES(
                  SEQ_PIM_MODELO.NEXTVAL,
                  4,
                  to_clob('{ "id_pim": "' ||  TRIM(REG.Id_Pim) ||
                          '", "CodAtributo":"RAZON_SOCIAL", "valorAtributo": "'
                          || REG.vendor_name || '"}'), 'Resp PMM'
                );

                INSERT INTO PIM_MODELO(
                  ID_MODELO,
                  ID_TIPO,
                  MENSAJE,
                  MESSAGE_ID
                )
                VALUES(
                  SEQ_PIM_MODELO.NEXTVAL,
                  4,
                  to_clob('{ "id_pim": "' ||  TRIM(REG.Id_Pim) ||
                          '", "CodAtributo":"CODIGO_PROVEEDOR", "valorAtributo": "'
                          || REG.vendor_number || '"}'), 'Resp PMM'
                );

                INSERT INTO PIM_MODELO(
                  ID_MODELO,
                  ID_TIPO,
                  MENSAJE,
                  MESSAGE_ID
                )
                VALUES(
                  SEQ_PIM_MODELO.NEXTVAL,
                  4,
                  to_clob('{ "id_pim": "' ||  TRIM(REG.Id_Pim) ||
                          '", "CodAtributo":"UNIDAD_DE_MEDIDA_DE_INVENTARIO_UMI", "valorAtributo": "'
                          || REG.umi || '"}'), 'Resp PMM'
                );

                INSERT INTO PIM_MODELO(
                  ID_MODELO,
                  ID_TIPO,
                  MENSAJE,
                  MESSAGE_ID
                )
                VALUES(
                  SEQ_PIM_MODELO.NEXTVAL,
                  4,
                  to_clob('{ "id_pim": "' ||  TRIM(REG.Id_Pim) ||
                          '", "CodAtributo":"EAN", "valorAtributo": "'
                          || REG.ean || '"}'), 'Resp PMM'
                );

                INSERT INTO PIM_MODELO(
                  ID_MODELO,
                  ID_TIPO,
                  MENSAJE,
                  MESSAGE_ID
                )
                VALUES(
                  SEQ_PIM_MODELO.NEXTVAL,
                  4,
                  to_clob('{ "id_pim": "' ||  TRIM(REG.Id_Pim) ||
                          '", "CodAtributo":"UNIDAD_DE_MEDIDA_DE_VENTA", "valorAtributo": "'
                          || REG.VPC_CASE_QTY_UOM || '"}'), 'Resp PMM'
                );

                INSERT INTO PIM_MODELO(
                  ID_MODELO,
                  ID_TIPO,
                  MENSAJE,
                  MESSAGE_ID
                )
                VALUES(
                  SEQ_PIM_MODELO.NEXTVAL,
                  4,
                  to_clob('{ "id_pim": "' ||  TRIM(REG.Id_Pim) ||
                          '", "CodAtributo":"SKU_PROVEEDOR", "valorAtributo": "'
                          || REG.sku_proveedor || '"}'), 'Resp PMM'
                );

                INSERT INTO PIM_MODELO(
                  ID_MODELO,
                  ID_TIPO,
                  MENSAJE,
                  MESSAGE_ID
                )
                VALUES(
                  SEQ_PIM_MODELO.NEXTVAL,
                  4,
                  to_clob('{ "id_pim": "' ||  TRIM(REG.Id_Pim) ||
                          '", "CodAtributo":"TIPO_DE_SURTIDO", "valorAtributo": "'
                          || REG.tipo_surtido || '"}'), 'Resp PMM'
                );

                --actualizar el snapshot
                update EDSR.PIM_PRODUCTO_DATA_PMM
                set estadoProducto = REG.prd_status
                    , dun14 = REG.dun14
                    , razon_social = REG.vendor_name
                    , codigo_proveedor = REG.vendor_number
                    , umi = REG.umi
                    , ean = REG.ean
                    , umv = REG.VPC_CASE_QTY_UOM
                    , sku_proveedor = REG.sku_proveedor
                    , tipo_surtido = REG.tipo_surtido
                where ID_PIM = REG.ID_PIM;
                DBMS_OUTPUT.PUT_LINE('PRD_LVL_CHILD: ' || REG.PRD_LVL_CHILD || ' PRD_LVL_NUMBER: ' || REG.PRD_LVL_NUMBER);
              END LOOP;
            END;
            COMMIT;
    EXCEPTION
        	WHEN OTHERS THEN
        		DBMS_OUTPUT.PUT_LINE('ERROR OBTENER CAMBIOS DESDE PMM: ' || SQLERRM);
        		ROLLBACK;
    END;


