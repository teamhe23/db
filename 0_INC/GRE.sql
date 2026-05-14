SELECT * FROM EDSR.gre_modelo_dad
--UPDATE EDSR.gre_modelo_dad SET CH_PROCESADO = '0'
WHERE NU_ID_MODELO = 901;
COMMIT;




-- 2024/12/30 => Estoy elimiando este duplicado generado porque el GRE estuvo corriendo en dos cluster a la vez.

SELECT * FROM GRE_PAQUETE ORDER BY DT_FEC_REG DESC FETCH FIRST 10 ROWS ONLY;
SELECT GUIA.DT_FEC_REG, GUIA.* FROM gre_guia GUIA WHERE GUIA.ORG_LVL_CHILD = 423 ORDER BY GUIA.DT_FEC_REG DESC FETCH FIRST 10 ROWS ONLY;
SELECT * FROM GRE_PAQUETE WHERE NU_ID_PAQUETE IN (1844);
SELECT * FROM GRE_PAQUETE WHERE NU_ID_PAQUETE IN (1843);

select  e.vc_ruc,
              g.nu_id_guia,
              g.cod_establecimiento,
              g.cod_punto_emision,
              g.secuencial
      from gre_guia g
        inner join gre_empresa e on e.nu_id_empresa = g.nu_id_empresa
      where
          g.dt_fec_inicio >= trunc(sysdate-1) and
          g.nu_id_estado in (2, 5, 6);

SELECT GUIA.nu_id_estado, GUIA.* FROM EDSR.gre_guia GUIA
--UPDATE EDSR.gre_guia SET NU_ID_ESTADO = 2
WHERE NU_ID_GUIA IN (17522,17521,17520,17519,17518);
COMMIT;

SELECT guia.nu_id_estado, guia.VC_MENSAJE_eRROR, guia.* FROM EDSR.gre_paquete_guia guia
--UPDATE EDSR.gre_paquete_guia SET nu_id_estado = 0,VC_MENSAJE_ERROR = ''
WHERE NU_ID_PAQUETE = 1844;
COMMIT;

SELECT guia.nu_id_estado,guia.VC_DOC_RELACIONADO,guia.VC_DESTINO_NRO_DOC, guia.* FROM EDSR.gre_paquete_guia guia
--UPDATE EDSR.gre_paquete_guia SET nu_id_estado = 0
WHERE NU_ID_PAQUETE = 1843;
COMMIT;