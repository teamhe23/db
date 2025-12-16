/*
tabla nueva
codPromo, sku, porc_dscto, precio_pmm, nuevo_precio

precio_pmm = chlprce2

*/
select * from promotions p where p.description like 'CR%';
select value as porc_dscto, * from rewards r;

ALTER PROCEDURE GetPromotions
--merge into, actualice o inserte
create table edsr.ifh_credito_directo(
  cod_promocion        number(12) not null,
  cod_tienda           number(12) not null,
  item_code            varchar2(15) not null,
  porc_dscto           numeric(6,4) not null,
  precio_pmm           numeric(15,3) null,
  precio_credito       numeric(15,3) null
);


select * from edsr.chlprce2;

-- Usar para actual el precio
SELECT min(prc.prc_price)
FROM edsr.chlprce2 prc
  INNER JOIN edsr.tpprdmst prd on prd.prd_lvl_child = prc.prd_lvl_child
WHERE prd.prd_lvl_number = '10016'
  AND prc.org_lvl_number = 101;


--merge into, actualice o inserte
SELECT * FROM edsr.ifh_credito_directo;

SELECT  * FROM edsr.tpprdmst;
SELECT  DISTINCT org_lvl_number FROM edsr.chlprce2;

SELECT COUNT(*)
FROM edsr.ifh_credito_directo
WHERE FLG_ELIMINAR = 1;

SELECT COUNT(*)
FROM edsr.ifh_credito_directo
WHERE FLG_ELIMINAR = 0;

SELECT COUNT(*)
FROM edsr.ifh_credito_directo;





SELECT *
FROM edsr.ifh_credito_directo
WHERE precio_credito IS NULL OR PRECIO_CREDITO IS NULL;

SELECT * FROM edsr.ifh_credito_directo
WHERE ITEM_CODE = '000032927';

SELECT min(prc.prc_price) FROM edsr.chlprce2 prc
    INNER JOIN edsr.tpprdmst prd on prd.prd_lvl_child = prc.prd_lvl_child
WHERE prd.prd_lvl_number = LTRIM('000032926', '0')
      AND prc.org_lvl_number = 101;

 SELECT LTRIM('0005785', '0') FROM DUAL;

 PROCEDURE UpdatePrice()
 AS
 BEGIN
	UPDATE edsr.ifh_credito_directo
	SET
            precio_pmm = (SELECT min(prc.prc_price) FROM edsr.chlprce2 prc INNER JOIN edsr.tpprdmst prd on prd.prd_lvl_child = prc.prd_lvl_child
                        WHERE prd.prd_lvl_number = RTRIM(edsr.ifh_credito_directo.item_code, '0')
                          AND prc.org_lvl_number = edsr.ifh_credito_directo.COD_TIENDA)

	WHERE precio_pmm = 0;


	UPDATE edsr.ifh_credito_directo
    SET
        precio_credito = precio_pmm *  (ifh_credito_directo.porc_dscto/100)
    WHERE precio_credito = 0;
 END;