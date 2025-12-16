SELECT * FROM EDSR.HPB2BINV WHERE SKU IN ('21555') ORDER BY CREATED_DATE DESC;
select * from EDSR.HP_B2B_VEV_S ORDER BY CREATED_DATE DESC;
SELECT * FROM EDSR.HP_B2B_VEV_S WHERE SKU IN ('21555','21575','21576','21577','21578','21579','34559','35084','21563','21568','21570','21571','21572','21573','21574','24377');


-------------------------------------
--Para actualizar el stock
-------------------------------------

select * from EDSR.HP_SUC_VTEX;
select * from EDSR.CSTMSTEE;
select * from EDSR.CAPSTREE;


SELECT DISTINCT PROVEEDOR, to_date(sysdate, 'dd-mm-yyyy'), 1, PROVEEDOR, 'E', null, null, null, null,
       null, null, null, null, 'T', 'F', PROVEEDOR, 40, 'F', null FROM EDSR.Hpb2binv;