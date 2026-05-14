/*
Contribucion = Venta Neta - Venta costo
%GM = Sum (Contribucion)/Sum (VentaNeta)
 */

select SUM(A.ptr_brutopos + A.ptr_brutoneg - COALESCE(A.ptr_impuesto,0) - COALESCE(A.ptr_impuesto_isc,0)) AS VENTA_NETA,SUM(A.PTR_COSTO * (A.PTR_UNIDADES + A.PTR_PESO)) AS COSTO_TOTAL
FROM   ct.ctx_header_trx H
INNER JOIN ct.ctx_productos_trx a on H.HED_PAIS = A.HED_PAIS
                   and H.HED_ORIGENTRX = A.HED_ORIGENTRX
                   and H.HED_LOCAL = A.HED_LOCAL
                   and H.HED_POS = A.HED_POS
                   and H.HED_NUMTRX = A.HED_NUMTRX
                   and H.HED_FECHATRX = A.HED_FECHATRX
                   and H.HED_HORATRX = A.HED_HORATRX
WHERE TO_CHAR(H.hed_fechatrx,'YYYYMMDD') BETWEEN '20250127' and '20250127'
      AND H.hed_tipotrx = 'PVT'
      and H.hed_tipodoc in ('NCR','TFC','BLT') --BLT: Transacciones diferidas
      and H.Hed_Anulado in ('N', 'D')
      and A.HED_LOCAL = 101;

select * from ctx_productos_trx limit 10;

--Margen
SELECT
    SUM(A.ptr_brutopos + A.ptr_brutoneg - COALESCE(A.ptr_impuesto, 0) - COALESCE(A.ptr_impuesto_isc, 0)) AS VENTA_NETA,
    SUM(A.PTR_COSTO * (A.PTR_UNIDADES + A.PTR_PESO)) AS COSTO_TOTAL,
    SUM(A.ptr_brutopos + A.ptr_brutoneg - COALESCE(A.ptr_impuesto, 0) - COALESCE(A.ptr_impuesto_isc, 0)) -
    SUM(A.PTR_COSTO * (A.PTR_UNIDADES + A.PTR_PESO)) AS CONTRIBUCION,
    (SUM(A.ptr_brutopos + A.ptr_brutoneg - COALESCE(A.ptr_impuesto, 0) - COALESCE(A.ptr_impuesto_isc, 0)) -
    SUM(A.PTR_COSTO * (A.PTR_UNIDADES + A.PTR_PESO))) /
    NULLIF(SUM(A.ptr_brutopos + A.ptr_brutoneg - COALESCE(A.ptr_impuesto, 0) - COALESCE(A.ptr_impuesto_isc, 0)), 0) AS MARGEN
FROM
    ct.ctx_header_trx H
INNER JOIN
    ct.ctx_productos_trx A
    ON H.HED_PAIS = A.HED_PAIS
    AND H.HED_ORIGENTRX = A.HED_ORIGENTRX
    AND H.HED_LOCAL = A.HED_LOCAL
    AND H.HED_POS = A.HED_POS
    AND H.HED_NUMTRX = A.HED_NUMTRX
    AND H.HED_FECHATRX = A.HED_FECHATRX
    AND H.HED_HORATRX = A.HED_HORATRX
WHERE
    TO_CHAR(H.hed_fechatrx, 'YYYYMMDD') BETWEEN '20250219' AND '20250219'
    AND H.hed_tipotrx = 'PVT'
    AND H.hed_tipodoc IN ('NCR', 'TFC', 'BLT')  -- BLT: Transacciones diferidas
    AND H.Hed_Anulado IN ('N', 'D')
    AND A.HED_LOCAL = 101;

--20250203 => 0.20376034158010725 = 20.4 != 20.6
--20250204 => 0.2514048873388689 = 25.1 != 25.4
--20250212 => 0.22683438671396905 = 22.7 != 22.8
--20250217 => 0.26197429245920945 = 26.2 != 26.7
