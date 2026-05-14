/*

0	Variacion                          	VAR
1	Producto/Estilo                    	PRD/EST 
2	Linea                              	LINEA   
3	Departamento                       	DEPTO   
4	Area                               	AREA    
5	Division                           	DIVISION

*/
--Niveles de la jerarquía
SELECT * FROM EPMM.PRDCTLEE FETCH FIRST 20 ROWS ONLY;
--Maestra de status
SELECT * FROM EPMM.PRDSTSEE FETCH FIRST 20 ROWS ONLY;
--Maestro de productos
SELECT * FROM EPMM.PRDMSTEE WHERE PRD_LVL_ID = 1  FETCH FIRST 20 ROWS ONLY;
--Auditoría Maestro de productos
SELECT * FROM EPMM.PRDMSTAE FETCH FIRST 20 ROWS ONLY;
--Maestra de hist status
SELECT * FROM EPMM.PRDSTEEE FETCH FIRST 20 ROWS ONLY;
--Maestra status por local
SELECT * FROM EPMM.PRDSBLEE FETCH FIRST 20 ROWS ONLY;
--Maestra de hist status por local
SELECT * FROM EPMM.PRDSTLEE FETCH FIRST 20 ROWS ONLY;
--Relación entre padre-hijo de PRD
SELECT * FROM EPMM.PRDPLVEE FETCH FIRST 20 ROWS ONLY;