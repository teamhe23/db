--ERRORES EN LA CREACION DE PRODUCTOS
/*
 
ORA-00018: maximum number of sessions exceeded

The SSL connection could not be established, see inner exception.

An error occurred while sending the request.

<html>
	<head>
		<title>504 Gateway Time-out</title>
	</head>
	<body>
		<center><h1>504 Gateway Time-out</h1></center>
		<hr><center>nginx</center>
	</body>
</html>

{"success":false,"response":{"message":"User inactive or deleted."}}

<html>
	<head>
		<title>502 Bad Gateway</title>
	</head>
	<body>
		<center><h1>502 Bad Gateway</h1></center>
		<hr><center>nginx</center>
	</body>
</html>

The request was canceled due to the configured HttpClient.Timeout of 300 seconds elapsing.
ORA-28547: connection to server failed, probable Oracle Net admin error
{"success":false,"response":{"message":"Error loading stage data. "}}
{"success":false,"response":{"message":"Invalid username/password."}}
 */

--SELECT * FROM EDSR.WMS_ITEM_ENVIO WHERE  

SELECT * FROM EDSR.PRDMSTEE WHERE PRD_LVL_NUMBER = '40397';
SELECT * FROM EDSR.PRDMSTEE WHERE PRD_LVL_CHILD = 130515;

SELECT  DISTINCT MENSAJE FROM EDSR.WMS_ITEM_ENVIO WHERE FLG_ERROR = '1';

SELECT * FROM EDSR.WMS_ITEM_ENVIO 
WHERE TRAN_TYPE = 'C'
	AND PRD_LVL_CHILD IN (	SELECT PRD_LVL_CHILD
							FROM EDSR.WMS_ITEM_ENVIO 
							WHERE FEC_PROCESADO IS NOT NULL
							AND FLG_ERROR = '1'
							AND MENSAJE = '{"success":false,"response":{"message":"Error loading stage data. "}}'
							AND TRAN_TYPE = 'A'
							AND prd_lvl_child IN (SELECT DISTINCT prd_lvl_child FROM EDSR.WMS_ITEM_ENVIO WHERE TRAN_TYPE = 'C')
						)
ORDER BY FEC_REG DESC
;

SELECT 
	--*
	 PRD_LVL_CHILD
FROM EDSR.WMS_ITEM_ENVIO 
WHERE FEC_PROCESADO IS NOT NULL
AND FLG_ERROR = '1'
AND MENSAJE = '{"success":false,"response":{"message":"Error loading stage data. "}}'
AND TRAN_TYPE = 'A'
AND prd_lvl_child IN (SELECT DISTINCT prd_lvl_child FROM EDSR.WMS_ITEM_ENVIO WHERE TRAN_TYPE = 'C')
ORDER BY FEC_PROCESADO DESC
--FETCH FIRST 20 ROWS ONLY
;

SELECT PRD.PRD_LVL_NUMBER ,ITEM.MENSAJE, ITEM.TEXT_RESQUEST,ITEM.TRAN_TYPE , ITEM.* FROM EDSR.WMS_ITEM_ENVIO ITEM INNER JOIN TPPRDMST PRD ON PRD.PRD_LVL_CHILD = ITEM.PRD_LVL_CHILD
WHERE  PRD.PRD_LVL_NUMBER = 41589;

---------------------------------------
--Listar errores (A:CREATE, C:UPDATE)
---------------------------------------
-- No se encontró item 7861149643878
-- LOS ERRORES A IDENTIFICAR SON LOS QUE NO SE CREAN EN EL WMS tienen TRAN_TYPE = A y MENSAJE = Error loading stage data
SELECT  PRD.PRD_LVL_NUMBER ,item.PRD_LVL_CHILD, ITEM.FEC_PROCESADO, ITEM.MENSAJE, ITEM.TRAN_TYPE FROM EDSR.WMS_ITEM_ENVIO ITEM
	INNER JOIN TPPRDMST PRD ON PRD.PRD_LVL_CHILD = ITEM.PRD_LVL_CHILD
WHERE ITEM.TRAN_TYPE = 'A' AND ITEM.MENSAJE =  '{"success":false,"response":{"message":"Error loading stage data. "}}'
ORDER BY ITEM.FEC_PROCESADO DESC
;

