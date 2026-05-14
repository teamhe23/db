/*
 * "Nro Trf"	"Carga Salida"	FECHA					SKU		"Descripción"			  "Area"	"Cant.Pedido"								"Cant.Despachada"	"Cant.Recibida.Carga"	"Cant.Recibida.Trf"	"Cos.Uni"	"Val.Tot"	"Razón Trf"	"Suc.Origen"	"Suc.Destino"	"Estado Trf"	"F.Aprob.Trf"	"F.Despa.Trf"	"F.Recep.Trf"	NRO_OC	"Tipo TRF"	"Dpto"	"Master_Pack"	"Ref."
 * 10070		OS85100000801	2023-11-09 00:00:00.000	10163	SET HERRAMIENTAS PARRILLA    4 		PZAS ORANGE	A17 - AIRE LIBRE Y TEMPORADA	16						8							8				16		10.66538	170.64608	10 - NORMAL	851	101	05.Recepcion Completa	2023-11-09 00:00:00.000	2023-12-13 00:00:00.000	2023-12-12 00:00:00.000		10 - 	D154 - PARRILLAS	8	TE-TRF-58238528
 * 
 * 
 */
select a.trf_number "Nro Trf",
       mh.trf_manifest_id "Carga Salida", --OS85100000801
       a.trf_entry_date Fecha,
       d.prd_lvl_number SKU, --10163
       d.prd_full_name "Descripción",
       d.cod_area || ' - ' || d.des_area "Area",
       b.trf_qty_req "Cant.Pedido",
       nvl(sum(dc.TRF_QTY_SHIP),
       nvl(b.trf_qty_ship, 0) + nvl(b.shp_manifest_inners, 0) +
       nvl(b.shp_carton_inners, 0)) "Cant.Despachada",
       nvl(sum(dc.TRF_REC_TO_DATE), 0) "Cant.Recibida.Carga",
       nvl(b.trf_qty_rec, 0) + nvl(b.trf_rec_mft_to_dat, 0) + nvl(b.trf_rec_ctn_to_dat, 0)  "Cant.Recibida.Trf",
       EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_log(d.prd_lvl_child,f.org_lvl_child) "Cos.Uni",
       EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_log(d.prd_lvl_child,f.org_lvl_child) *  b.trf_qty_req  "Val.Tot",
       g.trf_prior_id || ' - ' || g.trf_prior_desc "Razón Trf",
       e.org_lvl_number "Suc.Origen",
       f.org_lvl_number "Suc.Destino",
       c.trf_sts_desc "Estado Trf",
  	   a.trf_aprov_date "F.Aprob.Trf",
       a.trf_ship_date "F.Despa.Trf",
       mh.trf_rec_date  "F.Recep.Trf",
       a.pmg_po_number as Nro_OC,
       a.trf_prior_id || ' - ' || tip.trf_type_desc as "Tipo TRF",
       d.cod_dpto || ' - ' || d.des_dpto "Dpto",
       d.dist_qty  as "Master_Pack",
       a.trf_ref_number as "Ref."     
  from EDSR.trfhdree a
	 inner join EDSR.trfdtlee b
	    on a.trf_number = b.trf_number
	 inner join EDSR.trfstscd c
	    on a.trf_status = c.trf_status_id
	 inner join EDSR.tpprdmst d
	    on b.prd_lvl_child = d.prd_lvl_child
	 inner join EDSR.orgmstee e
	    on a.trf_ship_loc = e.org_lvl_child
	 inner join EDSR.orgmstee f
	    on a.trf_rec_loc = f.org_lvl_child
	 inner join EDSR.trfptyee g
	    on a.trf_prior_id = g.trf_prior_id
	 left join EDSR.trfctdee dc
	    on b.trf_number = dc.trf_number
	   and b.prd_lvl_child = dc.prd_lvl_child
	 left join EDSR.trfmfcee mc
	    on dc.trf_carton_key = mc.trf_carton_key
	 left join EDSR.trfmfhee mh
	    on mc.trf_manifest_key = mh.trf_manifest_key
	 left join EDSR.TRFPTYML rz
	    on a.trf_prior_id = rz.trf_prior_id
	 left join EDSR.TRFTYPCD tip
	    on a.trf_type_id = tip.trf_type_id 
	   and a.trf_status NOT IN (5, 96, 2)
 WHERE 
 	mh.trf_manifest_id = 'OS85100015381' -- OS85100015322
	AND f.org_lvl_number = '102'
 group by a.trf_number,
          mh.trf_manifest_id,
          a.trf_entry_date,
          d.prd_lvl_number,
          d.prd_full_name,
          d.cod_area || ' - ' || d.des_area,
          b.trf_qty_req,
          nvl(b.trf_qty_ship, 0) + nvl(b.shp_manifest_inners, 0) +
          nvl(b.shp_carton_inners, 0),
          nvl(b.trf_qty_rec, 0) + nvl(b.trf_rec_mft_to_dat, 0) +
          nvl(b.trf_rec_ctn_to_dat, 0),
          EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_log(d.prd_lvl_child,f.org_lvl_child),
          EDSR.TP_PKG_GEN_FUNCIONES.Fn_Costo_log(d.prd_lvl_child,f.org_lvl_child) * b.trf_qty_req,
          g.trf_prior_id || ' - ' || g.trf_prior_desc,
          e.org_lvl_number,
          f.org_lvl_number,
          c.trf_sts_desc,
          a.trf_aprov_date,
          a.trf_ship_date,
          mh.trf_rec_date,
          a.trf_prior_id || ' - ' || tip.trf_type_desc,
          d.cod_dpto || ' - ' || d.des_dpto,
          d.dist_qty,
          a.pmg_po_number,
          a.trf_ref_number
    FETCH FIRST 4 ROWS ONLY
     ;
