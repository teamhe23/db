-- PRUEBAS DEL BLOQUE EXCEPTION
DECLARE
    V_NUMBER NUMBER := '10' ;
BEGIN
    IF V_NUMBER > 5 THEN
        RAISE_APPLICATION_ERROR(-20001,'El numero es mayor que 5');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CODIGO: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('ERROR BLOQUE EXCEPTION:' || SQLERRM);
END;



 SELECT *
      FROM prdmstee V
      WHERE TRIM(V.PRD_NAME_FULL) = trim('PISO PORC RF MARMOLIZA NEVADA GREY 60X120CM 1.46M2');

/* 2024-08-06: 13:06
   Se agrega control al tipo de Marca PORQUE estaban viniendo tipos de marca que no existen en PMM.
 */

BEGIN
    SELECT * FROM BASACDEE WHERE ATR_CODE_DESC LIKE '%PROP%' AND ATR_HDR_TECH_KEY = 106;
    DECLARE
        V_COD_ATR VARCHAR2(500);
    BEGIN
        select trim(atr_code)
          into V_COD_ATR
          from basacdee
          where atr_hdr_tech_key  in (select ATR_HDR_TECH_KEY from PIM_ATRIBUTO
                                  where cod_atributo = 'TipoMarca')
                and atr_code_desc = upper('Exclusiva');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Tipo de Marca No existe');
            RAISE_APPLICATION_ERROR(-20001,'519');
    END;
END;