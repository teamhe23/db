/*
 * 2026-03-04: 
 * 16:35: Se finalizo la evaluación de las tablas para analizar cual es la query de validación para la carga del MinMax
 */
SELECT * FROM EDSR.temp_CargaMasivaMinMax ORDER BY ID;
SELECT prd_lvl_number,rpl_min_stk,rpl_max_stk,
	prd_lvl_child,rpl_method_code,rpl_dist_method,pmh_tech_key,PRF_TECH_KEY,rpl_begdate,rpl_enddate
FROM EPMM.rplpmhee 
WHERE prd_lvl_child IN (133254,134603,134604,134605,134607)
;
SELECT * FROM EDSR.tpprdmst;
SELECT * FROM EPMM.whsprdee WHERE prd_lvl_child IN (133254,134603,134604,134605,134607); --Relacion (ORG_LVL_CHILD,PRD_LVL_CHILD,TRF_DIST_PAK) => (420,135815, 1)
SELECT * FROM EPMM.rplmthcd WHERE RPL_METHOD_CODE IN (1,3); --METHOD (Mín/Máx:1 | Dinámico: 3)
SELECT * FROM EPMM.rpldmtcd; --Distribución: OC predistribuida | OC Simple | Transferencia | Multi entrega | Denegado | Ninguno | OC PreDistribuida             
SELECT * FROM EPMM.RPLPFHEE; --Perfil: PERFIL 1 | PERFIL VVEE
SELECT DISTINCT f.pmh_tech_key
FROM EPMM.RPLWGTEE f
WHERE pmh_tech_key in (10389703,10389702,10389701,10389700,10389699);
SELECT prd_lvl_number,PRD_LVL_CHILD FROM tpprdmst WHERE prd_lvl_number IN (46380,46379,46381,46383,45030);

WITH U AS (
                SELECT distinct e.org_lvl_number   AS sucursal,
                       e.prd_lvl_number   AS sku,
                       e.rpl_min_stk      AS min,
                       e.rpl_max_stk      AS max
                FROM   EPMM.rplpmhee e,
                       EDSR.tpprdmst f,
                       EPMM.whsprdee g,
                       EPMM.rplmthcd s,
                       EPMM.rpldmtcd d,
                       EPMM.RPLPFHEE pe
                WHERE  (SELECT x.caldat FROM EPMM.caldayee x) --2026-03-04 00:00:00.000
                          BETWEEN e.rpl_begdate AND e.rpl_enddate       
                  AND  e.prd_lvl_child     = f.prd_lvl_child --AQUI VALIDA QUE EXISTA EL PRODUCTO EN tpprdmst
                  AND  e.prd_lvl_child     = g.prd_lvl_child --AQUI VALIDA SI EXISTE EN whsprdee
                  --Aquí  valida el codigo del CD: 420
                  AND  g.org_lvl_child IN (SELECT TO_NUMBER(TRIM(param_value)) FROM EPMM.chlparam WHERE  param_code IN ('CENTRODIS'))
                  -- Valida el Metodo: MinMax:1 | DYNAMIC:3
                  AND  e.rpl_method_code   = s.rpl_method_code
                  -- Valida el metodo de distribucion: "OC Simple":2
                  AND  e.rpl_dist_method   = d.dmt_code 
                  AND e.prd_lvl_child IN (133254,134603,134604,134605,134607)
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
FROM   EDSR.temp_CargaMasivaMinMax P
       LEFT JOIN U U_KEY
         ON TRIM(P.E_TIENDA)       = TRIM(U_KEY.SUCURSAL)
        AND TRIM(P.E_PRODUCTO)     = TRIM(U_KEY.SKU)
       LEFT JOIN U U_FULL
         ON TRIM(P.E_TIENDA)       = TRIM(U_FULL.SUCURSAL)
        AND TRIM(P.E_PRODUCTO)     = TRIM(U_FULL.SKU)
        AND TRIM(P.E_MIN)          = TRIM(U_FULL.MIN)
        AND TRIM(P.E_MAX)          = TRIM(U_FULL.MAX)
WHERE  U_FULL.SKU IS NULL