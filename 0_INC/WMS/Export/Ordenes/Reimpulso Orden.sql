--153938662 = 153954714 
SELECT id_wms,hdr.TRF_NUMBER,FLG_ERROR, ID_TIPO, hdr.fec_procesado,hdr.json_response,hdr.mensaje,hdr.flg_error,hdr.text_request,hdr.*
FROM EDSR.wms_order_hdr_envio hdr
 --UPDATE EDSR.WMS_ORDER_HDR_ENVIO SET FEC_PROCESADO = null
WHERE TRF_NUMBER IN (257914);
COMMIT;

SELECT id_wms,hdr.TRF_NUMBER,FLG_ERROR, ID_TIPO
	, hdr.fec_procesado,hdr.flg_error, HDR.*
FROM EDSR.wms_order_hdr_envio hdr
WHERE	
	id_wms IS null AND hdr.TRF_NUMBER  IS NOT NULL
	AND FLG_ERROR = '1'
ORDER BY hdr.FEC_PROCESADO DESC;

SELECT DISTINCT ID_TIPO FROM EDSR.wms_order_hdr_envio;
/*
 * 
 * TRF: 162738 | procesado: 2025-06-02 03:05:11.000
 {"success":true,"response":{"message":"Process stage order submitted for file group RESTAPI_hesa_sistemas_order_20250602030440935"}}
 
 Reenviar: 03-06-2025 13:12
 Process stage order submitted for file group RESTAPI_hesa_sistemas_order_20250603131203983
 */


SELECT TRF_NUMBER
	--,  bb.* 
FROM wms_order_hdr_envio bb 
WHERE TRF_NUMBER >=159000  AND TRF_NUMBER <=159050
ORDER BY TRF_NUMBER DESC FETCH FIRST 500 ROWS ONLY;

--2025-02-17 10:31:43.000
/*
2025-05-01 15:36:56.000
2025-05-01 03:05:32.000
2025-05-05 03:07:42.000
 */

SELECT * FROM B2BACKEE2 bb ORDER BY B2B_DOWNLOAD_DATE DESC;