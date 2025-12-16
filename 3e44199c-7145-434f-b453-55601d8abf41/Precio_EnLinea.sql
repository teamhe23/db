-- PRECIO EN LINEA son los cambios que se genera en el mismo dia

-- 1. AGREGAR PRODUCTOS EN TURBO ENTRY DESDE CARGA -> PRECIOS -> PRECIO EN LINEA, por sku, uno por uno o en masivo, luego darle en Guardar.
    -- TABLA DE PRODUCTOS
    SELECT * FROM EDSR.TPPRDMST ORDER BY 1 DESC;

SELECT * FROM EDSR.IFH_PRC_LOAD WHERE FEC_CRE >= TRUNC(SYSDATE);

-- 2. edsr.PKG_ARCHIVOS_POS.sp_carga_prc_linea, va a cargar los productos de IFH_PRC_LOAD a

SELECT * FROM EDSR.SIST_CAJA_PRC_LINEA WHERE FEC_PROCESADO IS NULL;
SELECT * FROM EDSR.SIST_CAJA_PRC_LINEA order by FEC_PROCESADO DESC;
SELECT * FROM EDSR.SIST_CAJA_PRC_LINEA WHERE FEC_PROCESADO >= TRUNC(SYSDATE);
SELECT * FROM EDSR.SIST_CAJA_PRC_LINEA WHERE PRD_LVL_CHILD = 121048;

-- 3. Envio de la API POS

    -- Lista de Servidores Linux ( La API POS mandara los archivos planos por medio de FTP)
    SELECT * FROM EDSR.SIST_CAJA_PRECIOS;

    /*
     Log ( Guarda los envios de los archivos que envia la API POS)
     El contenido del archivo que son los precios y skus que van a la caja, Fecha/Hora,  NombreArchivo, etc)
     */
    SELECT * FROM EDSR.SIST_CAJA_PRECIOS_LOG ORDER BY 1 DESC;







SELECT * FROM EDSR.TPPRDMST WHERE PRD_LVL_NUMBER = '32303';
SELECT * FROM EDSR.CHLPRCE2 WHERE PRD_LVL_CHILD = 121048;

-- EDSR.PKG_ARCHIVOS_POS.SP_SEL_TIENDAS

SELECT ORG.ORG_LVL_CHILD,
             ORG.ORG_LVL_NUMBER,
             SC.SO_FLG,
             SC.IGV_FLG,
             SC.SRV_IP,
             SC.SRV_USR,
             SC.SRV_PWD
      FROM ORGMSTEE ORG
        INNER JOIN SIST_CAJA_PRECIOS SC ON SC.ORG_LVL_CHILD = ORG.ORG_LVL_CHILD
      WHERE ORG.ORG_LVL_ID = 1;



-- 	edsr.PKG_ARCHIVOS_POS.sp_carga_prc_linea

/*insert into sist_caja_prc_linea(
      sec_prc,
      org_lvl_child,
      prd_lvl_child
    )
 */
select prc.sec_prc,
       prc.org_lvl_child,
       prc.prd_lvl_child
from ifh_prc_load prc
where prc.fec_cre >= trunc(sysdate)
  and not exists(
                 select 1
                 from sist_caja_prc_linea x
                 where x.sec_prc = prc.sec_prc
                   and x.org_lvl_child = prc.org_lvl_child
                   and x.prd_lvl_child = prc.prd_lvl_child
                );