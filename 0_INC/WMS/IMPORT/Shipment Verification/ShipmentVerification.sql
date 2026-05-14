/*
+++ Comienzo shell: wms_shipment_verification.ksh +++ 13:40:00
	14/04/2025 13:40:01. Inicio proceso recepcion OC
	14/04/2025 13:40:01. INICIO ASN:SHJ013601 hdr_group_nbr:14924
	14/04/2025 13:40:01. INICIO ASN:NAC000917746 hdr_group_nbr:14925
	14/04/2025 13:40:02. FINAL ASN:NAC000917746 hdr_group_nbr:14925
	14/04/2025 13:40:02. Inicio proceso recepcion TRF
	58743835
	14/04/2025 13:40:02. Inicio proceso recepcion carga CD a tienda
	58743836
+++ Fin shell: wms_shipment_verification.ksh +++ 13:40:02

 */

--BUSQUEDA DEL MODELO (Llega desde el WMS)
SELECT * FROM WMS_MODELO_REQUEST
--UPDATE EDSR.WMS_MODELO_REQUEST SET FLAG_PROCESADO = '0', FLAG_ERROR = '0', FEC_PROCESO= NULL
WHERE 
	--WMS_MODELO_REQUEST.IDENTIFICADOR IN ('OS85100031706') --AND ID_TIPO = 2
	ID_MODELO = 250755;
ORDER BY IDENTIFICADOR, FEC_REG
;
COMMIT;

SELECT * FROM WMS_MODELO_REQUEST WHERE ID_MODELO = 250755; --ORA-01013: user requested cancel of current operation
SELECT * FROM WMS_MODELO_REQUEST WHERE modelo LIKE '%OS85100031706%';

--Repcecion Carga

SELECT DOWNLOAD_DATE_1,ERR_CODE, substr(shipment_nbr, 1, 2), shipment_nbr ,HDR.* 
FROM WMS_RCV_ASN_HDR HDR
--UPDATE WMS_RCV_ASN_HDR SET DOWNLOAD_DATE_1 = null, ERR_CODE = null
WHERE SHIPMENT_NBR = 'OS85100029261';
COMMIT;

SELECT ERR_CODE,PO_NBR, dtl.* FROM WMS_RCV_ASN_DTL dtl WHERE HDR_GROUP_NBR = 36532;
SELECT * FROM PMGHDREE WHERE PMG_PO_NUMBER IN (120382,120139,120138);
SELECT * FROM pmgdtlee WHERE PMG_PO_NUMBER = 120382;

--Errores
select * from edsr.wms_error_int WHERE ERR_CODE IN (25,32,40) ;

select 
	--nvl(max(m.trf_manifest_sts), 0)
	trf_manifest_sts,m.*
    --into v_sts_trf
  from trfmfhee m
  where m.trf_manifest_id = 'OS85100031706';