-- Inserting default row into CE_PAYMENT_METHODS
INSERT INTO BL_3NF.CE_PAYMENT_METHODS (
    PAYMENT_METHOD_ID, PAYMENT_METHOD, TA_INSERT_DT, TA_UPDATE_DT, PAYMENT_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT -1, 'n. a.', '1900-01-01', '1900-01-01', 'n. a.', 'MANUAL', 'MANUAL'
WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_PAYMENT_METHODS WHERE PAYMENT_METHOD_ID = -1);
COMMIT;

-- Inserting default row into CE_DEALSIZES
INSERT INTO BL_3NF.CE_DEALSIZES (
    DEALSIZE_ID, DEALSIZE, TA_INSERT_DT, TA_UPDATE_DT, DEALSIZE_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT -1, 'n. a.', '1900-01-01', '1900-01-01', 'n. a.', 'MANUAL', 'MANUAL'
WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_DEALSIZES WHERE DEALSIZE_ID = -1);
COMMIT;

-- Inserting default row into CE_PRODUCTS
INSERT INTO BL_3NF.CE_PRODUCTS (
    PRODUCT_ID, PRODUCTCODE, PRODUCTLINE, PRICEEACH, MSRP, TA_INSERT_DT, TA_UPDATE_DT, PRODUCT_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT -1, 'n. a.', 'n. a.', -1, -1, '1900-01-01', '1900-01-01', 'n. a.', 'MANUAL', 'MANUAL'
WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_PRODUCTS WHERE PRODUCT_ID = -1);
COMMIT;

-- Inserting default row into CE_COUNTRIES
INSERT INTO BL_3NF.CE_COUNTRIES (
    COUNTRY_ID, COUNTRY_NAME, TA_INSERT_DT, TA_UPDATE_DT, COUNTRY_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT -1, 'n. a.', '1900-01-01', '1900-01-01', 'n. a.', 'MANUAL', 'MANUAL'
WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_COUNTRIES WHERE COUNTRY_ID = -1);
COMMIT;

-- Inserting default row into CE_STATES
INSERT INTO BL_3NF.CE_STATES (
    STATE_ID, STATE_NAME, COUNTRY_ID, TA_INSERT_DT, TA_UPDATE_DT, STATE_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT -1, 'n. a.', -1, '1900-01-01', '1900-01-01', 'n. a.', 'MANUAL', 'MANUAL'
WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_STATES WHERE STATE_ID = -1);
COMMIT;

-- Inserting default row into CE_CITIES
INSERT INTO BL_3NF.CE_CITIES (
    CITY_ID, CITY_NAME, STATE_ID, TA_INSERT_DT, TA_UPDATE_DT, CITY_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT -1, 'n. a.', -1, '1900-01-01', '1900-01-01', 'n. a.', 'MANUAL', 'MANUAL'
WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_CITIES WHERE CITY_ID = -1);
COMMIT;

-- Inserting default row into CE_ADDRESSES
INSERT INTO BL_3NF.CE_ADDRESSES (
    ADDRESS_ID, ADDRESSLINE1, CITY_ID, TA_INSERT_DT, TA_UPDATE_DT, ADDRESS_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT -1, 'n. a.', -1, '1900-01-01', '1900-01-01', 'n. a.', 'MANUAL', 'MANUAL'
WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_ADDRESSES WHERE ADDRESS_ID = -1);
COMMIT;

-- Inserting default row into CE_CUSTOMERS_SCD
INSERT INTO BL_3NF.CE_CUSTOMERS_SCD (
    CUSTOMER_ID, CUSTOMERNAME, CONTACTFIRSTNAME, CONTACTLASTNAME, PHONE, ADDRESS_ID, START_DT, END_DT, IS_ACTIVE, TA_INSERT_DT,  CUSTOMER_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT -1, 'n. a.', 'n. a.', 'n. a.', 'n. a.', -1, '1900-01-01', '9999-12-31', 'Y', '1900-01-01',  'n. a.', 'MANUAL', 'MANUAL'
WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_CUSTOMERS_SCD WHERE CUSTOMER_ID = -1);
COMMIT;

-- Inserting default row into CE_ORDERS
INSERT INTO BL_3NF.CE_ORDERS (
    ORDERNUMBER, QUANTITYORDERED, SALES, PAYMENT_METHOD_ID, DEALSIZE_ID, PRODUCT_ID, CUSTOMER_ID, EVENT_DT, TA_INSERT_DT, TA_UPDATE_DT, ORDER_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT -1, -1, -1, -1, -1, -1, -1, '1900-01-01', '1900-01-01', '1900-01-01', 'n. a.', 'MANUAL', 'MANUAL'
WHERE NOT EXISTS (SELECT 1 FROM BL_3NF.CE_ORDERS WHERE ORDERNUMBER = -1);
COMMIT;
