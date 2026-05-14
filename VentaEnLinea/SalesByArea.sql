SELECT * FROM ctx_productos_trx;

select * from ctx_header_trx;

SELECT * FROM ctx_header_trx
WHERE hed_anulado = 'N' 
AND hed_tipodoc in ('TFC', 'NCR') 
AND hed_fechatrx >= '20250310'
AND hed_fechatrx < '20250311';


SELECT * FROM {_dataSettings.UserPackage}.{TABLE_NAME} 
WHERE GOAL_DATE >= :initial_date 
	AND GOAL_DATE < :end_date