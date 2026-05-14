/*
EDSR.PKG_WMS_ORDER.sp_carga_order

TRF_STATUS
0 En Trabajo
1 Aprobada
3 Enviada a Pickeo
4 Despachada TRF
5 Recepcion Completa

TRF_TYPE_CODE:
c_trf_type_id_1 = 1 => Tienda a Tienda
c_trf_type_id_3 = 3 => CD a Tienda
c_trf_type_id_4 = 4 => CD a CD

c_trf_est_pickeo = 3
 */
--------------------------------
--  TABLAS DE CONFIGURACION
--------------------------------
SELECT * FROM ORGMSTEE WHERE ORG_LVL_CHILD IN (420,419,423);
SELECT * FROM TRFSTSCD;
SELECT * FROM WMS_TIPO_INTERFAZ;
SELECT * FROM WMS_TIPO_INTEGRACION_ORG;

--------------------------------
--  TRANSFERENCIAS
--------------------------------

 SELECT * FROM TRFHDREE WHERE TRF_NUMBER IN (89149,88400,88411);
 SELECT * FROM SDITRFDTE WHERE TRF_NUMBER IN (89149,88400,88411);
 SELECT * FROM TRFDTLEE WHERE TRF_NUMBER IN (89149,88400,88411);

 SELECT sdi.trf_number,trf.trf_status,trf.trf_prior_id,sdi.action_code,sdi.trf_type_code,sdi.reference, SDI.* FROM SDITRFDTE SDI
      inner join trfhdree trf ON trf.trf_number = sdi.trf_number
 WHERE trf.TRF_NUMBER IN (40071,40072,40073,40074,40075,40076,40077,40078,40079,40080,40081,40082,40083,40084,40085,40086,50942);

 SELECT hdr.TRF_NUMBER, hdr.fec_procesado,hdr.json_response,hdr.mensaje,hdr.flg_error,hdr.text_request,hdr.* FROM wms_order_hdr_envio hdr
 WHERE TRF_NUMBER IN (89149,88400,88411);


--2da Parte
 SELECT hdr.TRF_NUMBER, hdr.fec_procesado,hdr.json_response,hdr.mensaje,hdr.flg_error,hdr.text_request,hdr.* FROM wms_order_hdr_envio hdr
 WHERE TRF_NUMBER IN (55578,56129,56733,56985,56990,56996,57967,58252,58264,58267,58846,59163,59173,59190,60015,60560,61184,61336,61378,67525,67561,67608,68211);

--Inicidencia
 SELECT hdr.TRF_NUMBER, hdr.fec_procesado,hdr.json_response,hdr.mensaje,hdr.flg_error,hdr.text_request,hdr.* FROM wms_order_hdr_envio hdr
 --WHERE TRF_NUMBER IN (81899,81880,81877,81891,81889);
 WHERE TRF_NUMBER IN (10061,10067,10068);