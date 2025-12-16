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

select P.fec_procesado, P.id_wms,P.MENSAJE, P.* from edsr.wms_purchaseorder_envio P
--actualizar para ponerlo como pendiente y vuelva a enviar la interfaz
--update edsr.wms_purchaseorder_envio set fec_procesado = null, id_wms = null
where pmg_po_number IN (122041) and ID_TIPO = 4; --4: CREATE 16: UPDATE
COMMIT;