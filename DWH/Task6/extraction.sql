
-- Creating DEALSIZE_ID sequence
CREATE SEQUENCE IF NOT EXISTS BL_3NF.dealsize_id_seq;

-- Combining data from both sources
WITH combined_dealsizes AS (
    SELECT DISTINCT
        COALESCE(us.dealsize,'n. a.' ) AS DEALSIZE,
        us.dealsize AS DEALSIZE_SRC_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'src_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.src_us_order us
    UNION ALL
    SELECT DISTINCT
        COALESCE(nous.deal_size, 'n. a.') AS DEALSIZE,
        nous.deal_size AS DEALSIZE_SRC_ID,
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY
    FROM sa_no_usa_orders.src_no_usa_order nous
)
INSERT INTO BL_3NF.CE_DEALSIZES (
    DEALSIZE_ID, DEALSIZE, DEALSIZE_SRC_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    nextval('BL_3NF.dealsize_id_seq') AS DEALSIZE_ID,
    cd.DEALSIZE,
    cd.DEALSIZE_SRC_ID,
    CURRENT_DATE AS TA_INSERT_DT,
    CURRENT_DATE AS TA_UPDATE_DT,
    cd.SOURCE_SYSTEM,
    cd.SOURCE_ENTITY
FROM combined_dealsizes cd
ON CONFLICT (DEALSIZE) DO NOTHING;

COMMIT;

SELECT * FROM BL_3NF.CE_DEALSIZES;


--  PAYMENT_METHOD_ID sequence 
CREATE SEQUENCE IF NOT EXISTS BL_3NF.payment_method_id_seq;


-- Combine data from both sources
WITH combined_payment_methods AS (
    SELECT DISTINCT
        COALESCE(us.payment_method, 'n. a.') AS PAYMENT_METHOD,
        COALESCE(us.payment_method, 'n. a.') AS PAYMENT_SRC_ID,  
        'sa_us_orders' AS SOURCE_SYSTEM,
        'src_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.src_us_order us
    UNION ALL
    SELECT DISTINCT
        COALESCE(nous.payment_method, 'n. a.') AS PAYMENT_METHOD,
        COALESCE(nous.payment_method, 'n. a.') AS PAYMENT_SRC_ID,  
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY
    FROM sa_no_usa_orders.src_no_usa_order nous
)
INSERT INTO BL_3NF.CE_PAYMENT_METHODS (
    PAYMENT_METHOD_ID, PAYMENT_METHOD, PAYMENT_SRC_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    nextval('BL_3NF.payment_method_id_seq') AS PAYMENT_METHOD_ID,
    pm.PAYMENT_METHOD,
    pm.PAYMENT_SRC_ID,
    CURRENT_DATE AS TA_INSERT_DT,
    CURRENT_DATE AS TA_UPDATE_DT,
    pm.SOURCE_SYSTEM,
    pm.SOURCE_ENTITY
FROM combined_payment_methods pm
ON CONFLICT (PAYMENT_METHOD) DO NOTHING;

COMMIT;

SELECT * FROM BL_3NF.CE_PAYMENT_METHODS;


-- okay now lets fill other tables, next is product 

CREATE SEQUENCE IF NOT EXISTS BL_3NF.product_id_seq;

-- combining both source data
WITH combined_products AS (
    SELECT DISTINCT
        us.productcode AS PRODUCTCODE,
        us.productline AS PRODUCTLINE,
        us.priceeach::VARCHAR AS PRICEEACH,
        us.msrp::VARCHAR AS MSRP,
        COALESCE(us.productcode, 'n. a.') AS PRODUCT_SRC_ID,  
        'sa_us_orders' AS SOURCE_SYSTEM,
        'src_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.src_us_order us
    UNION ALL
    SELECT DISTINCT
        nous.product_model AS PRODUCTCODE,
        nous.product_line AS PRODUCTLINE,
        nous.price_for_each AS PRICEEACH,
        nous.ms_rp AS MSRP,
        COALESCE(nous.product_model, 'n. a.') AS PRODUCT_SRC_ID,  
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY
    FROM sa_no_usa_orders.src_no_usa_order nous
)
INSERT INTO BL_3NF.CE_PRODUCTS (
    PRODUCT_ID, PRODUCTCODE, PRODUCTLINE, PRICEEACH, MSRP, PRODUCT_SRC_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    nextval('BL_3NF.product_id_seq') AS PRODUCT_ID,
    p.PRODUCTCODE,
    p.PRODUCTLINE,
    p.PRICEEACH::NUMERIC,
    p.MSRP::NUMERIC,
    p.PRODUCT_SRC_ID,
    CURRENT_DATE AS TA_INSERT_DT,
    CURRENT_DATE AS TA_UPDATE_DT,
    p.SOURCE_SYSTEM,
    p.SOURCE_ENTITY
FROM combined_products p
ON CONFLICT (PRODUCTCODE) DO NOTHING;

COMMIT;



select * from bl_3nf.ce_products cp 



-- COUNTRY_ID sequence 
CREATE SEQUENCE IF NOT EXISTS BL_3NF.country_id_seq;

-- combining data from both sources
WITH combined_countries AS (
    SELECT DISTINCT
        us.country AS COUNTRY_NAME,
        COALESCE(us.country, 'n. a.') AS COUNTRY_SRC_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'src_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.src_us_order us
    UNION ALL
    SELECT DISTINCT
        nous.country_name AS COUNTRY_NAME,
        COALESCE(nous.country_name, 'n. a.') AS COUNTRY_SRC_ID,
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY
    FROM sa_no_usa_orders.src_no_usa_order nous
)
INSERT INTO BL_3NF.CE_COUNTRIES (
    COUNTRY_ID, COUNTRY_NAME, COUNTRY_SRC_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    nextval('BL_3NF.country_id_seq') AS COUNTRY_ID,
    c.COUNTRY_NAME,
    c.COUNTRY_SRC_ID,
    CURRENT_DATE AS TA_INSERT_DT,
    CURRENT_DATE AS TA_UPDATE_DT,
    c.SOURCE_SYSTEM,
    c.SOURCE_ENTITY
FROM combined_countries c
ON CONFLICT (COUNTRY_NAME) DO NOTHING;

COMMIT;

SELECT * FROM BL_3NF.CE_COUNTRIES;



--  COUNTRY_ID sequence
CREATE SEQUENCE IF NOT EXISTS BL_3NF.state_id_seq;

-- combining data from both sources

WITH combined_states AS (
    SELECT DISTINCT
        us.state AS STATE_NAME,
        COALESCE(us.state, 'n. a.') AS STATE_SRC_ID,  
        c.country_id AS COUNTRY_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'src_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.src_us_order us
    LEFT JOIN BL_3NF.CE_COUNTRIES c 
    ON c.source_system = 'sa_us_orders'
    AND c.source_entity = 'src_us_order'
    AND us.country = c.country_src_id
)
INSERT INTO BL_3NF.CE_STATES (
    STATE_ID, STATE_NAME, STATE_SRC_ID, COUNTRY_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    nextval('BL_3NF.state_id_seq') AS STATE_ID,
    s.STATE_NAME,
    s.STATE_SRC_ID,
    s.COUNTRY_ID,
    CURRENT_DATE AS TA_INSERT_DT,
    CURRENT_DATE AS TA_UPDATE_DT,
    s.SOURCE_SYSTEM,
    s.SOURCE_ENTITY
FROM combined_states s
ON CONFLICT (STATE_NAME) DO NOTHING;

COMMIT;

-- Verify the inserted data
SELECT * FROM BL_3NF.CE_STATES;


-- next is cities
--  COUNTRY_ID sequence creating 
CREATE SEQUENCE IF NOT EXISTS BL_3NF.city_id_seq;
-- combine data from both sources
WITH us_cities AS (
    SELECT DISTINCT
        us.city AS CITY_NAME,
        COALESCE(us.city, 'n. a.') AS CITY_SRC_ID,
        COALESCE(s.state_id, -1) AS STATE_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'src_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.src_us_order us
    LEFT JOIN BL_3NF.CE_STATES s ON us.state = s.state_name
),
non_us_cities AS (
    SELECT DISTINCT
        nous.city_name AS CITY_NAME,
        COALESCE(nous.city_name, 'n. a.') AS CITY_SRC_ID,
        -1 AS STATE_ID,  -- default value for state_id
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY
    FROM sa_no_usa_orders.src_no_usa_order nous
)
INSERT INTO BL_3NF.CE_CITIES (
    CITY_ID, CITY_NAME, CITY_SRC_ID, STATE_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    nextval('BL_3NF.city_id_seq') AS CITY_ID,
    c.CITY_NAME,
    c.CITY_SRC_ID,
    c.STATE_ID,
    CURRENT_DATE AS TA_INSERT_DT,
    CURRENT_DATE AS TA_UPDATE_DT,
    c.SOURCE_SYSTEM,
    c.SOURCE_ENTITY
FROM (
    SELECT * FROM us_cities
    UNION ALL
    SELECT * FROM non_us_cities
) c
ON CONFLICT (CITY_NAME) DO NOTHING;

COMMIT;

select * from bl_3nf.ce_cities cc 

--combining 
WITH combined_addresses AS (
    SELECT DISTINCT
        COALESCE(us.addressline1, 'n. a.') AS ADDRESSLINE1,
        COALESCE(us.address_id::VARCHAR, 'n. a.') AS ADDRESS_SRC_ID,
        COALESCE(c.city_id, -1) AS CITY_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'src_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.src_us_order us
    LEFT JOIN BL_3NF.CE_CITIES c 
    ON us.city = c.city_name
    UNION ALL
    SELECT DISTINCT
        COALESCE(nous.address_line, 'n. a.') AS ADDRESSLINE1,
        COALESCE(nous.address_id_num::VARCHAR, 'n. a.') AS ADDRESS_SRC_ID,
        COALESCE(c.city_id, -1) AS CITY_ID,
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY
    FROM sa_no_usa_orders.src_no_usa_order nous
    LEFT JOIN BL_3NF.CE_CITIES c 
    ON nous.city_name = c.city_name
)
INSERT INTO BL_3NF.CE_ADDRESSES (
    ADDRESS_ID, ADDRESSLINE1, ADDRESS_SRC_ID, CITY_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    nextval('BL_3NF.address_id_seq') AS ADDRESS_ID,
    a.ADDRESSLINE1,
    a.ADDRESS_SRC_ID,
    a.CITY_ID,
    CURRENT_DATE AS TA_INSERT_DT,
    CURRENT_DATE AS TA_UPDATE_DT,
    a.SOURCE_SYSTEM,
    a.SOURCE_ENTITY
FROM combined_addresses a
ON CONFLICT (ADDRESSLINE1) DO NOTHING;

COMMIT;


select * from bl_3nf.ce_addresses ca 



-- Create the sequence for CUSTOMER_ID
CREATE SEQUENCE IF NOT EXISTS BL_3NF.customer_id_seq;

-- Combine data from both sources
WITH combined_customers AS (
    SELECT DISTINCT
        COALESCE(us.customer_id::BIGINT, -1) AS CUSTOMER_ID,  
        COALESCE(us.customername, 'n. a.') AS CUSTOMERNAME,
        COALESCE(us.contactfirstname, 'n. a.') AS CONTACTFIRSTNAME,
        COALESCE(us.contactlastname, 'n. a.') AS CONTACTLASTNAME,
        COALESCE(us.phone, 'n. a.') AS PHONE,
        COALESCE(us.customer_id::VARCHAR, 'n. a.') AS CUSTOMER_SRC_ID,
        COALESCE(a.address_id, -1) AS ADDRESS_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'src_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.src_us_order us
    LEFT JOIN BL_3NF.CE_ADDRESSES a 
    ON us.addressline1 = a.addressline1
    AND a.source_system = 'sa_us_orders'
    AND a.source_entity = 'src_us_order'
    UNION ALL
    SELECT DISTINCT
        COALESCE(nous.customers_id::BIGINT, -1) AS CUSTOMER_ID, 
        COALESCE(nous.cust_name, 'n. a.') AS CUSTOMERNAME,
        COALESCE(nous.cust_firstname, 'n. a.') AS CONTACTFIRSTNAME,
        COALESCE(nous.cust_lastname, 'n. a.') AS CONTACTLASTNAME,
        COALESCE(nous.phone_number, 'n. a.') AS PHONE,
        COALESCE(nous.customers_id::VARCHAR, 'n. a.') AS CUSTOMER_SRC_ID,
        COALESCE(a.address_id, -1) AS ADDRESS_ID,
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY
    FROM sa_no_usa_orders.src_no_usa_order nous
    LEFT JOIN BL_3NF.CE_ADDRESSES a 
    ON nous.address_line = a.addressline1
    AND a.source_system = 'sa_no_usa_orders'
    AND a.source_entity = 'src_no_usa_order'
)
INSERT INTO BL_3NF.CE_CUSTOMERS_SCD (
    CUSTOMER_ID, CUSTOMERNAME, CONTACTFIRSTNAME, CONTACTLASTNAME, PHONE, CUSTOMER_SRC_ID, ADDRESS_ID, 
    START_DT, END_DT, IS_ACTIVE, TA_INSERT_DT,  SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    nextval('BL_3NF.customer_id_seq') AS CUSTOMER_ID,
    cd.CUSTOMERNAME,
    cd.CONTACTFIRSTNAME,
    cd.CONTACTLASTNAME,
    cd.PHONE,
    cd.CUSTOMER_SRC_ID,
    cd.ADDRESS_ID,
    CURRENT_DATE AS START_DT,
    '9999-12-31' AS END_DT,
    'Y' AS IS_ACTIVE,
    CURRENT_DATE AS TA_INSERT_DT,
    cd.SOURCE_SYSTEM,
    cd.SOURCE_ENTITY
FROM combined_customers cd
ON CONFLICT (CUSTOMERNAME)
DO UPDATE SET
    CONTACTFIRSTNAME = EXCLUDED.CONTACTFIRSTNAME,
    CONTACTLASTNAME = EXCLUDED.CONTACTLASTNAME,
    PHONE = EXCLUDED.PHONE,
    CUSTOMER_SRC_ID = EXCLUDED.CUSTOMER_SRC_ID,
    ADDRESS_ID = EXCLUDED.ADDRESS_ID

COMMIT;

select * from bl_3nf.ce_customers_scd ccs 


-- Create the sequence for ORDERNUMBER
CREATE SEQUENCE IF NOT EXISTS BL_3NF.ordernumber_seq;

-- Combine data from both sources
WITH combined_orders AS (
    SELECT DISTINCT
        COALESCE(us.ordernumber::BIGINT, -1) AS ORDERNUMBER,  
        COALESCE(us.quantityordered::INTEGER, -1) AS QUANTITYORDERED,  
        COALESCE(us.sales::NUMERIC, -1) AS SALES,  
        COALESCE(pm.PAYMENT_METHOD_ID, -1) AS PAYMENT_METHOD_ID,
        COALESCE(ds.DEALSIZE_ID, -1) AS DEALSIZE_ID,
        COALESCE(p.PRODUCT_ID, -1) AS PRODUCT_ID,
        COALESCE(c.CUSTOMER_ID, -1) AS CUSTOMER_ID,
        COALESCE(us.orderdate::DATE, '1900-01-01') AS EVENT_DT,  
        'sa_us_orders' AS SOURCE_SYSTEM,
        'src_us_order' AS SOURCE_ENTITY,
        COALESCE(us.ordernumber::VARCHAR, 'n. a.') AS ORDER_SRC_ID  
    FROM sa_us_orders.src_us_order us
    LEFT JOIN BL_3NF.CE_PAYMENT_METHODS pm ON us.payment_method = pm.PAYMENT_METHOD
    LEFT JOIN BL_3NF.CE_DEALSIZES ds ON us.dealsize = ds.DEALSIZE
    LEFT JOIN BL_3NF.CE_PRODUCTS p ON us.productcode = p.PRODUCTCODE
    LEFT JOIN BL_3NF.CE_CUSTOMERS_SCD c ON us.customer_id::BIGINT = c.CUSTOMER_ID  
    UNION ALL
    SELECT DISTINCT
        COALESCE(nous.order_id::BIGINT, -1) AS ORDERNUMBER,  
        COALESCE(nous.quantity::INTEGER, -1) AS QUANTITYORDERED,  
        COALESCE(nous.sales_amount::NUMERIC, -1) AS SALES,  
        COALESCE(pm.PAYMENT_METHOD_ID, -1) AS PAYMENT_METHOD_ID,
        COALESCE(ds.DEALSIZE_ID, -1) AS DEALSIZE_ID,
        COALESCE(p.PRODUCT_ID, -1) AS PRODUCT_ID,
        COALESCE(c.CUSTOMER_ID, -1) AS CUSTOMER_ID,
        COALESCE(nous.date_of_order::DATE, '1900-01-01') AS EVENT_DT, 
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY,
        COALESCE(nous.order_id::VARCHAR, 'n. a.') AS ORDER_SRC_ID  
    FROM sa_no_usa_orders.src_no_usa_order nous
    LEFT JOIN BL_3NF.CE_PAYMENT_METHODS pm ON nous.payment_method = pm.PAYMENT_METHOD
    LEFT JOIN BL_3NF.CE_DEALSIZES ds ON nous.deal_size = ds.DEALSIZE
    LEFT JOIN BL_3NF.CE_PRODUCTS p ON nous.product_model = p.PRODUCTCODE
    LEFT JOIN BL_3NF.CE_CUSTOMERS_SCD c ON nous.customers_id::BIGINT = c.CUSTOMER_ID  
)
INSERT INTO BL_3NF.CE_ORDERS (
    ORDERNUMBER, QUANTITYORDERED, SALES, PAYMENT_METHOD_ID, DEALSIZE_ID, PRODUCT_ID, CUSTOMER_ID, 
    EVENT_DT, TA_INSERT_DT, TA_UPDATE_DT, ORDER_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    COALESCE(o.ORDERNUMBER, nextval('BL_3NF.ordernumber_seq')) AS ORDERNUMBER,
    o.QUANTITYORDERED,
    o.SALES,
    o.PAYMENT_METHOD_ID,
    o.DEALSIZE_ID,
    o.PRODUCT_ID,
    o.CUSTOMER_ID,
    o.EVENT_DT,
    CURRENT_DATE AS TA_INSERT_DT,
    CURRENT_DATE AS TA_UPDATE_DT,
    o.ORDER_SRC_ID,
    o.SOURCE_SYSTEM,
    o.SOURCE_ENTITY
FROM combined_orders o
ON CONFLICT (ORDERNUMBER) DO NOTHING;

COMMIT;

SELECT * FROM BL_3NF.CE_ORDERS;

