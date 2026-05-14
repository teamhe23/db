/*
WMS_IMP_RCV_OC_PROC

tablas: sdircvhdi y sdircvdti

SP para procesar la recepción: RCVADDIM(var_thread_id)
*/

--header
SELECT * FROM EPMM.sdircvhdi;

--detalle
SELECT * FROM EPMM.sdircvdti;