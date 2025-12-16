--Reimpulsos de creacion de  ASN
--112152
SELECT LTRIM(asn.SHIPMENT_NBR, 'NAC000') AS NroCarga,
       asn.SHIPMENT_NBR,asn.FLG_ERROR, asn.JSON_RESPONSE,ASN.fec_procesado, ASN.*
FROM wms_asn_hdr_envio asn
--UPDATE EDSR.wms_asn_hdr_envio SET fec_procesado = NULL
WHERE asn.SHIPMENT_NBR LIKE ('%913350%') -- AND FLG_ERROR = '1';
    --AND FLG_ERROR = 1

