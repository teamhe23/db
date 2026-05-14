SELECT * FROM EDSR.HPRECRFCAB; --307
SELECT * FROM EDSR.HPRECRFDET ORDER BY FEC_RF DESC; --34779
SELECT * FROM EDSR.HPRECRFDET WHERE CANTIDAD = 122 ORDER BY FEC_RF desc;
--A04 : HERRAMIENTAS |           
SELECT * FROM PRDMSTEE WHERE PRD_LVL_ID = 2 AND PRD_STATUS = 2;
SELECT * FROM TPPRDMST;
SELECT * FROM TPPRDMST WHERE DES_AREA LIKE '%HERRAMIENTA%' ;

SELECT P.PRD_LVL_NUMBER, UPC.PRD_UPC FROM EPMM.PRDMSTEE P
	INNER JOIN EPMM.PRDUPCEE UPC ON P.PRD_LVL_CHILD = UPC.PRD_LVL_CHILD
	LEFT JOIN EPMM.PRDUPCAE A ON UPC.PRD_UPC = A.PRD_UPC AND A.AUDIT_TYPE = 'A'
WHERE 	UPC.PRODUCT_UPC = 'T'
 		AND UPC.PRD_PRIMARY_FLAG = 'T'
		AND P.PRD_LVL_NUMBER  IN ('10615','10616','10660','10662','10665','10666','10667','10661','10658','10656','10659','10663','10619','10620','10702','10707','10709','10706');

--CONSULTA
SELECT DISTINCT PHY_CTRL_NUM FROM EPMM.PHYPIDEE INV 
WHERE PHY_FRZ_DATE IS NOT NULL
AND PHY_FRZ_DATE < TO_DATE('20250618', 'YYYYMMDD')
AND PHY_FRZ_DATE >= TO_DATE('20250617', 'YYYYMMDD')
--ORDER BY PHY_FRZ_DATE DESC;

SELECT NVL(D.ID_ASIG, 0) ID_ASIG,
       D.ORG_LVL_NUMBER,
       D.PRD_LVL_NUMBER,
       D.USU_RF, --USUARIO CONTEO
       D.FEC_RF, --FECHA CONTEO
       D.NRO_LOTE, --NRO LOTE
       D.FEC_INI_LOTE,
       D.FEC_FIN_LOTE, 
       C.USUARIO, -- USUARIO SUBIDA
       C.FECHA,
       SUM(D.CANTIDAD) CANTIDAD
  FROM EDSR.HPRECRFDET D
 INNER JOIN EDSR.HPRECRFCAB C
    ON D.ID_REF = C.ID_RECRF
 WHERE to_char(C.FECHA , 'YYYYMMDD') = @FECHA (RF)@ AND D.ORG_LVL_NUMBER=@IDSUCURSAL (RF)@
 GROUP BY NVL(D.ID_ASIG, 0), D.ORG_LVL_NUMBER, D.PRD_LVL_NUMBER,D.USU_RF,D.FEC_RF,D.FEC_INI_LOTE,D.FEC_FIN_LOTE,C.USUARIO,C.FECHA,D.NRO_LOTE

SELECT AA.ID_ASIG ASIG,
       BB.PHY_CTRL_NUM CONTEO,
       O.ORG_LVL_NUMBER || ' - ' || O.ORG_NAME_FULL SUCURSAL,
       P.PRD_LVL_NUMBER SKU,
       P.PRD_FULL_NAME DESCRIPCION,
       P.DES_EST ESTADO,
       P.COD_AREA || ' - ' || P.DES_AREA AREA,
       P.COD_DPTO || ' - ' || P.DES_DPTO DPTO,
       P.COD_LIN || ' - ' || P.DES_LIN LIN,
       P.DES_MARCA MARCA, -- DCJ 01/02/2018
       P.DES_PRV PROVEEDOR,
       SUBSTR(P.DES_PROCE, 0, 3) PROCEDENCIA,
       bb.trf_dist_pak pack_cd,
       bb.OO_TRF_1, bb.OO_OC_1, 
       BB.PHY_FRZ_CST "COSTO.CONGELADO", 
       EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_log(P.PRD_LVL_CHILD, O.ORG_LVL_CHILD) "COST.UNI",
       --NVL(BB.PHY_FRZ_CST,TP_PKG_GEN_FUNCIONES.Fn_Costo_log(P.PRD_LVL_CHILD, O.ORG_LVL_CHILD)) "COST.UNI2",
       (EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_log(P.PRD_LVL_CHILD, O.ORG_LVL_CHILD) * (BB.ON_HAND_QTY_01 + BB.ON_HAND_QTY_02 + BB.ON_HAND_QTY_03 + BB.ON_HAND_QTY_04 + BB.ON_HAND_QTY_05 + BB.ON_HAND_QTY_06 )) "TOT.VAL.OH",
       BB.ON_HAND_QTY_01 "01-DIS",
       BB.ON_HAND_QTY_02 "02-ASI",
       BB.ON_HAND_QTY_03 "03-RSV",
       BB.ON_HAND_QTY_04 "04-NODIS",
       BB.ON_HAND_QTY_05 "05-DAÑ",
       BB.ON_HAND_QTY_06 "06-CIC",
       (BB.ON_HAND_QTY_01 + BB.ON_HAND_QTY_02 + BB.ON_HAND_QTY_03 +
       BB.ON_HAND_QTY_04 + BB.ON_HAND_QTY_05 + BB.ON_HAND_QTY_06) "TOT.OH",
       NVL(AA.CANTIDAD, 0) FISICO,
       AA.USU_RF "Usr.Conteo", --USUARIO CONTEO
       TO_CHAR(AA.FEC_RF, 'dd/MM/yyyy hh:mm:ss') "Fec.Conteo", --FECHA CONTEO
       AA.NRO_LOTE "NRO.LOTE", --NRO LOTE
       TO_CHAR(AA.FEC_INI_LOTE, 'dd/MM/yyyy hh:mm:ss') "Fec.Creac.Lote",
       TO_CHAR(AA.FEC_FIN_LOTE, 'dd/MM/yyyy hh:mm:ss') "Fec.Cierre.Lote", 
       AA.USUARIO "Usr.Subida", -- USUARIO SUBIDA
       TO_CHAR(AA.FECHA, 'dd/MM/yyyy hh:mm:ss') "Fec.Subida"
  FROM (SELECT NVL(D.ID_ASIG, 0) ID_ASIG,
               D.ORG_LVL_NUMBER,
               D.PRD_LVL_NUMBER,
               D.USU_RF, --USUARIO CONTEO
               D.FEC_RF, --FECHA CONTEO
               D.NRO_LOTE, --NRO LOTE
               D.FEC_INI_LOTE,
               D.FEC_FIN_LOTE, 
               C.USUARIO, -- USUARIO SUBIDA
               C.FECHA,
               SUM(D.CANTIDAD) CANTIDAD
          FROM EDSR.HPRECRFDET D
         INNER JOIN EDSR.HPRECRFCAB C
            ON D.ID_REF = C.ID_RECRF
         WHERE to_char(C.FECHA , 'YYYYMMDD') = '20250617' AND D.ORG_LVL_NUMBER='101'
         GROUP BY NVL(D.ID_ASIG, 0), D.ORG_LVL_NUMBER, D.PRD_LVL_NUMBER,D.USU_RF,D.FEC_RF,D.FEC_INI_LOTE,D.FEC_FIN_LOTE,C.USUARIO,C.FECHA,D.NRO_LOTE
         ) AA
FULL OUTER JOIN (SELECT ORG.ORG_LVL_NUMBER,
                          PRD.PRD_LVL_NUMBER,
                          INV2.PHY_CTRL_NUM,
                          INV2.PHY_FRZ_CST,
                          w.trf_dist_pak,
                          nvl(a.to_ord_qty,0) OO_TRF_1, 
                          nvl(a.po_ord_qty,0) OO_OC_1, 
                          NVL(A.ON_HAND_QTY, 0) ON_HAND_QTY_01,
                          NVL(B.ON_HAND_QTY, 0) ON_HAND_QTY_02,
                          NVL(C.ON_HAND_QTY, 0) ON_HAND_QTY_03,
                          NVL(D.ON_HAND_QTY, 0) ON_HAND_QTY_04,
                          NVL(E.ON_HAND_QTY, 0) ON_HAND_QTY_05,
                          NVL(F.ON_HAND_QTY, 0) ON_HAND_QTY_06
                     FROM (SELECT DISTINCT INV.ORG_LVL_CHILD,
                                           INV.PRD_LVL_CHILD,
                                           INV.PHY_CTRL_NUM,
                                           INV.PHY_FRZ_CST
                             FROM EDSR.PHYPIDEE INV
                            WHERE INV.PHY_CTRL_NUM = @CONTEO (PMM)@
                            ) INV2
                    INNER JOIN EDSR.ORGMSTEE ORG
                       ON INV2.ORG_LVL_CHILD = ORG.ORG_LVL_CHILD
                    INNER JOIN EDSR.TPPRDMST PRD
                       ON INV2.PRD_LVL_CHILD = PRD.PRD_LVL_CHILD
                    INNER JOIN EDSR.Whsprdee w
                       ON w.prd_lvl_child = PRD.PRD_LVL_CHILD
                       and w.org_lvl_child in (select to_number(trim(param_value))
                                                 from EDSR.chlparam
                                                where param_code in ('CENTRODIS'))
                     LEFT JOIN EDSR.INVBALEE A
                       ON INV2.PRD_LVL_CHILD = A.PRD_LVL_CHILD
                      AND INV2.ORG_LVL_CHILD = A.ORG_LVL_CHILD
                      AND A.INV_TYPE_CODE = '01'
                     LEFT JOIN EDSR.INVBALEE B
                       ON INV2.PRD_LVL_CHILD = B.PRD_LVL_CHILD
                      AND INV2.ORG_LVL_CHILD = B.ORG_LVL_CHILD
                      AND B.INV_TYPE_CODE = '02'
                     LEFT JOIN EDSR.INVBALEE C
                       ON INV2.PRD_LVL_CHILD = C.PRD_LVL_CHILD
                      AND INV2.ORG_LVL_CHILD = C.ORG_LVL_CHILD
                      AND C.INV_TYPE_CODE = '03'
                     LEFT JOIN EDSR.INVBALEE D
                       ON INV2.PRD_LVL_CHILD = D.PRD_LVL_CHILD
                      AND INV2.ORG_LVL_CHILD = D.ORG_LVL_CHILD
                      AND D.INV_TYPE_CODE = '04'
                     LEFT JOIN EDSR.INVBALEE E
                       ON INV2.PRD_LVL_CHILD = E.PRD_LVL_CHILD
                      AND INV2.ORG_LVL_CHILD = E.ORG_LVL_CHILD
                      AND E.INV_TYPE_CODE = '05'
                     LEFT JOIN EDSR.INVBALEE F
                      ON INV2.PRD_LVL_CHILD = F.PRD_LVL_CHILD
                      AND INV2.ORG_LVL_CHILD = F.ORG_LVL_CHILD
                      AND F.INV_TYPE_CODE = '06'
                         ) BB
    ON AA.PRD_LVL_NUMBER = BB.PRD_LVL_NUMBER
   AND AA.ORG_LVL_NUMBER = BB.ORG_LVL_NUMBER
  INNER JOIN EDSR.ORGMSTEE O
   ON O.ORG_LVL_NUMBER = NVL(AA.ORG_LVL_NUMBER, BB.ORG_LVL_NUMBER)
INNER JOIN EDSR.TPPRDMST P
    ON P.PRD_LVL_NUMBER = NVL(AA.PRD_LVL_NUMBER, BB.PRD_LVL_NUMBER)
WHERE 
    NVL(BB.ON_HAND_QTY_01, 0) <> 0
    OR NVL(BB.ON_HAND_QTY_02, 0) <> 0
    OR NVL(BB.ON_HAND_QTY_03, 0) <> 0
    OR NVL(BB.ON_HAND_QTY_04, 0) <> 0
    OR NVL(BB.ON_HAND_QTY_05, 0) <> 0
    OR NVL(BB.ON_HAND_QTY_06, 0) <> 0
    OR NOT AA.CANTIDAD IS NULL
ORDER BY P.PRD_LVL_NUMBER