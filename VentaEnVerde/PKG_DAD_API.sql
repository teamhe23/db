select oc.PMG_EFFECT_DATE, oc.*
from pmghdree oc
order by oc.PMG_EFFECT_DATE DESC;

/*
  Todos los productos que se cargan en el B2B Logistico son LongTail
  Todos Tendran la descripcion de DISPONIBLE PROVEEDOR?
  Hay en PRD 1795 LongTail con DISPONIBLE PROVEEDOR
  Hay en PRD 1763 LongTail con DISPONIBLE PROVEEDOR

 */

SELECT PRD.DES_BIGTCK,PRD.ATR_LONG_TAIL, PRD.* FROM TPPRDMST PRD where PRD_LVL_NUMBER in ('21555','21563','21568','21576','21577','21575','21574','21578','21579','21570','21571','21572','21573');
SELECT distinct ATR_LONG_TAIL FROM TPPRDMST PRD
--SELECT  COUNT(1) FROM TPPRDMST PRD
--WHERE PRD.ATR_LONG_TAIL = 'X';
WHERE PRD.DES_BIGTCK = 'DISPONIBLE PROVEEDOR';


   select
     --  count(*), min(c.estado), min(c.num_oc)
    c.estado, c.num_oc, c.FEC_MOD, c.FEC_CRE,C.*
      from EDSR.TP_DAD_OC_CTRL c
     where c.NUM_DOC = '452921621';

--VTB_DATA    TP_PKG_INTERFAZ_DES_DOM.TBL_TYPDATOSOC;
SELECT * FROM SDIPMGHDI;

--TP_PKG_INTERFAZ_DES_DOM.SP_GRABAR_OCC
--Tabla Usuarios
 select trim(bas_user_name), bas.* from basusree bas;
 select IM.FEC_CRE,IM.DOWNLOAD_DATE_1, IM.PMG_PO_NUMBER, im.* from tpimpocc im WHERE IM.FEC_CRE IS NOT NULL ORDER BY IM.FEC_CRE DESC;

/*****************************************************
          DEBUG EDSR.PKG_DAD_API.SP_ADD_OC
                    Seguimiento
******************************************************/

declare
  -- Non-scalar parameters require additional processing
pinvc_sku edsr.tbl_ocdet_sku := edsr.tbl_ocdet_sku();
pinnu_qty edsr.tbl_ocdet_qty := edsr.tbl_ocdet_qty();
begin
  pinvc_sku.EXTEND(1); -- Ajustar el tamaño de la colección según la cantidad de SKUs
  pinnu_qty.EXTEND(1);

  -- Asignar valores a las colecciones
  pinvc_sku(1) := '21592';
  pinnu_qty(1) := 5;
  -- Call the procedure
  edsr.PKG_DAD_API.SP_ADD_OC(pinvc_cod_prv => :pinvc_cod_prv,
                             pinnu_cod_tda => :pinnu_cod_tda,
                             pinvc_fec_entrega => :pinvc_fec_entrega,
                             pinvc_fec_canc => :pinvc_fec_canc,
                             pinvc_num_doc => :pinvc_num_doc,
                             pinvc_sku => pinvc_sku,
                             pinnu_qty => pinnu_qty,
                             PINVC_HD => :PINVC_HD,
                             POUCU_DATA => :POUCU_DATA);
end;


SELECT * FROM TP_DAD_OC_LOG ORDER BY FEC_CRE DESC;
SELECT * FROM TP_DAD_OC_LOG WHERE NUM_DOC = '1000103';

--Valida si existe, actualiza sino inserta
SELECT ESTADO, NUM_DOC FROM TP_DAD_OC_CTRL WHERE NUM_DOC = '1000101';

--Valida el producto
-- Si tiene case pack
-- etc

--FOR LOOP => VTB_DATA DE TIPO TABLE TYPDATOSOC QUE ES UN RECORD personalizado sacado de la tablas intermedias SDIPMGHDI y SDIPMGDTI
--Tablas intermedias para la creacion de OC me parece que es xd
-- Siendo el campo C_ORG_LVL_NUMBER_DET para la Sucursal destino para predistribuidas
SELECT TRAN_TYPE,VENDOR_NUMBER,PMG_TYPE_NAME,ORG_LVL_NUMBER,DMT_CODE,PMG_EXP_RCT_DATE,PMG_BUYER,PMG_ALLOCATOR,BAS_USR_NAME,PMG_CNCL_BY_DATE,JDA_ORIGIN,PMG_EXT_PO_NUM,THREAD_ID,ORG_LVL_NUMBER
FROM SDIPMGHDI;

SELECT PMG_SEQ_NUM,PMG_LINE_NUMBER,PRD_LVL_NUMBER,PMG_DTL_TYPE,PMG_SELL_QTY,PMG_DIST_SELL_QTY
FROM SDIPMGDTI;

--Valida si el proveedor existe entonces ejecuta: TP_PKG_INTERFAZ_DES_DOM.SP_GRABAR_OCC(VTB_DATA, RETORNO1, RETORNO2)
/*
Obtiene el usuario que autoriza OCs =>  JDARPL
*/
select * from basusree
where trim(usr_signon) = (select trim(param_value) from chlparam where param_code = 'USRAUTHOC');

/*
Sino tiene fecha de entrega obtiene la fecha actual y Fecha cancelacion = fechaActual + 7 dias

Se insterta en TPIMPOCC (ID: edsr.Tp_Seq_Audit_Number.Nextval)
Se Crea el numero de OC: V_PMG_PO_NUMBER => edsr.PMG_PO_NUMBER.Nextval


*/


--------------------------------------------------------------------------------------------------
--TP_PKG_INTERFAZ_DES_DOM.SP_GRABAR_OCC(VTB_DATA, RETORNO1, RETORNO2)
--------------------------------------------------------------------------------------------------

SELECT IMP.FEC_CRE, IMP.* FROM TPIMPOCC IMP ORDER BY IMP.FEC_CRE DESC; --(PMG_PO_NUMBER,VENDOR_NUMBER)
SELECT AUDIT_NUMBER,SISTEMA,TRAN_TYPE,PMG_PO_NUMBER,VENDOR_NUMBER,PMG_TYPE_NAME,
       ORG_LVL_NUMBER,DMT_CODE,PMG_EXP_RCT_DATE,PMG_BUYER,PMG_ALLOCATOR,BAS_USR_NAME,PMG_CNCL_BY_DATE,JDA_ORIGIN,
       PMG_EXT_PO_NUM,THREAD_ID,FEC_CRE,VPC_FLG
FROM TPIMPOCC IMP WHERE PMG_PO_NUMBER IN (4545); --(PMG_PO_NUMBER,VENDOR_NUMBER)

--Obtiene valores de la tbl TPPRDMST
SELECT E.PRD_LVL_ID, E.COD_STL FROM TPPRDMST E WHERE E.PRD_LVL_NUMBER = '21564';

SELECT IMPOCD.FEC_CRE, IMPOCD.* FROM TPIMPOCD IMPOCD WHERE IMPOCD.FEC_CRE IS NOT NULL ORDER BY IMPOCD.FEC_CRE DESC  ;

-- Tabla sqlerree => Inserta errores:
SELECT * FROM sqlerree WHERE procedure_name = 'TP_PKG_INTERFAZ_DES_DOM.SP_GRABAR_OCC';
--------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------
--TP_PKG_INTERFAZ_DES_DOM.SP_GRABAR_OCC(VTB_DATA, RETORNO1, RETORNO2)
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------

-- Consultar OC

select oc.PMG_EFFECT_DATE,OC.PMG_PO_NUMBER,OC.PMG_EXT_PO_NUM, oc.* from edsr.pmghdree oc order by oc.PMG_EFFECT_DATE DESC;


select oc.PMG_EFFECT_DATE,OC.PMG_PO_NUMBER,OC.PMG_EXT_PO_NUM, oc.* from edsr.pmghdree oc
WHERE OC.PMG_PO_NUMBER =101476;

select DTL.PMG_PO_NUMBER, PRD.PRD_LVL_NUMBER,DTL.PMG_DTL_TECH_KEY, DTL.PMG_SELL_QTY,DTL.PMG_DTL_TECH_KEY,  dtl.*
from edsr.PMGDTLEE DTL
    INNER JOIN PRDMSTEE PRD ON PRD.PRD_LVL_CHILD = DTL.PRD_LVL_CHILD
WHERE DTL.PMG_PO_NUMBER = 101476;




/*****************************************************
          DEBUG EDSR.PKG_DAD_API.SP_RCV_OC
                    Seguimiento
******************************************************/

--Log de errores
SELECT * FROM HP_RCV_OC_DAD_HDR ;

/*
TP_PKG_DES_DOM.SP_GRABAR_RCV() :
    1.Recorre todos los SKUs RECIBIDOS para grabar en TPIMPRCV
 */

SELECT * FROM TPIMPRCV ORDER BY DATE_CREATED DESC;
--Guarda todas las recepciones. Validación download_date
SELECT IMP.download_date, IMP.* FROM TPIMPRCV IMP WHERE PMG_PO_NUMBER = 4564;
SELECT IMP.download_date, IMP.* FROM TPIMPRCV IMP
WHERE PMG_PO_NUMBER = 101476 AND PMG_DTL_TECH_KEY = 8482641;

/*---------------------------------------
TP_PKG_ARCHIVOS_BBR.sp_inserta_sol_rcv
 ---------------------------------------*/
 --se usa como tabla temporal y se guarda var_rcv_batch_id
 SELECT * FROM TP_IMP_RCV_OC RCV ORDER BY pmg_po_number DESC;

--Luego se ejecuta el EDSR.TP_IMP_RCV_OC_PROC('SDD')
-- Se OBTIENE var_thread_id = TP_SEQ_THREAD_ID.NEXTVAL
  select TP_SEQ_THREAD_ID.NEXTVAL from dual;

 --Validar al final en SDIRCVHDI
SELECT RCV.tech_key,
        RCV.rcv_session_id,
        RCV.thread_id -- var_thread_id
      ,RCV.tran_type,RCV.org_lvl_number,RCV.rcv_date_ses_opn,RCV.rcv_session_sts,RCV.download_date_1,RCV.download_date_2,RCV.orig_pos_tech_key,RCV.*
FROM SDIRCVHDI RCV ORDER BY RCV.tech_key DESC;

SELECT * FROM hprcvdetr  WHERE rcv_session_id = 789456;

-- DETALLE DE SKUS recibidos
SELECT * FROM SDIRCVDTI  WHERE pmg_po_number = 101476;
SELECT * FROM SDIRCVDTI  WHERE pmg_po_number = 101476 AND tech_key = 45656;

-- Finalmente se ejecuta, HACE TODA LA MAGIA
---------------------------------------------
-- RCVADDIM(var_thread_id)
---------------------------------------------

--Finalmente validar si hay error:
SELECT error_number, procedure_name, error_date, sql_error, sql_text
FROM SQLERREE WHERE procedure_name = 'IMP_RCV_OC' ORDER BY error_number DESC


/*****************************************************
          DEBUG EDSR.PKG_DAD_API.SP_RCV_OC
                    Seguimiento
******************************************************/


select oc.PMG_EFFECT_DATE,OC.PMG_PO_NUMBER,OC.PMG_STAT_CODE, OC.PMG_EXT_PO_NUM, oc.* from edsr.pmghdree oc order by oc.PMG_EFFECT_DATE DESC;

SELECT * FROM PMGSTSCD;

select oc.PMG_EFFECT_DATE,OC.PMG_PO_NUMBER,OC.PMG_STAT_CODE, OC.PMG_CANCEL_DATE,OC.PMG_EXT_PO_NUM, oc.* from edsr.pmghdree oc
WHERE OC.PMG_PO_NUMBER IN (101477,101475);

--Tiene que estar en ON ORDER (6)
