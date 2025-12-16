/*
TURBO ENTRY:
PROCEDIMIENTO AL ACTUALIZAR OC
EDSR.TP_PKG_TURBO_ENTRY.SP_P_UPD_FECHAOC
*/
SELECT * FROM EDSR.WMS_TIPO_INTEGRACION WTI WHERE TIPO_INTEGRACION LIKE '%PUR%';
-- Estados
SELECT * FROM EDSR.PMGSTSCD ;
SELECT * FROM EDSR.PMGSTSCD ;
-- WMS_PURCHASEORDER_ENVIO
SELECT * FROM EDSR.WMS_PURCHASEORDER_ENVIO WPE WHERE PMG_PO_NUMBER = 108902;
SELECT * FROM EDSR.WMS_PURCHASEORDER_ENVIO WPE WHERE FEC_PROCESADO IS NULL;
SELECT * FROM EDSR.sdipmghde WHERE PMG_PO_NUMBER = 108902;

select P.fec_procesado, P.id_wms, P.* from edsr.wms_purchaseorder_envio P
--actualizar para ponerlo como pendiente y vuelva a enviar la interfaz
--update edsr.wms_purchaseorder_envio set fec_procesado = null, id_wms = null
where pmg_po_number IN (108902) and ID_TIPO = 4; --4: CREATE 16: UPDATE

SELECT * FROM EPMM.PMGHDREE WHERE  NOT PMG_STAT_CODE = 7;

--TPIMPOCC
SELECT PMG_CNCL_BY_DATE,PMG_EXP_RCT_DATE,(PMG_CNCL_BY_DATE - PMG_EXP_RCT_DATE) as dias FROM EDSR.TPIMPOCC WHERE  PMG_PO_NUMBER = 108902;
--PMGHDREE
SELECT WPE.PMG_CNCL_BY_DATE,WPE.PMG_EXP_RCT_DATE, WPE.PMG_SHIP_DATE, WPE.* FROM EDSR.PMGHDREE WPE WHERE PMG_PO_NUMBER = 108902;

--HP_OC_AMPLIACION
SELECT * FROM edsr.HP_OC_AMPLIACION hoa WHERE PMG_PO_NUMBER = 101031 ORDER BY FECHA_CARGA DESC;
SELECT FECHA_NUEVO FROM edsr.HP_OC_AMPLIACION hoa WHERE PMG_PO_NUMBER = 101031 ORDER BY FECHA_CARGA DESC FETCH FIRST 1 ROW ONLY;
--sdipmghde
SELECT SDI.PMG_CANCEL_DATE, sdi.DOWNLOAD_DATE, SDI.Pmg_Stat_Code, sdi.* FROM edsr.sdipmghde sdi  WHERE Pmg_Stat_Code = 4 AND PMG_PO_NUMBER = 101031 ORDER BY SDI.DOWNLOAD_DATE DESC;

----------------------------------------------------------------------------------------
-- INICIO OPERACION CANCELAR
----------------------------------------------------------------------------------------
SELECT * FROM B2B_OC_CANCEL_ENVIO OC
--UPDATE B2B_OC_CANCEL_ENVIO OC SET OC.FEC_PROCESADO = SYSDATE
WHERE OC.FEC_PROCESADO IS NULL AND TO_CHAR(FEC_REG, 'YYYY')   = '2024' AND NOT TO_CHAR(FEC_REG, 'YYYY-MM-DD') = '2024-05-14';

SELECT * FROM B2B_OC_CANCEL_ENVIO OC
-- DELETE FROM B2B_OC_CANCEL_ENVIO OC
WHERE PMG_PO_NUMBER = 101047;

SELECT * FROM EDSR.B2B_OC_ENVIO X
WHERE PMG_PO_NUMBER IN (101047)
        AND X.FEC_PROCESADO IS NOT NULL
        AND X.FLG_ERROR = '0';

SELECT SDI.DOWNLOAD_DATE_2,SDI.PMG_STAT_CODE, SDI.* FROM SDIPMGHDE SDI
--UPDATE SDIPMGHDE SDI SET SDI.DOWNLOAD_DATE_2 = NULL
WHERE PMG_PO_NUMBER = 101047
        and PMG_STAT_CODE IN (6, 7)
        and DOWNLOAD_DATE_2 IS NULL;

SELECT
    --SHD.PMG_PO_NUMBER, SHD.PMG_CNCL_BY_DATE,SHD.PMG_CANCEL_DATE,SHD.DOWNLOAD_DATE_2,SHD.PMG_STAT_CODE,SHD.*
    DISTINCT SHD.PMG_PO_NUMBER, SHD.PMG_CNCL_BY_DATE,SHD.PMG_CANCEL_DATE
FROM SDIPMGHDE SHD
--UPDATE SDIPMGHDE SHD SET SHD.DOWNLOAD_DATE_2 = NULL
WHERE SHD.TRAN_TYPE IN ('A', 'C') AND SHD.PMG_PO_NUMBER IN (101047)
    AND SHD.DOWNLOAD_DATE_2 IS NULL
    AND SHD.PMG_STAT_CODE = 7
    AND EXISTS(
               SELECT 1
               FROM EDSR.B2B_OC_ENVIO X
               WHERE X.PMG_PO_NUMBER = SHD.PMG_PO_NUMBER
                 AND X.FEC_PROCESADO IS NOT NULL
                 AND X.FLG_ERROR = '0'
              );


 PROCEDURE SP_GRABA_B2B_OC_CANCEL_ENVIO(
      P_PMG_PO_NUMBER      NUMBER,
      P_PMG_CNCL_BY_DATE   DATE,
      P_FEC_CANCEL         DATE
    )
    IS
    BEGIN
      UPDATE SDIPMGHDE
         SET DOWNLOAD_DATE_2 = SYSDATE
       WHERE PMG_PO_NUMBER = 101047
         and PMG_STAT_CODE IN (6, 7)
         and DOWNLOAD_DATE_2 IS NULL;

      MERGE INTO B2B_OC_CANCEL_ENVIO B2B
        USING (
               SELECT 101047 AS OC,
                      TO_DATE('2024-05-14','YYYY-MM-DD') AS FEC_CANCEL,
                      TO_DATE('2024-05-14','YYYY-MM-DD') AS PMG_CNCL_BY_DATE
               FROM DUAL
              ) A
        ON (B2B.PMG_PO_NUMBER = A.OC)
      WHEN MATCHED THEN
        UPDATE
           SET FEC_CANCEL       = A.FEC_CANCEL,
               PMG_CNCL_BY_DATE = A.PMG_CNCL_BY_DATE,
               FEC_PROCESADO    = NULL,
               NOMBRE_ARCHIVO   = NULL,
               XML_DATA         = EMPTY_CLOB(),
               FLG_ERROR        = '0',
               MENSAJE          = NULL,
               FEC_REG          = SYSDATE
      WHEN NOT MATCHED THEN
        INSERT (PMG_PO_NUMBER, FEC_CANCEL, PMG_CNCL_BY_DATE)
        VALUES (A.OC, A.FEC_CANCEL, A.PMG_CNCL_BY_DATE);

      COMMIT;
    END;



SELECT DECODE(FEC_CANCEL, PMG_CNCL_BY_DATE, 'vencida', 'cancelar') FROM  EDSR.B2B_OC_CANCEL_ENVIO WHERE PMG_PO_NUMBER IN (101047);
DECLARE
    l_xml XMLTYPE;
BEGIN
    SELECT XMLSERIALIZE(CONTENT XMLElement("Message",
                  XMLConcat(
                            XMLElement("E0", PMG_PO_NUMBER),
                            XMLElement("E1", DECODE(FEC_CANCEL, PMG_CNCL_BY_DATE, 'vencida', 'cancelar'))
                           )
                 )  AS CLOB) AS XML
    --INTO l_xml
    FROM B2B_OC_CANCEL_ENVIO
    WHERE PMG_PO_NUMBER IN (101031);

    DBMS_OUTPUT.PUT_LINE(XMLSERIALIZE(CONTENT l_xml AS CLOB));
END;

----------------------------------------------------------------------------------------
-- FIN OPERACION CANCELAR
----------------------------------------------------------------------------------------

/*
UPDATE edsr.HP_OC_AMPLIACION
SET FEC_WMS_ENVIO = sysdate;
COMMIT;
*/
-- OC HEAD
SELECT WPE.VPC_TECH_KEY ProveedorID, WPE.* FROM EDSR.PMGHDREE WPE WHERE PMG_PO_NUMBER = 105659;
-- OC DETAILS
SELECT * FROM EDSR.PMGDTLEE WPE WHERE PMG_PO_NUMBER = 101029;
-- Proveedor
SELECT WPE.VENDOR_NUMBER CodigoProveedor_TurboEntry, WPE.* FROM EDSR.VPCMSTEE WPE WHERE VPC_TECH_KEY = 14430;



SELECT WPE.VENDOR_NUMBER CodigoProveedor_TurboEntry, WPE.* FROM EDSR.VPCMSTEE WPE WHERE VENDOR_NUMBER = '1790876896001';
SELECT WPE.VPC_TECH_KEY ProveedorID, WPE.* FROM EDSR.PMGHDREE WPE WHERE VPC_TECH_KEY = 14430;
SELECT * FROM EDSR.PMGDTLEE WPE WHERE PMG_PO_NUMBER = 100618;
-- Productos
select PRD_LVL_NUMBER from edsr.tpprdmst prd where PRD_LVL_CHILD IN ('105206',
'105212'
);

SELECT WPE.XML_REQUEST, WPE.* FROM EDSR.WMS_PURCHASEORDER_ENVIO WPE WHERE ID_TIPO = 5;


SELECT * FROM EDSR.WMS_TIPO_INTEGRACION WHERE ID_TIPO = 7;
--SELECT * FROM EDSR.WMS_LOG_INTEGRACION_OC WHERE ID_TIPO = 7 AND IDENTIFICADOR = '1784863';


--FECHA_NUEVO => Es la nueva fecha
SELECT * FROM edsr.HP_OC_AMPLIACION hoa ORDER BY FECHA_CARGA DESC ;
SELECT * FROM edsr.HP_OC_AMPLIACION WHERE FEC_WMS_ENVIO IS NULL ORDER BY ID_CARGA;

SELECT PMG_PO_NUMBER, AUDIT_NUMBER, ID_TIPO, FEC_REG, FEC_PROCESADO, XML_REQUEST, JSON_RESPONSE, FLG_ERROR, MENSAJE, ID_WMS FROM edsr.wms_purchaseorder_envio;
SELECT PMG_PO_NUMBER, AUDIT_NUMBER, ID_TIPO, FEC_REG, FEC_PROCESADO, JSON_RESPONSE, FLG_ERROR, MENSAJE, ID_WMS FROM edsr.wms_purchaseorder_envio;
SELECT PMG_PO_NUMBER, AUDIT_NUMBER, ID_TIPO, FEC_REG, FEC_PROCESADO, FLG_ERROR, MENSAJE, ID_WMS FROM edsr.wms_purchaseorder_envio;
SELECT PMG_PO_NUMBER, AUDIT_NUMBER, ID_TIPO FROM edsr.wms_purchaseorder_envio;
SELECT DISTINCT ID_TIPO FROM edsr.wms_purchaseorder_envio;

SELECT SDI.PMG_PO_NUMBER , max(sdi.audit_number) as audit_number
FROM EDSR.SDIPMGHDE SDI
WHERE sdi.org_lvl_child in (select org.org_lvl_child from wms_tipo_integracion_org org where org.id_tipo = 4)
      and sdi.tran_type = 'A'
      and sdi.download_date_1 is null
      and sdi.pmg_stat_code = v_est_oc_onorder
GROUP BY sdi.pmg_po_number;

SELECT DISTINCT PMG_STAT_CODE FROM EDSR.SDIPMGHDE SDI;


-- INSERT A ENVIAR A QA y PRD
SELECT * FROM edsr.WMS_TIPO_INTEGRACION wti WHERE TIPO_INTEGRACION  LIKE '%PUR%';--crear nueva entrada para update
INSERT INTO EDSR.WMS_TIPO_INTEGRACION (ID_TIPO, TIPO_INTEGRACION, HORA_INICIO, HORA_FINAL) VALUES (16, 'PURCHASE ORDER - UPDATE', 0, 23);

SELECT * FROM WMS_TIPO_INTEGRACION_ORG ORG WHERE ORG.ID_TIPO = 16;
INSERT INTO EDSR.WMS_TIPO_INTEGRACION_ORG (ID_TIPO, ORG_LVL_CHILD) VALUES (16, 419);
INSERT INTO EDSR.WMS_TIPO_INTEGRACION_ORG (ID_TIPO, ORG_LVL_CHILD) VALUES (16, 420);


BEGIN
    INSERT INTO EDSR.WMS_TIPO_INTEGRACION (ID_TIPO, TIPO_INTEGRACION, HORA_INICIO, HORA_FINAL) VALUES (16, 'PURCHASE ORDER - UPDATE', 0, 23);
    INSERT INTO EDSR.WMS_TIPO_INTEGRACION_ORG (ID_TIPO, ORG_LVL_CHILD) VALUES (16, 419);
    INSERT INTO EDSR.WMS_TIPO_INTEGRACION_ORG (ID_TIPO, ORG_LVL_CHILD) VALUES (16, 420);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;


SELECT WPE.FEC_PROCESADO, WPE.ID_WMS, WPE.* FROM edsr.WMS_PURCHASEORDER_ENVIO WPE WHERE PMG_PO_NUMBER IN (101031 , 101032 ,101033);
SELECT * FROM edsr.WMS_PURCHASEORDER_ENVIO WHERE ID_TIPO  = 5;

INSERT INTO EDSR.HP_OC_AMPLIACION (PMG_PO_NUMBER, FECHA_NUEVO, FECHA_ANTERIOR, USUARIO, BACTUALIZADO, ID_CARGA)
VALUES (101031, DATE '2024-05-01', DATE '2024-04-30', 'SISTEMAS', '0', 16);

INSERT INTO EDSR.HP_OC_AMPLIACION (PMG_PO_NUMBER, FECHA_NUEVO, FECHA_ANTERIOR, USUARIO, BACTUALIZADO, ID_CARGA)
VALUES (101032, DATE '2024-05-02', DATE '2024-04-30', 'SISTEMAS', '0', 17);

INSERT INTO EDSR.HP_OC_AMPLIACION (PMG_PO_NUMBER, FECHA_NUEVO, FECHA_ANTERIOR, USUARIO, BACTUALIZADO, ID_CARGA)
VALUES (101033, DATE '2024-05-03', DATE '2024-04-30', 'SISTEMAS', '0', 18);

SELECT WPE.PMG_CNCL_BY_DATE,WPE.PMG_EXP_RCT_DATE, WPE.PMG_SHIP_DATE, WPE.* FROM EDSR.PMGHDREE WPE WHERE PMG_PO_NUMBER IN (101031,101032,101033);
/*
EDSR.PKG_WMS_PURCHASE_ORDER
crear nuevos SP para update
	procesar
	select
	get
*/

-- 1er
select count(pmg_po_number)
from (select pmg_po_number, count(*) conteo
      from HP_OC_AMPLIACION
      where id_carga = 9
      group by pmg_po_number
      having count(*) > 1
      ) s;


-- Al momento de ampliar OC
-- Package: TP_PKG_TURBO_ENTRY
-- sp_grabarAmpliacion

  PROCEDURE sp_grabarAmpliacion(
    pPmg_po_number in NUMBER,
    pFecha_nuevo   in varchar2,
    pUsuario       in VARCHAR2,
    pId_carga      in NUMBER
  )
  is
  begin

    INSERT INTO HP_OC_AMPLIACION
      (pmg_po_number, fecha_nuevo, usuario, bactualizado, id_carga)

    VALUES

      (pPmg_po_number,
       to_date(pFecha_nuevo, 'YYYYMMDD'),
       pUsuario,
       '0',
       pId_carga

       );

  end;


-- sp_procesar_ampliacionOC
PROCEDURE sp_procesar_ampliacionOC(
    pIDCarga IN NUMBER
  )
  IS
    nConteoduplicados number;
  BEGIN

    SELECT count(pmg_po_number)
    INTO nConteoduplicados
    FROM ( SELECT pmg_po_number, count(*) conteo FROM HP_OC_AMPLIACION
           WHERE id_carga = pIDCarga
           GROUP BY pmg_po_number
           HAVING count(*) > 1
         ) s;

    IF (nConteoduplicados = 0) THEN

      -- Actualiza la fecha de Cancelacion actual de PMGHDREE en fecha_anterior de HP_OC_AMPLIACION
      MERGE INTO HP_OC_AMPLIACION oc
      USING (SELECT p.pmg_po_number, pmg_cncl_by_date
             FROM pmghdree p
             INNER JOIN HP_OC_AMPLIACION oa on oa.pmg_po_number = p.pmg_po_number
             WHERE oa.id_carga = 22 --pIDCarga
             GROUP BY p.pmg_po_number, pmg_cncl_by_date
             ) s
      ON (s.pmg_po_number = oc.pmg_po_number and oc.id_carga = 22) --pIDCarga
      WHEN MATCHED THEN
        UPDATE SET oc.fecha_anterior = s.pmg_cncl_by_date;

      -- Actualiza la fecha nueva de Cancelacion en PMGHDREE
      MERGE INTO pmghdree pg
      USING (
             SELECT pmg_po_number, fecha_nuevo, fecha_anterior, usuario
             FROM HP_OC_AMPLIACION
             WHERE id_carga = 37 --pIDCarga
             GROUP BY pmg_po_number, fecha_nuevo, fecha_anterior, usuario
            ) s
      ON (s.pmg_po_number = pg.pmg_po_number and pg.pmg_stat_code in('2','4','5'))
      WHEN MATCHED THEN
        UPDATE SET pg.pmg_cncl_by_date = s.fecha_nuevo;

      MERGE INTO edsr.sdipmghde sdi
      USING(
            SELECT p.pmg_po_number
            FROM pmghdree p
            INNER JOIN HP_OC_AMPLIACION oa on oa.pmg_po_number = p.pmg_po_number
            WHERE oa.id_carga = 22 --pIDCarga
            GROUP BY p.pmg_po_number
           ) src
      ON (sdi.pmg_po_number = src.pmg_po_number)
      WHEN MATCHED THEN
        UPDATE SET DOWNLOAD_DATE = null
      WHERE Pmg_Stat_Code=4;

    ELSE
      Raise_application_error(cEXC_NEGOCIO_COM,'Existen OC duplicadas en el archivo');

    END IF;

  END;

 --HP_OC_AMPLIACION
SELECT * FROM edsr.HP_OC_AMPLIACION hoa WHERE PMG_PO_NUMBER = 101031 ORDER BY FECHA_CARGA DESC;
--PMGHDREE
SELECT WPE.PMG_CNCL_BY_DATE,WPE.PMG_EXP_RCT_DATE, WPE.PMG_SHIP_DATE, WPE.* FROM EDSR.PMGHDREE WPE WHERE PMG_PO_NUMBER = 101031;
--SDIPMGHDE
SELECT sdi.DATE_CREATED, sdi.DOWNLOAD_DATE,sdi.DOWNLOAD_DATE_1, sdi.AUDIT_NUMBER, sdi.org_lvl_child, SDI.tran_type,sdi.pmg_stat_code, SDI.*
    --,max(sdi.audit_number) as audit_number
FROM sdipmghde sdi WHERE PMG_PO_NUMBER =  101031 ORDER BY SDI.DATE_CREATED DESC;

--WMS_TIPO_INTEGRACION_ORG
select id_tipo, org.org_lvl_child from wms_tipo_integracion_org org where org.id_tipo = 4;

-- TPIMPOCC
-- SELECT PMG_CNCL_BY_DATE,PMG_EXP_RCT_DATE,(PMG_CNCL_BY_DATE - PMG_EXP_RCT_DATE) as dias FROM EDSR.TPIMPOCC WHERE  PMG_PO_NUMBER = 101031;


SELECT * FROM  wms_purchaseorder_envio WHERE PMG_PO_NUMBER = 101031; --GROUP BY PMG_PO_NUMBER HAVING COUNT(PMG_PO_NUMBER) >1;

SELECT * FROM wms_purchaseorder_envio WHERE ID_TIPO = 16;
SELECT * FROM edsr.HP_OC_AMPLIACION hoa WHERE PMG_PO_NUMBER = 101031 ORDER BY FECHA_CARGA DESC;
SELECT * FROM edsr.HP_OC_AMPLIACION hoa WHERE PMG_PO_NUMBER = 101032 ORDER BY FECHA_CARGA DESC;
SELECT * FROM edsr.HP_OC_AMPLIACION hoa WHERE PMG_PO_NUMBER = 101033 ORDER BY FECHA_CARGA DESC;

SELECT * FROM edsr.HP_OC_AMPLIACION WHERE PMG_PO_NUMBER IN (101031,101032,101033) order By FECHA_CARGA desc;
SELECT * FROM edsr.sdipmghde sdi WHERE PMG_PO_NUMBER IN (101031) AND PMG_STAT_CODE = 4 ORDER BY AUDIT_NUMBER DESC; -- 4544537041 (15 REGISTROS)
SELECT * FROM edsr.sdipmghde sdi WHERE PMG_PO_NUMBER IN (101032) AND PMG_STAT_CODE = 4 ORDER BY AUDIT_NUMBER DESC; -- 4544536017 / 4544536017
SELECT * FROM edsr.sdipmghde sdi WHERE PMG_PO_NUMBER IN (101033) AND PMG_STAT_CODE = 4 ORDER BY AUDIT_NUMBER DESC; -- 4544535935
SELECT * FROM edsr.HP_OC_AMPLIACION hoa WHERE FEC_WMS_ENVIO IS NULL;
--UPDATE sdipmghde SET download_date_1 = NULL WHERE PMG_PO_NUMBER IN (101031,101032,101033);

SELECT sdi.pmg_po_number, max(sdi.audit_number) as audit_number
-- SELECT  sdi.pmg_po_number, sdi.audit_number,  sdi.tran_type ,sdi.pmg_stat_code,sdi.download_date_1,HOA.FEC_WMS_ENVIO,sdi.PMG_PO_NUMBER
FROM sdipmghde sdi
    INNER JOIN HP_OC_AMPLIACION HOA ON HOA.PMG_PO_NUMBER = SDI.PMG_PO_NUMBER --WHERE  sdi.PMG_PO_NUMBER IN (101032)  ORDER BY sdi.audit_number DESC;
WHERE sdi.org_lvl_child IN (select org.org_lvl_child from wms_tipo_integracion_org org where org.id_tipo = 16) --v_tipo_update
      AND sdi.tran_type != 'A'
      AND sdi.pmg_stat_code = 4 -- v_est_oc_onorder
      AND sdi.download_date_1 IS NULL
      AND HOA.FEC_WMS_ENVIO IS NULL
      --AND sdi.PMG_PO_NUMBER IN (101032)
      --ORDER BY sdi.audit_number DESC
group by sdi.pmg_po_number;

SELECT count (PMG_PO_NUMBER) FROM wms_purchaseorder_envio;
DELETE FROM  wms_purchaseorder_envio WHERE ID_TIPO = 16;
-- sp_procesar_actualizacion

DECLARE
v_est_oc_onorder     constant number(2) := 4;
v_est_oc_cancel      constant number(2) := 7;

v_tipo_create        constant number(3) := 4;
v_tipo_cancel        constant number(3) := 5;
v_tipo_update		 constant number(3) := 16;


BEGIN
    MERGE INTO wms_purchaseorder_envio wms
          -- SELECT * FROM edsr.wms_purchaseorder_envio WHERE PMG_PO_NUMBER IN (101031);
          -- SELECT * FROM edsr.HP_OC_AMPLIACION WHERE PMG_PO_NUMBER IN (101031);
           SELECT * FROM edsr.HP_OC_AMPLIACION ORDER BY FECHA_CARGA DESC;
           SELECT * FROM sdipmghde sdi ORDER BY AUDIT_NUMBER DESC;
          -- SELECT sdi.tran_type,sdi.pmg_stat_code , SDI.download_date_1 , SDI.* FROM edsr.sdipmghde SDI WHERE PMG_PO_NUMBER IN (101031) ORDER BY AUDIT_NUMBER DESC;
          USING(
                SELECT sdi.pmg_po_number, max(sdi.audit_number) as audit_number
                FROM sdipmghde sdi
                    INNER JOIN HP_OC_AMPLIACION HOA ON HOA.PMG_PO_NUMBER = SDI.PMG_PO_NUMBER
                WHERE sdi.org_lvl_child IN (select org.org_lvl_child from wms_tipo_integracion_org org where org.id_tipo = 16) -- v_tipo_update
                      AND sdi.tran_type != 'A'
                      AND sdi.pmg_stat_code = 4 -- v_est_oc_onorder
                      AND sdi.download_date_1 IS NULL
                      AND HOA.FEC_WMS_ENVIO IS NULL
                GROUP BY sdi.pmg_po_number
               )  sdi
          ON (
                 wms.pmg_po_number  = sdi.pmg_po_number
             and wms.audit_number   = sdi.audit_number
             and wms.id_tipo        = v_tipo_update
             )
        WHEN MATCHED THEN
          update
             set fec_procesado  = null,
                 xml_request    = empty_clob(),
                 json_response  = empty_clob(),
                 flg_error      = '0',
                 mensaje        = null
        WHEN NOT MATCHED THEN
          insert (
            pmg_po_number,
            audit_number,
            id_tipo
          )
          values(
            sdi.pmg_po_number,
            sdi.audit_number,
            v_tipo_update
          );

    UPDATE sdipmghde sdi
      set  download_date_1 = sysdate
    WHERE sdi.org_lvl_child in (select org.org_lvl_child from wms_tipo_integracion_org org where org.id_tipo = v_tipo_update)
      and sdi.tran_type != 'A'
      and sdi.download_date_1 is null
      and sdi.pmg_stat_code = v_est_oc_onorder


    UPDATE (
            SELECT sdi.download_date_1 as download_date_1, SYSDATE now
            FROM sdipmghde sdi
                     INNER JOIN HP_OC_AMPLIACION HOA ON HOA.PMG_PO_NUMBER = SDI.PMG_PO_NUMBER
                     INNER JOIN WMS_PURCHASEORDER_ENVIO WMS ON HOA.PMG_PO_NUMBER = SDI.PMG_PO_NUMBER AND wms.audit_number = sdi.audit_number
            WHERE sdi.org_lvl_child IN
                  (select org.org_lvl_child from wms_tipo_integracion_org org where org.id_tipo = 16) --v_tipo_update
              AND sdi.tran_type != 'A'
              AND sdi.pmg_stat_code = 4                                                               -- v_est_oc_onorder
              AND sdi.download_date_1 IS NULL
              AND WMS.ID_TIPO = 16 --v_tipo_update
              AND HOA.FEC_WMS_ENVIO IS NULL
    ) UNIDAS SET UNIDAS.download_date_1 = UNIDAS.now;

    SELECT * FROM WMS_PURCHASEORDER_ENVIO WHERE FEC_PROCESADO >= SYSDATE -1 ;
    SELECT * FROM WMS_PURCHASEORDER_ENVIO WHERE ID_TIPO = 16;

    BEGIN
        EDSR.PKG_WMS_PURCHASE_ORDER.sp_procesar_actualizacion;
    END;


    UPDATE SDIpmgHDE SDI
    SET SDI.download_date_1 = SYSDATE
    WHERE EXISTS (
                    SELECT 1
                    FROM  HP_OC_AMPLIACION HOA
                        INNER JOIN  WMS_PURCHASEORDER_ENVIO WMS ON HOA.PMG_PO_NUMBER = SDI.PMG_PO_NUMBER AND wms.audit_number = SDI.audit_number
                    WHERE HOA.PMG_PO_NUMBER = SDI.PMG_PO_NUMBER
                      AND SDI.org_lvl_child IN (SELECT ORG.org_lvl_child FROM wms_tipo_integracion_org ORG WHERE ORG.id_tipo = v_tipo_update) --16
                      AND SDI.tran_type != 'A'
                      AND SDI.pmg_stat_code = v_est_oc_onorder -- 4
                      AND SDI.download_date_1 IS NULL
                      AND WMS.ID_TIPO = v_tipo_update --16
                      AND HOA.FEC_WMS_ENVIO IS NULL
                 );

     select * from wms_purchaseorder_envio wms
     where wms.pmg_po_number IN (1010,101032,101033)

    COMMIT;
END;

-- sp_sel_actualizacion
PROCEDURE sp_sel_actualizacion(
    ordenes        OUT T_CURSOR
  )
IS
BEGIN
    OPEN ordenes FOR
      SELECT  wms.pmg_po_number,
              wms.audit_number
      FROM wms_purchaseorder_envio wms
      WHERE wms.id_tipo       = 16 --v_tipo_update
        AND wms.fec_procesado IS NULL;
END;

-- sp_get_actualizacion
  PROCEDURE sp_get_actualizacion(
    p_pmg_po_number       number,
    p_audit_number        number,
    cabecera              out t_cursor,
    detalle               out t_cursor
  )
  IS
    v_company_cod         varchar2(4);
    v_flag_item           char(1);
  BEGIN

    v_company_cod := PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('COD_EMPR');
    v_flag_item   := PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('FLG_ITEM');

    /*
     SELECT PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('COD_EMPR') AS v_company_cod FROM DUAL;
     SELECT PKG_WMS_GENERAL.FN_OBTENER_VALOR_PARAM('FLG_ITEM') AS v_flag_item FROM DUAL;
     */

    OPEN cabecera FOR
      SELECT /*po_nbr*/
             sdi.pmg_po_number as po_nbr,
             /*facility_code*/
             sdi.org_lvl_number as facility_code,
             /*company_code*/
             'HESA' as company_code, -- v_company_cod
             /*vendor_code*/
             trim(sdi.vendor_number) as vendor_code,
             /*action_code*/
             'UPDATE' as action_code,
             /*ord_date*/
             to_char(sdi.pmg_release_date, 'yyyy-mm-dd') as ord_date,
             /*ref_nbr*/
             sdi.dmt_code as ref_nbr,
             /*po_type*/
             sdi.pmg_type_code as po_type,
             /*delivery_date*/
             to_char(sdi.pmg_exp_rct_date, 'yyyy-mm-dd') as delivery_date,
             /*dept_code*/
             (
              select decode('T','F',prd.cod_dpto,prd.cod_area) -- v_flag_item
              FROM sdipmgdte dtl
                inner join tpprdmst prd on dtl.prd_lvl_child = prd.prd_lvl_child
              where dtl.pmg_po_number = sdi.pmg_po_number
                and ROWNUM = 1
             ) as dept_code,
             /*ship_date*/
             to_char(sdi.pmg_exp_rct_date, 'yyyy-mm-dd') as ship_date,
             /*cancel_date*/
             --to_char(sdi.pmg_cncl_by_date, 'yyyy-mm-dd') as cancel_date,
             (SELECT FECHA_NUEVO FROM edsr.HP_OC_AMPLIACION hoa WHERE PMG_PO_NUMBER = 101031 ORDER BY FECHA_CARGA DESC FETCH FIRST 1 ROW ONLY) AS cancel_date, -- p_pmg_po_number
             /*cust_field_1*/
             pkg_wms_general.fn_omitir_caracteres(trim(sdi.pmg_lc_number)) as cust_field_1,
             /*cust_field_2*/
             null as cust_field_2,
             /*cust_field_3*/
             null as cust_field_3,
             /*cust_field_4*/
             null as cust_field_4,
             /*cust_field_5*/
             null as cust_field_5
      FROM wms_purchaseorder_envio wms
        INNER JOIN sdipmghde sdi ON sdi.pmg_po_number = wms.pmg_po_number
          AND sdi.audit_number = wms.audit_number
      WHERE wms.pmg_po_number = 101031 -- p_pmg_po_number
        AND wms.audit_number = 4544537071; -- p_audit_number;

    OPEN detalle FOR
      SELECT DISTINCT
             /*seq_nbr*/
             rownum as seq_nbr,
             /*action_code*/
             'UPDATE' as action_code,
             /*item_alternate_code*/
             trim(det.prd_lvl_number) as item_alternate_code,
             /*item_part_a*/
             trim(det.prd_lvl_number) as item_part_a,
             /*item_part_b*/
             null as item_part_b,
             /*item_part_c*/
             null as item_part_c,
             /*item_part_d*/
             null as item_part_d,
             /*item_part_e*/
             null as item_part_e,
             /*item_part_f*/
             null as item_part_f,
             /*pre_pack_code*/
             null as pre_pack_code,
             /*pre_pack_ratio*/
             null as pre_pack_ratio,
             /*pre_pack_total_units*/
             '0' as pre_pack_total_units,
             /*ord_qty*/
             det.pmg_sell_qty as ord_qty,
             /*unit_cost*/
             '1' as unit_cost,
             /*vendor_item_code*/
             null as vendor_item_code,
             /*internal_misc_n1*/
             null as internal_misc_n1,
             /*internal_misc_a1*/
             null as internal_misc_a1,
             /*unit_retail*/
             det.pmg_sell_qty as unit_retail,
             /*cust_field_1*/
             null as cust_field_1,
             /*cust_field_2*/
             null as cust_field_2,
             /*cust_field_3*/
             null as cust_field_3,
             /*cust_field_4*/
             null as cust_field_4,
             /*cust_field_5*/
             null as cust_field_5,
             /*pre_pack_ratio_seq*/
             null as pre_pack_ratio_seq
      FROM wms_purchaseorder_envio wms
        INNER JOIN sdipmghde sdi ON sdi.pmg_po_number = wms.pmg_po_number
          AND sdi.audit_number = wms.audit_number
        INNER JOIN sdipmgdte det ON det.pmg_po_number = sdi.pmg_po_number
          -- AND det.tran_type = sdi.tran_type
          AND det.tran_type = 'A'
          AND det.org_lvl_child = sdi.org_lvl_child
      WHERE wms.pmg_po_number = 101031 -- p_pmg_po_number
        AND wms.audit_number = 4544537071 -- p_audit_number
        AND wms.ID_TIPO = 16 -- v_tipo_update
        AND SDI.TRAN_TYPE = 'C';
  END;

SELECT DISTINCT rownum as seq_nbr,
             /*action_code*/
             'UPDATE' as action_code,
             sdi.pmg_po_number,
             sdi.audit_number,
             SDI.TRAN_TYPE AS SDI_type,
             det.tran_type AS DES_type,
             /*item_alternate_code*/
             trim(det.prd_lvl_number) as item_alternate_code,
             /*item_part_a*/
             trim(det.prd_lvl_number) as item_part_a FROM wms_purchaseorder_envio wms
    INNER JOIN sdipmghde sdi ON sdi.pmg_po_number = wms.pmg_po_number AND sdi.audit_number = wms.audit_number AND SDI.TRAN_TYPE != 'A'
    INNER JOIN sdipmgdte det ON det.pmg_po_number = WMS.pmg_po_number
          -- AND det.tran_type = sdi.tran_type
          AND det.tran_type = 'A'
          AND det.org_lvl_child = sdi.org_lvl_child
WHERE WMS.PMG_PO_NUMBER IN (101031) AND WMS.ID_TIPO = 16 AND SDI.TRAN_TYPE = 'C';

SELECT wms.audit_number,WMS.* FROM wms_purchaseorder_envio WMS WHERE PMG_PO_NUMBER IN (101047,101048,101049,101050);
SELECT SDI.AUDIT_NUMBER,SDI.DATE_CREATED, SDI.DOWNLOAD_DATE_1,SDI.TRAN_TYPE, SDI.PMG_CNCL_BY_DATE, SDI.* FROM sdipmghde SDI WHERE PMG_PO_NUMBER IN (101050) ORDER BY SDI.AUDIT_NUMBER DESC;
SELECT * FROM sdipmghde SDI WHERE PMG_PO_NUMBER IN (101050) ORDER BY AUDIT_NUMBER DESC;
SELECT * FROM sdipmghde WHERE SDIPMGHDE.AUDIT_NUMBER IN (4544537160);
SELECT * FROM sdipmgdte WHERE PMG_PO_NUMBER IN (101050);

DECLARE
    T_CURSOR SYS_REFCURSOR;
BEGIN
EDSR.PKG_WMS_PURCHASE_ORDER.SP_SEL_ACTUALIZACION(T_CURSOR);
-- SELECT * FROM T_CURSOR;
END;

 SELECT PMG_PO_NUMBER, COUNT(PMG_PO_NUMBER) FROM wms_purchaseorder_envio WHERE ID_TIPO = 16 GROUP BY PMG_PO_NUMBER;



