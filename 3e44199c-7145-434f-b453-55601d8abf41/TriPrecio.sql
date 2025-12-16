/*
1. Llenar en ifh_triprecio_vencer, todos los productos que NO SON TRIPRECIO.
2. Vencer a esos productos.
*/

SELECT * FROM dbo.ifh_triprecio_vencer;

-- ELIMINAR TABLA
CREATE PROCEDURE ifh_eliminar_triprecio
AS
BEGIN
    TRUNCATE TABLE dbo.ifh_triprecio_vencer;
END

-- sp_helptext ifh_eliminar_triprecio

-- VENCER PRODUCTOS
CREATE PROCEDURE ifh_agregarProducto_triprecio
    @CodigoTienda int,
    @ItemCodigo varchar(20)
AS
BEGIN
    INSERT INTO dbo.ifh_triprecio_vencer(cod_tienda, item_code) VALUES (@CodigoTienda,@ItemCodigo);
END

-- sp_helptext ifh_agregarProducto_triprecio
-- sp_helptext ifh_cierra_triprecio

    SELECT endDate,* FROM dbo.promotions
-- VENCER PRODUCTOS
ALTER PROCEDURE dbo.ifh_cierra_triprecio
AS
BEGIN
	DECLARE @promotion_category_precio_fijo_x_volumen NUMERIC(1) = 3

	UPDATE dbo.promotions SET endDate = DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
	FROM dbo.promotions promo
	WHERE EXISTS (
		SELECT	TOP (1)
				p.promotionId
		FROM dbo.record_included_items i
			INNER JOIN dbo.records r ON i.record_id = r.id
			INNER JOIN dbo.promotions p ON r.promotionId = p.promotionId
			INNER JOIN dbo.branch_promotions b ON b.promotionId = p.promotionId
			INNER JOIN dbo.branches branch ON branch.id = b.branchId
            INNER JOIN dbo.ifh_triprecio_vencer v ON  v.cod_tienda = branch.code and try_cast(v.item_code as int) =  try_cast(i.item_code as int)
		WHERE	p.promotionCategoryid = @promotion_category_precio_fijo_x_volumen
			AND p.promotionCategoryId IS NOT NULL
			AND p.endDate >= CAST(GETDATE() AS DATE)
			AND p.promotionId = promo.promotionId
	)
END


EXEC dbo.ifh_cierra_triprecio;

    UPDATE dbo.ifh_triprecio_vencer SET cod_tienda = 2;
    SELECT * FROM dbo.ifh_triprecio_vencer;
    SELECT * FROM dbo.branches branch;
    SELECT promotionId,promotionCategoryid,endDate,* FROM dbo.promotions p ;
    SELECT COUNT(*) FROM dbo.promotions p ;
    SELECT COUNT(*) FROM dbo.promotions p WHERE	p.promotionCategoryid = 3;

    SELECT COUNT(*) FROM dbo.record_included_items i
         INNER JOIN dbo.ifh_triprecio_vencer v ON try_cast(v.item_code as int) =  try_cast(i.item_code as int)

  SELECT  *
  FROM dbo.promotions promo
	WHERE EXISTS (
		SELECT	--TOP (1)
				p.promotionId
		FROM dbo.record_included_items i
			INNER JOIN dbo.records r ON i.record_id = r.id
			INNER JOIN dbo.promotions p ON r.promotionId = p.promotionId
			INNER JOIN dbo.branch_promotions b ON b.promotionId = p.promotionId
			INNER JOIN dbo.branches branch ON branch.id = b.branchId
            INNER JOIN dbo.ifh_triprecio_vencer v ON  v.cod_tienda = branch.code and try_cast(v.item_code as int) =  try_cast(i.item_code as int)
		WHERE -- p.promotionCategoryid = @promotion_category_precio_fijo_x_volumen
			-- p.promotionCategoryId IS NOT NULL AND
			 p.endDate >= CAST(GETDATE() AS DATE)
			AND p.promotionId = promo.promotionId
	)

SELECT DATEADD(DAY, -1, CAST(GETDATE() AS DATE))


select * from edsr.tpprdmst where prd_lvl_number = '10101'; --tabla maestra de producto general (aplanada)
select * from edsr.hprangoprecio where sku = '10101';
select * from edsr.dpc_tienda_campana;

/*
update edsr.hprangoprecio set inicio = trunc(sysdate);
--where sku = '10101'
COMMIT;

Probar omitiendo
       campaignDescription
       campaignStartDate
       campaignEndDate
       campaignBranches

es un job, que se ejecuta una vez al día (5:00am); enviando las promos de volumen al DPC
por cada fila del select un JSON y una promo en DPC
EDSR.PKG_DPC_RANGO_PRECIO

*/
SELECT * FROM edsr.dpc_tienda_campana TC;
UPDATE edsr.dpc_tienda_campana TC SET SUCURSAL = 2;

SELECT TC.SUCURSAL,
       TC.ID_CAMPANA,
       TC.Des_Campana,
       LPAD(TRIM(R.SKU), 9, 0) SKU,
       R.PRECIO,
       R.RANGO1 CANTIDAD1,
       R.PRECIO1,
       R.RANGO2 CANTIDAD2,
       R.PRECIO2,
       R.INICIO,
       R.FIN,
       SUBSTR(R.DESCRIPCION,0,40) AS DESC_PROMO
FROM EDSR.HPRANGOPRECIO R
    INNER JOIN edsr.dpc_tienda_campana TC ON TC.SUCURSAL = R.SUCURSAL
WHERE R.INICIO = TRUNC(SYSDATE);

SELECT * FROM EDSR.HPRANGOPRECIO;
SELECT * FROM edsr.dpc_tienda_campana;


-- PROCEDURE SP_GET_PRODUCTO_SIN_TRIPRECIO
SELECT LPAD(TRIM(C.PRODUCT_NUMBER), 9, 0) PRD_LVL_NUMBER,
             C.ORG_LVL_NUMBER
FROM EDSR.CHLPRCE2 C
WHERE C.PRC_FROM_DATE >= trunc(sysdate) - 10
      AND C.PRC_QTY_BRK_ID IS NULL
GROUP BY C.PRODUCT_NUMBER, C.ORG_LVL_NUMBER;


SELECT LPAD(TRIM(C.PRODUCT_NUMBER), 9, 0) PRD_LVL_NUMBER,
             C.ORG_LVL_NUMBER
FROM EDSR.CHLPRCE2 C;

SELECT * FROM EDSR.CHLPRCE2;

SELECT * FROM ALL_SYNONYMS WHERE SYNONYM_NAME = 'CHLPRCE2';
SELECT * FROM ALL_SYNONYMS WHERE SYNONYM_NAME = 'dpc_tienda_campana';

