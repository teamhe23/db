WITH U AS (
                SELECT e.org_lvl_number   AS sucursal,
                       e.prd_lvl_number   AS sku,
                       h.prf_wgt_weeks    AS semanas,
                       e.rpl_min_stk      AS min,
                       e.rpl_max_stk      AS max
                FROM   EPMM.rplpmhee e,
                       EDSR.tpprdmst f,
                       EPMM.whsprdee g,
                       (SELECT DISTINCT f.pmh_tech_key, f.prf_wgt_weeks
                          FROM EPMM.RPLWGTEE f) h,
                       EPMM.rplmthcd s,
                       EPMM.rpldmtcd d,
                       EPMM.RPLPFHEE pe
                WHERE  (SELECT x.caldat FROM EPMM.caldayee x)
                          BETWEEN e.rpl_begdate AND e.rpl_enddate
                  AND  e.prd_lvl_child     = f.prd_lvl_child
                  AND  e.prd_lvl_child     = g.prd_lvl_child
                  AND  g.org_lvl_child IN (
                           SELECT TO_NUMBER(TRIM(param_value))
                           FROM   EPMM.chlparam
                           WHERE  param_code IN ('CENTRODIS')
                       )
                  AND  e.rpl_method_code   = s.rpl_method_code
                  AND  e.rpl_dist_method   = d.dmt_code
                  AND  e.pmh_tech_key      = h.pmh_tech_key
                  AND  e.PRF_TECH_KEY      = pe.PRF_TECH_KEY
            )
SELECT DISTINCT
       P.ID,
       P.E_TIENDA,
       P.E_PRODUCTO,
       P.E_MIN,
       P.E_MAX,
       CASE
         WHEN U_KEY.SKU IS NULL THEN
              'No apareció'
         WHEN U_FULL.SKU IS NULL THEN
              'Los valores min y max no se cargaron correctamente'
         ELSE
              'OK'
       END AS MENSAJE
FROM   EDSR.temp_CargaMasiva_ParametrosPMM P
       LEFT JOIN U U_KEY
         ON TRIM(P.E_TIENDA)       = TRIM(U_KEY.SUCURSAL)
        AND TRIM(P.E_PRODUCTO)     = TRIM(U_KEY.SKU)
        AND TRIM(P.E_SEMANA_VENTA) = TRIM(U_KEY.SEMANAS)
       LEFT JOIN U U_FULL
         ON TRIM(P.E_TIENDA)       = TRIM(U_FULL.SUCURSAL)
        AND TRIM(P.E_PRODUCTO)     = TRIM(U_FULL.SKU)
        AND TRIM(P.E_SEMANA_VENTA) = TRIM(U_FULL.SEMANAS)
        AND TRIM(P.E_MIN)          = TRIM(U_FULL.MIN)
        AND TRIM(P.E_MAX)          = TRIM(U_FULL.MAX)
WHERE  U_FULL.SKU IS NULL