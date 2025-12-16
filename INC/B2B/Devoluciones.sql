select fec_procesado, RTV.* from B2B_RTV_ENVIO RTV
-- UPDATE B2B_RTV_ENVIO SET fec_procesado = null
where RTV_NUMBER IN ('10274','10253');
COMMIT;