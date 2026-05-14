/*
 1	Pendiente
2	Omitido
3	Enviado
4	Autorizado
5	Rechazado
6	Sin respuesta del SRI
7	Requiere Revisión
8	Cancelado
 */
 select  g.nu_id_estado,g.dt_fec_inicio,e.vc_ruc,
              g.nu_id_guia,
              g.cod_establecimiento,
              g.cod_punto_emision,
              g.secuencial
  from gre_guia g
    inner join gre_empresa e on e.nu_id_empresa = g.nu_id_empresa
   WHERE g.nu_id_estado in (2, 5, 6);
  /*where g.dt_fec_inicio >= trunc(sysdate-10)
    and g.nu_id_estado in (2, 5, 6);*/
 
SELECT * FROM EDSR.gre_guia_consulta_sovos ORDER BY dt_fec_reg DESC FETCH FIRST 1 ROWS ONLY;
 
 SELECT NU_ID_GUIA, nu_id_CONSULTA, DT_FEC_REG FROM gre_guia_consulta_sovos
  --UPDATE gre_guia_consulta_sovos SET nu_id_CONSULTA = 8
 WHERE NU_ID_GUIA in (829365,829366,829367);
 EDSR.FK_GRE_GUIA_ESTADO
 
 SELECT DISTINCT constraint_type FROM dba_constraints;
 SELECT * FROM dba_constraints WHERE UPPER(constraint_name) LIKE '%FK%';
 
SELECT 
    fk.owner           AS fk_owner,
    fk.table_name      AS fk_table,
    fk_col.column_name AS fk_column,
    pk.owner           AS pk_owner,
    pk.table_name      AS pk_table,
    pk_col.column_name AS pk_column,
    fk.constraint_name AS fk_name,
    pk.constraint_name AS pk_name
FROM 
    all_constraints fk
JOIN 
    all_cons_columns fk_col 
    ON fk.constraint_name = fk_col.constraint_name AND fk.owner = fk_col.owner
JOIN 
    all_constraints pk 
    ON fk.r_constraint_name = pk.constraint_name AND fk.owner = pk.owner
JOIN 
    all_cons_columns pk_col 
    ON pk.constraint_name = pk_col.constraint_name AND pk.owner = pk_col.owner
    AND fk_col.position = pk_col.position
WHERE 
    fk.constraint_type = 'R' -- 'R' = Foreign Key
    AND fk.owner = UPPER('edsr') -- ← Cambia por tu esquema si quieres filtrar
    AND UPPER(fk.constraint_name) LIKE '%FK_GRE_GUIA_ESTADO%'
ORDER BY 
    fk.table_name, fk_col.POSITION
;

 --(EDSR.FK_GRE_GUIA_ESTADO) 
 SELECT nu_id_estado,dt_fec_inicio,
              nu_id_guia,
              cod_establecimiento,
              cod_punto_emision,
              secuencial FROM gre_guia
 --UPDATE gre_guia SET nu_id_estado = 7
 WHERE NU_ID_GUIA in (829365,829366,829367);
 COMMIT;
 
 SELECT * FROM GRE_GUIA_EST;
 