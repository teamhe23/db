select id_cita,appt_nbr
from wms_cita_envio
where fec_procesado >= trunc(sysdate-1)
    and flg_error = '0'
	and id_wms is null;


select * from wms_cita_envio
--update edsr.wms_cita_envio set fec_procesado = to_date(2025-03-13,'YYYY-MM-DD'),flg_error = '0',id_wms = null
where appt_nbr = '916339';
COMMIT;