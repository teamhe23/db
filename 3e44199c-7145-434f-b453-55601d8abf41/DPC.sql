/*
usuario: sdpc
clave: HH$2044.BTA

create sequence edsr.seq_dpc_pl_carga minvalue 1 maxvalue 999999999999999999 start with 1 increment by 1 nocache;

create table edsr.dpc_pl_carga(
  id_carga    numeric(18) not null,
  descripcion varchar2(255) null,
  fec_reg     date default sysdate not null,
  usr_reg     varchar2(45) not null,
  constraint pk_dpc_pl_carga primary key(id_carga)
);

create table edsr.dpc_pl_carga_promo (
  id_carga      numeric(18) not null,
  id_promocion  numeric(18) null,
  desc_pmt      varchar2(255) null,
  fec_inicio    date not null,
  fec_final     date not null,
  sucursal      number(12) not null,
  precio        number(15,5) not null,
  prioridad     number(3) not null,
  tipo          char(1) not null,
  sku           varchar2(15) not null,
  tarjeta_oh    char(1) not null,
  grupo_promo   varchar2(20) not null,
  observacion   varchar2(255) null,
  centro_costo  varchar2(15) not null,
  flg_error     char(1) null,
  mensaje_error varchar2(255) null
);
*/

select edsr.seq_dpc_pl_carga.nextval from dual;
select * from edsr.dpc_pl_carga ORDER BY ID_CARGA DESC;
select * from edsr.dpc_pl_carga_promo;

SELECT * FROM dpc_pl_carga order by ID_CARGA DESC;
SELECT MAX(ID_CARGA) FROM dpc_pl_carga_promo;
SELECT
		 	id_carga,
			id_promocion,
			desc_pmt,
			fec_inicio,
			fec_final,
			sucursal,
			precio,
			prioridad,
			tipo,
			sku,
			tarjeta_oh,
			grupo_promo,
			observacion,
			centro_costo
		 FROM dpc_pl_carga_promo
		 WHERE ID_CARGA = 56;