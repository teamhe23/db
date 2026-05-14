/*
 * Este reporte te mostrara todos los movimientos de Inventario
 * Puedes filtrar por sucursal, transferencia(Numero de Referencia), SKU, Movimiento (TRF Recepcionadas), Cantidad, etc
 * Este reporte sirve para verificar si hubo recepcion de una CARGA  (EJM: OS85100015322) 
 * La carga contiene varias transferencias (EJM: 121760) en donde indica los movimientos (EJM: TRF Recepcionadas) que hubieron por cada SKU (EJM: Cantidad que se recepciono)
 * Este reporte cuadrarlo por el reporte EstadoTRF de Transferencias (Path: WMS/Import/Transferencias)
 * En ese reporte de Estado de Transferencias indicara las cantidades que se movieron de un SKU, entonces los mismos que se ven ahí deberían figurar en este reporte
 */
SELECT 
	V.AUDIT_NUMBER "Auditoria",
	V.TRANS_SESSION "Sesión",
	O.ORG_LVL_NUMBER "Sucursal",
	V.TRANS_REF "Número Referencia",
	P.PRD_LVL_NUMBER "Sku",
	D.INV_DRPT_DESC "Movimiento",
	V.TRANS_QTY "Cantidad",
	TRUNC(V.POSTED_DATE_TIME) "Fecha Proceso",
	V.TRANS_DATE "Fecha Transaccion",
	P.DES_AREA "Area",
	P.DES_LIN "Línea",	
	V.TRANS_REF2 "Número Referencia 2",
	V.INV_MRPT_CODE "Maestro Reporte",
	V.INV_DRPT_CODE "Detalle Reporte",
	V.INV_EFF_QTY "Efecto Inventario",
	V.INV_EFF_CST "Efecto Costo",
	P.PRD_FULL_NAME "Descripción",
	V.TRANS_COST "Costo",
	V.TRANS_RETL "Precio",
	V.TRANS_EXT_COST "Costo Ext",
	V.TRANS_EXT_RETL "Precio Ext",
	H.TRANS_USER "Usuario",
	V.PROC_SOURCE "Proceso"FROM EDSR.INVAUDEE V 
INNER JOIN EDSR.ORGMSTEE O
ON V.TRANS_ORG_CHILD = O.ORG_LVL_CHILD
INNER JOIN EDSR.TPPRDMST P
ON V.TRANS_PRD_CHILD = P.PRD_LVL_CHILD 
INNER JOIN EDSR.INVAHREE H
ON V.TRANS_SESSION = H.TRANS_SESSION
INNER JOIN EDSR.INVTRDEE D
ON V.INV_MRPT_CODE = D.INV_MRPT_CODE
AND V.INV_DRPT_CODE = D.INV_DRPT_CODE
WHERE 
	O.ORG_LVL_NUMBER = '102' 
 	AND V.TRANS_REF = '121760'
 	AND P.PRD_LVL_NUMBER = '10537'
 	AND D.INV_DRPT_DESC = 'TRF Recepcionadas'
ORDER BY V.POSTED_DATE_TIME ASC
;
