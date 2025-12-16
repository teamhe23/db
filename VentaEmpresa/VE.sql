/*
EDSR.TP_PKG_ARCHIVOS_BBR.sp_inserta_sol_oc
PASO: 101879
 */
 --TPI
SELECT VPC_APT_DESC, oc.* FROM EDSR.TPIMPOCC OC WHERE OC.PMG_PO_NUMBER  IN (123897);
--TPI_DETALLE
SELECT OC.FEC_CRE,oc.AUDIT_NUMBER_CAB, OC.* FROM EDSR.TPIMPOCD OC where FEC_CRE IS NOT NULL ORDER BY OC.FEC_CRE DESC;
SELECT * FROM EDSR.TPIMPOCD OC WHERE OC.AUDIT_NUMBER_CAB  IN (264032);
SELECT * FROM TPPRDMST WHERE PRD_LVL_NUMBER IN ('32045','32043','21555');
--DELETE TPIMPOCD WHERE AUDIT_NUMBER = 1737;

SELECT * FROM PRDMSTEE;
SELECT * FROM PRDMSTEE WHERE PRD_LVL_PARENT = 91967;
/*
 El PARENT: PADRE
 El CHILD: HIJO

 RECORDAR: PRDMSTEE => Los productos tienen 5 niveles (PRD_LVL_ID).
 El NIVEL maximo es 5, su PARENT es 0, ya que es el maximo nivel, es el PADRE de todos.
 Todos los niveles desde el 4 hasta el 1 son hijos
 El NIVEL 1 son los producto

 */
SELECT * FROM PRDMSTEE WHERE PRD_LVL_ID = 5;
SELECT * FROM PRDMSTEE WHERE PRD_LVL_ID = 4;
SELECT * FROM PRDMSTEE WHERE PRD_LVL_ID = 3;
SELECT * FROM PRDMSTEE WHERE PRD_LVL_ID = 2;
SELECT * FROM PRDMSTEE WHERE PRD_LVL_ID = 1;

SELECT PRD.PRD_NAME_FULL, PRD.PRD_LVL_ID, VPC.* FROM EPMM.VPCAPPEE VPC
    INNER JOIN PRDMSTEE PRD ON PRD.PRD_LVL_CHILD = VPC.PRD_LVL_CHILD
WHERE VPC.PRD_LVL_CHILD IN (91920,91982,92259,92055,92050)
;
SELECT * FROM EPMM.PRDPLVEE VE
    INNER JOIN EPMM.PRDPLVEE PRD ON PRD.PRD_LVL_PARENT = VE.P
WHERE PRD_LVL_CHILD IN (110880,120800,120802);
--CxP
SELECT * FROM EPMM.vpcaptee;
SELECT * FROM EPMM.vpcaptee where VPC_APT_DESC = 'CHQ/TRF 60';

SELECT   vpc_apt_key, prdplvee.prd_parent_id + 1 inh_id, vpcappee.*
 FROM EPMM.vpcappee, prdplvee
WHERE --vpcappee.vpc_tech_key = in_vpc_tech_key
 -- AND vpc_shp_point = v_vpc_shp_point AND
 --  prdplvee.prd_lvl_child = '110880' AND
   vpcappee.prd_lvl_child = prdplvee.prd_lvl_parent
;
--OC_HDR_LOAD_AUT
SELECT OC.modified_aut_on, OC.* FROM EDSR.OC_HDR_LOAD_AUT OC where modified_aut_on IS NOT NULL ORDER BY OC.modified_aut_on DESC;
SELECT OC.DOWNLOAD_DATE, OC.* FROM EDSR.LOADDTLOC OC where DOWNLOAD_DATE IS NOT NULL ORDER BY OC.DOWNLOAD_DATE DESC;

--Lista Pendientes
SELECT TPI.PMG_PO_NUMBER
FROM TPIMPOCC TPI
WHERE TPI.SISTEMA = 'TOC'
    AND TPI.DOWNLOAD_DATE IS NULL
    AND EXISTS (
       SELECT 1
         FROM OC_HDR_LOAD
        WHERE PMG_PO_NUMBER = TPI.PMG_PO_NUMBER
    );

--TPIMPOCC
SELECT OC.DOWNLOAD_DATE, OC.DOWNLOAD_DATE_1,VPC_APT_DESC, OC.THREAD_ID,SISTEMA,PMG_LC_NUMBER, OC.* FROM EDSR.TPIMPOCC OC
--UPDATE TPIMPOCC SET  DOWNLOAD_DATE = NULL
WHERE PMG_PO_NUMBER  IN (101962); --101956
--WHERE PMG_PO_NUMBER  IN (101879);
COMMIT;
--TPIMPOCD
SELECT PMG_SELL_QTY, oc.* FROM EDSR.TPIMPOCD OC WHERE OC.AUDIT_NUMBER_CAB  IN (264082);
SELECT  oc.* FROM EDSR.SDIPMGHDI OC WHERE OC.PMG_PO_NUMBER  IN (101956);
select * from DBA_OBJECTS where upper(OBJECT_NAME) like '%FU_GET_LAST_MOD_CP_ID%';
 SELECT FU_GET_LAST_MOD_CP_ID(32045,1793039804001) FROM DUAL;
-- BBR PENDIENTES
SELECT tran_type,
             vendor_number,
             pmg_type_name,
             org_lvl_number,
             dmt_code,
             pmg_exp_rct_date,
             pmg_buyer,
             pmg_allocator,
             bas_usr_name,
             pmg_cncl_by_date,
             pmg_ext_po_num,
             audit_number,
             pmg_po_number,
             pmg_percent,
             vpc_apt_desc,
             vpc_flg,
             pmg_lc_number,
             -- <00009>
             flg_req_ins,
             -- </00009>
             -- <000011>
             pmg_shipping_date,
             id_puerto,
             id_incoterm
             -- </00011>
        FROM tpimpocc oc
       WHERE oc.download_date IS NULL
            --AND oc.sistema = 'SDD'
         AND oc.sistema = 'TOC' --'SDD';
         AND (oc.pmg_po_number = 101956);


SELECT CASE WHEN TRUNC(1.0) != 1.0 THEN 1 ELSE 0 END CASE FROM DUAL;
--CASE PACK: Multiplos 21552
SELECT PRD_LVL_NUMBER, prd.* FROM PRDMSTEE prd WHERE PRD_LVL_NUMBER IN ('32045','32043'); -- CHILD: 120802

    SELECT   /*+ ordered use_nl(prdmstee) index(sdipmgdti sdipmgdtii2)
           index(prdmstee  prdmsteei2) */
                  NVL (prdmstee.prd_lvl_child, 0) prd_lvl_child,
                  -- Log ID 19228
                  NVL (prdmstee.prd_lvl_id, 1) prd_lvl_id, sdipmgdti.*,
                  sdipmgdti.ROWID                                      --25726
             FROM sdipmgdti, prdmstee
            WHERE sdipmgdti.pmg_po_number = 101955
           --   AND sdipmgdti.download_date_1 IS NULL               -- Log 12893
            --  AND NVL (sdipmgdti.tran_type, 'F') != 'D' --c_del_tran
            --  AND sdipmgdti.prd_lvl_number = prdmstee.prd_lvl_number(+)
           --   AND (   prdmstee.prd_lvl_id IS NULL OR prdmstee.prd_lvl_id BETWEEN 0 AND 1 )
         ORDER BY pmg_line_number, pmg_seq_num, 2 DESC;

--Vendor
SELECT vendor_number,vpc_tech_key, cntry_lvl_child,
     curr_code, NVL (vpc_divert_flag, 'F'),
     vpc_prdvpc_flag,pmg_type_code
--INTO v_vpc_tech_key, v_cntry_lvl_child,v_vend_curr_code, v_vpc_divert_flag,v_vpc_prdvpc_flag, vpc_pmg_type_code
FROM vpcmstee
WHERE vendor_number IN ('1790004724001','1793039804001');
--P_VPC_PRD_TECH_KEY
    SELECT NVL(MAX(VP.VPC_PRD_TECH_KEY), 0)
  --    INTO P_VPC_PRD_TECH_KEY
      FROM VPCPRDEE VP
     INNER JOIN PRDMSTEE P
        ON VP.PRD_LVL_CHILD = P.PRD_LVL_CHILD
     INNER JOIN VPCMSTEE V
        ON VP.VPC_TECH_KEY = V.VPC_TECH_KEY
     WHERE VP.VPC_PRIMARY_FLAG = 'T'
       AND P.PRD_LVL_NUMBER = '32045'
       AND V.VENDOR_NUMBER = '1793039804001';

--P_VPC_CASE_PACK_ID
SELECT VP.VPC_CASE_PACK_ID
FROM VPCPRDEE VP
WHERE VP.VPC_PRD_TECH_KEY = 133928;

SELECT sll_units_per_inner,
       vpc_case_pack_id,
       vpc_tech_key,
       prd_lvl_child, vpc.*
FROM vpcprdee vpc
WHERE vpc_tech_key = 14467 AND  --14413 --v_vpc_tech_key: Codigo del Proveedor
     prd_lvl_child = 120802
    AND vpc_case_pack_id = '125888'-- dtl.vpc_case_pack_id
;
/*
 PRD_LVL_CHILD
120800
120802

 */

SELECT * FROM EPMM.sdipmghdi H ORDER BY PMG_PO_NUMBER DESC;
SELECT * FROM EPMM.sdipmghdi H WHERE H.PMG_PO_NUMBER = 101953;
--errores
SELECT DOWNLOAD_DATE_1,error_code, rej.* FROM EPMM.SDIHDIREJ rej WHERE rej.PMG_PO_NUMBER = 101955;
SELECT rej_code, rej.* FROM EPMM.SDIREJCD rej WHERE rej.rej_code = 715;

select s.rej_code, s.rej_code || ' - ' || s.rej_desc
from SDIHDIREJ h, SDIREJCD s
where (h.error_code = s.rej_code)
    and h.pmg_po_number = 101955
    and rownum = 1
    and h.error_code is not null;

SELECT * FROM EPMM.SDIHDIREJ H WHERE H.PMG_PO_NUMBER = 101953;
SELECT * FROM EPMM.SDIREJCD WHERE REJ_CODE = 456;

 SELECT   vpc_apt_key, 1 inh_id
 FROM epmm.vpcappee
WHERE vpcappee.vpc_tech_key = in_vpc_tech_key
  AND vpc_shp_point = v_vpc_shp_point
  AND prd_lvl_child = var_prd_lvl_child

SELECT EPMM.vpcappget ( '14467', --v_vpc_tech_key,
           0, --v_vpc_shp_point,
           120802 --v_prd_lvl_child
          ) FROM DUAL;

--vpcappget
SELECT   vpc_apt_key, 1 inh_id
FROM EPMM.vpcappee
WHERE vpcappee.vpc_tech_key = '14467' -- in_vpc_tech_key
  AND vpc_shp_point = 0 --v_vpc_shp_point
  AND prd_lvl_child = 120802 -- var_prd_lvl_child
UNION
SELECT   vpc_apt_key, prdplvee.prd_parent_id + 1 inh_id
 FROM EPMM.vpcappee, prdplvee
WHERE vpcappee.vpc_tech_key = '14467' -- in_vpc_tech_key
  AND vpc_shp_point = 0 --v_vpc_shp_point
  AND prdplvee.prd_lvl_child = 120802 -- var_prd_lvl_child
  AND vpcappee.prd_lvl_child = prdplvee.prd_lvl_parent
ORDER BY 2;

--INTO VNU_CODE_ERROR, VVC_MENS_ERROR
--Error
select s.rej_code, s.rej_code || ' - ' || s.rej_desc
from epmm.SDIHDIREJ h, epmm.sdirejcd s
where (h.error_code = s.rej_code)
 and h.pmg_po_number = 101953
 and rownum = 1
 and h.error_code is not null;

