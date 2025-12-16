--CREATE OR REPLACE PROCEDURE EPMM."BASTKEY"
--(
DECLARE
    in_bas_counter_name     bascntee.bas_counter_name%TYPE := 'prd_lvl_number' ;
    in_bas_counter_value    bascntee.bas_counter_value%TYPE := 0 ;
    out_bas_counter_value   bascntee.bas_counter_value%TYPE;-- PRD_LVL_NUMBER
    in_process_luw          CHAR DEFAULT 'T';
    in_batch_count          INTEGER DEFAULT 0;
--)
--IS

BEGIN

DECLARE

-- Exceptions
EXP_SEQ_DOES_NOT_EXIST      EXCEPTION;
PRAGMA              EXCEPTION_INIT(EXP_SEQ_DOES_NOT_EXIST,-2289);

-- Variables
var_bas_counter_value   bascntee.bas_counter_value%TYPE;
var_bas_counter_max     bascntee.bas_counter_max%TYPE;
var_bas_counter_min     bascntee.bas_counter_min%TYPE;

var_rowid                     ROWID;
sql_stmt                      VARCHAR(255);
cur_id                        INTEGER;
var_bas_counter_name    seq.sequence_name%TYPE;
var_min_value           NUMBER;
var_max_value           NUMBER;
var_increment_by        NUMBER;
var_cycle_flag          CHAR(1);
var_seq_value           NUMBER;


--------------------------------------------------------------------------
-- This procedure is used to maintain counters for other procedures     --
-- The main variable used is in_bas_counter_name, the value of the      --
--      counter is returned in out_bas_counter_value                   --
-- If the counter does not exist, this schema will create it with       --
--     a value of 1.                                                   --
-- IF force value is not 0, the counter will be set to force value.     --
-- Modification Log:
-- Modified by  Modified on     Date
-- Ashok Patel  11/21/97    Log ID: 4906
--              Modified to commit only IF in_process_luw
--              is 'T' AND the counter is not a SEQUENCE.
-- BPowell      09/26/02 Log ID: 16788
--    Re-worked the dynamic SQL used to select ORACLE sequence's. SQL will now
--    correctly set the sequence when an argument value is passed in
--    'in_bas_counter_value', refered to above as the force value. The
--    original SQL would not set the counter with the force argument value for
--    an ORACLE sequence number.
--------------------------------------------------------------------------

BEGIN

-- Get the data from the sequence if it exists
BEGIN
--sql_stmt := 'SELECT ' || RTRIM(in_bas_counter_name) ||
--     ' .NEXTVAL counter_value FROM DUAL';
-- Open the cursor
--cur_id := dbms_sql.open_cursor;
-- Parse the sql statement
--dbms_sql.parse(cur_id,sql_stmt,dbms_sql.NATIVE);
-- Define the type of the column
--dbms_sql.define_column(cur_id,1,var_bas_counter_value);
-- Get the value from sequence
--var_bas_counter_value:=dbms_sql.execute_and_fetch(cur_id);
--dbms_sql.column_value(cur_id,1,var_bas_counter_value);

var_bas_counter_name := UPPER(in_bas_counter_name);

    EXECUTE IMMEDIATE 'SELECT ' || var_bas_counter_name ||
                      '.NEXTVAL  FROM DUAL ' INTO var_bas_counter_value;



    IF in_bas_counter_value > 0 THEN

      SELECT min_value,
             max_value,
             increment_by,
             cycle_flag,
             last_number
        INTO var_min_value,
             var_max_value,
             var_increment_by,
             var_cycle_flag,
             var_seq_value
        FROM seq
       WHERE sequence_name = var_bas_counter_name;

      IF (in_bas_counter_value > var_bas_counter_value) THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || var_bas_counter_name;

        IF (var_cycle_flag = 'F') THEN
          EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || var_bas_counter_name ||
                            ' START WITH ' || (in_bas_counter_value +1) ||
                            ' MINVALUE ' || var_min_value ||
                            ' MAXVALUE ' || var_max_value;
        ELSE
          EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || var_bas_counter_name ||
                            ' START WITH ' || (in_bas_counter_value +1) ||
                            ' MINVALUE ' || var_min_value ||
                            ' MAXVALUE ' || var_max_value ||
                            ' CYCLE ' || '';
        END IF;
      END IF;
   END IF;

EXCEPTION
WHEN EXP_SEQ_DOES_NOT_EXIST THEN
       -- Get the data from bascntee
       BEGIN
       SELECT   /*+ INDEX(BASCNTEE) */
        bas_counter_value,bas_counter_max,
        bas_counter_min,ROWID
       INTO     var_bas_counter_value,var_bas_counter_max,
        var_bas_counter_min,var_rowid
       FROM     bascntee
       WHERE    bas_counter_name = in_bas_counter_name
       FOR  UPDATE;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
        -- No record available
        var_rowid := NULL;
        var_bas_counter_value := 0;
        var_bas_counter_min := 1;
        var_bas_counter_max := 99999999999;
       END;

       -- Check whether a force value has been specified
       IF in_bas_counter_value > 0 THEN
        -- Set counter to the number passed in
        var_bas_counter_value := in_bas_counter_value;
       ELSE
        -- Update the counter
        IF var_bas_counter_value  = var_bas_counter_max THEN
            -- Set the counter to min value.
            var_bas_counter_value := var_bas_counter_min;
        ELSE
            -- Increment counter by 1
            var_bas_counter_value := var_bas_counter_value + 1;
        END IF;
       END IF;

       -- Insert/Update bascntee
       IF var_rowid IS NOT NULL THEN
        UPDATE  /*+ ROWID(BASCNTEE) */
            bascntee
        SET     bas_counter_value = var_bas_counter_value
        WHERE   ROWID = var_rowid;
       ELSE
        -- Insert a new row into the table
        INSERT INTO bascntee
        (
        bas_counter_name,
        bas_counter_value,
        bas_counter_min,
        bas_counter_max,
        bas_counter_is_key
        )
        VALUES
        (
        in_bas_counter_name,
        var_bas_counter_value,
        var_bas_counter_min,
        var_bas_counter_max,
        1
        );
       END IF;
       IF in_process_luw = 'T' THEN
        COMMIT;
       END IF;
END;

-- Close the cursor
--dbms_sql.close_cursor(cur_id);
--out_bas_counter_value := var_bas_counter_value;

out_bas_counter_value := var_bas_counter_value;

EXCEPTION
WHEN OTHERS THEN
       -- Raise the error
       RAISE;
END;
END;
