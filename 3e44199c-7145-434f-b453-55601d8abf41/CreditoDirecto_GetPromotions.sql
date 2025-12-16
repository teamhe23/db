select * from promotions p where p.description like 'CR%';
select value as porc_dscto, * from rewards r;

ALTER PROCEDURE GetPromotions
AS
BEGIN
    SELECT p.code as codigoPromocion, b.code as codSucursal, rew.value as porc_descuento, rii.item_code
    FROM promotions p
       INNER JOIN REWARDS rew ON p.PROMOTIONID = rew.PROMOTIONID
       INNER JOIN record_included_items rii ON rew.reward_id = rii.RECORD_ID
       INNER JOIN branch_promotions bp ON p.PROMOTIONID = bp.PROMOTIONID
       INNER JOIN branches b ON bp.branchId = b.id
    WHERE p.description like 'CR%' AND
      (CHARINDEX('%', p.description) > 0)
END;

--sp_helptext GetPromotions

EXEC dbo.GetPromotions;

SELECT
    DISTINCT
        p.code as codigoPromocion,
        b.code as codSucursal,
        rii.item_code
        ,rew.value as porc_descuento
        ,p.description --Solo para ver description pero no va en la query orignal
FROM promotions p
   INNER JOIN REWARDS rew ON p.PROMOTIONID = rew.PROMOTIONID
   INNER JOIN record_included_items rii ON rew.reward_id = rii.RECORD_ID
   INNER JOIN branch_promotions bp ON p.PROMOTIONID = bp.PROMOTIONID
   INNER JOIN branches b ON bp.branchId = b.id
WHERE   p.description like 'CR%'
        AND (CHARINDEX('%', p.description) > 0)
        AND rii.item_code = '000033039'