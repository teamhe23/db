ALTER TABLE customer_clubpro
ADD COLUMN profession VARCHAR(255) NULL;

select ctid,club.* from cm.customer_clubpro club order by ctid desc;
SELECT ctid, ci.* FROM cm.customer_invoice ci order by ctid desc;


---- Registro de Facturas ----

CREATE TABLE customer_invoice (
    invoice VARCHAR(50) PRIMARY KEY,     -- Número de factura (único)
    identitynumber VARCHAR(20)           -- Número de cédula
);

SELECT ctid, ci.* FROM customer_invoice ci order by ctid desc;
SELECT *
FROM customer_invoice
WHERE invoice = 'INV123456';

INSERT INTO customer_invoice (invoice, identitynumber)
VALUES ('INV123456', '87654321');