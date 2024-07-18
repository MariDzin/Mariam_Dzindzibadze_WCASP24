

alter table  BL_3NF.CE_DEALSIZES
add column dealsize_src_id varchar(100) ;


-- now inserting in dealsize

-- creaing DEALSIZE_ID sequence exists
CREATE SEQUENCE IF NOT EXISTS BL_3NF.dealsize_id_seq;

--  unique constraint on the DEALSIZE column
ALTER TABLE BL_3NF.CE_DEALSIZES
ADD CONSTRAINT unique_dealsize UNIQUE (DEALSIZE);


-- combining data from both sources 
WITH combined_dealsizes AS (
    SELECT DISTINCT
        COALESCE(us.dealsize, 'UNKNOWN') AS DEALSIZE,
        us.dealsize AS DEALSIZE_SRC_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'ext_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.ext_us_order us
    UNION ALL
    SELECT DISTINCT
        COALESCE(nous.deal_size, 'UNKNOWN') AS DEALSIZE,
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

-- now inserting into payment methods cuz i forgot to add it in time of creation 
-- first i need to add column i deleted by accident 
alter table  BL_3NF.ce_payment_methods 
add column payment_src_id varchar(100) ;

-- add constain for peyment method to be unique
ALTER TABLE BL_3NF.ce_payment_methods 
ADD CONSTRAINT  unique_payment_method UNIQUE (PAYMENT_METHOD);

--  PAYMENT_METHOD_ID sequence 
CREATE SEQUENCE IF NOT EXISTS BL_3NF.payment_method_id_seq;


-- Combine data from both sources and perform incremental extraction
WITH combined_payment_methods AS (
    SELECT DISTINCT
        COALESCE(us.payment_method, 'UNKNOWN') AS PAYMENT_METHOD,
        COALESCE(us.payment_method, 'UNKNOWN') AS PAYMENT_SRC_ID,  
        'sa_us_orders' AS SOURCE_SYSTEM,
        'src_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.src_us_order us
    UNION ALL
    SELECT DISTINCT
        COALESCE(nous.payment_method, 'UNKNOWN') AS PAYMENT_METHOD,
        COALESCE(nous.payment_method, 'UNKNOWN') AS PAYMENT_SRC_ID,  
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
--  PRODUCT_ID sequence 
CREATE SEQUENCE IF NOT EXISTS BL_3NF.product_id_seq;
-- combine data
WITH combined_products AS (
    SELECT DISTINCT
        p.productcode AS PRODUCTCODE,
        p.productline AS PRODUCTLINE,
        p.priceeach AS PRICEEACH,
        p.msrp AS MSRP,
        COALESCE(p.product_src_id, 'UNKNOWN') AS PRODUCT_SRC_ID, 
        p.source_system AS SOURCE_SYSTEM,
        p.source_entity AS SOURCE_ENTITY
    FROM (
        SELECT
            us.productcode AS productcode,
            us.productline AS productline,
            us.priceeach AS priceeach,
            us.msrp AS msrp,
            COALESCE(us.productcode, 'UNKNOWN') AS product_src_id,  
            'sa_us_orders' AS source_system,
            'ext_us_order' AS source_entity
        FROM sa_us_orders.ext_us_order us
        UNION ALL
        SELECT
            nous.product_model AS productcode,
            nous.product_line AS productline,
            nous.price_for_each::NUMERIC AS priceeach,
            nous.ms_rp::NUMERIC AS msrp,
            COALESCE(nous.product_model, 'UNKNOWN') AS product_src_id,  
            'sa_no_usa_orders' AS source_system,
            'src_no_usa_order' AS source_entity
        FROM sa_no_usa_orders.src_no_usa_order nous
    ) p
)
INSERT INTO BL_3NF.CE_PRODUCTS (
    PRODUCT_ID, PRODUCTCODE, PRODUCTLINE, PRICEEACH, MSRP, PRODUCT_SRC_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    nextval('BL_3NF.product_id_seq') AS PRODUCT_ID,
    p.PRODUCTCODE,
    p.PRODUCTLINE,
    p.PRICEEACH,
    p.MSRP,
    p.PRODUCT_SRC_ID,
    CURRENT_DATE AS TA_INSERT_DT,
    CURRENT_DATE AS TA_UPDATE_DT,
    p.SOURCE_SYSTEM,
    p.SOURCE_ENTITY
FROM combined_products p
ON CONFLICT (PRODUCTCODE) DO NOTHING;

COMMIT;

ALTER TABLE BL_3NF.ce_products  
ADD CONSTRAINT  unique_products UNIQUE (PRODUCTCODE);

ALTER TABLE BL_3NF.CE_PRODUCTS
ADD COLUMN IF NOT EXISTS PRODUCT_SRC_ID VARCHAR(50) NOT NULL DEFAULT 'UNKNOWN';


select * from bl_3nf.ce_products cp 



-- now im gonna fill  countries

ALTER TABLE BL_3NF.ce_countries  
ADD CONSTRAINT  unique_countries UNIQUE (COUNTRY_NAME);

ALTER TABLE BL_3NF.ce_countries
ADD COLUMN IF NOT EXISTS COUNTRY_SRC_ID VARCHAR(50) NOT NULL DEFAULT 'UNKNOWN';

-- e COUNTRY_ID sequence 
CREATE SEQUENCE IF NOT EXISTS BL_3NF.country_id_seq;

-- combine data
WITH combined_countries AS (
    SELECT DISTINCT
        c.country_name AS COUNTRY_NAME,
        COALESCE(c.country_src_id, 'UNKNOWN') AS COUNTRY_SRC_ID,
        c.source_system AS SOURCE_SYSTEM,
        c.source_entity AS SOURCE_ENTITY
    FROM (
        SELECT
            us.country AS country_name,
            COALESCE(us.country, 'UNKNOWN') AS country_src_id,  -- Assuming country as src_id for us orders
            'sa_us_orders' AS source_system,
            'ext_us_order' AS source_entity
        FROM sa_us_orders.ext_us_order us
        UNION ALL
        SELECT
            nous.country_name AS country_name,
            COALESCE(nous.country_name, 'UNKNOWN') AS country_src_id,  -- Assuming country_name as src_id for non-us orders
            'sa_no_usa_orders' AS source_system,
            'src_no_usa_order' AS source_entity
        FROM sa_no_usa_orders.src_no_usa_order nous
    ) c
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

select * from bl_3nf.ce_countries cc 

-- now fill up state

ALTER TABLE BL_3NF.ce_states  
ADD CONSTRAINT  unique_states UNIQUE (STATE_NAME);

ALTER TABLE BL_3NF.ce_states 
ADD COLUMN IF NOT EXISTS STATE_SRC_ID VARCHAR(50) NOT NULL DEFAULT 'UNKNOWN';

--  COUNTRY_ID sequence
CREATE SEQUENCE IF NOT EXISTS BL_3NF.state_id_seq;

-- combine data
WITH combined_states AS (
    SELECT DISTINCT
        us.state AS STATE_NAME,
        COALESCE(us.state, 'UNKNOWN') AS STATE_SRC_ID,  
        c.country_id AS COUNTRY_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'ext_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.ext_us_order us
    left JOIN BL_3NF.CE_COUNTRIES c ON us.country = c.country_name
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

select * from bl_3nf.ce_states cs 



-- next is cities

ALTER TABLE BL_3NF.ce_cities  
ADD CONSTRAINT  unique_cities UNIQUE (CITY_NAME);

ALTER TABLE BL_3NF.ce_cities 
ADD COLUMN IF NOT EXISTS CITY_SRC_ID VARCHAR(50) NOT NULL DEFAULT 'UNKNOWN';

--  COUNTRY_ID sequence creating 
CREATE SEQUENCE IF NOT EXISTS BL_3NF.city_id_seq;


-- combine data from both sources
WITH us_cities AS (
    SELECT DISTINCT
        us.city AS CITY_NAME,
        COALESCE(us.city, 'UNKNOWN') AS CITY_SRC_ID,
        s.state_id AS STATE_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'ext_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.ext_us_order us
    LEFT JOIN BL_3NF.CE_STATES s ON us.state = s.state_name
),
non_us_cities AS (
    SELECT DISTINCT
        nous.city_name AS CITY_NAME,
        COALESCE(nous.city_name, 'UNKNOWN') AS CITY_SRC_ID,
        NULL::BIGINT AS STATE_ID,  --not sure if thats correct
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
-- i need to drop not null constrain

ALTER TABLE BL_3NF.CE_CITIES
ALTER COLUMN STATE_ID DROP NOT NULL;




-- next is address 

ALTER table  BL_3NF.ce_addresses  
ADD CONSTRAINT  unique_addresses UNIQUE (ADDRESSLINE1);

ALTER TABLE BL_3NF.ce_addresses 
ADD COLUMN IF NOT EXISTS ADDRESSES_SRC_ID VARCHAR(50) NOT NULL DEFAULT 'UNKNOWN';

--COUNTRY_ID sequence 
CREATE SEQUENCE IF NOT EXISTS BL_3NF.address_id_seq;

-- combine data from both sources
WITH us_addresses AS (
    SELECT DISTINCT
        us.addressline1 AS ADDRESSLINE1,
        COALESCE(us.address_id::VARCHAR, 'UNKNOWN') AS ADDRESS_SRC_ID,  -
        c.city_id AS CITY_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'ext_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.ext_us_order us
    left JOIN BL_3NF.CE_CITIES c ON us.city = c.city_name
),
non_us_addresses AS (
    SELECT DISTINCT
        nous.address_line AS ADDRESSLINE1,
        COALESCE(nous.address_id_num::VARCHAR, 'UNKNOWN') AS ADDRESS_SRC_ID,  
        c.city_id AS CITY_ID,
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY
    FROM sa_no_usa_orders.src_no_usa_order nous
    left JOIN BL_3NF.CE_CITIES c ON nous.city_name = c.city_name
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
FROM (
    SELECT * FROM us_addresses
    UNION ALL
    SELECT * FROM non_us_addresses
) a
ON CONFLICT (ADDRESSLINE1) DO NOTHING;

COMMIT;

select * from bl_3nf.ce_addresses ca 


-- now customers

ALTER table  BL_3NF.ce_customers_scd  
ADD CONSTRAINT  unique_customer UNIQUE (CUSTOMERNAME);

ALTER TABLE BL_3NF.ce_customers_scd 
ADD COLUMN IF NOT EXISTS CUSTOMER_SRC_ID VARCHAR(50) NOT NULL DEFAULT 'UNKNOWN';

-- CUSTOMER_ID sequence
CREATE SEQUENCE IF NOT EXISTS BL_3NF.customer_id_seq;
-- combinining data
WITH combined_customers AS (
    SELECT DISTINCT
        us.customer_id::BIGINT AS CUSTOMER_ID,  
        us.customername AS CUSTOMERNAME,
        us.contactfirstname AS CONTACTFIRSTNAME,
        us.contactlastname AS CONTACTLASTNAME,
        us.phone AS PHONE,
        COALESCE(us.customer_id::VARCHAR, 'UNKNOWN') AS CUSTOMER_SRC_ID,
        a.address_id AS ADDRESS_ID,
        'sa_us_orders' AS SOURCE_SYSTEM,
        'ext_us_order' AS SOURCE_ENTITY
    FROM sa_us_orders.ext_us_order us
    JOIN BL_3NF.CE_ADDRESSES a ON us.addressline1 = a.addressline1
    UNION ALL
    SELECT DISTINCT
        nous.customers_id::BIGINT AS CUSTOMER_ID, 
        nous.cust_name AS CUSTOMERNAME,
        nous.cust_firstname AS CONTACTFIRSTNAME,
        nous.cust_lastname AS CONTACTLASTNAME,
        nous.phone_number AS PHONE,
        COALESCE(nous.customers_id::VARCHAR, 'UNKNOWN') AS CUSTOMER_SRC_ID,
        a.address_id AS ADDRESS_ID,
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY
    FROM sa_no_usa_orders.src_no_usa_order nous
    left JOIN BL_3NF.CE_ADDRESSES a ON nous.address_line = a.addressline1
),
latest_customers AS (
    SELECT 
        c.CUSTOMER_ID,
        c.CUSTOMERNAME,
        c.CONTACTFIRSTNAME,
        c.CONTACTLASTNAME,
        c.PHONE,
        c.CUSTOMER_SRC_ID,
        c.ADDRESS_ID,
        c.SOURCE_SYSTEM,
        c.SOURCE_ENTITY,
        row_number() OVER (PARTITION BY c.CUSTOMER_ID ORDER BY c.TA_UPDATE_DT DESC) as rn
    FROM BL_3NF.CE_CUSTOMERS_SCD c
    WHERE c.IS_ACTIVE = 'Y'
)
SELECT 
    nc.CUSTOMER_ID,
    nc.CUSTOMERNAME,
    nc.CONTACTFIRSTNAME,
    nc.CONTACTLASTNAME,
    nc.PHONE,
    nc.CUSTOMER_SRC_ID,
    nc.ADDRESS_ID,
    nc.SOURCE_SYSTEM,
    nc.SOURCE_ENTITY,
    l.CUSTOMER_ID AS OLD_CUSTOMER_ID,
    l.CUSTOMER_ID IS NULL AS IS_NEW
INTO temp_changes
FROM combined_customers nc
LEFT JOIN latest_customers l
ON nc.CUSTOMER_ID = l.CUSTOMER_ID AND l.rn = 1
WHERE 
    l.CUSTOMER_ID IS NULL OR
    (nc.CUSTOMERNAME != l.CUSTOMERNAME OR
     nc.CONTACTFIRSTNAME != l.CONTACTFIRSTNAME OR
     nc.CONTACTLASTNAME != l.CONTACTLASTNAME OR
     nc.PHONE != l.PHONE OR
     nc.ADDRESS_ID != l.ADDRESS_ID);

--  deactivate oldrecords but there is no old records but still 
UPDATE BL_3NF.CE_CUSTOMERS_SCD
SET 
    END_DT = CURRENT_DATE - INTERVAL '1 day',
    IS_ACTIVE = 'N',
    TA_UPDATE_DT = CURRENT_DATE
FROM temp_changes c
WHERE BL_3NF.CE_CUSTOMERS_SCD.CUSTOMER_ID = c.OLD_CUSTOMER_ID
AND c.IS_NEW = FALSE;

-- Inserting
INSERT INTO BL_3NF.CE_CUSTOMERS_SCD (
    CUSTOMER_ID, CUSTOMERNAME, CONTACTFIRSTNAME, CONTACTLASTNAME, PHONE, CUSTOMER_SRC_ID, ADDRESS_ID, 
    START_DT, END_DT, IS_ACTIVE, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    nextval('BL_3NF.customer_id_seq') AS CUSTOMER_ID,
    c.CUSTOMERNAME,
    c.CONTACTFIRSTNAME,
    c.CONTACTLASTNAME,
    c.PHONE,
    c.CUSTOMER_SRC_ID,
    c.ADDRESS_ID,
    CURRENT_DATE AS START_DT,
    '9999-12-31' AS END_DT,
    'Y' AS IS_ACTIVE,
    CURRENT_DATE AS TA_INSERT_DT,
    CURRENT_DATE AS TA_UPDATE_DT,
    c.SOURCE_SYSTEM,
    c.SOURCE_ENTITY
FROM temp_changes c
WHERE c.IS_NEW = TRUE OR c.OLD_CUSTOMER_ID IS NOT NULL;

COMMIT;


select * from bl_3nf.ce_customers_scd ccs 


-- now lets fill orders last table

-- combine data 
WITH combined_orders AS (
    SELECT DISTINCT
        us.ordernumber::BIGINT AS ORDERNUMBER,  
        us.quantityordered::INTEGER AS QUANTITYORDERED,  
        us.sales::NUMERIC AS SALES,  
        pm.PAYMENT_METHOD_ID,
        ds.DEALSIZE_ID,
        p.PRODUCT_ID,
        c.CUSTOMER_ID,
        us.orderdate::DATE AS EVENT_DT,  
        'sa_us_orders' AS SOURCE_SYSTEM,
        'ext_us_order' AS SOURCE_ENTITY,
        COALESCE(us.ordernumber::VARCHAR, 'UNKNOWN') AS ORDER_SRC_ID  
    FROM sa_us_orders.ext_us_order us
    left JOIN BL_3NF.CE_PAYMENT_METHODS pm ON us.payment_method = pm.PAYMENT_METHOD
    left JOIN BL_3NF.CE_DEALSIZES ds ON us.dealsize = ds.DEALSIZE
    left JOIN BL_3NF.CE_PRODUCTS p ON us.productcode = p.PRODUCTCODE
    left JOIN BL_3NF.CE_CUSTOMERS_SCD c ON us.customer_id::BIGINT = c.CUSTOMER_ID  
    UNION ALL
    SELECT DISTINCT
        nous.order_id::BIGINT AS ORDERNUMBER,  
        nous.quantity::INTEGER AS QUANTITYORDERED,  
        nous.sales_amount::NUMERIC AS SALES,  
        pm.PAYMENT_METHOD_ID,
        ds.DEALSIZE_ID,
        p.PRODUCT_ID,
        c.CUSTOMER_ID,
        nous.date_of_order::DATE AS EVENT_DT, 
        'sa_no_usa_orders' AS SOURCE_SYSTEM,
        'src_no_usa_order' AS SOURCE_ENTITY,
        COALESCE(nous.order_id::VARCHAR, 'UNKNOWN') AS ORDER_SRC_ID  
    FROM sa_no_usa_orders.src_no_usa_order nous
    left JOIN BL_3NF.CE_PAYMENT_METHODS pm ON nous.payment_method = pm.PAYMENT_METHOD
    left JOIN BL_3NF.CE_DEALSIZES ds ON nous.deal_size = ds.DEALSIZE
    left JOIN BL_3NF.CE_PRODUCTS p ON nous.product_model = p.PRODUCTCODE
    left JOIN BL_3NF.CE_CUSTOMERS_SCD c ON nous.customers_id::BIGINT = c.CUSTOMER_ID  
)
INSERT INTO BL_3NF.CE_ORDERS (
    ORDERNUMBER, QUANTITYORDERED, SALES, PAYMENT_METHOD_ID, DEALSIZE_ID, PRODUCT_ID, CUSTOMER_ID, 
    EVENT_DT, TA_INSERT_DT, TA_UPDATE_DT, ORDER_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
)
SELECT
    o.ORDERNUMBER,
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

select * from bl_3nf.ce_orders co 


