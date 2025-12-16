/*
 --------------------------------------------------------
    GENERACIÓN DE XML de un OC para enviar a B2B
    ACTUAL VALOR DE OC: pPMG_PO_NUMBER
    RUTA: /prochp/interfaces/b2b/export/out/log
    Formato:
            ****************************************
                OC100065.xml.gz.trg
                OC100065.xml.gz
            ****************************************
 --------------------------------------------------------
 */
SELECT * FROM dba_directories WHERE directory_name = 'TP_FILE_B2B';
BEGIN
    dataman123('PMG','HDR','SDI');
    dataman123('PMG','DTL','SDI');
    dataman123('PMG','ALL','SDI');
    COMMIT;
END;
SELECT * FROM TP_DAD_OC_CTRL WHERE NUM_OC IN (101720,101721,101722);
SELECT * FROM tpimpocc WHERE PMG_PO_NUMBER =101712;

SELECT * FROM PMGHDREE ORDER BY PMG_PO_NUMBER DESC FETCH FIRST 50 ROWS ONLY;
SELECT * FROM SDIPMGHDE ORDER BY PMG_PO_NUMBER DESC FETCH FIRST 50 ROWS ONLY;

SELECT PMG.PMG_EXT_PO_NUM,PMG.DOWNLOAD_DATE, PMG.DOWNLOAD_DATE_1, PMG.*
FROM SDIPMGHDE PMG  WHERE PMG_PO_NUMBER IN (101670);

DECLARE
    pPMG_PO_NUMBER NUMBER := 101681;
    v_cod_emp VARCHAR2(2) := '01';
    v_ruc_emp VARCHAR2(150);
    v_rsc_emp VARCHAR2(150);
    XML VARCHAR2(4000);
BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_OC_B2B_XML_A1';
      EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_OC_B2B_XML_A2';
      EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_OC_B2B_XML_A3';
      EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_OC_B2B_XML_D23';

      insert into TMP_OC_B2B_XML_A1
        SELECT ORG.org_lvl_number,
               TRIM(ORG.org_name_full),
               TRIM(ADR.bas_addr_1)
          FROM (
                SELECT E.PMG_PO_NUMBER, E.ORG_LVL_CHILD
                FROM PMGLOCEE E
                WHERE E.PMG_PO_NUMBER = pPMG_PO_NUMBER
               ) ORD,
               orgmstee ORG,
               orgdtlee ODT,
               basadree ADR
         WHERE ORD.org_lvl_child = ORG.org_lvl_child
           AND ORG.org_lvl_child = ODT.org_lvl_child
           AND ODT.bas_add_key = ADR.bas_add_key(+);

      SELECT RUC_EMP, DES_EMP
        INTO v_ruc_emp, v_rsc_emp
      FROM TGMSTEMP
      WHERE COD_EMP = v_cod_emp;

      insert into TMP_OC_B2B_XML_A2
        SELECT DISTINCT TRIM(DECODE(HDR.DMT_CODE, 1, 6, HDR.DMT_CODE)) AS DMT_CODE,
                        v_ruc_emp,
                        v_rsc_emp,
                        TRIM(USR.usr_tech_key),
                        TRIM(USR.bas_user_name),
                        'proveedoresb2b@hesa.pe',
                        SUBSTR(TRIM(PRV.vendor_number), 1, 13),
                        TRIM(PRV.vendor_name),
                        nvl((select to_char(vl.vpc_cod_lpn)
                             from tpvpclpn vl
                             where vl.vpc_tech_key = prv.vpc_tech_key),
                            'CODLPN') CODLPN,
                        NVL((SELECT TRIM(B.ATR_CODE)
                             FROM VPCATVEE V
                             INNER JOIN BASACDEE B ON V.ATR_COD_TECH_KEY =
                                                     B.ATR_COD_TECH_KEY
                             WHERE V.VPC_TECH_KEY = PRV.VPC_TECH_KEY
                               AND V.ATR_HDR_TECH_KEY =
                                  (SELECT PARAM_VALUE
                                     FROM CHLPARAM
                                    WHERE PARAM_CODE = 'AHRTIPPOR')),'C') TIPOPROVEEDOR,
                        TO_CHAR(HDR.pmg_release_date, 'YYYYMMDD'), --f_emision
                        TO_CHAR(HDR.pmg_release_date, 'YYYYMMDD'), --f_entrega
                        CASE WHEN HDR.Pmg_Cncl_By_Date < (SELECT FEC_APE FROM ifh_suc_fecap
                                                         WHERE ORG_LVL_CHILD = ORG.ORG_LVL_CHILD) THEN
                            TO_CHAR((SELECT FEC_APE FROM ifh_suc_fecap WHERE ORG_LVL_CHILD = ORG.ORG_LVL_CHILD), 'YYYYMMDD') --fecha apertura tienda
                        ELSE
                            TO_CHAR(HDR.Pmg_Cncl_By_Date, 'YYYYMMDD') --f_vencimiento
                        END,
                        ' ', -- observaciones
                        NVL(TRIM(PLA.vpc_apt_desc), ' '),
                        TRIM(PRD.cod_area),
                        TRIM(PRD.des_area),
                        hdr.pmg_type_code,--E11
                        (select trim(pmg_type_name) from pmgotpee where pmg_type_code = hdr.pmg_type_code),--E12
                        TRIM(HDR.curr_code),
                        TRIM(MON.curr_name),
                        TRIM(ORG.org_lvl_number),
                        TRIM(HDR.pmg_tot_po_cost),
                        TRIM(HDR.pmg_lc_number)
          FROM pmghdree HDR,
               basusree USR,
               vpcmstee PRV,
               pmgdtlee DTL,
               tpprdmst PRD,
               vpcaptee PLA,
               curmstee MON,
               pmglocee SUC,
               orgmstee ORG
         WHERE HDR.usr_tech_key = USR.usr_tech_key
           AND HDR.vpc_tech_key = PRV.vpc_tech_key
           AND HDR.pmg_po_number = DTL.pmg_po_number
           AND DTL.prd_lvl_child = PRD.prd_lvl_child
           AND HDR.vpc_apt_key = PLA.vpc_apt_key
           AND HDR.curr_code = MON.curr_code
           AND HDR.pmg_po_number = SUC.pmg_po_number
           AND SUC.pre_dist_po_loc = 'T'
           AND SUC.org_lvl_child = ORG.org_lvl_child
           AND ROWNUM = 1
           AND HDR.pmg_po_number = pPMG_PO_NUMBER;

      insert into TMP_OC_B2B_XML_A3
         SELECT TRIM(DTL.pmg_po_number) DS,
               TRIM(PRD.prd_lvl_number) D0,
               TRIM(CPR.VPC_CASE_PACK_ID),
               TRIM(CPR.VPC_CASE_QTY_UOM),
               '' DUN14,
               TRIM(PRD.cod_bar),
               TRIM(PRD.prd_full_name),
               ' ', --descripcion 2
               TRIM(PRD.cod_lin),
               TRIM(PRD.des_lin),
               TRIM(PRD.des_marca) D9,
               TRIM(PRD.des_tipman),
               TRIM(DTL.pmg_sell_cost), --'costo final'
               TRIM(DTL.pmg_loc_curr),
               TRIM(MON.curr_name) D13,
               TRIM(DECODE(VQT.pmg_sell_qty,
                           NULL,
                           DTL.pmg_sell_qty,
                           VQT.pmg_sell_qty)) AS pmg_sell_qty,
               NVL(TRIM(PRD.des_cur), ' '),
               NVL(TRIM(PRD.des_tal), ' '),
               VPD.VPC_BUY_MULTIPLE, --D17
               VPD.VPC_BUY_MULTIPLE, --D18
               NVL(TRIM(PRD.des_stl), ' '),
               ' ', --dimension 1
               ' ', --dimension 1
               CASE
                 WHEN PRD.COD_BIGTCK = 'BTA' THEN
                   'STOCK CD'
                 WHEN PRD.COD_BIGTCK = 'BTP' THEN
                   'STOCK PROVEEDOR'
                 WHEN PRD.COD_BIGTCK IS NULL THEN
                   'STOCK TIENDA'
                 ELSE
                   'NINGUNO'
               END
          FROM pmgdtlee DTL,
               pmghdree HDR,
               pmgvqtee VQT,
               tpprdmst PRD,
               curmstee MON,
               vpcprdee CPR,
               vpcprdee vpd,
               (select *
                  from WHSPRDEE
                 where org_lvl_child IN
                       (select param_value
                          from chlparam
                         where param_code = 'CENTRODIS')) wsh
         WHERE DTL.pmg_po_number = VQT.pmg_po_number(+)
           AND DTL.pmg_dtl_tech_key = VQT.pmg_dtl_tech_key(+)
           AND DECODE(VQT.prd_lvl_child,
                      NULL,
                      DTL.prd_lvl_child,
                      VQT.prd_lvl_child) = PRD.prd_lvl_child
           AND DTL.pmg_loc_curr = MON.curr_code
           AND PRD.PRD_LVL_CHILD = CPR.PRD_LVL_CHILD
           AND HDR.PMG_PO_NUMBER = DTL.PMG_PO_NUMBER
           AND DTL.VPC_PRD_TECH_KEY = CPR.VPC_PRD_TECH_KEY
           AND DTL.pmg_po_number = pPMG_PO_NUMBER
           AND DTL.VPC_PRD_TECH_KEY = VPD.VPC_PRD_TECH_KEY
           AND wsh.prd_lvl_child(+) = CPR.PRD_LVL_CHILD
         ORDER BY PRD.prd_lvl_child;

      insert into TMP_OC_B2B_XML_D23
        SELECT (select prd_lvl_number from prdmstee where prd_lvl_child = PSU.prd_lvl_child),
               SUC.org_lvl_number,
               NVL(POQ.pmg_sell_qty, 0)
          FROM (SELECT PRD.prd_lvl_child, ORG.org_lvl_child
                  FROM (SELECT DTL.pmg_po_number,
                               DECODE(PMG.prd_lvl_child,
                                      NULL,
                                      DTL.prd_lvl_child,
                                      PMG.prd_lvl_child) AS prd_lvl_child
                          FROM pmgdtlee DTL, pmgvqtee PMG
                         WHERE DTL.pmg_po_number = PMG.pmg_po_number(+)
                           AND DTL.pmg_dtl_tech_key = PMG.pmg_dtl_tech_key(+)
                           AND DTL.pmg_po_number = pPMG_PO_NUMBER) PRD,
                       (SELECT DISTINCT PDT.pmg_po_number,
                                        DECODE(PAL.org_lvl_child,
                                               NULL,
                                               PDT.org_lvl_child,
                                               PAL.org_lvl_child) AS org_lvl_child
                          FROM pmgdtlee PDT, pmgallee PAL
                         WHERE PDT.pmg_dtl_tech_key = PAL.pmg_dtl_tech_key(+)
                           AND PDT.pmg_po_number = pPMG_PO_NUMBER) ORG) PSU,
               (SELECT ORD.prd_lvl_child,
                       DECODE(ALE.org_lvl_child,
                              NULL,
                              ORD.org_lvl_child,
                              ALE.org_lvl_child) AS org_lvl_child,
                       DECODE(ALE.pmg_sell_qty,
                              NULL,
                              ORD.pmg_sell_qty,
                              ALE.pmg_sell_qty) AS pmg_sell_qty
                  FROM (SELECT DECODE(VQT.prd_lvl_child,
                                      NULL,
                                      DTE.prd_lvl_child,
                                      VQT.prd_lvl_child) AS prd_lvl_child,
                               DECODE(LOC.org_lvl_child,
                                      NULL,
                                      30,
                                      LOC.org_lvl_child) AS org_lvl_child,
                               DECODE(VQT.pmg_sell_qty,
                                      NULL,
                                      DTE.pmg_sell_qty,
                                      VQT.pmg_sell_qty) AS pmg_sell_qty,
                               DTE.pmg_dtl_tech_key
                          FROM pmgdtlee DTE, pmgvqtee VQT, pmglocee LOC
                         WHERE DTE.pmg_po_number = VQT.pmg_po_number(+)
                           AND DTE.pmg_dtl_tech_key = VQT.pmg_dtl_tech_key(+)
                           AND DTE.pmg_po_number = LOC.pmg_po_number(+)
                           AND LOC.pre_dist_po_loc(+) = 'T'
                           AND DTE.pmg_po_number = pPMG_PO_NUMBER) ORD,
                       pmgallee ALE
                 WHERE ORD.pmg_dtl_tech_key = ALE.pmg_dtl_tech_key(+)
                   AND ORD.prd_lvl_child = ALE.prd_lvl_child(+)) POQ,
               orgmstee SUC
         WHERE PSU.prd_lvl_child = POQ.prd_lvl_child--(+)
           AND PSU.org_lvl_child = POQ.org_lvl_child--(+)
           AND PSU.org_lvl_child = SUC.org_lvl_child
         ORDER BY PSU.prd_lvl_child, SUC.org_lvl_number;
     COMMIT;
   DBMS_OUTPUT.PUT_LINE('Finalizado');
END;

SELECT * FROM TMP_OC_B2B_XML_A1;
SELECT * FROM TMP_OC_B2B_XML_A2;
SELECT * FROM TMP_OC_B2B_XML_A3;
SELECT * FROM TMP_OC_B2B_XML_D23;

WITH home_delivery_data AS (
    SELECT XMLType(TRIM(REPLACE(DATA_HD, '<?xml version=''1.1'' encoding=''UTF-8''?>', ''))) AS XML_HD
    FROM TP_DAD_OC_CTRL
    WHERE NUM_OC = 10168199 --pPMG_PO_NUMBER
    AND DATA_HD IS NOT NULL
    AND LENGTH(DATA_HD) > 1
    FETCH FIRST 1 ROWS ONLY
)
SELECT XMLElement("Message",
                        XMLConcat((SELECT XMLElement("A0", 101681) --pPMG_PO_NUMBER
                                    FROM dual),
                                  --
                                  (SELECT XMLElement("A1",
                                                     XMLAgg(XMLElement("LS",
                                                                       XMLForest(L0,
                                                                                 L1,
                                                                                 L2))))
                                     FROM TMP_OC_B2B_XML_A1),
                                  --
                                  (SELECT XMLElement("A2",
                                                     XMLForest(E0),
                                                     XMLAgg(XMLElement("E1",
                                                                       XMLForest(B0,
                                                                                 B1))),
                                                     XMLAgg(XMLElement("E2",
                                                                       XMLForest(R0,
                                                                                 R1,
                                                                                 R2))),
                                                     XMLAgg(XMLElement("E3",
                                                                       XMLForest(P0,
                                                                                 P1,
                                                                                 P2,
                                                                                 P3))),
                                                     XMLAgg(XMLForest(E4,
                                                                      E5,
                                                                      E6,
                                                                      E7,
                                                                      E8,
                                                                      E9,
                                                                      E10,
                                                                      E11,
                                                                      E12,
                                                                      E13,
                                                                      E14,
                                                                      E15,
                                                                      E16,
                                                                      E17)))
                                     FROM TMP_OC_B2B_XML_A2
                                     GROUP BY E0),
                                  -- homeDelivery (15/01/2025 DonovanF)
                                    (CASE
                                        WHEN EXISTS (SELECT 1 FROM home_delivery_data)
                                        THEN
                                            XMLConcat(
                                                (SELECT XML_HD FROM home_delivery_data)
                                            )
                                        ELSE NULL
                                    END),
                                  (SELECT XMLElement("A3",
                                                     XMLAgg(XMLElement("DS",
                                                                       XMLForest(D0,
                                                                                 D1,
                                                                                 D2,
                                                                                 D3,
                                                                                 D4,
                                                                                 D5,
                                                                                 D6,
                                                                                 D7,
                                                                                 D8,
                                                                                 D9,
                                                                                 D10,
                                                                                 D11,
                                                                                 D12,
                                                                                 D13,
                                                                                 D14,
                                                                                 D15,
                                                                                 D16,
                                                                                 D17,
                                                                                 D18,
                                                                                 D19,
                                                                                 D20,
                                                                                 D21,
                                                                                 D22),
                                                                       (SELECT XMLElement("D23",
                                                                                          XMLAgg(XMLElement("KS",
                                                                                                            XMLForest(K0,
                                                                                                                      K1)))) AS D23
                                                                          FROM TMP_OC_B2B_XML_D23
                                                                         WHERE D23 = D0))))
                                     FROM TMP_OC_B2B_XML_A3
                                    WHERE A3 = 101681 ))) --pPMG_PO_NUMBER
        --INTO l_xml
        FROM DUAL;


select b.pmg_po_number || ':' || b.nombre_archivo from edsr.b2b_oc_envio b where b.fec_procesado is null;

