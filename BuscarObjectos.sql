SELECT *
FROM dba_objects
WHERE upper(object_name) like 'FN_FE%';

SELECT *
FROM dba_source
WHERE
    upper(name) like 'FN_FEC%' and --dba_source
   type = 'FUNCTION'
ORDER BY line;

SELECT *
FROM dba_synonyms
WHERE  upper(synonym_name) like 'FN_%'; --FN_FEC_APE

