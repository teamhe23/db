SELECT * FROM TPINTGENLOG WHERE FEC_GEN >= SYSDATE - 2 ORDER BY FEC_GEN DESC;

SELECT '"' || RTRIM(RPAD(REPLACE(ORG.ORG_LVL_NUMBER, '"', '""'), 5)) || '",' || '"' ||
             RTRIM(RPAD(REPLACE(ORG.ORG_NAME_FULL, '"', '""'), 30)) || '",' || '"' ||
             RTRIM(RPAD(REPLACE(BAS.BAS_ADDR_1, '"', '""'), 30)) || '",' || '"' ||
             RTRIM(RPAD(REPLACE(BAS.BAS_STATE, '"', '""'), 20)) || '",' || '"' ||
             RTRIM(RPAD(DECODE(ORG.ORG_IS_STORE, 'T', 'L', 'B'), 1)) || '",' || '"' ||
             RTRIM(RPAD(REPLACE((SELECT ORG_LVL_NUMBER
                                  FROM ORGMSTEE
                                 WHERE ORG_LVL_CHILD = ORG.ORG_LVL_PARENT),
                                '"',
                                '""'),
                        20)) || '",' || ROWNUM || ',' || 1 AS REGISTRO
        FROM ORGMSTEE ORG,
             ORGMSTEE B,
             ORGDTLEE DTL,
             BASADREE BAS,
             IFH_SUC_FECAP FA
       WHERE ORG.ORG_LVL_PARENT = B.ORG_LVL_CHILD(+)
         AND ORG.ORG_LVL_ID = 1
         AND ORG.ORG_LVL_CHILD = DTL.ORG_LVL_CHILD(+)
         AND DTL.BAS_ADD_KEY = BAS.BAS_ADD_KEY(+)
         AND ORG.ORG_LVL_CHILD = FA.ORG_LVL_CHILD(+)
         AND (FA.FEC_APE <= TRUNC(v_fec_pmm) OR ORG.ORG_IS_STORE = 'F')
       START WITH ORG.ORG_LVL_CHILD =
                  (SELECT PARAM_VALUE
                     FROM CHLPARAM
                    WHERE PARAM_CODE = 'SUCTDA')
      CONNECT BY PRIOR ORG.ORG_LVL_CHILD = ORG.ORG_LVL_PARENT;