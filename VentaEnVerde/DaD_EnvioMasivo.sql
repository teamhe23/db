SELECT * FROM hp_dad_stock_maestro_log;
ALTER TABLE hp_dad_stock_maestro_log ADD (REQUEST CLOB);


-----------------------------------------
--      INTEGRACION API DAD
-----------------------------------------
SELECT log.REQUEST, log.* FROM edsr.hp_dad_stock_maestro_log log
ORDER BY fec_reg DESC
FETCH FIRST 20 ROWS ONLY;