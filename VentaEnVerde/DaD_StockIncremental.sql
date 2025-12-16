SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%INSERT%HP_PRCETI_FEC%';
SELECT * FROM DBA_SOURCE WHERE UPPER(TEXT) LIKE '%SP_PRECIOS_MAESTRO_DIARIO%';
SELECT * FROM ALL_SOURCE WHERE UPPER(TEXT) LIKE '%HP_PRCETI_FEC%';

/*
 HP_DAD_STOCK_ANTERIOR  => 75948 REGISTROS
 HP_DAD_STOCK_ACTUAL    => 75964 REGISTROS
 HP_DAD_STOCK_DIFF    => 1129 REGISTROS
 */
truncate table hp_dad_stock_actual;
-- Data inicial del stock actual
insert into hp_dad_stock_actual
(org_lvl_child,
 org_lvl_number,
 prd_lvl_child,
 prd_lvl_number,
 org_is_store,
 cod_bigtck,
 flag_serv,
 cantidad)
select org_lvl_child,
       org_lvl_number,
       prd_lvl_child,
       prd_lvl_number,
       org_is_store,
       cod_bigtck,
       flag_serv,
       cantidad
  from hp_dad_stock_maestro
  WHERE ORG_LVL_CHILD IS NOT null;
commit;

--MAESTRO
SELECT * FROM HP_DAD_STOCK_MAESTRO  WHERE PRD_LVL_NUMBER = '21555';
--ANTERIOR
SELECT * FROM HP_DAD_STOCK_ANTERIOR  WHERE PRD_LVL_NUMBER = '21555';
--ACTUAL
SELECT * FROM HP_DAD_STOCK_ACTUAL WHERE PRD_LVL_NUMBER = '21555';
--DIFF
SELECT * FROM HP_DAD_STOCK_DIFF WHERE PRD_LVL_NUMBER = '21555';
SELECT * FROM HP_DAD_STOCK_DIFF WHERE PRD_LVL_NUMBER = '21555';

/*
 Es nul cuando es de VeV
 */
--ANTERIOR
SELECT * FROM HP_DAD_STOCK_ANTERIOR  WHERE org_lvl_number is null;
SELECT distinct org_lvl_number FROM HP_DAD_STOCK_ANTERIOR;
--ACTUAL
SELECT * FROM HP_DAD_STOCK_ACTUAL WHERE ORG_LVL_NUMBER is null;

--ACTUAL:
    delete from hp_dad_stock_anterior a
     where not exists (select *
              from hp_dad_stock_diff d
             where d.flg_procesado = 'F'
               and d.org_lvl_child = a.org_lvl_child
               and d.prd_lvl_child = a.prd_lvl_child);

     insert into hp_dad_stock_anterior
      select *
        from hp_dad_stock_actual a
       where not exists (select *
                from hp_dad_stock_diff d
               where d.flg_procesado = 'F'
                 and d.org_lvl_child = a.org_lvl_child
                 and d.prd_lvl_child = a.prd_lvl_child);

-- truncate table hp_dad_stock_actual;

--DIFF
    select nvl2(ant.org_lvl_number, 'UPD', 'NEW') flg_tipo,
             nvl(ant.org_lvl_child, act.org_lvl_child) org_lvl_child,
             nvl(ant.org_lvl_number, act.org_lvl_number) org_lvl_number,
             nvl(ant.prd_lvl_child, act.prd_lvl_child) prd_lvl_child,
             nvl(ant.prd_lvl_number, act.prd_lvl_number) prd_lvl_number,
             nvl(ant.cantidad, 0) cantidad_ant,
             nvl(act.cantidad, 0) cantidad_act,
             case
               when nvl(ant.cantidad, 0) < nvl(act.cantidad, 0) then
                'ADD'
               else
                'SUBTRACT'
             end operation,
             abs(nvl(ant.cantidad, 0) - nvl(act.cantidad, 0)) cantidad_var
        from hp_dad_stock_anterior ant
        full outer join hp_dad_stock_actual act
          on ant.org_lvl_child = act.org_lvl_child
         and ant.prd_lvl_child = act.prd_lvl_child
       where nvl(ant.cantidad, 0) <> nvl(act.cantidad, 0);

--Diferencia Stock  (sp_leer_dif_stock_inc)
select * from HP_DAD_STOCK_DIFF;

SELECT 'HESA' || '-' || a.org_lvl_number as entityCode,
             A.OPERATION as operationType,
             A.CANTIDAD_VAR as quantity,
             A.PRD_LVL_NUMBER as skuCode,
             a.org_lvl_number
        FROM EDSR.HP_DAD_STOCK_DIFF a
       WHERE A.FLG_PROCESADO = 'F'
         AND A.FLG_TIPO = 'UPD'
         AND A.OPERATION = 'ADD'
         and CANTIDAD_VAR >= nvl((select to_number(param_value)
                                   from edsr.chlparam
                                  where param_code = 'DADMINSTK'),
                                 0)
      UNION ALL
      SELECT 'HESA' || '-' || a.org_lvl_number as entityCode,
             A.OPERATION as operationType,
             A.CANTIDAD_VAR as quantity,
             A.PRD_LVL_NUMBER as skuCode,
             a.org_lvl_number
        FROM EDSR.HP_DAD_STOCK_DIFF a
       WHERE A.FLG_PROCESADO = 'F'
         AND A.FLG_TIPO = 'UPD'
         AND A.OPERATION = 'SUBTRACT'
         and CANTIDAD_VAR >= nvl((select to_number(param_value)
                                   from edsr.chlparam
                                  where param_code = 'DADMINSTK'),
                                 0)
      UNION ALL
        SELECT 'HESA' || '-' || org_lvl_number as entityCode,
            OPERATION as operationType,
            DIFERENCIA as quantity,
            PRD_LVL_NUMBER as skuCode,
            ORG_LVL_NUMBER
        FROM HE_DAD_VEV_STOCK_ACTUAL
        WHERE FLG_DIFERENCIA = 'T'
            AND FLG_PROCESADO = 'F'
;