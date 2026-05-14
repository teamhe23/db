/*
CASO 117550:
<html>
<head><title>504 Gateway Time-out</title></head>
<body>
<center><h1>504 Gateway Time-out</h1></center>
<hr><center>nginx</center>
</body>
</html>

*/
SELECT * FROM edsr.wms_purchaseorder_envio
--update edsr.wms_purchaseorder_envio set fec_procesado = null, id_wms = null
WHERE FLG_ERROR = '1' AND fec_reg > To_date('2025-03-10', 'YYYY-MM-DD');

/*
 124177 y 123514
 */
select P.fec_procesado, P.id_wms, p.FLG_ERROR ,P.MENSAJE, P.* from edsr.wms_purchaseorder_envio P
--actualizar para ponerlo como pendiente y vuelva a enviar la interfaz
--update edsr.wms_purchaseorder_envio set fec_procesado = null, id_wms = null
where pmg_po_number IN (142166) and ID_TIPO = 4; --4: CREATE 16: UPDATE
COMMIT;

--The request was canceled due to the configured HttpClient.Timeout of 100 seconds elapsing.
--The request was canceled due to the configured HttpClient.Timeout of 100 seconds elapsing.

--Listado de Ordenes de Compra
--TO_NUMBER(REGEXP_SUBSTR(codigo_usuario, '[0-9]+$')) AS numero
/*
 * Es posible que una OC no tenga ASN porque el proveedor no CARGO una ASN EN B2B, el estado en el reporte de CITAS del B2B seria la columna Estado = Cita Agendada
 */
SELECT 
	--DISTINCT dtl.ERR_CODE,TO_NUMBER(REGEXP_SUBSTR(ASN.SHIPMENT_NBR, '[0-9]+$')) AS ASN, ASN.SHIPMENT_NBR,DOWNLOAD_DATE_1
	DISTINCT dtl.ERR_CODE,dtl.PO_NBR,TO_NUMBER(REGEXP_SUBSTR(ASN.SHIPMENT_NBR, '[0-9]+$')) AS numero, ASN.SHIPMENT_NBR,DOWNLOAD_DATE_1
	--dtl.ERR_CODE,dtl.PO_NBR,TO_NUMBER(REGEXP_SUBSTR(ASN.SHIPMENT_NBR, '[0-9]+$')) AS numero, ASN.SHIPMENT_NBR, dtl.* 
FROM WMS_RCV_ASN_DTL dtl
	INNER JOIN WMS_RCV_ASN_HDR ASN ON ASN.HDR_GROUP_NBR = DTL.HDR_GROUP_NBR
WHERE PO_NBR IN (126632,126824,126458,126818,126537,126451,126662,126464,126522,126822);

SELECT ERR_CODE,PO_NBR, dtl.* FROM WMS_RCV_ASN_DTL dtl WHERE PO_NBR LIKE '126%'; -- 126766
