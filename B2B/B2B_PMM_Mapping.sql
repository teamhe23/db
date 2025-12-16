SELECT * FROM DAD_AJUSTE_INV ORDER BY FECHA_REGISTRO DESC;
SELECT * FROM DAD_AJUSTE_INV WHERE SKU_CODE = 28542;
SELECT DAD_INV.FECHA_REGISTRO, DAD_INV.* FROM DAD_AJUSTE_INV DAD_INV
WHERE DAD_INV.SKU_CODE = 26016
ORDER BY DAD_INV.FECHA_REGISTRO DESC;

--Nombre de los archivos
SELECT b.tpe_name_arch, b.*
FROM tpeparep b
WHERE b.tpe_app_name IN
('TP_B2B_PRD','TP_B2B_PRV','TP_B2B_PPV','TP_B2B_JPR','TP_B2B_LOC','TP_B2B_JLO','TP_B2B_INV','TP_B2B_VTA');

-- B2B LOGISTICO
--******************************************
--      B2B --> PMM  [IMPORT]
--******************************************
--  /prochp/interfaces/b2b/import/ksh/
--******************************************
-- CRONTAB (Tarea en AIX(variante UNIX))

-- Generación ASN (hp_b2b_asn.ksh)
SELECT * FROM EDSR.WMS_ASN_HDR_ENVIO;
SELECT * FROM EDSR.WMS_ASN_DTL_ENVIO;

-- Generación CITAS (hp_b2b_cita.ksh)
SELECT * FROM EDSR.WMS_CITA_ENVIO;

--******************************************
--      PMM --> B2B  [EXPORT]
--******************************************
--  /prochp/interfaces/b2b/export/ksh/
--******************************************
-- CRONTAB (Tarea en AIX(variante UNIX))

-- Ordenes de Compra       (tp_b2b_xml_oc.ksh)
-- Cancelacion Vencidos    (tp_b2b_xml_oc_cancel.ksh)
-- Recepcion Retail        (tp_b2b_xml_oc_recep_log.ksh)
    BEGIN
        TP_PKG_ARCHIVOS_B2B.sp_genera_archivo_xml_oc_recep_log;
        /*
            B2B_OC_RCV_ENVIO

        */
    END;

-- MALLA (PACKAGE: TP_PKG_ARCHIVOS_B2B)
--        Proceso                     KSH            TP_PKG_ARCHIVOS_B2B
----------------------------------------------------------------------------
-- Maestro de PROVEEDORES       (tp_b2b_prv.ksh)    SP_GENERA_ARCHIVO_PRV
-- Maestro de PRODUCTOS         (tp_b2b_prd.ksh)    SP_GENERA_ARCHIVO_PRD
-- Maestro JERARQUÍA PRODUCTOS  (tp_b2b_jpr.ksh)    SP_GENERA_ARCHIVO_JPR
-- Maestro PRODUCTO PROVEEDOR   (tp_b2b_ppv.ksh)    SP_GENERA_ARCHIVO_PPV
-- Maestro LOCALES              (tp_b2b_loc.ksh)    SP_GENERA_ARCHIVO_LOC
    SELECT CALDAT FROM CALDAYEE;
    SELECT * FROM TPTMPPRD;
SELECT '"' || RTRIM(RPAD(REPLACE(ORG.ORG_LVL_NUMBER, '"', '""'), 5)) || '",' || '"' ||
             RTRIM(RPAD(REPLACE(ORG.ORG_NAME_FULL, '"', '""'), 30)) || '",' || '"' ||
             RTRIM(RPAD(REPLACE(BAS.BAS_ADDR_1, '"', '""'), 30)) || '",' || '"' ||
             RTRIM(RPAD(REPLACE(BAS.BAS_STATE, '"', '""'), 20)) || '",' || '"' ||
             RTRIM(RPAD(DECODE(ORG.ORG_IS_STORE, 'T', 'L', 'B'), 1)) || '",' || '"' ||
             RTRIM(RPAD(REPLACE(
                                (SELECT ORG_LVL_NUMBER
                                  FROM ORGMSTEE
                                 WHERE ORG_LVL_CHILD = ORG.ORG_LVL_PARENT),
                                '"',
                                '""'),
                        20)) || '",' || ROWNUM || ',' || 1 AS REGISTRO
        FROM ORGMSTEE ORG,
             ORGMSTEE B,
             ORGDTLEE DTL,
             BASADREE BAS,
             IFH_SUC_FECAP FA
       WHERE ORG.ORG_LVL_PARENT = B.ORG_LVL_CHILD(+)
         AND ORG.ORG_LVL_ID = 1
         AND ORG.ORG_LVL_CHILD = DTL.ORG_LVL_CHILD(+)
         AND DTL.BAS_ADD_KEY = BAS.BAS_ADD_KEY(+)
         AND ORG.ORG_LVL_CHILD = FA.ORG_LVL_CHILD(+)
         AND (FA.FEC_APE <= TRUNC('2024-10-23') OR ORG.ORG_IS_STORE = 'F')
       START WITH ORG.ORG_LVL_CHILD =
                  (SELECT PARAM_VALUE
                     FROM CHLPARAM
                    WHERE PARAM_CODE = 'SUCTDA')
      CONNECT BY PRIOR ORG.ORG_LVL_CHILD = ORG.ORG_LVL_PARENT;

SELECT * FROM CHLPARAM WHERE PARAM_CODE = 'SUCTDA';
SELECT * FROM ORGMSTEE  ;
SELECT * FROM ORGMSTEE WHERE ORG_NAME_FULL LIKE '%GRANADOS%' ;
SELECT * FROM ORGMSTEE WHERE ORG_NAME_FULL LIKE '%GUAYAQUIL%' ;
SELECT * FROM ORGMSTEE WHERE ORG_NAME_FULL LIKE '%ORELLANA%' ;
SELECT * FROM ORGDTLEE ;
SELECT * FROM BASADREE ;
SELECT * FROM IFH_SUC_FECAP;
SELECT PARAM_VALUE FROM CHLPARAM WHERE PARAM_CODE = 'SUCTDA';

-- JERARQUÍA de LOCALES         (tp_b2b_jlo.ksh)    SP_GENERA_ARCHIVO_JLO
-- VENTA DIARIA                 (tp_b2b_vta.ksh)    SP_GENERA_ARCHIVO_VTA
-- INVENTARIO DIARIO            (tp_b2b_inv.ksh)    SP_GENERA_ARCHIVO_INV



-- B2B FINANCIERO
--******************************************
--      B2B --> PMM  [IMPORT]
--******************************************
--  /prochp/interfaces/b2b/import/ksh/
--******************************************

--******************************************
--      PMM --> B2B  [EXPORT]
--******************************************
--  /prochp/interfaces/b2b/export/ksh/
--******************************************

-- MALLA (PACKAGE: TP_PKG_ARCHIVOS_B2B)
--        Proceso                     KSH                       TP_PKG_ARCHIVOS_B2B
----------------------------------------------------------------------------
-- RECEPCION RETAIL        (tp_b2b_xml_oc_recep_fin.ksh)        sp_genera_archivo_xml_recep_fin
-- DEVOLUCIONES RETAIL    (tp_b2b_rtv_fin.ksh)                 sp_genera_archivo_xml_rtv