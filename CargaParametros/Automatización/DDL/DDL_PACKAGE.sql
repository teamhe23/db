CREATE OR REPLACE PACKAGE EDSR.PKG_CARPAR_CARGA AS
    PROCEDURE RUN_DYNAMIC(p_process_id IN VARCHAR2, p_usuario IN VARCHAR2);
    PROCEDURE RUN_MINMAX (p_process_id IN VARCHAR2, p_usuario IN VARCHAR2);
END PKG_CARPAR_CARGA;
/

CREATE OR REPLACE PACKAGE BODY EDSR.PKG_CARPAR_CARGA AS

    PROCEDURE upd(
        p_process_id VARCHAR2,
        p_status     VARCHAR2,
        p_p          VARCHAR2,
        p_detail     VARCHAR2,
        p_err        VARCHAR2 DEFAULT NULL
    ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE EDSR.CARPAREPO
            SET STATUS         = p_status,
                PROCESS        = p_p,
                DETAIL_PROCESS = p_detail,
                ERROR_MSG      = p_err
        WHERE PROCESS_ID = p_process_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END;

    PROCEDURE start_process(
        p_process_id VARCHAR2
    ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE EDSR.CARPAREPO
            SET PROCESS_START  = SYSTIMESTAMP
        WHERE PROCESS_ID = p_process_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END;

    PROCEDURE end_process(
        p_process_id VARCHAR2
    ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE EDSR.CARPAREPO
            SET PROCESS_END = SYSTIMESTAMP
        WHERE PROCESS_ID = p_process_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END;

    PROCEDURE RUN_DYNAMIC(p_process_id IN VARCHAR2, p_usuario IN VARCHAR2) IS
        v_p   VARCHAR2(10) := 'P1';
        v_det VARCHAR2(4000) := 'Iniciando el proceso de carga de parámetros DYNAMIC';

        TOTAL NUMBER := 0;
        MINIMO NUMBER := 0;
        MAXIMO NUMBER := 0;

        p_secuencia NUMBER;
        V_PRD_LVL_NUMBER VARCHAR2(15);
        TOTAL_PARAMETROS NUMBER := 0;
        TOTAL_SKUS_CROSSDOCKING NUMBER := 0;

        intTotSemanas NUMBER := 0;
        strFijo CHAR;
        intDiaRevision NUMBER(3);
        intDiaProceso NUMBER(3);
        intSemSR NUMBER(3);
        dblPorServicio NUMBER(4, 2);
        intSemVenta NUMBER(7);

        v_count NUMBER := 0;

        CURSOR cur_conflict IS
            SELECT t.RPL_SEQ,
                    t.RPL_SEQ_REG,
                    t.WGT_WEEK
            FROM EDSR.TEMP_TPCARSEM t
            WHERE EXISTS (
                SELECT 1
                FROM EDSR.TPCARSEM c
                WHERE NVL(c.RPL_SEQ, -999999)       = NVL(t.RPL_SEQ, -999999)
                    AND NVL(c.RPL_SEQ_REG, -999999)   = NVL(t.RPL_SEQ_REG, -999999)
                    AND NVL(c.WGT_WEEK, -999999)      = NVL(t.WGT_WEEK, -999999)
            )
            ORDER BY t.RPL_SEQ, t.RPL_SEQ_REG, t.WGT_WEEK;

    BEGIN
        upd(p_process_id, 'RUNNING', v_p, v_det);
        start_process(p_process_id);

        v_p := 'P2'; 
        v_det := 'Calculando el total de parámetros'; 
        upd(p_process_id, 'PROCESSING', v_p, v_det);


        SELECT COUNT(*)
        INTO TOTAL
        FROM EDSR.temp_CargaMasiva_ParametrosPMM;

        v_p := 'P3'; 
        v_det := 'Carga Inicial. Total de parámetros para la carga: ' || TO_CHAR(TOTAL);
        upd(p_process_id, 'PROCESSING', v_p, v_det);

        IF TOTAL > 0 THEN
            SELECT MIN(ID), MAX(ID)
            INTO MINIMO,MAXIMO
            FROM EDSR.temp_CargaMasiva_ParametrosPMM
            ;

            v_p := 'P4'; 
            v_det := 'Generación de secuencia: ' || TO_CHAR(p_secuencia);
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            SELECT EDSR.TP_SEQ_RPL_SEQ.NEXTVAL
            INTO p_secuencia
            FROM DUAL;

            v_p := 'P4'; 
            v_det := 'Transformando carga por cada registro de un total de '|| TO_CHAR(TOTAL) ||'. Secuencia: '|| TO_CHAR(p_secuencia);
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            DBMS_OUTPUT.PUT_LINE('TOTAL: ' || TOTAL);
            DBMS_OUTPUT.PUT_LINE('MINIMO: ' || MINIMO);
            DBMS_OUTPUT.PUT_LINE('MAXIMO: ' || MAXIMO);
            DBMS_OUTPUT.PUT_LINE('Secuencia: ' || p_secuencia);

            DBMS_OUTPUT.PUT_LINE('>>>>>>>>> INICIO BUCLE <<<<<<<<<');
            WHILE MINIMO <= MAXIMO LOOP
                SELECT E_PRODUCTO
                INTO V_PRD_LVL_NUMBER
                FROM EDSR.temp_CargaMasiva_ParametrosPMM
                WHERE ID = MINIMO;

                SELECT COUNT(*)
                INTO TOTAL_PARAMETROS
                FROM TPPARREP REP,
                    TPPRDMST PRD
                WHERE REP.COD_DIV = PRD.COD_DIV
                    AND REP.COD_AREA = PRD.COD_AREA
                    AND REP.COD_DPTO = PRD.COD_DPTO
                    AND REP.COD_LIN = PRD.COD_LIN
                    AND PRD.PRD_LVL_NUMBER = V_PRD_LVL_NUMBER;
                
                IF TOTAL_PARAMETROS > 0 THEN
                SELECT REP.RPL_FIJO, REP.RPL_REVIEW_DAYS, REP.RPL_PROC_DAYS, REP.RPL_SS, REP.PMH_SERV_LVL, REP.PRF_WGT_WEEKS
                INTO strFijo,  intDiaRevision,  intDiaProceso,  intSemSR,  dblPorServicio,  intSemVenta
                FROM TPPARREP REP,
                    TPPRDMST PRD
                WHERE REP.COD_DIV = PRD.COD_DIV
                    AND REP.COD_AREA = PRD.COD_AREA
                    AND REP.COD_DPTO = PRD.COD_DPTO
                    AND REP.COD_LIN = PRD.COD_LIN
                    AND PRD.PRD_LVL_NUMBER = V_PRD_LVL_NUMBER
                    AND ROWNUM = 1;

                DBMS_OUTPUT.PUT_LINE('MINIMO: ' || MINIMO || ' => strFijo: ' || strFijo );

                IF strFijo = 'T' THEN
                    UPDATE EDSR.temp_CargaMasiva_ParametrosPMM
                    SET
                        RPL_SEQ = p_secuencia,
                        RPL_SEQ_REG = ID,
                        RPL_METHOD_CODE = 3,
                        PRD_LVL_CHILD = S_OBT_PRODUCTO(E_PRODUCTO),
                        ORG_LVL_CHILD = S_OBT_SUCURSAL(E_TIENDA),
                        PRF_TECH_KEY = S_OBT_PERFIL(E_PERFIL),
                        RPL_DIST_METHOD = CASE WHEN E_METODO_RPL = 'OCS' THEN 2
                                            WHEN E_METODO_RPL = 'CAT' THEN 6
                                            WHEN E_METODO_RPL = 'RAT' THEN 3
                                        END,
                        RPL_REVIEW_DAYS = intDiaRevision ,
                        RPL_PROC_DAYS =  intDiaProceso,
                        RPL_SS =  intSemSR,
                        PMH_SERV_LVL = dblPorServicio ,
                        RPL_MIN_STK = E_MIN ,
                        RPL_MAX_STK = E_MAX,
                        PRF_WGT_WEEKS = intSemVenta,
                        USR_CRE = 'SISTEMAS'
                    WHERE ID = MINIMO;

                    intTotSemanas := intSemVenta;

                    EXECUTE IMMEDIATE 'DELETE EDSR.TEMP_PARAMREPOSEM';
                    INSERT INTO EDSR.TEMP_PARAMREPOSEM(WGT_WEEK, WGT_FACTOR, PRD_LVL_NUMBER)
                    SELECT
                        SEM.WGT_WEEK,
                        SEM.WGT_FACTOR,
                        V_PRD_LVL_NUMBER
                    FROM TPPARSEM SEM,
                        TPPRDMST PRD
                    WHERE SEM.COD_DIV = PRD.COD_DIV
                        AND SEM.COD_AREA = PRD.COD_AREA
                        AND PRD.PRD_LVL_NUMBER = V_PRD_LVL_NUMBER
                        AND SEM.COD_DPTO = PRD.COD_DPTO
                        AND SEM.COD_LIN = PRD.COD_LIN
                    ORDER BY SEM.WGT_WEEK;

                    INSERT INTO EDSR.TEMP_TPCARSEM(RPL_SEQ, RPL_SEQ_REG, WGT_WEEK, WGT_FACTOR, USR_CRE, FEC_CRE)
                    SELECT
                        p_secuencia,
                        MINIMO,
                        TEMPSEM.WGT_WEEK,
                        TEMPSEM.WGT_FACTOR,
                        'SISTEMAS',
                        SYSDATE
                    FROM EDSR.TEMP_PARAMREPOSEM TEMPSEM
                    WHERE TEMPSEM.WGT_WEEK <= intTotSemanas
                        AND PRD_LVL_NUMBER = V_PRD_LVL_NUMBER
                    ORDER BY TEMPSEM.WGT_WEEK;
                END IF;
                ELSE
                SELECT E_SEMANA_VENTA
                INTO intTotSemanas
                FROM EDSR.temp_CargaMasiva_ParametrosPMM
                WHERE ID = MINIMO;

                UPDATE EDSR.temp_CargaMasiva_ParametrosPMM
                SET
                    RPL_SEQ = p_secuencia,
                    RPL_SEQ_REG = ID,
                    RPL_METHOD_CODE = 3,
                    PRD_LVL_CHILD = S_OBT_PRODUCTO(E_PRODUCTO),
                    ORG_LVL_CHILD = S_OBT_SUCURSAL(E_TIENDA),
                    PRF_TECH_KEY = S_OBT_PERFIL(E_PERFIL),
                    RPL_DIST_METHOD = CASE WHEN E_METODO_RPL = 'OCS' THEN 2
                                        WHEN E_METODO_RPL = 'CAT' THEN 6
                                        WHEN E_METODO_RPL = 'RAT' THEN 3
                                    END,
                    RPL_REVIEW_DAYS = E_DIAS_REVISION ,
                    RPL_PROC_DAYS =  E_DIAS_PROCESO,
                    RPL_SS =  E_SEMANAS_SR,
                    PMH_SERV_LVL = E_SERVICIO ,
                    RPL_MIN_STK = E_MIN ,
                    RPL_MAX_STK = E_MAX,
                    PRF_WGT_WEEKS = E_SEMANA_VENTA,
                    USR_CRE = 'SISTEMAS'
                WHERE ID = MINIMO;

                EXECUTE IMMEDIATE 'DELETE EDSR.TEMP_PARAMREPOSEM';
                INSERT INTO EDSR.TEMP_PARAMREPOSEM TEMP (WGT_WEEK, PRD_LVL_NUMBER , WGT_FACTOR)
                SELECT ROWNUM, V_PRD_LVL_NUMBER ,WGT_FACTOR
                    FROM ( SELECT ID,E_SEM1, E_SEM2, E_SEM3, E_SEM4, E_SEM5, E_SEM6, E_SEM7, E_SEM8, E_SEM9, E_SEM10 FROM EDSR.temp_CargaMasiva_ParametrosPMM WHERE ID = MINIMO
                    )
                UNPIVOT(
                    WGT_FACTOR FOR SEMANA IN (E_SEM1, E_SEM2, E_SEM3, E_SEM4, E_SEM5, E_SEM6, E_SEM7, E_SEM8, E_SEM9, E_SEM10)
                    );
                
                INSERT INTO EDSR.TEMP_TPCARSEM(RPL_SEQ, RPL_SEQ_REG, WGT_WEEK, WGT_FACTOR, USR_CRE, FEC_CRE)
                SELECT
                    p_secuencia,
                    MINIMO,
                    TEMPSEM.WGT_WEEK,
                    TEMPSEM.WGT_FACTOR,
                    'SISTEMAS',
                    SYSDATE
                FROM EDSR.TEMP_PARAMREPOSEM TEMPSEM
                WHERE TEMPSEM.WGT_WEEK <= intTotSemanas
                    AND PRD_LVL_NUMBER = V_PRD_LVL_NUMBER
                ORDER BY TEMPSEM.WGT_WEEK;

                END IF;
                --IF TOTAL_PARAMETROS > 0 THEN ... END IF;

                MINIMO := MINIMO + 1 ;

                COMMIT;
            END LOOP;
            --WHILE MINIMO <= MAXIMO LOOP ... END LOOP

            v_p := 'P5'; 
            v_det := 'Fin del proceso de transformación de carga por registro'; 
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            DBMS_OUTPUT.PUT_LINE('>>>>>>>>> FIN BUCLE <<<<<<<<<');
            DBMS_OUTPUT.PUT_LINE('ULTIMO SKU PROCESADO: ' || V_PRD_LVL_NUMBER);
            DBMS_OUTPUT.PUT_LINE('PROCESADO: ' || TO_CHAR(MINIMO-1) );

            DBMS_OUTPUT.PUT_LINE('------> INSERT INTO EDSR.TPCARPAR');
            INSERT INTO EDSR.TPCARPAR
            (
            RPL_SEQ,
            RPL_SEQ_REG,
            RPL_METHOD_CODE,
            PRD_LVL_CHILD,
            ORG_LVL_CHILD,
            PRF_TECH_KEY,
            RPL_DIST_METHOD,
            RPL_REVIEW_DAYS,
            RPL_PROC_DAYS,
            RPL_SS,
            PMH_SERV_LVL,
            RPL_MIN_STK,
            RPL_MAX_STK,
            PRF_WGT_WEEKS,
            USR_CRE,
            FEC_CRE
            )
            SELECT
                RPL_SEQ,
                RPL_SEQ_REG,
                RPL_METHOD_CODE,
                PRD_LVL_CHILD,
                ORG_LVL_CHILD,
                PRF_TECH_KEY,
                RPL_DIST_METHOD,
                RPL_REVIEW_DAYS,
                RPL_PROC_DAYS,
                RPL_SS,
                PMH_SERV_LVL,
                RPL_MIN_STK,
                RPL_MAX_STK,
                PRF_WGT_WEEKS,
                USR_CRE,
                sysdate
            FROM temp_CargaMasiva_ParametrosPMM
            ;

            v_p := 'P6'; 
            v_det := 'Construcción de Semanas y registro al destino'; 
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            DBMS_OUTPUT.PUT_LINE('=== Registros que violarían la PK (XPKTPCARSEM) ===');
            FOR rec IN cur_conflict LOOP
                v_count := v_count + 1;
                DBMS_OUTPUT.PUT_LINE(
                    'RPL_SEQ=' || rec.RPL_SEQ ||
                    ', RPL_SEQ_REG=' || rec.RPL_SEQ_REG ||
                    ', WGT_WEEK=' || rec.WGT_WEEK
                );
            END LOOP;

            v_p := 'P6'; 
            v_det := 'Validación de duplicados'; 
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            IF v_count = 0 THEN
                DBMS_OUTPUT.PUT_LINE('Se Verifica que no existen duplicados en la tabla destino con esta consulta');

            ELSE
                v_det := 'Total de DUPLICADOS detectados: ' || TO_CHAR(v_count);
                DBMS_OUTPUT.PUT_LINE('Total de conflictos reales detectados: ' || v_count);
                upd(p_process_id, 'FAILED', v_p,'Falló en '||v_p||': '||v_det);
                RAISE_APPLICATION_ERROR(-20001, 'Falló en '||v_p||': '||v_det);
            END IF;
            
            DBMS_OUTPUT.PUT_LINE('------> INSERT INTO EDSR.TPCARSEM');
            INSERT INTO TPCARSEM
            (
            RPL_SEQ,
            RPL_SEQ_REG,
            WGT_WEEK,
            WGT_FACTOR,
            USR_CRE,
            FEC_CRE
            )
            SELECT RPL_SEQ, RPL_SEQ_REG, WGT_WEEK, WGT_FACTOR, USR_CRE, FEC_CRE
            FROM EDSR.TEMP_TPCARSEM;

            COMMIT;

            
            DBMS_OUTPUT.PUT_LINE('Busca los productos que no tienen habilitado el cross-docking y los borra');
            -- Busca los productos que no tienen habilitado el cross-docking y los borra
            INSERT INTO TPCARPAR_REC_TMP (RPL_SEQ, RPL_SEQ_REG, PRD_LVL_CHILD, ORG_LVL_CHILD)
            SELECT T1.RPL_SEQ, T1.RPL_SEQ_REG, T1.PRD_LVL_CHILD, T1.ORG_LVL_CHILD
            FROM TPCARPAR T1
            INNER JOIN TPPRDMST P
                ON T1.PRD_LVL_CHILD = P.PRD_LVL_CHILD
            WHERE RPL_SEQ = p_secuencia
                AND RPL_DIST_METHOD = 6 -- CAT
                AND (P.VPC_TECH_KEY, P.COD_AREA, T1.ORG_LVL_CHILD) NOT IN
                (
                    SELECT PRV_AREA.VPC_TECH_KEY, PRV_AREA.COD_AREA, AO.ORG_LVL_CHILD
                    FROM (  SELECT DISTINCT PC1.VPC_TECH_KEY, TA.COD_AREA, TCD.TIPO
                            FROM HP_CROSS_PROV PC1
                            CROSS JOIN (SELECT TRIM(PRD_LVL_NUMBER) COD_AREA
                                        FROM PRDMSTEE
                                        WHERE PRD_LVL_ID = 4) TA
                            CROSS JOIN (SELECT DISTINCT TIPO FROM HP_CROSS_PROV) TCD) PRV_AREA
                    LEFT JOIN HP_CROSS_PROV PC2
                        ON PC2.VPC_TECH_KEY = PRV_AREA.VPC_TECH_KEY
                        AND PC2.TIPO = PRV_AREA.TIPO
                        AND PC2.COD_AREA IS NULL
                    LEFT JOIN HP_CROSS_PROV PC3
                        ON PC3.VPC_TECH_KEY = PRV_AREA.VPC_TECH_KEY
                        AND PC3.TIPO = PRV_AREA.TIPO
                        AND PC3.COD_AREA = PRV_AREA.COD_AREA
                    LEFT JOIN BASACDEE CA
                        ON NVL(PC3.TIPO, PC2.TIPO) = CA.ATR_COD_TECH_KEY
                    LEFT JOIN BASATOEE AO
                        ON CA.ATR_COD_TECH_KEY = AO.ATR_COD_TECH_KEY
                    LEFT JOIN HP_CROSS_SUC SC
                        ON NVL(PC2.ID, PC3.ID) = SC.ID
                        AND AO.ORG_LVL_CHILD = SC.ORG_LVL_CHILD
                    LEFT JOIN ORGMSTEE O
                        ON AO.ORG_LVL_CHILD = O.ORG_LVL_CHILD
                    WHERE NOT NVL(PC2.ID, PC3.ID) IS NULL
                        AND SC.ORG_LVL_CHILD IS NULL
                );

            DBMS_OUTPUT.PUT_LINE('------> DELETE FROM TPCARPAR');
            DELETE FROM TPCARPAR
            WHERE (RPL_SEQ, RPL_SEQ_REG) IN
                    (SELECT RPL_SEQ, RPL_SEQ_REG
                    FROM TPCARPAR_REC_TMP
                    WHERE RPL_SEQ = p_secuencia);

            SELECT
                COUNT(*)
            INTO TOTAL_SKUS_CROSSDOCKING
            FROM TPCARPAR_REC_TMP R
            INNER JOIN TPPRDMST P
                ON R.PRD_LVL_CHILD = P.PRD_LVL_CHILD
            INNER JOIN ORGMSTEE O
                ON R.ORG_LVL_CHILD = O.ORG_LVL_CHILD
            WHERE RPL_SEQ = p_secuencia;
            DBMS_OUTPUT.PUT_LINE('TOTAL_SKUS_CROSSDOCKING: ' || TOTAL_SKUS_CROSSDOCKING);

            IF TOTAL_SKUS_CROSSDOCKING > 0 THEN
                DBMS_OUTPUT.PUT_LINE('Se encontraron ' || TOTAL_SKUS_CROSSDOCKING || ' SKUs no válidos por el Cross-docking');

                DELETE FROM EDSR.TPCARSEM
                WHERE (RPL_SEQ, RPL_SEQ_REG) IN
                    (
                        SELECT
                        R.RPL_SEQ,
                        R.RPL_SEQ_REG
                        FROM TPCARPAR_REC_TMP R
                        INNER JOIN TPPRDMST P
                        ON R.PRD_LVL_CHILD = P.PRD_LVL_CHILD
                        INNER JOIN ORGMSTEE O
                        ON R.ORG_LVL_CHILD = O.ORG_LVL_CHILD
                        WHERE RPL_SEQ = p_secuencia
                    );
            END IF;

            v_p := 'P7'; 
            v_det := 'Proceso Cross-docking'; 
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            COMMIT;
            DBMS_OUTPUT.PUT_LINE('**** FIN DE CARGA ****');
            DBMS_OUTPUT.PUT_LINE('----> Secuencia: ' || p_secuencia);

        ELSE
            DBMS_OUTPUT.PUT_LINE('No se encontraron registros');
        END if;
        --IF TOTAL > 0 THEN ... END if;


        v_p := 'P8'; 
        v_det := 'Los parámetros de reposición se están procesando en PMM';
        upd(p_process_id, 'PROCESSING', v_p, v_det);

        EDSR.TP_PKG_REPDIN.SP_CARGA_PARAM_REPO(p_secuencia,p_usuario);

        v_p := 'P8';
        v_det := 'Proceso de carga de parametros de resposición en PMM finalizado';
        upd(p_process_id, 'FINALIZED', v_p, v_det);
        end_process(p_process_id);

    EXCEPTION
        WHEN OTHERS THEN
            upd(p_process_id, 'FAILED', v_p, SUBSTR('Falló en '||v_p||': '||SQLERRM,1,4000), SUBSTR(SQLERRM,1,3900));
            RAISE;
    END;

    PROCEDURE RUN_MINMAX(p_process_id IN VARCHAR2, p_usuario IN VARCHAR2) IS
        v_p   VARCHAR2(10) := 'P1';
        v_det VARCHAR2(4000) := 'Iniciando el proceso de carga de parámetros MIN/MAX';

        TOTAL NUMBER := 0;
        MINIMO NUMBER := 0;
        MAXIMO NUMBER := 0;

        p_secuencia NUMBER;

        V_PRD_LVL_NUMBER VARCHAR2(15);

    BEGIN
        upd(p_process_id, 'RUNNING', v_p, v_det);
        start_process(p_process_id);

        v_p := 'P2';
        v_det := 'Calculando el total de parámetros';
        upd(p_process_id, 'PROCESSING', v_p, v_det);

        SELECT COUNT(*)
        INTO TOTAL
        FROM EDSR.temp_CargaMasivaMinMax;

        v_p := 'P3'; 
        v_det := 'Carga Inicial. Total de parámetros para la carga: ' || TO_CHAR(TOTAL);
        upd(p_process_id, 'PROCESSING', v_p, v_det);

        IF TOTAL > 0 THEN
            SELECT MIN(ID), MAX(id)
            INTO MINIMO,MAXIMO
            FROM EDSR.temp_CargaMasivaMinMax
            ;

            SELECT EDSR.TP_SEQ_RPL_SEQ.NEXTVAL
            INTO p_secuencia
            FROM DUAL;
            
            v_p := 'P4';
            v_det := 'Generación de secuencia: ' || TO_CHAR(p_secuencia);
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            DBMS_OUTPUT.PUT_LINE('TOTAL: ' || TOTAL);
            DBMS_OUTPUT.PUT_LINE('MINIMO: ' || MINIMO);
            DBMS_OUTPUT.PUT_LINE('MAXIMO: ' || MAXIMO);
            DBMS_OUTPUT.PUT_LINE('p_secuencia: ' || p_secuencia);

            v_p := 'P4'; 
            v_det := 'Transformando carga por cada registro de un total de '|| TO_CHAR(TOTAL) ||'. Secuencia: '|| TO_CHAR(p_secuencia);
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            DBMS_OUTPUT.PUT_LINE('BEGIN: WHILE MINIMO <= MAXIMO LOOP');
            WHILE MINIMO <= MAXIMO LOOP
                SELECT E_PRODUCTO
                INTO V_PRD_LVL_NUMBER
                FROM EDSR.temp_CargaMasivaMinMax
                WHERE ID = MINIMO;


                UPDATE EDSR.temp_CargaMasivaMinMax
                    SET
                        RPL_SEQ = p_secuencia,
                        RPL_SEQ_REG = ID,
                        RPL_METHOD_CODE = 1,
                        PRD_LVL_CHILD = EDSR.S_OBT_PRODUCTO(E_PRODUCTO),
                        ORG_LVL_CHILD = EDSR.S_OBT_SUCURSAL(E_TIENDA),
                        RPL_DIST_METHOD = CASE WHEN E_METODO_RPL = 'OCS' THEN 2
                                                WHEN E_METODO_RPL = 'CAT' THEN 6
                                                WHEN E_METODO_RPL = 'RAT' THEN 3
                                            END,
                        RPL_MIN_STK = E_MIN ,
                        RPL_MAX_STK = E_MAX,
                        USR_CRE = 'SISTEMAS'
                    WHERE ID = MINIMO;

                MINIMO := MINIMO + 1 ;
                --DBMS_OUTPUT.PUT_LINE(V_PRD_LVL_NUMBER);
                COMMIT;
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('END: WHILE MINIMO <= MAXIMO LOOP');
            
            v_p := 'P5';
            v_det := 'Transformación de carga por registro'; 
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            MINIMO := MINIMO - 1 ;
            DBMS_OUTPUT.PUT_LINE('PROCESADOS: ' || MINIMO);
            DBMS_OUTPUT.PUT_LINE('INSERT INTO EDSR.TPCARPAR');
            INSERT INTO EDSR.TPCARPAR
                (
                RPL_SEQ,
                RPL_SEQ_REG,
                RPL_METHOD_CODE,
                PRD_LVL_CHILD,
                ORG_LVL_CHILD,
                RPL_DIST_METHOD,
                RPL_MIN_STK,
                RPL_MAX_STK,
                USR_CRE,
                FEC_CRE
                )
            SELECT
                RPL_SEQ,
                RPL_SEQ_REG,
                RPL_METHOD_CODE,
                PRD_LVL_CHILD,
                ORG_LVL_CHILD,
                RPL_DIST_METHOD,
                RPL_MIN_STK,
                RPL_MAX_STK,
                USR_CRE,
                sysdate
            FROM temp_CargaMasivaMinMax
            --WHERE ID <=50 --OPCIONAL
            ;
            
            v_p := 'P6';
            v_det := 'Construcción de Semanas y registro al destino'; 
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            COMMIT;

            DBMS_OUTPUT.PUT_LINE('Busca los productos que no tienen habilitado el cross-docking y los borra');
            -- Busca los productos que no tienen habilitado el cross-docking y los borra
            INSERT INTO TPCARPAR_REC_TMP
                (RPL_SEQ, RPL_SEQ_REG, PRD_LVL_CHILD, ORG_LVL_CHILD)
                SELECT T1.RPL_SEQ, T1.RPL_SEQ_REG, T1.PRD_LVL_CHILD, T1.ORG_LVL_CHILD
                FROM TPCARPAR T1
                INNER JOIN TPPRDMST P
                    ON T1.PRD_LVL_CHILD = P.PRD_LVL_CHILD
                WHERE RPL_SEQ = p_secuencia
                    AND RPL_DIST_METHOD = 6 -- CAT
                    AND (P.VPC_TECH_KEY, P.COD_AREA, T1.ORG_LVL_CHILD) NOT IN
                        (SELECT PRV_AREA.VPC_TECH_KEY, PRV_AREA.COD_AREA, AO.ORG_LVL_CHILD
                        FROM (SELECT DISTINCT PC1.VPC_TECH_KEY, TA.COD_AREA, TCD.TIPO
                                FROM HP_CROSS_PROV PC1
                                CROSS JOIN (SELECT TRIM(PRD_LVL_NUMBER) COD_AREA
                                            FROM PRDMSTEE
                                            WHERE PRD_LVL_ID = 4) TA
                                CROSS JOIN (SELECT DISTINCT TIPO FROM HP_CROSS_PROV) TCD) PRV_AREA
                        LEFT JOIN HP_CROSS_PROV PC2
                            ON PC2.VPC_TECH_KEY = PRV_AREA.VPC_TECH_KEY
                            AND PC2.TIPO = PRV_AREA.TIPO
                            AND PC2.COD_AREA IS NULL
                        LEFT JOIN HP_CROSS_PROV PC3
                            ON PC3.VPC_TECH_KEY = PRV_AREA.VPC_TECH_KEY
                            AND PC3.TIPO = PRV_AREA.TIPO
                            AND PC3.COD_AREA = PRV_AREA.COD_AREA
                        LEFT JOIN BASACDEE CA
                            ON NVL(PC3.TIPO, PC2.TIPO) = CA.ATR_COD_TECH_KEY
                        LEFT JOIN BASATOEE AO
                            ON CA.ATR_COD_TECH_KEY = AO.ATR_COD_TECH_KEY
                        LEFT JOIN HP_CROSS_SUC SC
                            ON NVL(PC2.ID, PC3.ID) = SC.ID
                            AND AO.ORG_LVL_CHILD = SC.ORG_LVL_CHILD
                        LEFT JOIN ORGMSTEE O
                            ON AO.ORG_LVL_CHILD = O.ORG_LVL_CHILD
                        WHERE NOT NVL(PC2.ID, PC3.ID) IS NULL
                            AND SC.ORG_LVL_CHILD IS NULL);

            DBMS_OUTPUT.PUT_LINE('DELETE FROM TPCARPAR');
            DELETE FROM TPCARPAR
            WHERE (RPL_SEQ, RPL_SEQ_REG) IN
                    (SELECT RPL_SEQ, RPL_SEQ_REG
                        FROM TPCARPAR_REC_TMP
                        WHERE RPL_SEQ = p_secuencia);

            v_p := 'P7';
            v_det := 'Proceso Cross-docking'; 
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            v_p := 'P8'; 
            v_det := 'Los parámetros de reposición se están procesando en PMM';
            upd(p_process_id, 'PROCESSING', v_p, v_det);

            EDSR.TP_PKG_REPDIN.SP_CARGA_PARAM_REPO(p_secuencia,p_usuario);

            v_p := 'P8';
            v_det := 'Proceso de carga de parametros de resposición en PMM finalizado';
            upd(p_process_id, 'FINALIZED', v_p, v_det);
            end_process(p_process_id);
            
            COMMIT;
        ELSE
            DBMS_OUTPUT.PUT_LINE('No se encontraron registros');
        END if;
        --IF TOTAL > 0 THEN ... END if;

    EXCEPTION
        WHEN OTHERS THEN
            upd(p_process_id, 'FAILED', v_p, SUBSTR('Falló en '||v_p||': '||SQLERRM,1,4000), SUBSTR(SQLERRM,1,3900));
            RAISE;
    END;

END PKG_CARPAR_CARGA;
/