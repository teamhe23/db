select * from wms_purchaseorder_envio order by PMG_PO_NUMBER desc fetch first 20 rows only;
select * from wms_purchaseorder_envio WHERE FEC_PROCESADO >= TO_DATE('2025-02-13' , 'YYYY-MM-DD');
-- Listar para CREAR OC
select  wms.pmg_po_number,wms.audit_number, wms.id_tipo,wms.fec_procesado,wms.* from wms_purchaseorder_envio wms
--UPDATE wms_purchaseorder_envio wms SET wms.fec_procesado = null
where wms.id_tipo = 4
    --and wms.fec_procesado is null
    AND wms.PMG_PO_NUMBER in (122041)
;
/*
 TP_PKG_TURBO_ENTRY.SP_P_ADD_TPIMPOCC
 TP_PKG_TURBO_ENTRY.SP_P_ADD_TPIMPOCD
 TP_PKG_ARCHIVOS_BBR.sp_inserta_sol_oc
 TP_PKG_TURBO_ENTRY.SP_P_CONSULTAOC_GET
 */
SELECT IMP.FEC_CRE,IMP.PMG_PO_NUMBER
     ,IMP.* FROM tpimpocc IMP
WHERE IMP.FEC_CRE IS NOT NULL
ORDER BY IMP.FEC_CRE DESC FETCH FIRST 30 ROWS ONLY ;

SELECT IMP.FEC_CRE,IMP.PMG_PO_NUMBER, IMP.download_date, imp.SISTEMA, IMP.ID_PUERTO
     ,IMP.* FROM tpimpocc IMP WHERE PMG_PO_NUMBER IN (101571);

--101934
select oc.PMG_EFFECT_DATE, oc.* from edsr.pmghdree oc order by oc.PMG_EFFECT_DATE DESC;
SELECT SDI.DATE_CREATED, DOWNLOAD_DATE_1, DOWNLOAD_DATE, SDI.* FROM sdipmghde SDI ORDER BY SDI.DATE_CREATED DESC FETCH FIRST 100 ROWS ONLY;

SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%SDIPMGHDE%';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%DATAMAN123%';

SELECT DISTINCT DATE_CREATED FROM SDIPMGHDE WHERE PMG_PO_NUMBER IN (101479,101549);
SELECT * FROM sdipmghde WHERE PMG_PO_NUMBER IN (101479,101549);
SELECT * FROM SDIPMGHDE WHERE PMG_PO_NUMBER IN (101571);
SELECT * FROM SDIPMGHDE WHERE PMG_PO_NUMBER IN (101575);
SELECT * FROM PMGHDREE WHERE PMG_PO_NUMBER IN (101571);
SELECT * FROM PMGDTLEE WHERE PMG_PO_NUMBER IN (101571);
SELECT * FROM PMGOCTIPO;
BEGIN

END;

BEGIN
   -- TP_PKG_ARCHIVOS_BBR.sp_inserta_sol_oc('TOC');

     --Este es el que finalmente dispara la OC en SDIPMGHDE
    EPMM.dnlsdipmghdr('T');
   COMMIT;
end;

SELECT * FROM TPPRDMST WHERE PRD_LVL_NUMBER = '';

BEGIN
    dataman123('PMG','HDR','SDI');
    dataman123('PMG','DTL','SDI');
    dataman123('PMG','ALL','SDI');
    COMMIT;
END;

select app_name, app_post_process
from   EPMM.appmstee
where app_name;