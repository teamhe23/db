/*************************************************************
          DEBUG EDSR.PKG_DAD_API.SP_RCV_OC
	Seguimiento: recepciones de mercaderia desde el DAD
**************************************************************/

--ESTADOS
--3:Aprobado | 4:On Order | 5:Recibo Parcial | 6:Recibo Completo| 7:Cancel
SELECT * FROM PMGSTSCD;

select oc.PMG_EFFECT_DATE,OC.PMG_PO_NUMBER,OC.PMG_STAT_CODE, OC.PMG_CANCEL_DATE,OC.PMG_EXT_PO_NUM, oc.*
from edsr.pmghdree oc
WHERE OC.PMG_PO_NUMBER IN (130935,131534)
order by oc.PMG_EFFECT_DATE DESC;

--Tiene que estar en ON ORDER (6)
 select * from pmghdree
 where pmg_po_number = 130935;
 
 SELECT * FROM EDSR.HP_RCV_OC_DAD_HDR
 where pmg_po_number IN (130935,131534) 
 ORDER BY CREATE_DATE desc;
 
 --BUSCAMOS ERRORES:
  SELECT * FROM sqlerree 
  WHERE procedure_name LIKE '%RCVADDIM%' --RCVADDIM
  ORDER BY error_date DESC;
 
 --SINO HAY ERRORES BUSCAMOS LA RECEPCIÓN EN:
SELECT * FROM edsr.TPIMPRCV
WHERE PMG_PO_NUMBER = 133378
ORDER BY DATE_CREATED DESC;