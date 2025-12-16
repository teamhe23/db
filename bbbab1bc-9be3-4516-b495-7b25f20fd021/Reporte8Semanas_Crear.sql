-- EDSR.HP_GENERAR_REPORTE_8_SEMANAS
SELECT * FROM EDSR.ORGMSTEE WHERE ORG_LVL_ID = 1;
SELECT * FROM EDSR.HPREP8SEMANAS_FULL WHERE SKU= '34481';

select * from TPPRDMST where PRD_LVL_NUMBER = '34481';
select stock.PO_ORD_QTY ,stock.* from INVBALEE stock where PRD_LVL_CHILD = '123187';

-- TOTAL DE STOCK PENDIENTE.
-- Estados de Codigo (PMG_STAT_CODE)
SELECT * FROM EDSR.PMGSTSCD;
SELECT PMG.PMG_TOT_SELL_QTY, PMG.PMG_CNCL_BY_DATE, PMG.* FROM EDSR.PMGHDREE PMG WHERE PMG_PO_NUMBER IN (107559); -- 2024-06-08
SELECT PMG.PMG_CNCL_BY_DATE, PMG.* FROM EDSR.PMGDTLEE PMG WHERE PMG_PO_NUMBER IN (107559); -- 2024-06-08

SELECT DTL.PMG_SELL_QTY,DTL.PMG_RCV_SQTY, DTL.PMG_STATUS, DTL.PMG_CNCL_BY_DATE, DTL.*
FROM EDSR.PMGDTLEE DTL
WHERE PRD_LVL_CHILD IN ('121096')-- AND PMG_PO_NUMBER IN (107642)
    --PMG_STATUS = 5 AND (PMG_SELL_QTY = PMG_RCV_SQTY);
ORDER BY DTL.PMG_CNCL_BY_DATE DESC;

SELECT HOA.FECHA_NUEVO, HOA.* FROM edsr.HP_OC_AMPLIACION hoa ORDER BY FECHA_CARGA DESC;--FETCH FIRST 1 ROW ONLY;
SELECT HOA.FECHA_NUEVO, HOA.* FROM edsr.HP_OC_AMPLIACION hoa WHERE PMG_PO_NUMBER = 107559 ORDER BY FECHA_CARGA DESC FETCH FIRST 1 ROW ONLY;
SELECT PRD_LVL_CHILD FROM PRDMSTEE WHERE PRD_LVL_NUMBER = '21062';

-- STORE PROCEDURE HP_GENERAR_REPORTE_8_SEMANAS
-- QUERY QUE CALCULA LAS UNIDADES PENDIENTES A ENTREGAR POR SKU EN CADA OC
SELECT
   -- PMG.PMG_TOT_SELL_QTY, PMG.PMG_ENTRY_DATE, PMG.PMG_CNCL_BY_DATE, DTL.PMG_SELL_QTY,DTL.PMG_RCV_SQTY
    NVL(SUM(CASE WHEN PMG.PMG_STAT_CODE = 4 THEN DTL.PMG_SELL_QTY ELSE DTL.PMG_SELL_QTY-DTL.PMG_RCV_SQTY END),0) as OC
FROM EDSR.PMGHDREE PMG
    INNER JOIN EDSR.PMGDTLEE DTL ON PMG.PMG_PO_NUMBER = DTL.PMG_PO_NUMBER
WHERE PMG.PMG_CNCL_BY_DATE >= TRUNC(SYSDATE)
      AND PMG.PMG_STAT_CODE IN (4,5)
      AND PMG.PRIM_ORG_LVL_NUMBER = 101
      AND DTL.PRD_LVL_CHILD = '110387'
-- GROUP BY DTL.PRD_LVL_CHILD
ORDER BY PMG.PMG_CNCL_BY_DATE
;


-- QUERY QUE VERIFICA LAS UNIDADES PENDIENTES A ENTREGAR POR SKU EN CADA OC
SELECT
  PMG.PRIM_ORG_LVL_NUMBER,DTL.PRD_LVL_CHILD,
  PMG.PMG_STAT_CODE, DTL.PMG_SELL_QTY,DTL.PMG_RCV_SQTY,
  --PMG.PMG_TOT_SELL_QTY, PMG.PMG_ENTRY_DATE, PMG.PMG_CNCL_BY_DATE,
  NVL(SUM(CASE WHEN PMG.PMG_STAT_CODE = 4 THEN DTL.PMG_SELL_QTY ELSE DTL.PMG_SELL_QTY-DTL.PMG_RCV_SQTY END),0) as SUM,
  T.OC
FROM EDSR.PMGHDREE PMG
  INNER JOIN EDSR.PMGDTLEE DTL ON PMG.PMG_PO_NUMBER = DTL.PMG_PO_NUMBER
  LEFT JOIN (SELECT H.PRIM_ORG_LVL_NUMBER, DTL.PRD_LVL_CHILD,
                    SUM(CASE
                            WHEN H.PMG_STAT_CODE = 4 THEN DTL.PMG_SELL_QTY
                            ELSE DTL.PMG_SELL_QTY - DTL.PMG_RCV_SQTY
                        END) AS OC
             FROM EDSR.PMGHDREE H
                      INNER JOIN EDSR.PMGDTLEE DTL ON H.PMG_PO_NUMBER = DTL.PMG_PO_NUMBER
             WHERE H.PMG_CNCL_BY_DATE >= TRUNC(SYSDATE)
               AND H.PMG_STAT_CODE IN (4, 5)
             GROUP BY H.PRIM_ORG_LVL_NUMBER, DTL.PRD_LVL_CHILD
             ) T ON T.PRIM_ORG_LVL_NUMBER = PMG.PRIM_ORG_LVL_NUMBER AND T.PRD_LVL_CHILD = DTL.PRD_LVL_CHILD
WHERE PMG.PMG_CNCL_BY_DATE >= TRUNC(SYSDATE)
  AND PMG.PMG_STAT_CODE IN (4,5)
  -- AND PMG.PRIM_ORG_LVL_NUMBER = 101
  -- AND DTL.PRD_LVL_CHILD = '108711'
GROUP BY  PMG.PRIM_ORG_LVL_NUMBER,DTL.PRD_LVL_CHILD,PMG.PMG_STAT_CODE, DTL.PMG_SELL_QTY,DTL.PMG_RCV_SQTY,T.OC
--GROUP BY PMG.PRIM_ORG_LVL_NUMBER, DTL.PRD_LVL_CHILD
ORDER BY DTL.PRD_LVL_CHILD DESC--PMG.PMG_CNCL_BY_DATE
;




-- 2do CASO OC aparecen cuando ya han vencido
-- Proceso Cancelar OC
/*
EDSR.PKG_WMS_PURCHASE_ORDER

sp_procesar_cancel
sp_sel_cancel
sp_get_cancel

 */
/*
 CASOS OC REPORTADOS:
 OC         SKUs                    VENCIO
 104210     31377(24 unidades)      20/03/24
 103729

 */
--sp_sel_cancel
-- 1165 TOTALES
SELECT
    --COUNT( WMS.pmg_po_number) AS TOTAL
    --WMS.pmg_po_number,WMS.audit_number,WMS.FEC_REG, WMS.FEC_PROCESADO, WMS.FLG_ERROR,WMS.MENSAJE,WMS.ID_WMS
    --WMS.pmg_po_number, COUNT(WMS.audit_number)
    WMS.PMG_PO_NUMBER, SDI.pmg_cancel_date
FROM WMS_PURCHASEORDER_ENVIO WMS
    INNER JOIN SDIPMGHDE SDI on sdi.pmg_po_number = wms.pmg_po_number and sdi.audit_number = wms.audit_number
WHERE id_tipo = 5 AND FLG_ERROR = '0'
--GROUP BY WMS.pmg_po_number,WMS.audit_number
--HAVING COUNT(WMS.audit_number) >= 1
;

SELECT * FROM EPMM.INVTYPEE;
SELECT * FROM EPMM.INVBALEE;

BEGIN
    PKG_WMS_SHIPMENT_VERIFICATION.sp_verification_oc;
END;


SELECT * FROM EDSR.sdipmghde WHERE PMG_PO_NUMBER = 103729;
SELECT * FROM EDSR.sdipmgdte WHERE PMG_PO_NUMBER = 103729;

--sp_get_cancel
select wms.pmg_po_number,
     wms.audit_number,
     sdi.pmg_po_number as po_nbr,
     sdi.org_lvl_number as facility_code,
     trim(sdi.vendor_number) as vendor_code,
     'DELETE' as action_code,
     to_char(sdi.pmg_release_date, 'yyyy-mm-dd') as ord_date,
     sdi.dmt_code as ref_nbr,
     sdi.pmg_type_code as po_type,
     to_char(sdi.pmg_exp_rct_date, 'yyyy-mm-dd') as delivery_date,
     to_char(sdi.pmg_exp_rct_date, 'yyyy-mm-dd') as ship_date,
     to_char(sdi.pmg_cancel_date, 'yyyy-mm-dd') as cancel_date
from wms_purchaseorder_envio wms
inner join sdipmghde sdi on sdi.pmg_po_number = wms.pmg_po_number
  and sdi.audit_number = wms.audit_number
where wms.pmg_po_number = p_pmg_po_number
and wms.audit_number  = p_audit_number;

SELECT DISTINCT OWNER FROM ALL_OBJECTS;
SELECT DISTINCT OBJECT_TYPE FROM ALL_OBJECTS;
SELECT DISTINCT STATUS FROM ALL_OBJECTS;
SELECT * FROM ALL_OBJECTS
WHERE OBJECT_TYPE IN ('FUNCTION', 'PROCEDURE', 'PACKAGE')
      AND STATUS NOT IN ('VALID');

SELECT *
FROM DBA_SOURCE
WHERE TYPE = 'PACKAGE BODY' AND TEXT LIKE '% stock%';
--WHERE  TYPE = 'PACKAGE BODY' AND TEXT LIKE '%from stock%' OR TEXT LIKE '%insert Stock%' OR TEXT LIKE '%update Stock%' OR TEXT LIKE '%, stock%';


SELECT NVL(0.25,0) FROM DUAL;
SELECT a.org_lvl_number,b.prd_lvl_child,b.inv_type_code,b.on_hand_qty,b.po_ord_qty,b.to_ord_qty
FROM EPMM.ORGMSTEE a
     INNER JOIN EPMM.INVBALEE b ON b.org_lvl_child = a.org_lvl_child
WHERE inv_type_code = '01';


SELECT b.prd_lvl_child, b.trf_dist_pak
FROM EPMM.ORGMSTEE a
     INNER JOIN epmm.whsprdee b ON b.org_lvl_child = a.org_lvl_child
WHERE a.org_lvl_child = 420
      AND b.prd_lvl_child IN ( SELECT PRD_LVL_CHILD,org_lvl_child
                               FROM EDSR.PRDMSTEE
                               WHERE PRD_LVL_NUMBER IN ('12344',
                                '12345',
                                '12760',
                                '14355',
                                '14357',
                                '14361',
                                '14369',
                                '14370',
                                '14371',
                                '14372')
)
;


-- TOTAL 1000 (40 NULL) (960 NOT NULL)
SELECT
   B.PRD_LVL_CHILD, PRD.PRD_LVL_NUMBER
FROM epmm.whsprdee B
    RIGHT JOIN EDSR.PRDMSTEE PRD ON PRD.PRD_LVL_CHILD =  B.PRD_LVL_CHILD
WHERE PRD.PRD_LVL_NUMBER IN ('12344',
'12345',
'12760',
'14355',
'14357',
'14361',
'14369',
'14370',
'14371',
'14372',
'14373',
'14375',
'14377',
'14383',
'14385',
'14386',
'14437',
'14441',
'14445',
'14508',
'14769',
'14770',
'14771',
'14772',
'14773',
'14774',
'14775',
'14776',
'14777',
'14778',
'14779',
'14780',
'14781',
'14782',
'14783',
'14784',
'14785',
'14786',
'14787',
'14788',
'14789',
'14791',
'14792',
'14793',
'14794',
'14795',
'14796',
'14797',
'14798',
'14799',
'14800',
'14801',
'14802',
'14803',
'14804',
'14805',
'14806',
'14807',
'14808',
'14809',
'14810',
'14811',
'14812',
'14813',
'14814',
'14815',
'14816',
'14817',
'14818',
'14819',
'14820',
'14821',
'14822',
'14823',
'14824',
'14825',
'14826',
'14827',
'14828',
'14829',
'14871',
'14872',
'14873',
'14892',
'14893',
'14894',
'14895',
'14896',
'14897',
'15311',
'15685',
'15691',
'19741',
'19867',
'19871',
'19872',
'19874',
'19877',
'19878',
'19879',
'19886',
'19887',
'19888',
'19889',
'19890',
'19895',
'19897',
'19899',
'19904',
'19905',
'19906',
'19907',
'19908',
'19909',
'19910',
'19911',
'19913',
'19914',
'19915',
'19916',
'19917',
'19918',
'19919',
'19920',
'19921',
'19922',
'19923',
'19924',
'19925',
'19926',
'19927',
'19928',
'19929',
'19930',
'19931',
'19932',
'19933',
'19934',
'19935',
'19936',
'19937',
'19938',
'19939',
'19940',
'19941',
'19942',
'19943',
'19944',
'19945',
'19946',
'20356',
'20416',
'20417',
'20418',
'20419',
'20420',
'20421',
'20422',
'20423',
'20424',
'20425',
'20426',
'20427',
'20542',
'20543',
'20544',
'20545',
'20546',
'20547',
'20548',
'20549',
'20550',
'20551',
'20552',
'20553',
'20554',
'20555',
'20556',
'20557',
'20558',
'20559',
'20560',
'20561',
'20562',
'20563',
'20564',
'20565',
'20566',
'20567',
'20568',
'20569',
'20570',
'20571',
'20572',
'20573',
'20574',
'20575',
'20576',
'20577',
'20578',
'20579',
'20580',
'20581',
'20582',
'20583',
'20584',
'20585',
'20586',
'20587',
'20588',
'20589',
'20614',
'20615',
'21158',
'21159',
'21170',
'21171',
'21173',
'21174',
'21183',
'21193',
'21194',
'21205',
'21206',
'21208',
'21209',
'21217',
'21218',
'21220',
'21223',
'21226',
'21227',
'21229',
'21232',
'21233',
'21235',
'21236',
'21242',
'21251',
'21253',
'21255',
'21758',
'21841',
'21842',
'21843',
'21844',
'21845',
'21846',
'21852',
'21853',
'21855',
'21856',
'21857',
'21858',
'21859',
'21860',
'21861',
'21870',
'21871',
'21872',
'21874',
'21877',
'21878',
'21879',
'21881',
'21884',
'21885',
'21886',
'21891',
'21892',
'21893',
'21894',
'21895',
'21896',
'21897',
'21901',
'21902',
'21903',
'21904',
'21906',
'21907',
'21908',
'21910',
'21911',
'21912',
'21913',
'21916',
'21917',
'21918',
'21920',
'21921',
'21922',
'21923',
'21927',
'21928',
'21929',
'21930',
'21932',
'21933',
'21934',
'21935',
'21936',
'21937',
'21938',
'21951',
'21961',
'21971',
'21973',
'21979',
'21985',
'21990',
'21991',
'21995',
'21996',
'21997',
'22005',
'22006',
'22014',
'22015',
'22016',
'22019',
'22020',
'22021',
'22024',
'22030',
'22034',
'22036',
'22038',
'22214',
'22215',
'22216',
'22219',
'22220',
'22221',
'22222',
'22223',
'22224',
'22225',
'22226',
'22227',
'22228',
'22229',
'22230',
'22231',
'22232',
'22233',
'22234',
'22235',
'22236',
'22237',
'22238',
'22239',
'22963',
'22965',
'23249',
'23250',
'23251',
'23417',
'23418',
'23419',
'23420',
'23424',
'23425',
'23426',
'23432',
'23433',
'23434',
'23435',
'23436',
'23453',
'23455',
'23472',
'23473',
'23474',
'23475',
'23483',
'23484',
'23488',
'23489',
'23490',
'23492',
'23493',
'23494',
'23495',
'23496',
'23497',
'23498',
'23499',
'23500',
'23501',
'23502',
'23503',
'23504',
'23505',
'23506',
'23507',
'23508',
'23509',
'23510',
'23511',
'23512',
'23513',
'23514',
'23515',
'23516',
'23517',
'23518',
'23519',
'23520',
'23521',
'23904',
'23905',
'23906',
'23907',
'23908',
'23991',
'23992',
'23993',
'23996',
'24016',
'24022',
'24024',
'24028',
'24029',
'24044',
'24045',
'24046',
'24061',
'24062',
'24068',
'24069',
'24079',
'24095',
'24096',
'24097',
'24098',
'24099',
'24100',
'24103',
'24104',
'24105',
'24110',
'24111',
'24112',
'24116',
'24117',
'24122',
'24123',
'24126',
'24133',
'24134',
'24135',
'24138',
'24139',
'24144',
'24146',
'24150',
'24151',
'24152',
'24153',
'24154',
'24155',
'24156',
'24157',
'24158',
'24161',
'24166',
'24182',
'24205',
'24211',
'24212',
'24213',
'24214',
'24215',
'24216',
'24217',
'24218',
'24219',
'24220',
'24221',
'24222',
'24223',
'24224',
'24225',
'24334',
'24396',
'24397',
'24398',
'24400',
'24402',
'24403',
'24406',
'24407',
'24408',
'24409',
'24415',
'24416',
'24418',
'24419',
'24421',
'24879',
'24881',
'24884',
'24887',
'24924',
'25267',
'25270',
'25276',
'25277',
'25280',
'25899',
'25903',
'25910',
'25912',
'25914',
'25915',
'25916',
'25917',
'25918',
'25937',
'25982',
'26112',
'26123',
'26259',
'26261',
'26262',
'26264',
'26265',
'26368',
'26369',
'26373',
'26374',
'26375',
'26376',
'26377',
'26378',
'26388',
'26390',
'26679',
'26680',
'26681',
'26682',
'26683',
'26684',
'26871',
'26886',
'26887',
'26890',
'26891',
'26892',
'26894',
'26896',
'26898',
'26905',
'26911',
'26913',
'26929',
'26930',
'26931',
'26933',
'26934',
'27089',
'27102',
'27301',
'27302',
'27303',
'27304',
'27353',
'27354',
'27355',
'27356',
'27486',
'27487',
'27488',
'27489',
'27490',
'27493',
'27519',
'27520',
'27533',
'27602',
'27637',
'27641',
'27742',
'27744',
'27746',
'27747',
'27749',
'27759',
'27812',
'27843',
'27844',
'27914',
'27915',
'28010',
'28011',
'28012',
'28878',
'28879',
'28880',
'28881',
'28882',
'28928',
'28929',
'28933',
'28934',
'28935',
'28936',
'28937',
'28941',
'28942',
'28948',
'28949',
'29295',
'29296',
'29467',
'29896',
'29897',
'29898',
'29899',
'30310',
'30311',
'30312',
'30313',
'30314',
'30315',
'30316',
'30317',
'30318',
'30319',
'30719',
'30720',
'30721',
'30722',
'30723',
'30794',
'30795',
'30805',
'30914',
'30922',
'30939',
'30940',
'30941',
'30942',
'30963',
'30964',
'31120',
'31121',
'31133',
'31139',
'31148',
'31149',
'31151',
'31153',
'31155',
'31217',
'31218',
'31220',
'31221',
'31222',
'31223',
'31239',
'31589',
'31606',
'31609',
'31610',
'31628',
'31629',
'31634',
'31702',
'31703',
'31707',
'31708',
'31709',
'31710',
'31711',
'31712',
'31713',
'31714',
'31715',
'31716',
'31717',
'31718',
'31719',
'31720',
'31721',
'31722',
'31723',
'31724',
'31725',
'31726',
'31727',
'31728',
'31729',
'31730',
'31731',
'31732',
'31733',
'31734',
'31735',
'31795',
'31796',
'31797',
'31798',
'31998',
'32074',
'32202',
'32203',
'32204',
'32258',
'32259',
'32260',
'32261',
'32273',
'32275',
'32276',
'32452',
'32453',
'32454',
'32455',
'32456',
'32457',
'32460',
'32463',
'32466',
'32467',
'32469',
'32470',
'32471',
'32473',
'32474',
'32475',
'32476',
'32477',
'32478',
'32479',
'32480',
'32481',
'32482',
'32483',
'32485',
'32486',
'32487',
'32488',
'32489',
'32490',
'32491',
'32492',
'32493',
'32494',
'32495',
'32498',
'32499',
'32501',
'32502',
'32503',
'32504',
'32505',
'32506',
'32511',
'32512',
'32514',
'32515',
'32516',
'32517',
'32518',
'32519',
'32520',
'32521',
'32522',
'32523',
'32524',
'32525',
'32526',
'32527',
'32528',
'32529',
'32530',
'32531',
'32532',
'32533',
'32534',
'32535',
'32536',
'32537',
'32538',
'32539',
'32540',
'32541',
'32542',
'32543',
'32544',
'32545',
'32546',
'32547',
'32561',
'32562',
'32563',
'32564',
'32565',
'32566',
'32567',
'32568',
'32573',
'32574',
'32576',
'32577',
'32578',
'32579',
'32580',
'32627',
'32646',
'32647',
'32648',
'32654',
'32693',
'32694',
'32695',
'32696',
'32697',
'32698',
'32736',
'32737',
'32738',
'32739',
'32740',
'32741',
'32742',
'32743',
'32752',
'32753',
'32936',
'32938',
'32942',
'33050',
'33053',
'33461',
'33480',
'33481',
'33495',
'33496',
'33497',
'33498',
'33499',
'33500',
'33501',
'33502',
'33504',
'33507',
'33600',
'33601',
'33604',
'33646',
'33648',
'33650',
'33651',
'33652',
'33791',
'33792',
'33793',
'33794',
'33795',
'33796',
'33797',
'33798',
'33799',
'33800',
'33801',
'33802',
'33803',
'33804',
'33805',
'33806',
'33807',
'33808',
'34169',
'34173',
'34177',
'34181',
'34185',
'34189',
'34193',
'34197',
'34201',
'34205',
'34209',
'34365',
'34366',
'34367',
'34368',
'34369',
'34370',
'34371',
'34372',
'34373',
'34374',
'34375',
'34376',
'34377',
'34378',
'34379',
'34380',
'34381',
'34382',
'34383',
'34384',
'34385',
'34386',
'34387',
'34388',
'34389',
'34390',
'34391',
'34392',
'34393',
'34394',
'34395',
'34396',
'34397',
'34398',
'34399',
'34400',
'34401',
'34402',
'34403',
'34404',
'34405',
'34406',
'34407',
'34408',
'34409',
'34410',
'34411',
'34412',
'34413',
'34414',
'34415',
'34416',
'34417',
'34418',
'34419',
'34420',
'34421',
'34422',
'34423',
'34424',
'34425',
'34426',
'34427',
'34428',
'34429',
'34430',
'34431',
'34432',
'34433',
'34434',
'34435',
'34436',
'34437',
'34438',
'34439',
'34440',
'34441',
'34442',
'34443',
'34444',
'34445',
'34446',
'34447',
'34448',
'34449',
'34450',
'34451',
'34452',
'34453',
'34454',
'34455',
'34456',
'34457',
'34458',
'34459',
'34460',
'34461',
'34462',
'34463',
'34464',
'34465',
'34489',
'34490',
'34491',
'34492',
'34493',
'34494',
'34495',
'34496',
'34497',
'34498',
'34499',
'34500',
'34501')
    AND B.PRD_LVL_CHILD IS NOT NULL
;


-- TOTAL 20 (3 NULL) (17 NOT NULL)
SELECT
   B.PRD_LVL_CHILD, PRD.PRD_LVL_NUMBER
FROM epmm.whsprdee B
    RIGHT JOIN EDSR.PRDMSTEE PRD ON PRD.PRD_LVL_CHILD =  B.PRD_LVL_CHILD
WHERE PRD.PRD_LVL_NUMBER IN ('34502',
                                '34503',
                                '34504',
                                '34505',
                                '34506',
                                '34507',
                                '34508',
                                '34509',
                                '34547',
                                '34548',
                                '34549',
                                '34550',
                                '34590',
                                '34591',
                                '34592',
                                '34814',
                                '35027',
                                '35028',
                                '35029',
                                '35030'
                                )
    AND B.PRD_LVL_CHILD IS NOT NULL
;

-- Luego del pase PRD
-- TOTAL 20 (3 NULL) (17 NOT NULL)
SELECT
   B.PRD_LVL_CHILD, PRD.PRD_LVL_NUMBER, B.TRF_DIST_PAK
FROM epmm.whsprdee B
    RIGHT JOIN EDSR.PRDMSTEE PRD ON PRD.PRD_LVL_CHILD =  B.PRD_LVL_CHILD
WHERE PRD.PRD_LVL_NUMBER IN ('12760',
'24190',
'24183',
'24189',
'24184',
'24191',
'26375',
'24393',
'24881',
'30542',
'30543',
'30574',
'30580',
'30572',
'28965',
'28966',
'32116',
'33579',
'33577',
'30611',
'30617',
'30636',
'30631',
'30648',
'30598',
'30645',
'30613',
'32106',
'32111',
'30603',
'30678',
'30695',
'32108',
'32122',
'30687',
'30697',
'31226',
'30805',
'31225',
'31227',
'31229',
'30679',
'30689',
'30688',
'31230',
'31224',
'31228',
'30608',
'30615',
'35744',
'34592',
'34549',
'34548',
'34550',
'34591',
'35771',
'34814',
'35658',
'34502',
'34506',
'34503',
'34509',
'34507',
'34508',
'34505',
'34488',
'35029',
'35030',
'35027',
'35028',
'34504',
'34590',
'33582')
    AND B.PRD_LVL_CHILD IS NOT NULL
;

SELECT * FROM EPMM.WHSPRDEE WHERE PRD_LVL_CHILD IN ('113399',
'113400',
'113405',
'113406',
'113407',
'113605',
'117981',
'117982',
'119428',
'119429',
'119458',
'119460',
'119466',
'119484',
'119489',
'119494',
'119497',
'119499',
'119501',
'119503',
'119517',
'119522',
'119531',
'119534',
'119564',
'119565',
'119573',
'119574',
'119575',
'119581',
'119583',
'120050',
'120051',
'120052',
'120053',
'120054',
'120055',
'120056',
'120863',
'120865',
'120868',
'120873',
'120879',
'122289',
'122291',
'122294',
'123194',
'123208',
'123209',
'123210',
'123211',
'123212',
'123213',
'123214',
'123215',
'123254',
'123255',
'123256',
'123297',
'123298',
'123520',
'123726',
'123727',
'123728',
'123729',
'124362',
'124448',
'124472')
;

/*
SKUS Con estado Excluido no TIENEN MASTERPACK
30805
26375
12760
24881
34590 (Del grupo 20 Skus)
 */

-- TOTAL PRODUCTOS: 24159
SELECT COUNT(PRD.PRD_LVL_CHILD) FROM tpprdmst PRD; -- 24159
SELECT DISTINCT PRD.PRD_LVL_CHILD FROM tpprdmst PRD; -- 24159
SELECT COUNT(PRD.PRD_LVL_NUMBER) FROM tpprdmst PRD; -- 24159
SELECT DISTINCT PRD.PRD_LVL_NUMBER, PRD.PRD_LVL_CHILD FROM tpprdmst PRD; -- 24159

--24159 (16 skus sin MasterPack) (24143 skus con MasterPack)
SELECT P.PRD_LVL_CHILD,C.VPC_CASE_STD_PACK
FROM edsr.tpprdmst P
  LEFT JOIN epmm.vpcprdee C
    ON C.vpc_prd_tech_key = P.vpc_prd_tech_key
       AND C.vpc_tech_key = P.vpc_tech_key
WHERE
    C.VPC_CASE_STD_PACK IS NULL;


-- CONTADOR
SELECT * FROM epmm.whsprdee b WHERE TRF_DIST_PAK IS NULL; -- 1022
SELECT COUNT(*) FROM epmm.whsprdee b WHERE ROUND(TRF_DIST_PAK) = 0; -- 1022

-- PARCHE

BEGIN
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,102729,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,114093,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,115568,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,119691,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,121217,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,121690,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,121692,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122203,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122219,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122220,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122234,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122235,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122236,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122237,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122238,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122239,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122240,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122241,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122360,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122362,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122363,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122364,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122499,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122500,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122501,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122502,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122503,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122504,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122505,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122506,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122507,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122508,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122509,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122510,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122511,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122512,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122513,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122514,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122515,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,122516,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,123296,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,123297,null);
    INSERT INTO EPMM.WHSPRDEE (ORG_LVL_CHILD, PRD_LVL_CHILD, TRF_DIST_PAK) VALUES (420,123298,null);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK ;
END;


-- First UPDATE
BEGIN
    MERGE INTO EPMM.WHSPRDEE WPE
    USING (
            SELECT P.PRD_LVL_CHILD,C.VPC_CASE_STD_PACK , P.PRD_LVL_NUMBER
            FROM edsr.tpprdmst P
              LEFT JOIN epmm.vpcprdee C
                ON C.vpc_prd_tech_key = P.vpc_prd_tech_key
                   AND C.vpc_tech_key = P.vpc_tech_key
            WHERE
                P.PRD_LVL_NUMBER IN ('12760',
'24190',
'24183',
'24189',
'24184',
'24191',
'26375',
'24393',
'24881',
'30542',
'30543',
'30574',
'30580',
'30572',
'28965',
'28966',
'32116',
'33579',
'33577',
'30611',
'30617',
'30636',
'30631',
'30648',
'30598',
'30645',
'30613',
'32106',
'32111',
'30603',
'30678',
'30695',
'32108',
'32122',
'30687',
'30697',
'31226',
'30805',
'31225',
'31227',
'31229',
'30679',
'30689',
'30688',
'31230',
'31224',
'31228',
'30608',
'30615',
'35744',
'34592',
'34549',
'34548',
'34550',
'34591',
'35771',
'34814',
'35658',
'34502',
'34506',
'34503',
'34509',
'34507',
'34508',
'34505',
'34488',
'35029',
'35030',
'35027',
'35028',
'34504',
'34590',
'33582')
                AND C.VPC_CASE_STD_PACK IS NOT NULL
          ) SRC
    ON (WPE.PRD_LVL_CHILD = SRC.PRD_LVL_CHILD)
    WHEN MATCHED THEN
        UPDATE SET
            WPE.TRF_DIST_PAK = SRC.VPC_CASE_STD_PACK
    ;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;


-- Second UPDATE
BEGIN
    MERGE INTO EPMM.WHSPRDEE WPE
    USING (
            SELECT P.PRD_LVL_CHILD,C.VPC_CASE_STD_PACK , P.PRD_LVL_NUMBER
            FROM edsr.tpprdmst P
              LEFT JOIN epmm.vpcprdee C
                ON C.vpc_prd_tech_key = P.vpc_prd_tech_key
                   AND C.vpc_tech_key = P.vpc_tech_key
            WHERE
                P.PRD_LVL_NUMBER IN ('34502',
                                '34503',
                                '34504',
                                '34505',
                                '34506',
                                '34507',
                                '34508',
                                '34509',
                                '34547',
                                '34548',
                                '34549',
                                '34550',
                                '34590',
                                '34591',
                                '34592',
                                '34814',
                                '35027',
                                '35028',
                                '35029',
                                '35030'
                                )
                AND C.VPC_CASE_STD_PACK IS NULL
          ) SRC
    ON (WPE.PRD_LVL_CHILD = SRC.PRD_LVL_CHILD)
    WHEN MATCHED THEN
        UPDATE SET
            WPE.TRF_DIST_PAK = SRC.VPC_CASE_STD_PACK
    ;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;


-- Third UPDATE
BEGIN
    MERGE INTO EPMM.WHSPRDEE WPE
    USING (
            SELECT P.PRD_LVL_CHILD,C.VPC_CASE_STD_PACK , P.PRD_LVL_NUMBER
            FROM edsr.tpprdmst P
              LEFT JOIN epmm.vpcprdee C
                ON C.vpc_prd_tech_key = P.vpc_prd_tech_key
                   AND C.vpc_tech_key = P.vpc_tech_key
            WHERE
                P.PRD_LVL_NUMBER IN ('12760',
'24190',
'24183',
'24189',
'24184',
'24191',
'26375',
'24393',
'24881',
'30542',
'30543',
'30574',
'30580',
'30572',
'28965',
'28966',
'32116',
'33579',
'33577',
'30611',
'30617',
'30636',
'30631',
'30648',
'30598',
'30645',
'30613',
'32106',
'32111',
'30603',
'30678',
'30695',
'32108',
'32122',
'30687',
'30697',
'31226',
'30805',
'31225',
'31227',
'31229',
'30679',
'30689',
'30688',
'31230',
'31224',
'31228',
'30608',
'30615',
'35744',
'34592',
'34549',
'34548',
'34550',
'34591',
'35771',
'34814',
'35658',
'34502',
'34506',
'34503',
'34509',
'34507',
'34508',
'34505',
'34488',
'35029',
'35030',
'35027',
'35028',
'34504',
'34590',
'33582')
                AND C.VPC_CASE_STD_PACK IS NOT NULL
          ) SRC
    ON (WPE.PRD_LVL_CHILD = SRC.PRD_LVL_CHILD)
    WHEN MATCHED THEN
        UPDATE SET
            WPE.TRF_DIST_PAK = SRC.VPC_CASE_STD_PACK
    ;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;

-- OBTENER SOLO MASTER PACK GLOBAL
SELECT P.prd_lvl_number SKU,ROUND(c.VPC_CASE_STD_PACK) MP,P.prd_full_name Producto,P.DES_EST Estado
FROM edsr.tpprdmst p
  LEFT JOIN epmm.vpcprdee c
    ON c.vpc_prd_tech_key = p.vpc_prd_tech_key
       AND c.vpc_tech_key = p.vpc_tech_key
WHERE
    c.VPC_CASE_STD_PACK IS NOT NULL
;



-- REPORTE MAESTRO DE PRODUCTOS
select P.prd_lvl_number "SKU",
       ROUND(c.VPC_CASE_STD_PACK) "MP", -- MASTER PACK
       P.VPC_CASE_PACK_ID "Case Pack",
       P.prd_full_name "Producto",
       P.DES_EST "Estado",
       cod_div "Cod. Division",
       des_div "Division",
       cod_area "Cod. Area",
       des_area "Area",
       cod_dpto "Cod. depto",
       des_dpto "Departamento",
       cod_lin "Cod. Linea",
       des_lin "Linea",
       des_marca "Marca",
       cod_tipmar "Tipo de Marca",
       cod_prv "Cod. Proveedor",
       des_prv "Proveedor",
       des_proce "Procedencia",
       cod_bar "Código de barras Primario",
       LPAD(upc.prd_upc, 14, 0) "GTIN",
       DECODE(afecto, 'F', 'SI', 'NO') "Afecto a IGV",
       des_tipneg "Tipo de Negociación",
       DECODE(flag_serv, 'F', 'NO', null, 'NO', 'SI') "Es servicio",
       des_serv "Servicio",
       des_tipman "Tipo de manejo",
       DECODE(flag_bigtck, null, 'NO', 'F', 'NO', 'SI') "Es Big Ticket",
       des_bigtck "Big Ticket",
       dist_qty "Dist. qty",
       p.des_ptoprecio "Punto de Precio",
       p.des_umi "Unidad de Medida de Inventario",
       p.des_umc "Unidad de Medida de Compra",
       p.des_umv "Unidad de Medida de Venta",
       NVL(b.value, 0) AS CANT_M2_CAJA,
       c.vpc_case_width Ancho,
       c.vpc_case_len largo,
       c.vpc_case_height alto,
       c.vpc_case_width * c.vpc_case_len * c.vpc_case_height VOLUMEN,
       c.case_cube_uom "UND MEDIDA VOLUMNEN",
       c.vpc_case_gross_wgt peso_bruto,
       c.vpc_case_WGT_UOM "UND MEDIDA PESO",
       p.fec_cre fecha_creacion,
       (SELECT MAX(EFFECT_DATE)
          FROM EPMM.PRDSTEEE
         WHERE PRD_LVL_CHILD = p.prd_lvl_child) "ULTIMO CAMBIO ESTADO",
       p.liquidacion,
       p.preciazo,
       des_bigtck_vtex "Big Ticket VTEX",
       p.cod_surtido "Codigo Surtido",
       DECODE(NVL(attr_inf.prd_lvl_child, 0), 0, 'NO', 'SI') "PRODUCTO INFALTABLE",
       p.FLAG_ECOM_RETIRO_TDA "VTEX RETIRO EN TIENDA",
       COD_SURTIDO "CODIGO SURTIDO",
       ATR_LONG_TAIL "SUB ATRIBUTO",
       --nvl(edsr.fn_get_atrib(p.prd_lvl_number, '161'), 'NO') "EXPRESS RETAIL",
       --nvl(edsr.fn_get_atrib(p.prd_lvl_number, '162'), 'NO') "EXPRESS ECOMMERCE",
       (select nvl(max(x2.atr_code), 'NO')
        from epmm.basatpee x1
          inner join epmm.basacdee x2 on x2.atr_cod_tech_key = x1.atr_cod_tech_key
        where x1.prd_lvl_child = p.prd_lvl_child
          and x1.atr_hdr_tech_key = 161) as "EXPRESS ECOMMERCE",
       P.PERECIBLE,
       ATR_TOP_2K     "COD. ATRIBUTO TOP2K",
       DES_ATR_TOP_2K "DESC. ATRIBUTO TOP2K"
      --, edsr.fnu_get_producto_iva(p.prd_lvl_child)||'%' "% IVA"
  from edsr.tpprdmst p
  LEFT JOIN epmm.vpcprdee c
    ON c.vpc_prd_tech_key = p.vpc_prd_tech_key
   and c.vpc_tech_key = p.vpc_tech_key
  LEFT JOIN epmm.BASVALEE b
    ON b.tech_key1 = p.prd_lvl_child
   AND b.FIELD_CODE = 'CP'
   AND b.ENTITY_NAME = 'PRDMSTEE'
  LEFT JOIN epmm.basatpee attr_inf
    on attr_inf.prd_lvl_child = p.prd_lvl_child
   and attr_inf.atr_typ_tech_key = 21
   and attr_inf.atr_hdr_tech_key = 158
   and attr_inf.atr_cod_tech_key = 2919
  LEFT JOIN epmm.PRDUPCEE upc
    on p.prd_lvl_child = upc.prd_lvl_child
   and upc.vpc_primary_flag = 'T'

  /*
  WHERE nvl(p.cod_div, '') = decode(upper('@DIVISION@'), '0', nvl(p.cod_div, ''), upper('@DIVISION@'))
   and nvl(p.cod_area, '') = decode(upper('@AREA@'), '0', nvl(p.cod_area, ''), upper('@AREA@'))
   and nvl(p.cod_prv, '*') = decode(upper('@PROVEEDOR@'), '0', nvl(p.cod_prv, '*'), upper('@PROVEEDOR@'))
  