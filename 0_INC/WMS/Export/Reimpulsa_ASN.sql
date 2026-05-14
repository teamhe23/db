SELECT * FROM EDSR.wms_asn_hdr_envio
--UPDATE EDSR.wms_asn_hdr_envio SET fec_procesado = NULL
WHERE SHIPMENT_NBR IN ('NAC000925108');
COMMIT;