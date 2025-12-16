SELECT * FROM EDSR.gre_modelo_dad
ORDER BY FECHA_PUBSUB DESC
FETCH FIRST 50 ROWS ONLY
;

SELECT *
FROM gre_modelo_dad
WHERE json_value(VC_CADENA, '$.facilityCode') = '102';

SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%GRE_MODELO_DAD%';
/*
    EDSR.PKG_GRE.SP_INS_PAQUETE
    TABLA: gre_paquete
 */

--INCIDENCIA
SELECT * FROM EDSR.gre_modelo_dad WHERE NU_ID_MODELO = 901;
SELECT * FROM EDSR.gre_modelo_dad WHERE NU_ID_MODELO = 907;
SELECT * FROM EDSR.gre_paquete WHERE NU_COD_SUCURSAL = '102';
SELECT * FROM EDSR.gre_paquete WHERE NU_ID_PAQUETE = 1696;
SELECT * FROM EDSR.gre_paquete_guia WHERE NU_ID_PAQUETE = 1685;
SELECT * FROM EDSR.gre_paquete_guia WHERE NU_ID_PAQUETE = 1696;
SELECT * FROM EDSR.gre_paquete_guia_det WHERE NU_ID_PAQUETE = 1685;
SELECT * FROM EDSR.gre_paquete_guia_det WHERE NU_ID_PAQUETE = 1696;
SELECT max(NU_ID_PAQUETE) FROM EDSR.gre_paquete_guia_det WHERE NU_ID_PAQUETE = 1696;

--nueva insercion
SELECT * FROM EDSR.gre_paquete WHERE NU_ID_PAQUETE IN (1685,1695);
SELECT * FROM EDSR.gre_paquete WHERE NU_ID_PAQUETE = 1695;
SELECT guia.nu_id_estado , guia.* FROM EDSR.gre_paquete_guia guia WHERE NU_ID_PAQUETE IN (1685,1695);
SELECT guia.nu_id_estado , guia.* FROM EDSR.gre_paquete_guia guia WHERE NU_ID_GUIA IN (16815);
SELECT det.* FROM EDSR.gre_paquete_guia_det det WHERE NU_ID_PAQUETE = 1695;


BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    EDSR.PKG_GRE.SP_INS_GUIA(
        p_org_lvl_child => 423,
        p_cod_establecimiento => '',
        p_cod_punto_emision =>'' ,
        p_secuencial =>0
    );

end;


begin
      select pto.id_punto_emision,
             est.cod_establecimiento,
             pto.cod_punto_emision,
             pto.secuencial + 1
        into v_id_punto_emision,
             p_cod_establecimiento,
             p_cod_punto_emision,
             p_secuencial
      from gre_punto_emision pto
        inner join gre_establecimiento est on est.org_lvl_child = pto.org_lvl_child
      where pto.org_lvl_child = p_org_lvl_child
        and pto.ch_estado     = '1';

      SELECT * FROM gre_punto_emision
      --update gre_punto_emision set secuencial = 1
      where id_punto_emision = 3;
    exception
      when others then
        p_cod_establecimiento := '';
        p_cod_punto_emision   := '';
        p_secuencial          := 0;
    end;

--Valida si existe | c_paquete_est_pendiente: 1 | c_paquete_est_cancelado : 8
select *
from gre_paquete p
    inner join gre_paquete_guia pg on pg.nu_id_paquete = p.nu_id_paquete
where p.nu_id_paquete != 1685
    and p.vc_nro_paquete = '1551091' --1551091
    and pg.nu_id_estado not in (1, 8)
    and rownum = 1;

SELECT * FROM gre_punto_emision;
SELECT * FROM GRE_ESTABLECIMIENTO;

select pto.id_punto_emision,
             est.cod_establecimiento,
             pto.cod_punto_emision,
             pto.secuencial + 1
      from gre_punto_emision pto
        inner join gre_establecimiento est on est.org_lvl_child = pto.org_lvl_child
      where pto.org_lvl_child = 423--p_org_lvl_child
        and pto.ch_estado     = '1';

-- Lista Pendientes
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
      where g.nu_id_estado = 1 --c_paquete_est_pendiente
        and rownum <= 20
      order by p.nu_id_paquete, g.nu_id_paquete_guia;


SELECT * FROM ORGMSTEE WHERE ORG_LVL_CHILD = 424;
SELECT * FROM gre_punto_emision;

SELECT * FROM GRE_ESTABLECIMIENTO;
SELECT * FROM GRE_PUNTO_EMISION;