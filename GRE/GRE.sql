--
 SELECT * FROM GRE_MODELO_WMS FETCH FIRST 20 ROWS ONLY ;
 SELECT * FROM GRE_MODELO_WMS WHERE VC_CADENA LIKE '%OS85100013601%'; -- CASO NEW 17/02/2025 WMS: PUB_SUB: 2025-02-17 13:55:36
 SELECT * FROM GRE_MODELO_WMS WHERE VC_CADENA LIKE '%OS85100013641%'; -- CASO NEW 14/02/2025
 SELECT * FROM GRE_MODELO_WMS WHERE VC_CADENA LIKE '%OS85100013461%'; -- CASO OLD 2025-02-11 10:25:39 (SALIO WMS: 11/02/2025 10:09:29)

--Agregar una tienda
SELECT * FROM GRE_ESTABLECIMIENTO;

INSERT INTO EDSR.GRE_ESTABLECIMIENTO
    (ORG_LVL_CHILD, COD_ESTABLECIMIENTO, VC_DIRECCION, NU_ID_EMPRESA, CH_RED_EXTERNA, VC_CANTON)
VALUES (423, '004', 'PICHINCHA / QUITO / INIAQUITO/ AV. GRANADOS SN Y DE LOS COLIMES', 1, '0', 'QUITO');
COMMIT;

--Integración DAD
SELECT COUNT(*) FROM EDSR.gre_modelo_dad ; --784
SELECT * FROM EDSR.gre_modelo_dad ORDER BY DT_FEC_REG DESC FETCH FIRST 10 ROWS ONLY;
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%GRE_MODELO_DAD%';

--Integración WMS
SELECT COUNT(*) FROM EDSR.gre_modelo_wms ; --568
SELECT * FROM EDSR.gre_modelo_wms ORDER BY DT_FEC_REG DESC FETCH FIRST 10 ROWS ONLY;
SELECT * FROM EDSR.gre_modelo_wms WHERE UPPER(VC_CADENA) LIKE '[H1]101%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%GRE_MODELO_WMS%';

--Pendientes:
select nu_id_modelo,
             vc_cadena
      from gre_modelo_dad
      where ch_procesado = '0'
        and rownum <= 100
      order by nu_id_modelo;

update gre_modelo_dad
set  ch_procesado = '1',
   dt_fec_proceso = sysdate,
   ch_error = p_ch_error,
   vc_desc_error = p_vc_desc_error
where nu_id_modelo = p_nu_id_modelo;


-- Guias
SELECT * FROM GRE_PAQUETE_EST;
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

SELECT * FROM GRE_GUIA_EST;
/*
NU_ID_ESTADO    VC_DESC_ESTADO
1	Pendiente
2	Enviado
3	Autorizado
4	Rechazado
5	Sin respuesta del SRI
6	En Procesamiento
7	Error al procesar
 */
SELECT PAQ.NU_ID_GUIA, PAQ.* FROM gre_paquete_guia PAQ WHERE NU_ID_PAQUETE IN (1450,1451,1452);

 SELECT * FROM CARTEL_ACTUALIZACION ORDER BY DT_FEC_INICIO DESC;

--PAQUETES
 SELECT * FROM GRE_PAQUETE ORDER BY DT_FEC_REG DESC FETCH FIRST 10 ROWS ONLY;
 SELECT * FROM GRE_PAQUETE WHERE NU_ID_PAQUETE IN (1912,1911,1910,1909);
 SELECT * FROM GRE_PAQUETE_GUIA WHERE NU_ID_PAQUETE IN (1450);

 SELECT * FROM GRE_PAQUETE_GUIA_DET WHERE NU_ID_PAQUETE IN (1450);

--GUIAS
 SELECT * FROM GRE_GUIA WHERE NU_ID_GUIA IN (10507);
 SELECT * FROM GRE_GUIA_DESTINO WHERE NU_ID_GUIA IN (10507);
 SELECT * FROM GRE_GUIA_DESTINO_DET WHERE NU_ID_GUIA IN (10507);

--**********************************
-- CONSULTAR PAQUETE Y  DETALLE
--**********************************
SELECT * FROM EDSR.GRE_PAQUETE_GUIA PAQ
   INNER JOIN EDSR.GRE_PAQUETE_GUIA_DET DET ON PAQ.NU_ID_PAQUETE = DET.NU_ID_PAQUETE
WHERE PAQ.NU_ID_PAQUETE IN (1912,1911,1910,1909);

--**********************************
-- CONSULTAR GUIA Y DETALLE
--**********************************
SELECT GRE.* FROM EDSR.GRE_GUIA GRE
   INNER JOIN EDSR.GRE_GUIA_DESTINO DEST ON GRE.NU_ID_GUIA = DEST.NU_ID_GUIA
   INNER JOIN EDSR.GRE_GUIA_DESTINO_DET DET ON DET.NU_ID_GUIA = GRE.NU_ID_GUIA
WHERE GRE.NU_ID_GUIA IN (10507);


select * from gre_paquete_guia ORDER BY NU_ID_PAQUETE DESC FETCH FIRST 10 ROWS ONLY;
--c_paquete_est_autorizado
select * from gre_paquete_guia WHERE NU_ID_PAQUETE IN (1450,1451,1452); -- Enviado      3 (NU_ID_ESTADO =>3)
select * from gre_paquete_guia WHERE NU_ID_PAQUETE IN (1453,1457);      -- Autorizados  4 (NU_ID_ESTADO =>4)


-- Enviado 3 (NU_ID_ESTADO =>3)
select * from gre_guia ORDER BY dt_fec_inicio DESC FETCH FIRST 5 ROWS ONLY; -- Enviado 3 (NU_ID_ESTADO =>3)
select DISTINCT ORG_LVL_CHILD from gre_guia; -- Enviado 3 (NU_ID_ESTADO =>3)
select MAX(SECUENCIAL) from gre_guia;--DESDE EL 1. TOTAL: 10483  (21/11/2024)
select DISTINCT MATRIZ_DIRECCION from gre_guia; -- Enviado 3 (NU_ID_ESTADO =>3)
select * from gre_guia WHERE TO_CHAR(DT_FEC_INICIO, 'YYYY-MM-DD') = '2024-11-11' and COD_ESTABLECIMIENTO = '003'; -- Enviado 3 (NU_ID_ESTADO =>3)
select * from gre_empresa; -- Enviado 3 (NU_ID_ESTADO =>3)
select * from ORGMSTEE; -- Enviado 3 (NU_ID_ESTADO =>3)
/*
    419	101	GYE ORELLANA    002
    420	851	CD GUAYAQUIL    003
    423	102	UIO GRANADOS    004
*/

/*
    c_guia_est_enviado         2
    c_guia_est_sin_respuesta   5
    c_guia_est_procesamiento   6
 */

--**********************************
-- CONSULTAR PENDIENTES
--**********************************
select  e.vc_ruc,
              g.nu_id_guia,
              g.cod_establecimiento,
              g.cod_punto_emision,
              g.secuencial
from gre_guia g
    inner join gre_empresa e on e.nu_id_empresa = g.nu_id_empresa
where g.dt_fec_inicio >= trunc(sysdate-1)
    -- and g.nu_id_estado in (c_guia_est_enviado, c_guia_est_sin_respuesta, c_guia_est_procesamiento);
and g.nu_id_estado in (2, 5, 6);

select PAQ.NU_ID_GUIA, PAQ.* from gre_paquete_guia PAQ WHERE NU_ID_PAQUETE IN (1450,1451,1452);
select GUIA.DT_FEC_INICIO, GUIA.NU_ID_ESTADO, GUIA.* from gre_guia GUIA WHERE NU_ID_GUIA IN (10507,10508,10509);

SELECT 'OK' FROM DUAL where TO_DATE('2024-11-20', 'YYYY-MM-DD') >= trunc(sysdate-1);

--pase 1
UPDATE EDSR.gre_guia
SET dt_fec_inicio = TO_DATE('2024-11-21', 'YYYY-MM-DD')
WHERE NU_ID_GUIA IN (10507,10508,10509);

--pase 2
UPDATE EDSR.gre_guia
SET dt_fec_inicio = TO_DATE('2024-11-11', 'YYYY-MM-DD')
WHERE NU_ID_GUIA IN (10507,10508,10509);


/*
APP GRE: Lista paquetes
*/
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

             est_p.nu_id_estado,
             est_p.vc_desc_estado
      from gre_paquete_guia pg
        inner join gre_paquete_est est_p on est_p.nu_id_estado = pg.nu_id_estado
        left join gre_guia g on g.nu_id_guia = pg.nu_id_guia
      where nu_id_paquete in (1912,1911,1910,1909);

/*
 CONSULTAR PENDIENTES A ENVIAR A SOVOS
 */
 select p.nu_id_paquete,
             p.nu_cod_sucursal,
             p.vc_nro_paquete,
             p.dt_fec_inicio,
             p.dt_fec_final,
             p.nu_id_origen,
             p.ch_emp_trans_cod_tdi,
             p.vc_emp_trans_nro_doc,
             p.vc_emp_trans_nombre,
             p.vc_emp_trans_placa,
             p.ch_conductor_cod_tdi,
             p.vc_conductor_nro_doc,
             p.vc_conductor_nombre,
             p.vc_conductor_correo,
             p.vc_conductor_celular,
             g.nu_id_paquete_guia,
             g.nu_id_tipo,
             g.ch_destino_cod_tdi,
             g.vc_destino_nro_doc,
             g.vc_destino_nombre,
             g.vc_destino_direccion,
             g.vc_cod_motivo,
             g.vc_suc_destino,
             g.vc_doc_relacionado,
             g.vc_observacion,
             g.nu_id_guia,
             p.vc_usr_reg,
             g.vc_ruta,
             g.vc_email_destino,
             g.vc_telefono_destino
      from gre_paquete_guia g
        inner join gre_paquete p on p.nu_id_paquete = g.nu_id_paquete
      where g.nu_id_estado = 1-- c_paquete_est_pendiente
        and rownum <= 20
      order by p.nu_id_paquete, g.nu_id_paquete_guia;