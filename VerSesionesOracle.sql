SELECT sid, serial#, username, status,machine,program, v.*
FROM v$session v
WHERE MACHINE = 'DESKTOP-3VRQPP3'
--WHERE username = 'USR_DEVTI' and PROGRAM = 'DataGrip'
;

SELECT
    s.sid,
    s.serial#,
    s.username,
    s.status,
    s.sql_id,
    q.sql_text
FROM
    v$session s
JOIN
    v$sql q ON s.sql_id = q.sql_id
WHERE
    q.sql_text LIKE '%PIV_TRX_BCT_HEAD%'  -- Reemplaza con el nombre de tu tabla
    AND s.status = 'ACTIVE';  -- Solo mostrar sesiones activas
