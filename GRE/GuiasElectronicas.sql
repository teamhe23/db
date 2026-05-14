--**************************************
-- APLICACION GRE 
--**************************************
----------------------------------------------------
--1) COMBO CD/TIENDA
----------------------------------------------------
select s.org_lvl_child,org.org_lvl_number,org.org_name_full
from gre_establecimiento s
	inner join orgmstee org on org.org_lvl_child = s.org_lvl_child
order by org.org_lvl_number;

----------------------------------------------------
--2)COMBO ESTADOS
----------------------------------------------------
select nu_id_estado,vc_desc_estado from EDSR.gre_paquete_est;

----------------------------------------------------
--3)GRILLA PRINCIPAL (Listar Paquetes)
----------------------------------------------------
select p.nu_id_paquete,
             p.nu_cod_sucursal,
             p.vc_nro_paquete,
             p.vc_emp_trans_placa,
             p.dt_fec_inicio,
             p.dt_fec_reg,
             p.nu_id_origen,
             p.vc_emp_trans_nro_doc,
             p.vc_emp_trans_nombre,
             p.ch_conductor_cod_tdi,
             p.vc_conductor_nro_doc,
             (
               select listagg(distinct resx.vc_desc_estado || '(' || resx.cant || ')', ' - ') within group (order by 1)
               from (
                 select x2.vc_desc_estado, count(1) as cant
                 from edsr.gre_paquete_guia x1
                   inner join edsr.gre_paquete_est x2 on x2.nu_id_estado = x1.nu_id_estado
                 where x1.nu_id_paquete = p.nu_id_paquete
                 group by x2.vc_desc_estado
               ) resx
             ) as vc_desc_estado,
             (
               select count(1)
               from gre_paquete_guia gx
               where gx.nu_id_paquete = p.nu_id_paquete
             ) as nu_cant_guias,
            count(1) over() as nu_total_registros
      from gre_paquete p
      where p.dt_fec_inicio between to_date('06/06/2025', 'DD/MM/YYYY') and to_date('06/06/2025', 'DD/MM/YYYY')
        and (NULL is null or p.nu_cod_sucursal = NULL)
        and (
            NULL is NULL --p_nu_id_estado
            or
            exists(select 1 from gre_paquete_guia x where x.nu_id_estado = null)
            )
        and (
            null is null
            or
            upper(p.vc_nro_paquete) like '%'||upper('')||'%'
            )
      order by p.nu_id_paquete desc
      offset 0 rows fetch next 25 rows only;

----------------------------------------------------
--3)BOTON VER GUIAS (Basado en el NU_ID_PAQUETE => )
----------------------------------------------------
select pg.nu_id_paquete_guia,
             pg.vc_doc_relacionado,
             pg.vc_mensaje_error,
             pg.nu_nro_impresiones,
             pg.nu_id_error,
             pg.ch_destino_cod_tdi,
             pg.vc_destino_nro_doc,
             g.nu_id_guia,
             g.cod_establecimiento,
             g.cod_punto_emision,
             g.secuencial,
             case when '0' = '1' then g.vc_pdf_base64 else null end as vc_pdf_base64,
             case when '0' = '1' then g.vc_xml_base64 else null end as vc_xml_base64,
             est_p.nu_id_estado,
             est_p.vc_desc_estado
      from gre_paquete_guia pg
        inner join gre_paquete_est est_p on est_p.nu_id_estado = pg.nu_id_estado
        left join gre_guia g on g.nu_id_guia = pg.nu_id_guia
      where nu_id_paquete = 3016 --3023
      ;

--**************************************
-- GUIAS GENERADAS DESDE EL WMS
--**************************************
SELECT * FROM GRE_MODELO_WMS ORDER BY DT_FEC_REG DESC FETCH FIRST 15 ROWS ONLY ;


--**************************************
-- GUIAS GENERADAS DESDE EL DAD
--**************************************
SELECT * FROM EDSR.gre_modelo_dad ORDER BY DT_FEC_REG DESC FETCH FIRST 15 ROWS ONLY;


--Listar Pendientes del DAD
  select nu_id_modelo,
         vc_cadena 
  from gre_modelo_dad
  where ch_procesado = '0'
    and rownum <= 100
  order by nu_id_modelo;

--Registra en gre_paquete_guia
SELECT * FROM gre_paquete_guia WHERE nu_id_paquete = 3016;

 SELECT * FROM GRE_PAQUETE ORDER BY DT_FEC_REG DESC FETCH FIRST 10 ROWS ONLY;
 SELECT * FROM GRE_PAQUETE WHERE NU_ID_PAQUETE IN (3016);
 
 SELECT * FROM EDSR.gre_guia WHERE NU_ID_GUIA = 32786;
 SELECT * FROM EDSR.gre_guia WHERE NU_ID_GUIA = 32803;
 
 SELECT * FROM EDSR.gre_guia_destino WHERE NU_ID_GUIA = 32786;