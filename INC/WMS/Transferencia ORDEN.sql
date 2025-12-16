
SELECT hdr.TRF_NUMBER,FLG_ERROR, ID_TIPO, hdr.fec_procesado,hdr.json_response,hdr.mensaje,hdr.flg_error,hdr.text_request,hdr.*
 FROM wms_order_hdr_envio hdr
 --UPDATE WMS_ORDER_HDR_ENVIO SET FEC_PROCESADO = null
 WHERE TRF_NUMBER IN (91821);
COMMIT;

--2025-02-14 03:11:31