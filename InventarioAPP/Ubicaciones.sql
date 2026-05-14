--PRODUCTO
SELECT P.PRD_LVL_NUMBER, UPC.PRD_UPC FROM EPMM.PRDMSTEE P
	INNER JOIN EPMM.PRDUPCEE UPC ON P.PRD_LVL_CHILD = UPC.PRD_LVL_CHILD
	LEFT JOIN EPMM.PRDUPCAE A ON UPC.PRD_UPC = A.PRD_UPC AND A.AUDIT_TYPE = 'A'
WHERE 	UPC.PRODUCT_UPC = 'T'
 		AND UPC.PRD_PRIMARY_FLAG = 'T'
		AND PRD_LVL_NUMBER IN ('21555');

SELECT * FROM invlocation;

SELECT * FROM EDSR.invlocationdtl;
SELECT min(ID), max(id) FROM EDSR.invlocationdtl;
SELECT DISTINCT ID FROM EDSR.INVLOCATIONDTL ;
SELECT COUNT(*) FROM EDSR.invlocationdtl;
UPDATE invlocationdtl SET ORG_LVL_NUMBER = '102' WHERE ID = 6;

INSERT INTO invlocation (prd_lvl_number,org_lvl_number) VALUES ('1001','101');

INSERT INTO invlocationdtl (prd_lvl_number, location, curr_qty) VALUES ('1001', 'ALM-001-016-001', 100);
INSERT INTO invlocationdtl (prd_lvl_number, location, curr_qty) VALUES ('1001', 'ALM-001-017-003', 20);
INSERT INTO invlocationdtl (prd_lvl_number, location, curr_qty) VALUES ('1001', 'ALM-001-011-001', 1);
COMMIT;

SELECT LDTL.ID, LDTL.LOCATION, LDTL.CURR_QTY
FROM EDSR.invlocation L
	INNER JOIN EDSR.invlocationdtl LDTL ON L.PRD_LVL_NUMBER = LDTL.PRD_LVL_NUMBER
WHERE L.org_lvl_number = '101' AND L.PRD_LVL_NUMBER = '1001';

INSERT INTO EDSR.INVLOCATIONDTL
(ORG_LVL_NUMBER, PRD_LVL_NUMBER, LOCATION, CURR_QTY, REGISTERDATE)
VALUES('101', '10025', 'ALM-001-016-099', 10,sysdate);
INSERT INTO EDSR.INVLOCATIONDTL
(ORG_LVL_NUMBER, PRD_LVL_NUMBER, LOCATION, CURR_QTY, REGISTERDATE)
VALUES('101','21590', 'ALM-001-016-001', 100,sysdate);
INSERT INTO EDSR.INVLOCATIONDTL
(ORG_LVL_NUMBER, PRD_LVL_NUMBER, LOCATION, CURR_QTY, REGISTERDATE)
VALUES('101','21590', 'ALM-001-017-003', 20,sysdate);
INSERT INTO EDSR.INVLOCATIONDTL
(ORG_LVL_NUMBER, PRD_LVL_NUMBER, LOCATION, CURR_QTY, REGISTERDATE)
VALUES('101','21590', 'ALM-001-011-001', 1,sysdate);
INSERT INTO EDSR.INVLOCATIONDTL
(ORG_LVL_NUMBER, PRD_LVL_NUMBER, LOCATION, CURR_QTY, REGISTERDATE)
VALUES('101','10027', 'ALM-001-016-001', 100,sysdate);
INSERT INTO EDSR.INVLOCATIONDTL
(ORG_LVL_NUMBER, PRD_LVL_NUMBER, LOCATION, CURR_QTY, REGISTERDATE)
VALUES('101','10027', 'ALM-001-017-003', 20,sysdate);
INSERT INTO EDSR.INVLOCATIONDTL
(ORG_LVL_NUMBER, PRD_LVL_NUMBER, LOCATION, CURR_QTY, REGISTERDATE)
VALUES('101', '10027', 'ALM-001-011-001', 1,sysdate);
INSERT INTO EDSR.INVLOCATIONDTL
(ORG_LVL_NUMBER, PRD_LVL_NUMBER, LOCATION, CURR_QTY)
VALUES('101', '10027', 'ALM-001-011-001', 1);
COMMIT;
   
SELECT EDSR.SEQ_inv_location.NEXTVAL FROM DUAL;
SELECT EDSR.SEQ_inv_location_dtl.NEXTVAL FROM DUAL;


DROP SEQUENCE EDSR.SEQ_inv_location_dtl;
DROP TABLE EDSR.invlocationdtl;

CREATE SEQUENCE EDSR.SEQ_inv_location_dtl
START WITH 1
INCREMENT BY 1
MAXVALUE 99999999
CYCLE  -- Opcional, solo si quieres que la secuencia vuelva al inicio después de alcanzar el valor máximo
CACHE 1000;  -- Por ejemplo, mantener 1000 valores en la caché para mejorar el rendimiento


CREATE TABLE invlocationdtl (
    id NUMBER DEFAULT EDSR.SEQ_inv_location_dtl.NEXTVAL PRIMARY KEY NOT NULL,
    org_lvl_number VARCHAR2(30) NOT NULL,
    prd_lvl_number VARCHAR2(25) NOT NULL,
    location VARCHAR2(50) NOT NULL,
    curr_qty NUMBER NOT NULL,
    registerDate DATE DEFAULT SYSDATE,
    modifyDate DATE
);

-----------------------------------------
-- TEST SetLocation
-----------------------------------------
BEGIN
   EDSR.PKG_WMS_LOCATIONS.SetLocation(
      v_sucursal  => '001',          -- código de sucursal
      v_sku       => 'ABC123',       -- código del producto (SKU)
      v_ubicacion => 'LOC-A1',       -- ubicación del producto en almacén
      v_cantidad  => 100             -- cantidad del producto
   );
   DBMS_OUTPUT.PUT_LINE('Insert exitoso.');
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error SetLocation: ' || SQLERRM);
END;

SELECT * FROM invlocationdtl;

-----------------------------------------
-- TEST DelLocation
-----------------------------------------
BEGIN
  EDSR.PKG_WMS_LOCATIONS.DelLocation;
END;
/





CREATE OR REPLACE PACKAGE EDSR.PKG_WMS_LOCATIONS IS

	PROCEDURE SetLocation
	 (
	  v_sucursal IN VARCHAR2,
	  v_sku IN VARCHAR2,
	  v_ubicacion IN VARCHAR2,
	  v_cantidad IN NUMBER
	 );
	
	PROCEDURE DelLocation
	
END;
/
CREATE OR REPLACE PACKAGE BODY EDSR.PKG_WMS_LOCATIONS IS

	PROCEDURE SetLocation (
	  v_sucursal IN VARCHAR2,
	  v_sku IN VARCHAR2,
	  v_ubicacion IN VARCHAR2,
	  v_cantidad IN NUMBER
	 ) AS
	 BEGIN
		INSERT INTO EDSR.INVLOCATIONDTL (ORG_LVL_NUMBER, PRD_LVL_NUMBER, LOCATION, CURR_QTY)
		VALUES (v_sucursal,v_sku,v_ubicacion,v_cantidad);
	 EXCEPTION
	 	WHEN OTHERS THEN
		    RAISE;
	 END;
	
	  PROCEDURE DelLocation
	  IS
	  BEGIN
	    execute immediate 'truncate table edsr.INVLOCATIONDTL';
	  END;
	
END;