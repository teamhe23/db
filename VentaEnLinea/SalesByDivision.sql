--1929
select
/*
hed_fechatrx,
DATE(hed_fechatrx),
ptr_codinterno,
ptr_total as grossSales,
ptr_impuesto,--grossSales (Venta Bruta)
ptr_total - ptr_impuesto as netSales, -- details.Sum(x => Math.Round(x.ptr_total - x.ptr_impuesto, 2)); (Venta Neta)
*
*/
count(*)
FROM ctx_productos_trx
WHERE ptr_tipodoc in ('TFC', 'NCR')
	AND hed_local = '101'
	and date(hed_fechatrx) = date('2025-03-11');
/*
	and hed_fechatrx >= '20250311'
	AND hed_fechatrx < '20250312'
    */
    --AND ptr_codinterno IN ('38616')
;

SELECT NOW();
SELECT date_trunc('day', '2025-03-13 14:25:37'::timestamp);
SELECT date_trunc('hour', '2025-03-13 14:25:37'::timestamp);
SELECT date_trunc('month', '2025-03-13 14:25:37'::timestamp);

SELECT DATE('2025-03-13 14:25:37');

SELECT DATE(NOW()), date('2025-03-13');


SELECT date_trunc('day', tu_columna_fecha)
FROM tu_tabla;

SELECT CURRENT_TIMESTAMP;
SELECT CURRENT_DATE;