declare
     TYPE t_cursor IS REF CURSOR;
     stock t_cursor;
BEGIN
    EDSR.HP_PKG_DAD_STOCK.SP_PROCESAR_MASIVO(stock);
END;

begin
      merge into hp_dad_stock_maestro sm
      using (select prd_lvl_child,qty, sku
               from hp_b2b_vev_s
              where TRIM(sts) = 'Activo') vev
      on (vev.prd_lvl_child = sm.prd_lvl_child AND sm.ORG_LVL_CHILD IS null)
      when matched then
        update
           set sm.cantidad = decode(sm.flag_serv,'T',999999,vev.qty);
      commit;
end;

---------------------------------------------------------------------
-- Productos LongTail con atributo L son los del VeV
---------------------------------------------------------------------
SELECT DISTINCT prd_lvl_id FROM TPPRDMST PRD;
SELECT DISTINCT prd_style_ind FROM TPPRDMST PRD;
SELECT DISTINCT cod_est FROM TPPRDMST PRD;
SELECT PRD.DES_EST, PRD.ATR_LONG_TAIL, PRD.*
FROM TPPRDMST PRD
WHERE DES_EST = 'Long Tail' AND ATR_LONG_TAIL IN ('L') FETCH FIRST 50 ROWS ONLY;

----------------------------------------------
--          HP_B2B_VEV_S
----------------------------------------------
SELECT vev.PRD_LVL_CHILD, vev.* FROM hp_b2b_vev_s vev
where SKU in ('21555');
--where SKU in ('21555','21563','21568','21570','21571','21572','21573','24377');

----------------------------------------------
--          HP_DAD_STOCK_MAESTRO
----------------------------------------------
SELECT count(*) FROM hp_dad_stock_maestro; --77434
--truncate table hp_dad_stock_maestro
SELECT * FROM hp_dad_stock_maestro;
SELECT sm.PRD_LVL_NUMBER,sm.CANTIDAD, sm.* FROM hp_dad_stock_maestro sm
where PRD_LVL_NUMBER in ('21555');
--where PRD_LVL_NUMBER in ('21555','21563','21568','21570','21571','21572','21573','24377');


-- ****** Alimentar HP_DAD_STOCK_MAESTRO ******
-- **** Cross Join => Multiplica filas de la primera tabla por filas de la segunda. 2x2, 3x4,etc ****
BEGIN
    select b.org_lvl_child,
           TO_CHAR(b.org_lvl_number) AS org_lvl_number,
           a.prd_lvl_child,
           a.prd_lvl_number,
           b.org_is_store,
           nvl(a.cod_bigtck, 'TDA') cod_bigtck,
           a.flag_serv,
           a.cod_lin
    from tpprdmst a
    cross join (select a.org_lvl_number,
                        a.org_lvl_id,
                        a.org_lvl_child,
                        a.org_is_store
                   from orgmstee a
                  where a.org_lvl_id = 1
                  start with a.org_lvl_child in (select param_value from chlparam where param_code in ('SUCTDA'))
                 connect by prior a.org_lvl_child = a.org_lvl_parent) b
    where a.prd_lvl_id in (0, 1)
       and a.prd_style_ind = 'F'
       and a.cod_est not in (3, 96, 97, 98, 99)
    UNION ALL --VeV
    SELECT   NULL, --'org_lvl_child',
             LPAD(a.cod_prv, 13, '0') AS org_lvl_number,
             a.prd_lvl_child,
             a.prd_lvl_number,
             'P',
             a.cod_bigtck,
             a.flag_serv,
             a.cod_lin
             ,a.DES_EST,a.ATR_LONG_TAIL
    FROM edsr.tpprdmst a
    WHERE a.prd_lvl_id IN (0, 1)
         AND a.prd_style_ind = 'F'
         AND a.cod_est NOT IN (3, 96, 97, 98, 99)
         AND a.des_est='Long Tail'
         --AND a.ATR_LONG_TAIL IN ('L')
        AND PRD_LVL_NUMBER IN ('21555')
    ORDER BY org_lvl_number, prd_lvl_number;
END;

-----------------------------------------
--      Costos => actualizar_costo
-----------------------------------------
/*
    Campo COSTO
    actualizar_costo:
        1. Criterio 01: prd_lvl_child | cstmstee y capstree
        2. Criterio 02: prd_lvl_child | cstmstee y cst_zone_id = 0
        3. Criterio 03: Si es null setea a 0.1
 */
SELECT CST.cst_zone_id, CST.* FROM cstmstee CST;
SELECT Z.cst_zone_id, Z.* FROM capstree Z; --Verificar el CST_ZONE_ID de la 102
SELECT DISTINCT cst_zone_id FROM cstmstee WHERE cst_zone_id = 0; -- cst_zone_id => 0 y 25

SELECT sm.COSTO,
       sm.*
FROM hp_dad_stock_maestro SM
WHERE ORG_LVL_CHILD IS NULL;

--Estos productos LongTail VeV no tienen costos definidos
SELECT CST.cst_zone_id, CST.*
FROM cstmstee CST
    INNER JOIN TPPRDMST PRD ON PRD.PRD_LVL_CHILD = CST.PRD_LVL_CHILD
where PRD.PRD_LVL_NUMBER in ('21555','21563','21568','21570','21571','21572','21573','24377');

-----------------------------------------
--      PRECIOS => actualizar_precio
-----------------------------------------
--HP_DAD_STOCK_MAESTRO (MST)
SELECT sm.PRC_VIG,
       sm.PRC_ETI,
       sm.*
FROM hp_dad_stock_maestro SM
WHERE ORG_LVL_CHILD IS NULL;
SELECT * FROM hp_prceti_fec;

-- actualizar precio etiqueta => MST.prd_lvl_child = HP_PRCETI_FEC.prd_lvl_child y HP_PRCETI_FEC.org_lvl_child = 0
    SELECT PRC.PRC_PRICE, PRC.* FROM HP_PRCETI_FEC PRC;
    SELECT PRC.PRC_PRICE, PRC.* FROM HP_PRCETI_FEC PRC WHERE prc.org_lvl_child = 0;

-- actualizar precio vigente => MST.prd_lvl_child = HP_PRECIOS_DIARIO.prd_lvl_child y MST.org_lvl_child = HP_PRECIOS_DIARIO.org_lvl_child
    SELECT prc.prc_price, PRC.* FROM HP_PRECIOS_DIARIO PRC;

-- Productos sin precio vigente
   -- Si PRC_VIG es null => stk.prc_vig = stk.prc_eti

-- Si PRC_VIG y PRC_ETI son NULL => Ambos son 0.1

-----------------------------------------
--      INTEGRACION API DAD
-----------------------------------------
