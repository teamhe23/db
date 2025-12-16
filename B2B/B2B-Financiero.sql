-- PMG_STAT_CODE Detail
/*
PMG_STAT_CODE   PMG_STAT_NAME
    0     Suspendido
    1     Modo Entrada
    2     Autorz Pend
    3     Aprobado
    4     On Order
    5     Recibo Parcial
    6     Recibo Completo
    7     Cancel
    8     Cambio Rechazado
 */

-- Archivos ACK en /prochp/interfaces/b2b/import/in/
-- Buscar por # Recepcion, # OC
SELECT * FROM EDSR.B2BACKEE2 WHERE B2B_MENSAJE LIKE '748816%'ORDER BY 1 DESC;
SELECT max(B2B_ID) FROM EDSR.B2BACKEE2 ORDER BY 1 DESC;
SELECT * FROM EDSR.B2BACKEE2 ORDER BY B2B_ID DESC;
--B2B_MENSAJE: ID TRANSACCION

SELECT * FROM ACK ORDER BY B2B_ID DESC;
SELECT * FROM EDSR.B2BACKEE2  where B2B_ID = 20361;
SELECT * FROM EDSR.B2BACKEE2 ORDER BY B2B_DOWNLOAD_DATE DESC;

--B2B Financiero
/*
 CASO FALLIDOS:     120139,120138
 CASO NO APARECE:   120382
 CASO EXITO:        104373
*/
SELECT * FROM EDSR.B2B_OC_RCV_ENVIO RCV
--UPDATE edsr.B2B_OC_RCV_ENVIO SET FEC_PROC_LOG = null
WHERE PMG_PO_NUMBER IN (120328) AND IMPUESTO_FIN != '0';

select * from pmgstscd where pmg_stat_code IN (4,6,7);
SELECT SDI.DOWNLOAD_DATE_1, SDI.DOWNLOAD_DATE_2, SDI.* FROM edsr.sdipmghde sdi
WHERE PMG_PO_NUMBER IN (110321,110360) AND PMG_STAT_CODE = 4 ORDER BY AUDIT_NUMBER DESC;
-- FUNCION PARA EXTRAER EL IVA PARA EL XML
    SELECT * FROM EDSR.B2B_IMPUESTO_SAP;

/*
 IMPUESTO_FIN	FLG_ORIGEN_PRV	PORCENTAJE	COD_SAP
        1	            I	        12.00	 FD
        1	            N	        12.00	 FA
        2	            I	        0.00	 F7
        2	            N	        0.00	 F2
        3	            I	        5.00	 FP
        3	            N	        5.00	 FM
        4	            I	        15.00	 G8
        4	            N	        15.00	 G5
        5	            I	        13.00	 FY
        5	            N	        13.00	 FV
 */

--integración pmm con b2b financiero
/*
 FUNCION PARA EXTRAER EL IVA PARA EL XML en la etiqueta <n></n>
    SELECT * FROM EDSR.B2B_IMPUESTO_SAP;
  INCIDENCIA CONAUTO (proveedor)
 CUANDO NO SUBE EL CORRECTO IVA, se envia dos archivos el .xml y el .xml.trg a la ruta del sFTP PMM PRD
    /PROCHP/INTERFACES/HPSA/B2B/INTEGRACION/OUTPUT/LOG/CQ

 Al subir los archivos y desaparecer, dura aprox unos minutos en reflejarse en el Financhelo
 Sino figura revisar el ACK en EDSR.B2BACKEE2, FILTRAR por fecha B2B_DOWNLOAD_DATE o campo B2B_MENSAJE que es la misma de la etiqueta <a>75117402</a> del XML
  */
SELECT * FROM EDSR.B2BACKEE2 ORDER BY B2B_DOWNLOAD_DATE DESC;


SELECT * FROM EDSR.B2B_IMPUESTO_SAP;

-- B2B Financiero : El Nro Referencia = #Orden Compra
-- Caso CONAUTO B2B FINANCHELO
select * from edsr.B2B_OC_RCV_ENVIO RCV
WHERE pmg_po_number IN (116806) AND impuesto_fin != '0'
;


--Recordar que el b2b_mensaje es el ID Transaccion del B2B Financhelo
select * from edsr.b2backee2 where b2b_mensaje like '749942%' OR B2B_MENSAJE like '%749943%';
--otra forma de buscar
select * from edsr.b2backee2 where b2b_tipo_mens = 'QR' order by 1 desc;

SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE FLAG_PROCESADO = '0' OR FLAG_ERROR = '1';
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE IDENTIFICADOR = 'NAC000905648';
SELECT * FROM EDSR.WMS_MODELO_REQUEST WHERE MODELO LIKE '%NAC000905648%';
SELECT * FROM EDSR.WMS_RCV_ASN_HDR WHERE SHIPMENT_NBR = 'NAC000905648';


select * from edsr.b2b_oc_rcv_envio where impuesto_fin != '0' and pmg_po_number = 105322 and xml_data_fin like '%32455%';

--SKUs: 28557, 28537
SELECT ROUND(125.1235,3),ROUND(125.1232,3),ROUND(125.1239,3) FROM DUAL;

--CABLES ELECTRICOS ECUATORIANOS C.A.
select * from edsr.B2B_OC_RCV_ENVIO where pmg_po_number = 110321 and impuesto_fin != '0';
select * from edsr.B2B_OC_RCV_ENVIO where pmg_po_number = 110360 and impuesto_fin != '0';

--CONAUTO
select * from edsr.B2B_OC_RCV_ENVIO where pmg_po_number = 110882 and impuesto_fin != '0';
select * from edsr.B2B_OC_RCV_ENVIO where pmg_po_number = 110922 and impuesto_fin != '0';
select * from edsr.B2B_OC_RCV_ENVIO where pmg_po_number = 110948 and impuesto_fin != '0';

SELECT * FROM EDSR.VPCMSTEE WHERE VENDOR_NUMBER = '0990018685001';

-- OBTENER EL PORCENTAJE IVA mediante SKU
DECLARE
    V_PORCENTAJE NUMBER(12,2);
    V_SKU VARCHAR2(9) := '28537'; --<w101></w101>
    V_PRECIO_NETO NUMBER := 61.992; --<w107></w107>
    V_MONTO_IGV NUMBER := 0 ;
BEGIN
    BEGIN
        SELECT FNU_GET_PRODUCTO_IVA(PRD_LVL_CHILD)
        INTO V_PORCENTAJE
        FROM TPPRDMST
        WHERE PRD_LVL_NUMBER = V_SKU;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('NO SE ENCONTRO EL SKU');
    END;

    SELECT ROUND(V_PRECIO_NETO*(V_PORCENTAJE/100),3)
    INTO V_MONTO_IGV
    FROM DUAL;

    DBMS_OUTPUT.PUT_LINE('SKU: ' || V_SKU || ' PORCENTAJE: ' || V_PORCENTAJE || ' PRECIO_NETO: ' || V_PRECIO_NETO || ' MONTO_IGV: ' || REPLACE(V_MONTO_IGV, ',','.') );
END;

/*
select * from edsr.rcvssdee where rcv_session_id in (744905, 745137) and prd_lvl_child in (113460);
select * from edsr.tpprdmst where prd_lvl_number = 24244;
select * from edsr.pmgdtlee where pmg_po_number = 100855 and prd_lvl_child in (113460);
*/
select * from edsr.WMS_ORDER_DTL_ENVIO; --CUST_SHORT_TEXT_2

-- OBTENER EL ID_IVA mediante SKU
DECLARE
    V_ID_IVA NUMBER(5);
BEGIN

    SELECT ID_IVA
    INTO V_ID_IVA
    FROM EDSRCT2.SRI_IVA_PORCENTAJE
    WHERE PORC_IVA = (
            SELECT FNU_GET_PRODUCTO_IVA(PRD_LVL_CHILD)
            FROM TPPRDMST
            WHERE PRD_LVL_NUMBER = '12266'
        );

    DBMS_OUTPUT.PUT_LINE('V_ID_IVA: ' || V_ID_IVA);
END;




BEGIN

SELECT EDSR.tp_pkg_archivos_b2b.fn_obtener_dato_comprador(1) FROM DUAL;
SELECT EDSR.tp_pkg_archivos_b2b.fn_obtener_tipo_impuesto_iva(1) FROM DUAL;
SELECT EDSR.tp_pkg_archivos_b2b.fn_obtener_tipo_cambio(1) FROM DUAL;

END;


select * from edsr.b2b_oc_rcv_envio where impuesto_fin != '0' and pmg_po_number = 101407 and xml_data_fin like '%32455%';

/*
select * from edsr.rcvssdee where rcv_session_id in (744905, 745137) and prd_lvl_child in (113460);
select * from edsr.tpprdmst where prd_lvl_number = 24244;
select * from edsr.pmgdtlee where pmg_po_number = 100855 and prd_lvl_child in (113460);
*/
select * from edsr.WMS_ORDER_DTL_ENVIO; --CUST_SHORT_TEXT_2

--CÓDIGO DE IMPUESTO
SELECT *FROM edsr.b2b_oc_rcv_envio
   WHERE pmg_po_number = 105322
     and impuesto_fin != '0';

WITH consulta AS
 (SELECT rcv_session_id
    FROM edsr.b2b_oc_rcv_envio
   WHERE pmg_po_number = 106274
     and impuesto_fin != '0')
SELECT TO_CHAR(d.rcv_session_id) || '04' AS IDTRANSACCION,  --=> ACTUALIZA AQUÍ EL CÓDIGO DE IMPUESTO
       TO_CHAR(e.pmg_po_number) AS NRO_ORDEN_COMPRA,
       edsr.tp_pkg_archivos_b2b.fn_obtener_dato_comprador(1) AS RUC_COMPRADOR,
       d.ruc_prov AS RUC_PROVEEDOR,
       TO_CHAR(d.org_lvl_number) AS LOCAL_RECEPCION,
       d.prd_lvl_number AS COD_PRODUCTO,
       d.cod_bar AS EAN_PRODUCTO,
       d.prd_full_name AS DESCRIPCION_PRODUCTO,
       NULL AS COD_PRODUCTO_PROVEEDOR,
       'UN'/*edsr.tp_pkg_archivos_b2b.fn_obtener_cod_medida(d.prd_lvl_child)*/ AS UM,
       ROUND(d.rcv_sell_qty, 3) AS CANTIDAD_RECEPCIONADA,
       0 AS COSTO_UNIT_RECEPCION_SIN_IGV,
       0 AS COSTO_UNIT_RECEPCION_CON_IGV,
       ROUND(d.rcv_case_qty * e.rcv_cost, 3) AS RECEPCION_TOTAL_SIN_IGV,
       ROUND(d.rcv_case_qty * e.rcv_cost, 3) + ROUND(NVL(g.tax_amt, 0), 3) AS RECEPCION_TOTAL_CON_IGV,
       edsr.tp_pkg_archivos_b2b.fn_obtener_tipo_impuesto_iva(d.vpc_tech_key,'4') AS TIPO_IMPUESTO,  --=> ACTUALIZA AQUÍ EL CÓDIGO DE IMPUESTO
       edsr.tp_pkg_archivos_b2b.fn_obtener_tipo_cambio(d.curr_code, e.rcv_date) AS TIPO_CAMBIO
  FROM (SELECT a.rcv_session_id,
               a.pmg_po_number,
               b.prd_lvl_number,
               a.prd_lvl_child,
               b.cod_bar,
               b.prd_full_name,
               a.pmg_dtl_tech_key,
               SUM(a.rcv_sell_qty) AS rcv_sell_qty,
               SUM(a.rcv_case_qty) AS rcv_case_qty,
               h.org_lvl_number,
               trim(h.vendor_number) AS ruc_prov,
               g.curr_code,
               g.vpc_tech_key
          FROM epmm.rcvssdee a,
               edsr.tpprdmst b,
               epmm.rcvsshee f,
               epmm.orgmstee h,
               epmm.chlrdvee j,
               epmm.pmghdree g,
               epmm.vpcmstee h
         WHERE a.prd_lvl_child = b.prd_lvl_child
           AND a.rcv_session_id = f.rcv_session_id
           AND f.org_lvl_child = h.org_lvl_child
           AND a.vpc_tech_key = j.vpc_tech_key
           AND a.rcv_session_id IN (SELECT aa.rcv_session_id FROM consulta aa)
           and g.pmg_po_number = a.pmg_po_number
           and h.vpc_tech_key = g.vpc_tech_key
         GROUP BY a.rcv_session_id,
                  a.pmg_po_number,
                  b.prd_lvl_number,
                  a.pmg_dtl_tech_key,
                  a.prd_lvl_child,
                  b.cod_bar,
                  b.prd_full_name,
                  h.org_lvl_number,
                  j.rut,
                  j.rutdv,
                  g.curr_code,
                  g.vpc_tech_key,
                  trim(h.vendor_number)) d,
       epmm.rcvssdee e,
       epmm.rcvtxsee g
 WHERE d.rcv_session_id = e.rcv_session_id
   AND d.pmg_dtl_tech_key = e.pmg_dtl_tech_key
   AND d.prd_lvl_child = e.prd_lvl_child
   AND d.pmg_po_number = e.pmg_po_number
   AND d.rcv_session_id = g.rcv_session_id(+)
   AND d.pmg_dtl_tech_key = g.pmg_dtl_tech_key(+)
   AND e.rcv_dtl_tech_key = g.rcv_dtl_tech_key(+)
   AND d.rcv_session_id IN (SELECT aa.rcv_session_id FROM consulta aa)


   and e.rcv_session_id = 745230
