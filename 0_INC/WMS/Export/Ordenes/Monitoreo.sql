SELECT id_wms,hdr.TRF_NUMBER,FLG_ERROR, ID_TIPO, hdr.fec_procesado
		,hdr.json_response,hdr.mensaje,hdr.flg_error,hdr.text_request
		,hdr.*
FROM EDSR.wms_order_hdr_envio hdr
 --UPDATE EDSR.WMS_ORDER_HDR_ENVIO SET FEC_PROCESADO = null
WHERE TRF_NUMBER IN (217230);
COMMIT;

