--  pro.promotionId = 11402
SELECT pro.promotionId,
           pro.code,
           pro.description,
           rew.rewardType,
           pro.startDate,
           pro.endDate,
           'PRF' as tipo,
           pro.startTime,
           pro.endTime
FROM dbo.promotions pro
 INNER JOIN dbo.rewards rew ON pro.promotionId = rew.promotionId
WHERE  pro.code = 393

SELECT rewardType,promotionId, * FROM dbo.rewards --WHERE promotionId IN (11402)
--UPDATE dbo.rewards SET rewardType = 1
WHERE  promotionId IN (11403)

SELECT state,* FROM dbo.promotions pro WHERE  description = 'CR % DE DESCUENTO'
SELECT state,* FROM dbo.promotions pro WHERE  description LIKE '%CR%'


CREATE PROCEDURE dbo.HP_VTEX_PROMOCIONES
as
BEGIN
SET NOCOUNT ON

	DECLARE @promociones TABLE (
	  promotionId 	int,
	  code			int,
	  description	varchar(29),
	  startDate		date,
	  endDate		date,
	  tipo			char(3),
	  startTime		varchar(5),
	  endTime		varchar(5)
	)


	insert into @promociones
	SELECT pro.promotionId,
           pro.code,
           pro.description,
           pro.startDate,
           pro.endDate,
           'PRF' as tipo,
           pro.startTime,
           pro.endTime
    FROM dbo.promotions pro
         INNER JOIN dbo.rewards rew ON pro.promotionId = rew.promotionId
    WHERE pro.state = 1--#Confirmadas
      AND pro.promotionId = 11402
      AND (
	      	(CHARINDEX('PRECIO', pro.description) > 0)
	      	or
	      	(CHARINDEX('KITS', pro.description) > 0)
            or
            (CHARINDEX('CR', pro.description) > 0 )
	      )
      AND concat(CAST(pro.endDate as CHAR(10)), ' ', pro.endTime) >= getdate()
      --AND (getdate() between pro.startDate AND pro.endDate)
      AND (CONVERT(VARCHAR(8),getdate(),112) between CONVERT(VARCHAR(8),pro.startDate,112) AND CONVERT(VARCHAR(8),pro.endDate, 112 ) )
      AND (rew.rewardType = 3)
      AND (rew.itemsQuantityToBenefit = 1 and rew.itemsQuantityToExecute = 1) --#add filtro por incidencia
      AND pro.promotionId IN
          (
           SELECT rec.promotionId
           FROM dbo.records rec
                    INNER JOIN dbo.promotions pro ON pro.promotionId = rec.promotionId
           WHERE concat(CAST(pro.endDate as CHAR(10)), ' ', pro.endTime) >= getdate()
           GROUP BY rec.promotionId
           HAVING COUNT(rec.promotionId) = 1
          )
    UNION
    SELECT pro.promotionId,
           pro.code,
           pro.description,
           pro.startDate,
           pro.endDate,
           'PRC',
           pro.startTime,
           pro.endTime
    FROM dbo.promotions pro
         INNER JOIN dbo.rewards rew ON pro.promotionId = rew.promotionId
    WHERE pro.state = 1--#Confirmadas
     -- AND pro.promotionId = 11403
      AND (CHARINDEX('%', pro.description) > 0)
      AND pro.description  like 'CR%'
      AND (CHARINDEX('ADC', pro.description) = 0)
      --AND (getdate() between pro.startDate AND pro.endDate)
      AND (CONVERT(VARCHAR(8),getdate(),112) between CONVERT(VARCHAR(8),pro.startDate,112) AND CONVERT(VARCHAR(8),pro.endDate, 112 ) )
      AND (rew.rewardType = 1)
      AND (rew.itemsQuantityToBenefit = 1 and rew.itemsQuantityToExecute = 1) --#add filtro por incidencia
      AND pro.promotionId IN
          (
           SELECT rec.promotionId
           FROM dbo.records rec
                    INNER JOIN dbo.promotions pro ON pro.promotionId = rec.promotionId
           WHERE concat(CAST(pro.endDate as CHAR(10)), ' ', pro.endTime) >= getdate()
           GROUP BY rec.promotionId
           HAVING COUNT(rec.promotionId) <= 2 -- antes era solo  1
          )


  	--PROMOCIONES
  	SELECT p.*,
           CAST(SUBSTRING(rew.VALUE, 1, 10) AS DECIMAL(11, 2)) AS valor,
           rew.limitQuantity
    FROM @promociones p
         INNER JOIN REWARDS rew ON p.PROMOTIONID = rew.PROMOTIONID
    WHERE try_cast(rew.value as NUMERIC(11, 2)) is not null

    --PROMOCIÓN TIENDA
	SELECT p.promotionId,
           case when bd.code = 199 then 101 else bd.code end as tienda
    FROM @promociones p
	     INNER JOIN branch_promotions bp ON p.PROMOTIONID = bp.PROMOTIONID
	     INNER JOIN branches b ON bp.branchId = b.id
	     INNER JOIN branch_group_branches bg ON b.id = bg.group_id
	     INNER JOIN branches bd ON bg.branch_id = bd.id
    WHERE b.type = 'G'
    UNION
    SELECT p.promotionId,
           case when b.code = 199 then 101 else b.code end as tienda
    FROM @promociones p
         INNER JOIN branch_promotions bp ON p.PROMOTIONID = bp.PROMOTIONID
         INNER JOIN branches b ON bp.branchId = b.id
    WHERE b.type = 'B'

    --PROMOCIÓN PRODUCTO
    SELECT DISTINCT p.promotionId,
                    try_cast(ITEM_CODE AS DECIMAL) as item_code,
                    'I' as tipo
    FROM @promociones p
         INNER JOIN REWARDS rew ON rew.PROMOTIONID = p.PROMOTIONID
         INNER JOIN record_included_items rii ON rew.reward_id = rii.RECORD_ID
    union
    SELECT DISTINCT p.promotionId,
    			try_cast(ITEM_CODE AS DECIMAL) as item_code,
           			'E' as tipo
    FROM @promociones p
         INNER JOIN records rc ON rc.PROMOTIONID = p.PROMOTIONID
         INNER JOIN record_excluded_items rcei ON rc.id = rcei.record_id
END

go

