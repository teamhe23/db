SELECT * FROM PRDMSTEE WHERE PRD_LVL_NUMBER = '18074'; --107675 DAÑADO
SELECT * FROM PRDMSTEE WHERE PRD_LVL_NUMBER = '37089'; --125675 SANO

SELECT * FROM sqlerree
WHERE procedure_name LIKE '%INV%'
    --AND TRUNC(error_date) = TO_DATE('2024-12-17','YYYY-MM-DD')
ORDER BY ERROR_DATE DESC
;
--INV
SELECT * FROM WMS_MODELO_REQUEST WHERE IDENTIFICADOR = '358486798';
SELECT INV.DOWNLOAD_DATE_1, INV.ERR_CODE, INV.CREATE_DATE_INT, INV.* FROM WMS_INV_HISTORY INV WHERE GROUP_NBR IN (358486798,358486921,358487012,358487019);

SELECT
i.rowid id_reg,
             i.group_nbr,
             i.seq_nbr,
             i.company_code,
             i.activity_code,
             i.reason_code,
             i.ref_value_1,
             i.ref_value_2,
             i.item_part_a prd_lvl_number,
             nvl(nvl(i.adj_qty, i.orig_qty),0) adj_qty,
             i.order_nbr,
             i.create_date  trans_date,
             i.shipment_nbr,
             i.lpn_nbr,
             i.lock_code,
             i.facility_code
FROM WMS_INV_HISTORY I
WHERE GROUP_NBR IN (358453042);
--WHERE GROUP_NBR IN (358486798,358486921,358487012,358487019);
/*
851 = 406 PARAMETROS    (IND_REQ_RCV => 90 T,316 F)
101 = 28 PARAMETROS
102 = 28 PARAMETROS POR INSERTAR xd
*/
SELECT * FROM WMS_ACTIVITY_CODE WHERE ACTIVITY_CODE IN ('23','25','51');
SELECT * FROM WMS_MAPEO_MOV_INV;
SELECT COUNT(*) FROM WMS_MAPEO_MOV_INV WHERE FACILITY_CODE IN ('101') and IND_REQ_RCV = 'T';
SELECT distinct SUC_INV FROM WMS_MAPEO_MOV_INV WHERE FACILITY_CODE IN ('101') ;
SELECT * FROM WMS_MAPEO_MOV_INV WHERE FACILITY_CODE IN ('851') ;
SELECT * FROM WMS_MAPEO_MOV_INV WHERE FACILITY_CODE IN ('101') ;
SELECT * FROM WMS_MAPEO_MOV_INV WHERE FACILITY_CODE IN ('102') ;
SELECT * FROM WMS_MAPEO_MOV_INV WHERE FACILITY_CODE IN ('101') AND ACTIVITY_CODE = '25';
SELECT * FROM WMS_MAPEO_MOV_INV WHERE FACILITY_CODE IN ('102') AND ACTIVITY_CODE = '25';

SELECT m.ind_efecto,
              m.cod_maestro,
              m.cod_detalle,
              m.suc_inv,
              m.ind_req_rcv,
              m.ind_sgn_wms FROM WMS_MAPEO_MOV_INV m WHERE FACILITY_CODE IN ('101');
SELECT * FROM WMS_MAPEO_MOV_INV WHERE FACILITY_CODE IN ('102');

-- Se usa esta Secuencia para crear una session transferencia. => EDSR.trans_session.NEXTVAL
SELECT (SEQ.LAST_NUMBER - 1) AS SEQUENCE_NOW, SEQ.LAST_NUMBER  , SEQ.* FROM dba_SEQUENCES SEQ WHERE SEQUENCE_NAME LIKE '%TRANS%SESSION%';

/*
Tabla de configuracion de Transacciones INVTRDEE
inv_mrpt_code inv_drpt_code  INV_DRPT_DESC
    TR	         20	          Salidas Disp
    TR	         30	          Entradas No Disp
*/
select * from INVTRDEE WHERE INV_MRPT_CODE = 'TR' AND INV_DRPT_CODE IN (30,20);

--Tabla Intermedia, siempre vacia
select * from INVTRNEE ORDER BY TRANS_SESSION DESC;

/*
Luego se ejecuta el insert edsr.invtrnee por VSESION generado por TRANS_SESSION.NEXTVAL, que a la fecha la veo por 58627694
----------------------------------------------------------------
            INVTRNPRC(VSESION, 'F');
----------------------------------------------------------------
Este proc al parecer dispara a las tabla correspondientes y deletea el invtrnee
probablemente mueve el INVBALEE
----------------------------------------------------------------
*/
-- En esta tabla se registran los errores que se hayan generado con una transferencia
select count(*) from INVREJEE ORDER BY TRANS_SESSION DESC;

-- Si falla a nivel de transaccion revisar la tabla SQLERREE
select * from SQLERREE WHERE procedure_name = 'INV_HIST.SP_PROCESO_TIENDA' ORDER BY error_date DESC;

-- En esta tabla se registran WMS_INV_HISTORY las transacciones con la transferencia siempre!
-- Siempre consultar esta tabla para ver que paso con una transferencia las columnas ERR_CODE y DOWNLOAD_DATE_1
-- Usa como ID al ROWID (Es la clave por cada registro o fila en una tabla (Que se crea IMPLICITO DE ORACLE))

select rowid, INV.ERR_CODE, INV.DOWNLOAD_DATE_1, INV.* from WMS_INV_HISTORY INV where rowid = 'AAAeK2ADYAABxQFAAN';

/*
    En esta tabla, TIENE COMO ACTIVITY_CODE DOS VALORES 12 y 27 NO SE QUE ES PERO VEO DOS REGISTROS XD
    COMPANY_CODE	ACTIVITY_CODE
       HESA	            12
       HESA	            27
 */
select * from wms_pikexp_mov_inv;






/*
23	Lock Container - After ASN Verification
25	Unlock Container - After ASN Verification
51	Inventory Movement

 */
/*
 358486798|2|102|HESA|23|NR|PP|LPN10200019677||18074|18074|18074||||||KIT COCINA MARIANA NUEZ/NEGRO 1PTA 3CAJ 120cm||||0|||0||1||||||OLD||NEW|PP|MNF||BAT||EXP||20241217000000||||0|||||||0|RF_CREAR LPN|rf.inbound.cwrfcreatelpn|TYP||SLN||LSN||RAL||FCN|UIO GRANADOS|PAS|No|CAS|No|||||20241217120032|||||||||GMR|No|||TRA||UOL|Yes|||||TRT||WOD||
358486921|1|102|HESA|25||PP|LPN10200017403||11014|11014|11014||||||SANITARIO 2 PIEZAS 2018 WASHDOWN BLANCO ORANGE||||0|||0||1||||||OLD|PP|NEW||MNF||BAT||EXP||20241217000000||||0|||||||0|RF_ALMACENAR|rf.inbound.cwrfputaway|TYP||SLN||LSN||RAL||FCN|UIO GRANADOS|PAS|No|CAS|Yes|||||20241217120053|||||||||GMR|No|||TRA||UOL|Removed|||||TRT||WOD||
358486921|2|102|HESA|51|||LPN10200017403||11014|11014|11014||||||SANITARIO 2 PIEZAS 2018 WASHDOWN BLANCO ORANGE||||0|||0||1||||||PLT||POS||||||||20241217000000||||0|||||||0|RF_ALMACENAR|rf.inbound.cwrfputaway|||||||||||||||||||20241217120057|||||||||||||||||||||||||ALM-001-015-001
358487012|1|102|HESA|25||PP|LPN10200019678||18074|18074|18074||||||KIT COCINA MARIANA NUEZ/NEGRO 1PTA 3CAJ 120cm||||0|||0||1||||||OLD|PP|NEW||MNF||BAT||EXP||20241217000000||||0|||||||0|RF_ALMACENAR|rf.inbound.cwrfputaway|TYP||SLN||LSN||RAL||FCN|UIO GRANADOS|PAS|No|CAS|Yes|||||20241217120134|||||||||GMR|No|||TRA||UOL|Removed|||||TRT||WOD||
358487012|2|102|HESA|51|||LPN10200019678||18074|18074|18074||||||KIT COCINA MARIANA NUEZ/NEGRO 1PTA 3CAJ 120cm||||0|||0||1||||||PLT||POS||||||||20241217000000||||0|||||||0|RF_ALMACENAR|rf.inbound.cwrfputaway|||||||||||||||||||20241217120134|||||||||||||||||||||||||ALM-001-008-001
358487019|1|102|HESA|25||PP|LPN10200019677||18074|18074|18074||||||KIT COCINA MARIANA NUEZ/NEGRO 1PTA 3CAJ 120cm||||0|||0||1||||||OLD|PP|NEW||MNF||BAT||EXP||20241217000000||||0|||||||0|RF_ALMACENAR|rf.inbound.cwrfputaway|TYP||SLN||LSN||RAL||FCN|UIO GRANADOS|PAS|No|CAS|Yes|||||20241217120147|||||||||GMR|No|||TRA||UOL|Removed|||||TRT||WOD||
358487019|2|102|HESA|51|||LPN10200019677||18074|18074|18074||||||KIT COCINA MARIANA NUEZ/NEGRO 1PTA 3CAJ 120cm||||0|||0||1||||||PLT||POS||||||||20241217000000||||0|||||||0|RF_ALMACENAR|rf.inbound.cwrfputaway|||||||||||||||||||20241217120147|||||||||||||||||||||||||ALM-001-008-001

 */

SELECT INV.INV_TYPE_CODE,INV.ON_HAND_QTY ,INV.* FROM INVBALEE INV WHERE PRD_LVL_CHILD IN ('107675');
SELECT INV.INV_TYPE_CODE,INV.ON_HAND_QTY ,INV.* FROM INVBALEE INV WHERE PRD_LVL_CHILD IN ('125675');
SELECT unistr('\0030\0034') STOCK_NODIS,unistr('\0030\0031') STOCK_DIS FROM DUAL;

SELECT S.DESCRIPCION,
           SUM(CASE B.INV_TYPE_CODE
                 WHEN unistr('\0030\0031') THEN
                  B.ON_HAND_QTY
                 ELSE
                  0
               END) STOCK_DIS,
           SUM(CASE B.INV_TYPE_CODE
                 WHEN unistr('\0030\0034') THEN
                  B.ON_HAND_QTY
                 ELSE
                  0
               END) STOCK_NODIS,
           SUM(CASE
                 WHEN B.INV_TYPE_CODE IN (unistr('\0030\0031'), unistr('\0030\0034')) THEN
                  B.ON_HAND_QTY + B.PO_ORD_QTY + B.PO_INTRN_QTY + B.TO_ORD_QTY +
                  B.TO_INTRN_QTY
                    -- ASIGNADO Y DA¿ADO
                 WHEN B.INV_TYPE_CODE IN (unistr('\0030\0032'), unistr('\0030\0035')) THEN
                  B.ON_HAND_QTY
                     --CICLICO
                 WHEN B.INV_TYPE_CODE IN (unistr('\0030\0036')) THEN
                  B.ON_HAND_QTY
                 ELSE
                  0
               END) STOCK_TOTAL,
           SUM(CASE
                 WHEN B.INV_TYPE_CODE IN (unistr('\0030\0031'), unistr('\0030\0034')) THEN
                  B.PO_ORD_QTY
                 ELSE
                  0
               END) STOCK_OO_OC,
           SUM(CASE
                 WHEN B.INV_TYPE_CODE IN (unistr('\0030\0031'), unistr('\0030\0034')) THEN
                  B.TO_ORD_QTY
                 ELSE
                  0
               END) STOCK_OO_TRF,
           SUM(CASE
                 WHEN B.INV_TYPE_CODE IN (unistr('\0030\0031'), unistr('\0030\0034')) THEN
                  B.PO_INTRN_QTY + B.TO_INTRN_QTY
                 ELSE
                  0
               END) STOCK_TRANSITO,
           SUM(CASE B.INV_TYPE_CODE
                 WHEN unistr('\0030\0032') THEN
                  B.ON_HAND_QTY
                 ELSE
                  0
               END) STOCK_ASIGNADO,
           -- DA¿ADO
           SUM(CASE B.INV_TYPE_CODE
                 WHEN unistr('\0030\0035') THEN
                  B.ON_HAND_QTY
                 ELSE
                  0
               END) STOCK_DANADO, S.ID,
       --CICLICO
           SUM(CASE B.INV_TYPE_CODE
                 WHEN unistr('\0030\0036') THEN
                  B.ON_HAND_QTY
                 ELSE
                  0
               END) STOCK_CICLICO
          ,TO_CHAR(OBJ.DATE_SALIDA, 'dd/MM/yyyy') "Date_Salida",
           -- Surtido de tienda
          case when
          CAMPO is null then 'NO' ELSE 'SI' END AS "SURTIDO"
      FROM INVBALEE B
      LEFT JOIN IFH_SUR_TPSURMST OBJ ON  ( OBJ.PRD_LVL_CHILD = B.PRD_LVL_CHILD AND OBJ.ORG_LVL_CHILD = B.ORG_LVL_CHILD ) AND 1 = 0


      RIGHT JOIN (
                 --CAMBIOS NUEVO CD
                 SELECT S1.ORG_LVL_CHILD,
                        125675 PRD_LVL_CHILD,
                        TRIM(S1.ORG_LVL_NUMBER) ORG_LVL_NUMBER,
                        TRIM(S1.ORG_NAME_FULL) DESCRIPCION,
                        CASE WHEN S1.ORG_IS_STORE = 'T' THEN 1 ELSE 0 END AS ID
                   FROM ORGMSTEE S1
                  WHERE S1.ORG_LVL_ID = 1
                        and s1.org_lvl_child not in
                        (
                        336
                        )
                  START WITH S1.ORG_LVL_CHILD IN
                             (SELECT PARAM_VALUE
                                FROM CHLPARAM
                               WHERE PARAM_CODE = 'SUCTDA')
                 CONNECT BY PRIOR S1.ORG_LVL_CHILD = S1.ORG_LVL_PARENT
                 ORDER BY S1.ORG_LVL_NUMBER
                  ) S ON B.PRD_LVL_CHILD = S.PRD_LVL_CHILD AND B.ORG_LVL_CHILD = S.ORG_LVL_CHILD

      LEFT JOIN (SELECT 1 CAMPO,SURT.ORG_LVL_NUMBER
               FROM hp_surtido_sku_suc SURT
               WHERE
                SURT.PRD_LVL_NUMBER = TRIM('37089')
                and SURT.fecha_inicio is not null
                and (SURT.fecha_fin is null or
                    SURT.fecha_fin > trunc(sysdate))
               ) SURTIDO ON SURTIDO.ORG_LVL_NUMBER=S.ORG_LVL_NUMBER

      GROUP BY S.ORG_LVL_CHILD, S.ORG_LVL_NUMBER, S.DESCRIPCION, S.ID,CAMPO, OBJ.DATE_SALIDA
      ORDER BY S.ID, S.ORG_LVL_NUMBER;