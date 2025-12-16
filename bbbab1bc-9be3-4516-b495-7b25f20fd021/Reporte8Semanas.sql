CREATE OR REPLACE PROCEDURE EDSR.HP_GENERAR_REPORTE_8_SEMANAS IS
BEGIN

  execute immediate 'truncate table HPREP8SEMANAS_FULL';

  INSERT INTO HPREP8SEMANAS_FULL(
    SUCURSAL,
    COD_AREA,
    AREA,
    COD_DPTO,
    DEPARTAMENTO,
    LINEA,
    PROVEEDOR,
    SKU,
    DESCRIPCION,
    COD_ESTADO,
    ESTADO,
    COD_PROCED,
    PROCEDENCIA,
    SUR_SUC,
    SUR_SKU,
    FEC_INICIO,
    FEC_FIN,
    ESTADO_MATRIZ,
    COSTO_MEDIO_VARIABLE_MV,
    FECHA_INGRESO_SURTIDO_SAS,
    UND_SEM1,
    UND_SEM2,
    UND_SEM3,
    UND_SEM4,
    UND_SEM5,
    UND_SEM6,
    UND_SEM7,
    UND_SEM8,
    PROM_VTA_UNID,
    TOT_VTA_UNID,
    TOT_VTA_DOLARES,
    STOCK,
    OC,
    TRANSF,
    MIN,
    MAX,
    MP,
    DIAS_REV,
    DIAS_PROCESO,
    RPL_DESC,
    DMT_DESC,
    DISPONIBLE_CD_851,
    OC_CD_851,
    TIPO_REP,
    EXHIBICION,
    FACTOR,
    INICIO,
    FIN,
    ATRIBUTO_BIG_TICKET,
    TIPO_REDONDEO_RPL,
    UND_ORI_DIF_8S,
    FLAG_INFALTABLE,
    DES_ATR_TOP_2K,
    FECHA_ASIGNACION
  )
  WITH asignaciones_tienda AS
  (
    SELECT MAX(audit_date) AS fecha_asignacion,
           prd_lvl_child
    FROM ifh_sur_matprdae
    WHERE action ='A'
    GROUP BY prd_lvl_child
  )
  SELECT s.org_lvl_number SUCURSAL,
         p.cod_area COD_AREA,
         p.des_area AREA,
         p.cod_dpto "COD.DPTO",
         p.des_dpto DEPARTAMENTO,
         p.des_lin LINEA,
         p.des_prv PROVEEDOR,
         p.prd_lvl_number SKU,
         p.prd_full_name DESCRIPCION,
         p.cod_est COD_ESTADO,
         p.des_est ESTADO,
         p.cod_proce COD_PROCED,
         p.des_proce PROCEDENCIA,
         x.sur_mat_cod "SUR.SUC",
         x.sur_sku "SUR.SKU",
         x.fecha_inicio "FEC.INICIO",
         x.fecha_fin "FEC.FIN",
         x.estado_matriz,
         CST.CST_COST AS "Costo Medio Variable MV",
         x.fecha_inicio AS "FECHA INGRESO SURTIDO SAS",
         NVL(s8.cant, 0) "UND.SEM1",
         NVL(s7.cant, 0) "UND.SEM2",
         NVL(s6.cant, 0) "UND.SEM3",
         NVL(s5.cant, 0) "UND.SEM4",
         NVL(s4.cant, 0) "UND.SEM5",
         NVL(s3.cant, 0) "UND.SEM6",
         NVL(s2.cant, 0) "UND.SEM7",
         NVL(s1.cant, 0) "UND.SEM8",
         ROUND((NVL(s1.cant, 0) + NVL(s2.cant, 0) + NVL(s3.cant, 0) + NVL(s4.cant, 0) + NVL(s5.cant, 0) + NVL(s6.cant, 0) + NVL(s7.cant, 0) + NVL(s8.cant, 0)) / 8, 2) "Prom.Vta.Unid",
         NVL(s1.cant, 0) + NVL(s2.cant, 0) + NVL(s3.cant, 0) + NVL(s4.cant, 0) + NVL(s5.cant, 0) + NVL(s6.cant, 0) + NVL(s7.cant, 0) + NVL(s8.cant, 0) "Tot.Vta.Unid",
         NVL(s1.vta, 0) + NVL(s2.vta, 0) + NVL(s3.vta, 0) + NVL(s4.vta, 0) + NVL(s5.vta, 0) + NVL(s6.vta, 0) + NVL(s7.vta, 0) + NVL(s8.vta, 0) "Tot.Vta.Dolares",
         NVL(bal.on_hand_qty, 0) STOCK,
         --NVL(bal.po_ord_qty, 0) OC,
         NVL(OC.TotalPendientes, 0) OC,
         NVL(bal.to_ord_qty, 0) TRANSF,
         NVL(rpl.rpl_min_stk, 0) MIN,
         NVL(rpl.rpl_max_stk, 0) MAX,
         ROUND(whs.trf_dist_pak, 0) MP,
         RPL.RPL_REVIEW_DAYS "Dias Rev",
         RPL.RPL_PROC_DAYS "Dias Proceso",
         RPLM.RPL_DESC "RPL DESC",
         RPLD.DMT_DESC "DMT DESC",
         NVL(cd851.on_hand_qty, 0) "Disponible CD 851",
         NVL(cd851.po_ord_qty, 0) "OC CD 851",
         REPO.ATR_CODE "TIPO REP",
         EX.ATR_CODE "Exhibicion",
         NVL(IFH.FACTOR, 1) "Factor",
         IFH.EFFECT_DATE "Inicio",
         IFH.END_DATE "Fin",
         P.DES_BIGTCK "Atributo Big Ticket",
         RED.ATR_CODE "Tipo Redondeo RPL",
         nvl(VTA_ORI_DIF.VTA_TOTAL, 0) UND_ORI_DIF_8S,
         P.FLAG_INFALTABLE "Atributo Infaltable",
         P.DES_ATR_TOP_2K "Atributo Top 2K",
         AST.fecha_asignacion
  FROM edsr.tpprdmst p
  LEFT JOIN asignaciones_tienda AST ON AST.prd_lvl_child = p.prd_lvl_child
  INNER JOIN (SELECT O.ORG_LVL_CHILD, O.ORG_LVL_NUMBER
               FROM EPMM.ORGMSTEE O
              WHERE O.ORG_LVL_ID = 1
                    AND O.ORG_IS_STORE = 'T'
         START WITH O.ORG_LVL_CHILD IN(SELECT PAR.PARAM_VALUE
                                         FROM EDSR.CHLPARAM PAR
                                        WHERE PAR.PARAM_CODE = 'SUCTDA')
         CONNECT BY PRIOR O.ORG_LVL_CHILD = O.ORG_LVL_PARENT) s ON 1 = 1
  INNER JOIN EPMM.CAPSTREE CAP ON CAP.ORG_LVL_CHILD = s.org_lvl_child
  LEFT JOIN EPMM.CSTMSTEE CST ON CST.PRD_LVL_CHILD = P.PRD_LVL_CHILD AND CST.CST_ZONE_ID = CAP.CST_ZONE_ID
  LEFT JOIN edsr.hp_surtido_sku_suc x ON x.org_lvl_number = s.org_lvl_number and x.prd_lvl_number = p.prd_lvl_number
  LEFT JOIN (select * from EPMM.IFHRPLFACEE WHERE TRUNC(END_DATE) >= TRUNC(SYSDATE)) IFH ON IFH.ORG_LVL_CHILD = s.org_lvl_child AND IFH.PRD_LVL_CHILD = P.PRD_LVL_CHILD
  LEFT JOIN (SELECT a.suc_lvl_number,a.prd_lvl_number,b.calcwy Semana,SUM(a.cantidad_uni) Cant,SUM(a.vta_ext_neta_s_igv) Vta
              FROM edsr.tpvtahis a
                   INNER JOIN epmm.caldtlee b ON b.calcur = trunc(sysdate) - 7
                   INNER JOIN epmm.caldtlee c ON c.calcur = a.fec_venta  AND c.calcwy = b.calcwy AND c.calcyr = b.calcyr
          GROUP BY a.suc_lvl_number, a.prd_lvl_number, b.calcwy) s1 ON s1.prd_lvl_number = p.prd_lvl_number AND s1.suc_lvl_number = s.org_lvl_number
  LEFT JOIN (SELECT a.suc_lvl_number, a.prd_lvl_number, b.calcwy Semana, SUM(a.cantidad_uni) Cant, SUM(a.vta_ext_neta_s_igv) Vta
                FROM edsr.tpvtahis a
                     INNER JOIN epmm.caldtlee b ON b.calcur = trunc(sysdate) - 14
                     INNER JOIN epmm.caldtlee c ON c.calcur = a.fec_venta AND c.calcwy = b.calcwy AND c.calcyr = b.calcyr
            GROUP BY a.suc_lvl_number, a.prd_lvl_number, b.calcwy) s2 ON s2.prd_lvl_number = p.prd_lvl_number AND s2.suc_lvl_number = s.org_lvl_number
  LEFT JOIN (SELECT a.suc_lvl_number,a.prd_lvl_number,b.calcwy Semana,SUM(a.cantidad_uni) Cant,SUM(a.vta_ext_neta_s_igv) Vta
                FROM edsr.tpvtahis a
                     INNER JOIN epmm.caldtlee b ON b.calcur = trunc(sysdate) - 21
                     INNER JOIN epmm.caldtlee c ON c.calcur = a.fec_venta AND c.calcwy = b.calcwy AND c.calcyr = b.calcyr
            GROUP BY a.suc_lvl_number, a.prd_lvl_number, b.calcwy) s3 ON s3.prd_lvl_number = p.prd_lvl_number AND s3.suc_lvl_number = s.org_lvl_number
  LEFT JOIN (SELECT a.suc_lvl_number,a.prd_lvl_number,b.calcwy Semana,SUM(a.cantidad_uni) Cant,SUM(a.vta_ext_neta_s_igv) Vta
                FROM edsr.tpvtahis a
                     INNER JOIN epmm.caldtlee b ON b.calcur = trunc(sysdate) - 28
                     INNER JOIN epmm.caldtlee c ON c.calcur = a.fec_venta AND c.calcwy = b.calcwy AND c.calcyr = b.calcyr
            GROUP BY a.suc_lvl_number, a.prd_lvl_number, b.calcwy) s4 ON s4.prd_lvl_number = p.prd_lvl_number AND s4.suc_lvl_number = s.org_lvl_number
  LEFT JOIN (SELECT a.suc_lvl_number, a.prd_lvl_number, b.calcwy Semana, SUM(a.cantidad_uni) Cant, SUM(a.vta_ext_neta_s_igv) Vta
                FROM edsr.tpvtahis a
                     INNER JOIN epmm.caldtlee b ON b.calcur = trunc(sysdate) - 35
                     INNER JOIN epmm.caldtlee c ON c.calcur = a.fec_venta AND c.calcwy = b.calcwy AND c.calcyr = b.calcyr
            GROUP BY a.suc_lvl_number, a.prd_lvl_number, b.calcwy) s5 ON s5.prd_lvl_number = p.prd_lvl_number AND s5.suc_lvl_number = s.org_lvl_number
  LEFT JOIN (SELECT a.suc_lvl_number,a.prd_lvl_number,b.calcwy Semana,SUM(a.cantidad_uni) Cant,SUM(a.vta_ext_neta_s_igv) Vta
                FROM edsr.tpvtahis a
                     INNER JOIN epmm.caldtlee b ON b.calcur = trunc(sysdate) - 42
                     INNER JOIN epmm.caldtlee c ON c.calcur = a.fec_venta AND c.calcwy = b.calcwy AND c.calcyr = b.calcyr
            GROUP BY a.suc_lvl_number, a.prd_lvl_number, b.calcwy) s6 ON s6.prd_lvl_number = p.prd_lvl_number AND s6.suc_lvl_number = s.org_lvl_number
  LEFT JOIN (SELECT a.suc_lvl_number,a.prd_lvl_number,b.calcwy Semana,SUM(a.cantidad_uni) Cant,SUM(a.vta_ext_neta_s_igv) Vta
                FROM edsr.tpvtahis a
                     INNER JOIN epmm.caldtlee b ON b.calcur = trunc(sysdate) - 49
                     INNER JOIN epmm.caldtlee c ON c.calcur = a.fec_venta AND c.calcwy = b.calcwy AND c.calcyr = b.calcyr
            GROUP BY a.suc_lvl_number, a.prd_lvl_number, b.calcwy) s7 ON s7.prd_lvl_number = p.prd_lvl_number AND s7.suc_lvl_number = s.org_lvl_number
  LEFT JOIN (SELECT a.suc_lvl_number,a.prd_lvl_number,b.calcwy Semana,SUM(a.cantidad_uni) Cant,SUM(a.vta_ext_neta_s_igv) Vta
                FROM edsr.tpvtahis a
                     INNER JOIN epmm.caldtlee b ON b.calcur = trunc(sysdate) - 56
                     INNER JOIN epmm.caldtlee c ON c.calcur = a.fec_venta AND c.calcwy = b.calcwy AND c.calcyr = b.calcyr
            GROUP BY a.suc_lvl_number, a.prd_lvl_number, b.calcwy) s8 ON s8.prd_lvl_number = p.prd_lvl_number AND s8.suc_lvl_number = s.org_lvl_number
  LEFT JOIN (SELECT a.org_lvl_number,b.prd_lvl_child,b.inv_type_code,b.on_hand_qty,b.po_ord_qty,b.to_ord_qty
                FROM EPMM.ORGMSTEE a
                     INNER JOIN EPMM.INVBALEE b ON b.org_lvl_child = a.org_lvl_child
               WHERE inv_type_code = '01') bal ON bal.prd_lvl_child = p.prd_lvl_child AND bal.org_lvl_number = s.org_lvl_number
  LEFT JOIN (SELECT H.PRIM_ORG_LVL_NUMBER, DTL.PRD_LVL_CHILD,
                    SUM(CASE
                            WHEN H.PMG_STAT_CODE = 4 THEN DTL.PMG_SELL_QTY
                            ELSE DTL.PMG_SELL_QTY - DTL.PMG_RCV_SQTY
                        END) AS TotalPendientes
             FROM EDSR.PMGHDREE H
                      INNER JOIN EDSR.PMGDTLEE DTL ON H.PMG_PO_NUMBER = DTL.PMG_PO_NUMBER
             WHERE H.PMG_CNCL_BY_DATE >= TRUNC(SYSDATE)
               AND H.PMG_STAT_CODE IN (4, 5)
             GROUP BY H.PRIM_ORG_LVL_NUMBER, DTL.PRD_LVL_CHILD
             ) OC ON OC.PRIM_ORG_LVL_NUMBER = s.org_lvl_number AND OC.PRD_LVL_CHILD = p.PRD_LVL_CHILD
  LEFT JOIN epmm.rplpmhee rpl ON rpl.prd_lvl_child = p.prd_lvl_child AND rpl.org_lvl_child = s.org_lvl_child
  LEFT JOIN epmm.rplmthcd rplm ON rplm.rpl_method_code = rpl.rpl_method_code LEFT JOIN epmm.rpldmtcd rpld ON rpld.dmt_code = rpl.rpl_dist_method
  LEFT JOIN (SELECT O.ORG_LVL_NUMBER, P.PRD_LVL_NUMBER, AC.ATR_CODE
                FROM EPMM.BASAPLEE B
                     INNER JOIN edsr.tpprdmst P ON B.PRD_LVL_CHILD = P.PRD_LVL_CHILD
                     INNER JOIN EPMM.ORGMSTEE O ON B.ORG_LVL_CHILD = O.ORG_LVL_CHILD
                     INNER JOIN EPMM.BASACDEE AC ON B.ATR_HDR_TECH_KEY = AC.ATR_HDR_TECH_KEY AND B.ATR_COD_TECH_KEY = AC.ATR_COD_TECH_KEY
               WHERE B.ATR_TYP_TECH_KEY = 23 AND B.ATR_HDR_TECH_KEY = 147) REPO ON REPO.PRD_LVL_NUMBER = P.PRD_LVL_NUMBER AND REPO.ORG_LVL_NUMBER = S.ORG_LVL_NUMBER
  LEFT JOIN (SELECT O.ORG_LVL_NUMBER, P.PRD_LVL_NUMBER, AC.ATR_CODE
                FROM EPMM.BASAPLEE B
                     INNER JOIN edsr.tpprdmst P ON B.PRD_LVL_CHILD = P.PRD_LVL_CHILD
                     INNER JOIN EPMM.ORGMSTEE O ON B.ORG_LVL_CHILD = O.ORG_LVL_CHILD
                     INNER JOIN EPMM.BASACDEE AC ON B.ATR_HDR_TECH_KEY = AC.ATR_HDR_TECH_KEY AND B.ATR_COD_TECH_KEY = AC.ATR_COD_TECH_KEY
               WHERE B.ATR_TYP_TECH_KEY = 23 AND B.ATR_HDR_TECH_KEY = 152) EX ON EX.PRD_LVL_NUMBER = P.PRD_LVL_NUMBER AND EX.ORG_LVL_NUMBER = S.ORG_LVL_NUMBER
  LEFT JOIN (SELECT O.ORG_LVL_NUMBER, P.PRD_LVL_NUMBER, AC.ATR_CODE
                FROM EPMM.BASAPLEE B
                     INNER JOIN edsr.tpprdmst P ON B.PRD_LVL_CHILD = P.PRD_LVL_CHILD
                     INNER JOIN EPMM.ORGMSTEE O ON B.ORG_LVL_CHILD = O.ORG_LVL_CHILD
                     INNER JOIN EPMM.BASACDEE AC ON B.ATR_HDR_TECH_KEY = AC.ATR_HDR_TECH_KEY AND B.ATR_COD_TECH_KEY = AC.ATR_COD_TECH_KEY
               WHERE B.ATR_TYP_TECH_KEY = 23 AND B.ATR_HDR_TECH_KEY = 153) RED ON RED.ORG_LVL_NUMBER = S.ORG_LVL_NUMBER AND RED.PRD_LVL_NUMBER = P.PRD_LVL_NUMBER
  LEFT JOIN (SELECT b.prd_lvl_child, b.trf_dist_pak
                FROM EPMM.ORGMSTEE a
                     INNER JOIN epmm.whsprdee b ON b.org_lvl_child = a.org_lvl_child
               WHERE a.org_lvl_child = 420) whs ON whs.prd_lvl_child = p.prd_lvl_child
  LEFT JOIN (SELECT a.org_lvl_number, b.prd_lvl_child, b.inv_type_code, b.on_hand_qty, b.po_ord_qty, b.to_ord_qty
                FROM EPMM.ORGMSTEE a
                     INNER JOIN EPMM.INVBALEE b ON b.org_lvl_child = a.org_lvl_child AND b.inv_type_code = '01'
               WHERE a.org_lvl_number = 851) cd851 ON cd851.prd_lvl_child = p.prd_lvl_child
  LEFT JOIN (SELECT SLS.SLS_ORG_CHILD, SLS.SLS_PRD_CHILD, SUM(SLS.SLS_UNITS) VTA_TOTAL
               FROM EPMM.SLSPH3EE SLS
                    INNER JOIN EPMM.RPLSLXEE SLX ON SLS.SLS_DET_NUM = SLX.RPL_SLS_TYPE AND SLX.PRF_TECH_KEY = 121
              WHERE EXISTS(SELECT *
                             FROM EPMM.CALDTLEE FEC
                            WHERE FEC.CALCUR BETWEEN TRUNC(SYSDATE) - 56 AND TRUNC(SYSDATE) - 1
                                  AND FEC.CALCYR = SLS.SLS_YEAR
                                  AND FEC.CALCPR = SLS.SLS_PERIOD
                                  AND FEC.CALCWP = SLS.SLS_WEEK)
              GROUP BY SLS.SLS_ORG_CHILD, SLS.SLS_PRD_CHILD) VTA_ORI_DIF ON VTA_ORI_DIF.SLS_ORG_CHILD = S.ORG_LVL_CHILD AND VTA_ORI_DIF.SLS_PRD_CHILD = P.PRD_LVL_CHILD;

  UPDATE HPREP8SEMANAS_FULL
    SET FEC_ACT_REPORTE = SYSDATE;

  COMMIT;
END;