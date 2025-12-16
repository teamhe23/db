
BEGIN
    dataman123('PMG','HDR','SDI');
    dataman123('PMG','DTL','SDI');
    dataman123('PMG','ALL','SDI');
END;

SELECT * FROM ORGMSTEE WHERE ORG_LVL_NUMBER IN (101,102,851);
SELECT NVL2((SELECT V.VPC_TECH_KEY FROM edsr.VPCMSTEE V WHERE TRIM(V.VENDOR_NUMBER) = TRIM('0190061264001')
             ),
             'T',
             'F')
FROM DUAL;
/*
 --------------------------------------------------------
                    TP_DAD_OC_CTRL
 --------------------------------------------------------
 */
SELECT * FROM TP_DAD_OC_LOG WHERE NUM_DOC ='1300500900-1';
SELECT * FROM TP_DAD_OC_CTRL WHERE NUM_DOC ='1300500900-1';
SELECT * FROM TP_DAD_OC_CTRL order by FEC_CRE desc fetch first 20 rows only;
SELECT NUM_DOC,NUM_OC, ESTADO,FEC_CRE,FEC_MOD, MESSAGE FROM TP_DAD_OC_CTRL order by FEC_CRE desc fetch first 200 rows only;

ALTER TABLE TP_DAD_OC_CTRL
ADD MESSAGE VARCHAR2(4000);

select * from EDSR.TP_DAD_OC_CTRL order by fec_cre desc fetch first 10 rows only;
select NUM_DOC, NUM_OC, ESTADO, FEC_CRE, FEC_MOD, PMG_EXT_PO_NUM from EDSR.TP_DAD_OC_CTRL order by fec_cre desc fetch first 20 rows only;

/*
 --------------------------------------------------------
                    TPIMPOCC
 --------------------------------------------------------
 */
SELECT IMP.FEC_CRE,IMP.PMG_PO_NUMBER, IMP.PMG_EXT_PO_NUM
     ,IMP.* FROM tpimpocc IMP
WHERE IMP.FEC_CRE IS NOT NULL
ORDER BY IMP.FEC_CRE DESC FETCH FIRST 30 ROWS ONLY;

/*
 101572 => Tiene costo 445.31
 */
 /*
 --------------------------------------------------------
                    PMGHDREE y PMGDTLEE
 --------------------------------------------------------
 */
SELECT * FROM PMGSTSCD;
SELECT * FROM PMGHDREE ORDER BY PMG_CANCEL_DATE DESC FETCH FIRST 10 ROWS ONLY;
SELECT * FROM PMGHDREE WHERE PMG_STAT_CODE = 7 ORDER BY PMG_CANCEL_DATE DESC FETCH FIRST 10 ROWS ONLY;
 SELECT * FROM PMGHDREE WHERE PMG_EXT_PO_NUM =  '2200000021359-1';
SELECT PMG_PO_NUMBER,PMG_EFFECT_DATE,PMG_ENTRY_DATE,PMG_RELEASE_DATE, PMG.PMG_EXT_PO_NUM,PMG.PRIM_ORG_LVL_NUMBER,PMG.PMG_TOT_PO_COST, PMG.* FROM PMGHDREE PMG
WHERE PMG_PO_NUMBER IN (101777,101785);
SELECT DTL.PMG_PO_NUMBER, PRD.PRD_LVL_NUMBER, DTL.PMG_SELL_COST, DTL.PMG_PACK_COST,DTL.PMG_TOT_DTL_COST, DTL.*
FROM PMGDTLEE DTL INNER JOIN PRDMSTEE PRD ON PRD.PRD_LVL_CHILD = DTL.PRD_LVL_CHILD
WHERE PMG_PO_NUMBER IN (101785);

/*
 --------------------------------------------------------
                    SDIPMGHDE
 --------------------------------------------------------
 Generación XML:
 DOWNLOAD_DATE   => Si es nuevo la OC
 DOWNLOAD_DATE_1 => Si se actualiza la OC
 --------------------------------------------------------
 */
SELECT PMG.PMG_EXT_PO_NUM,PMG.DOWNLOAD_DATE, PMG.DOWNLOAD_DATE_1,PRV.VENDOR_NUMBER,  PMG.*
FROM SDIPMGHDE PMG
    INNER JOIN VPCMSTEE PRV ON PRV.VENDOR_NUMBER = PMG.VENDOR_NUMBER
WHERE PMG_PO_NUMBER IN (101785);

/*
 --------------------------------------------------------
                    B2B_OC_ENVIO
 --------------------------------------------------------
 INSERT   => Si es nuevo la OC
 UPDATE   => Si se actualiza la OC
 KSH:
 Se Generan XML: /prochp/interfaces/b2b/export/out/log

 --------------------------------------------------------
 */
select * from B2B_OC_ENVIO ORDER BY FEC_REG DESC FETCH FIRST 10 ROWS ONLY;



select
--estado, num_oc
count(*), min(c.estado), min(c.num_oc)
--into VNU_CONT, vvc_cod_est, vnu_num_oc
from EDSR.TP_DAD_OC_CTRL c
where c.num_doc = '1300500901-1';

SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%SP_GRABAR_OCC%';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%TP_PKG_DESPACHO%';

SELECT c.constraint_name, c.table_name, c.*
FROM all_cons_columns c
WHERE c.constraint_name = 'SDIDTIREJP1';

SELECT * FROM SDIDTIREJ;

SELECT sequence_name, last_number FROM user_sequences;

SELECT (SEQ.LAST_NUMBER - 1) AS SEQUENCE_NOW, SEQ.LAST_NUMBER  , SEQ.* FROM ALL_SEQUENCES SEQ WHERE SEQUENCE_NAME LIKE '%SESSION_NUMBER%';
SELECT (SEQ.LAST_NUMBER - 1) AS SEQUENCE_NOW, SEQ.LAST_NUMBER  , SEQ.* FROM ALL_SEQUENCES SEQ WHERE SEQUENCE_NAME LIKE '%TRANS_SESSION%';


SELECT MAX(AUDIT_NUMBER)
FROM SDIDTIREJ WHERE AUDIT_NUMBER = 58241203;

update EDSR.tp_dad_oc_ctrl s
    set s.estado = 'E', s.fec_mod=sysdate
where s.num_doc = '2200000021632-1';

SELECT * FROM tp_dad_oc_ctrl s where s.num_doc = '2200000021632-1';
SELECT * FROM tp_dad_oc_ctrl s where s.num_doc = '220005601-1';
SELECT * FROM tp_dad_oc_ctrl s order by FEC_CRE desc ;
SELECT * FROM EPMM.PMGADDIM2  ;
SELECT * FROM sqlerree ORDER BY ERROR_DATE DESC ;



 /*
 --------------------------------------------------------
                    PROVEEDOR y SKUs relacionados
 --------------------------------------------------------
 */

SELECT * FROM VPCMSTEE WHERE VENDOR_NAME LIKE '%INDURAMA%'; --VENDOR_NUMBER => 0190061264001
SELECT DES_PRV, PRD.* FROM TPPRDMST PRD
WHERE COD_PRV LIKE '%0190061264001%';
