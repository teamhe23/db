/*****************************************************************
  PROVEEDOR SAINT GOBAIN ABRASIVOS Y ADHESIVOS ECUAD
 *****************************************************************/
SELECT * FROM EDSR.PMGHDREE WHERE PMG_PO_NUMBER = 109919;
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR IN ('NAC000909980');
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MESSAGE_ID IN ('12414004637286809'); --ORA-01013: user requested cancel of current operation (FEC_PROCESO => 2024-09-27 20:07:00)

-- B2B Logistico
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (114689) AND impuesto_fin = '0';

--B2B Financiero
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (114689,114731,114691) AND impuesto_fin != '0';

select * from edsr.B2B_OC_RCV_ENVIO RCV
--UPDATE EDSR.B2B_OC_RCV_ENVIO WMS SET FEC_PROC_FIN = NULL
WHERE pmg_po_number IN (114689,114731,114691) AND impuesto_fin != '0';
COMMIT;