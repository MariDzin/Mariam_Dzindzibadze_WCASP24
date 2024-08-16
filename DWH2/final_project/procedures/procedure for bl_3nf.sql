
-- Creating bl_Cl
CREATE SCHEMA IF NOT EXISTS BL_CL;


-- Creating a centralized logging table in BL_CL schema
CREATE TABLE IF NOT EXISTS BL_CL.procedure_logs (
    log_id SERIAL PRIMARY KEY,
    log_timestamp TIMESTAMPTZ DEFAULT NOW(),
    procedure_name TEXT,
    rows_affected INT,
    log_message TEXT,
    error_message TEXT
);

-- Creating a logging function in BL_CL schema
CREATE OR REPLACE FUNCTION BL_CL.log_procedure_action(
    proc_name TEXT, 
    rows INT, 
    message TEXT, 
    error_message TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO BL_CL.procedure_logs (procedure_name, rows_affected, log_message, error_message)
    VALUES (proc_name, rows, message, error_message);
END;
$$ LANGUAGE plpgsql;


-- Creating procedure to load data into CE_DEALSIZES
CREATE OR REPLACE PROCEDURE BL_cl.load_dealsizes()
LANGUAGE plpgsql AS $$
DECLARE
    rows_affected INT := 0;
BEGIN
    -- Combining data from both sources and ensuring uniqueness
    WITH combined_dealsizes AS (
        SELECT 
            deal_size AS DEALSIZE, 
            deal_size AS DEALSIZE_SRC_ID,
            'sa_no_usa_orders' AS SOURCE_SYSTEM,
            'src_no_usa_order' AS SOURCE_ENTITY
        FROM sa_no_usa_orders.src_no_usa_order
        UNION 
        SELECT 
            dealsize AS DEALSIZE, 
            dealsize AS DEALSIZE_SRC_ID,
            'sa_us_orders' AS SOURCE_SYSTEM,
            'src_us_order' AS SOURCE_ENTITY
        FROM sa_us_orders.src_us_order
    ),
    unique_dealsizes AS (
        SELECT 
            DISTINCT ON (cd.DEALSIZE) cd.DEALSIZE, 
            cd.DEALSIZE_SRC_ID, 
            cd.SOURCE_SYSTEM, 
            cd.SOURCE_ENTITY
        FROM combined_dealsizes cd
        ORDER BY cd.DEALSIZE 
    )
    INSERT INTO BL_3NF.CE_DEALSIZES (
        DEALSIZE_ID, DEALSIZE, DEALSIZE_SRC_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
    )
    SELECT
        nextval('BL_3NF.dealsize_id_seq') AS DEALSIZE_ID,
        ud.DEALSIZE,
        ud.DEALSIZE_SRC_ID,
        CURRENT_DATE AS TA_INSERT_DT,
        CURRENT_DATE AS TA_UPDATE_DT,
        ud.SOURCE_SYSTEM,
        ud.SOURCE_ENTITY
    FROM unique_dealsizes ud
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_DEALSIZES
        WHERE DEALSIZE = ud.DEALSIZE
    );

    -- Capture rows affected by the insert
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    RAISE NOTICE 'Inserted % row(s) into CE_DEALSIZES', rows_affected;

    -- Log the operation
    PERFORM BL_CL.log_procedure_action('load_dealsizes', rows_affected, 'Dealsizes loaded successfully');

EXCEPTION
    WHEN OTHERS THEN
        PERFORM BL_CL.log_procedure_action('load_dealsizes', 0, 'Error occurred during dealsizes load: ' || SQLERRM);
        RAISE;
END;
$$;


call BL_cl.load_dealsizes();
select * from ce_dealsizes cd ;


-- Creating procedure to load data into CE_PAYMENT_METHODS
CREATE OR REPLACE PROCEDURE BL_cl.load_payment_methods()
LANGUAGE plpgsql AS $$
DECLARE
    rows_affected INT := 0;
BEGIN
    -- Combine and deduplicate payment methods from both sources
    WITH combined_payment_methods AS (
        SELECT 
            payment_method, 
            payment_method AS payment_src_id,
            'sa_us_orders' AS source_system, 
            'src_us_order' AS source_entity
        FROM sa_us_orders.src_us_order
        UNION
        SELECT 
            payment_method, 
            payment_method AS payment_src_id,
            'sa_no_usa_orders' AS source_system, 
            'src_no_usa_order' AS source_entity
        FROM sa_no_usa_orders.src_no_usa_order
    ),
    unique_payment_methods AS (
        SELECT DISTINCT ON (payment_method)
            payment_method,
            payment_src_id,
            source_system,
            source_entity
        FROM combined_payment_methods
        WHERE payment_method IS NOT NULL
        ORDER BY payment_method
    )
    INSERT INTO BL_3NF.CE_PAYMENT_METHODS (
        PAYMENT_METHOD_ID, PAYMENT_METHOD, PAYMENT_SRC_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
    )
    SELECT
        nextval('BL_3NF.payment_method_id_seq') AS PAYMENT_METHOD_ID,
        upm.payment_method,
        upm.payment_src_id,
        CURRENT_DATE,
        CURRENT_DATE,
        upm.source_system,
        upm.source_entity
    FROM unique_payment_methods upm
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_PAYMENT_METHODS 
        WHERE PAYMENT_METHOD = upm.payment_method
    );

    -- Capture rows affected by the insert
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    PERFORM BL_CL.log_procedure_action('load_payment_methods', rows_affected, 'Payment methods loaded successfully');
    
EXCEPTION
    WHEN unique_violation THEN
        PERFORM BL_CL.log_procedure_action('load_payment_methods', 0, 'Unique constraint violation occurred');
    WHEN OTHERS THEN
        PERFORM BL_CL.log_procedure_action('load_payment_methods', 0, 'Error occurred during payment methods load: ' || SQLERRM);
        RAISE;
END;
$$;


call BL_cl.load_payment_methods();
select * from BL_3NF.CE_PAYMENT_METHODS;





-- Creating procedure to load data into CE_PRODUCTS
CREATE OR REPLACE PROCEDURE BL_cl.load_products()
LANGUAGE plpgsql AS $$
DECLARE
    rows_affected INT := 0;
BEGIN
    -- Combine and deduplicate product codes from both sources
    WITH combined_products AS (
        SELECT 
            productcode, 
            productline, 
            priceeach::VARCHAR, 
            msrp::VARCHAR, 
            productcode AS product_src_id,
            'sa_us_orders' AS source_system, 
            'src_us_order' AS source_entity
        FROM sa_us_orders.src_us_order
        UNION
        SELECT 
            product_model AS productcode, 
            product_line AS productline, 
            price_for_each AS priceeach, 
            ms_rp AS msrp, 
            product_model AS product_src_id,
            'sa_no_usa_orders' AS source_system, 
            'src_no_usa_order' AS source_entity
        FROM sa_no_usa_orders.src_no_usa_order
    ),
    unique_products AS (
        SELECT DISTINCT ON (productcode)
            productcode,
            productline,
            priceeach::NUMERIC,
            msrp::NUMERIC,
            product_src_id,
            source_system,
            source_entity
        FROM combined_products
        WHERE productcode IS NOT NULL
        ORDER BY productcode
    )
    INSERT INTO BL_3NF.CE_PRODUCTS (
        PRODUCT_ID, PRODUCTCODE, PRODUCTLINE, PRICEEACH, MSRP, PRODUCT_SRC_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
    )
    SELECT
        nextval('BL_3NF.product_id_seq') AS PRODUCT_ID,
        up.productcode,
        up.productline,
        up.priceeach,
        up.msrp,
        up.product_src_id,
        CURRENT_DATE,
        CURRENT_DATE,
        up.source_system,
        up.source_entity
    FROM unique_products up
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_PRODUCTS 
        WHERE PRODUCTCODE = up.productcode
    );

    -- Capture rows affected by the insert
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    PERFORM BL_CL.log_procedure_action('load_products', rows_affected, 'Products loaded successfully');
    
EXCEPTION
    WHEN unique_violation THEN
        PERFORM BL_CL.log_procedure_action('load_products', 0, 'Unique constraint violation occurred');
    WHEN OTHERS THEN
        PERFORM BL_CL.log_procedure_action('load_products', 0, 'Error occurred during products load: ' || SQLERRM);
        RAISE;
END;
$$;




call BL_cl.load_products();
select * from BL_3NF.CE_PRODUCTS;






-- Creating procedure to load data into CE_COUNTRIES
CREATE OR REPLACE PROCEDURE BL_cl.load_countries()
LANGUAGE plpgsql AS $$
DECLARE
    rows_affected INT := 0;
BEGIN
    -- Combine and deduplicate country names from both sources
    WITH combined_countries AS (
        SELECT 
            COALESCE(country, 'n. a.') AS country_name, 
            COALESCE(country, 'n. a.') AS country_src_id, 
            'sa_us_orders' AS source_system, 
            'src_us_order' AS source_entity
        FROM sa_us_orders.src_us_order
        UNION
        SELECT 
            COALESCE(country_name, 'n. a.') AS country_name, 
            COALESCE(country_name, 'n. a.') AS country_src_id, 
            'sa_no_usa_orders' AS source_system, 
            'src_no_usa_order' AS source_entity
        FROM sa_no_usa_orders.src_no_usa_order
    ),
    unique_countries AS (
        SELECT DISTINCT ON (country_src_id)
            country_name,
            country_src_id,
            source_system,
            source_entity
        FROM combined_countries
        ORDER BY country_src_id
    )
    INSERT INTO BL_3NF.CE_COUNTRIES (
        COUNTRY_ID, COUNTRY_NAME, COUNTRY_SRC_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
    )
    SELECT
        nextval('BL_3NF.country_id_seq') AS COUNTRY_ID,
        uc.country_name,
        uc.country_src_id,
        CURRENT_DATE,
        CURRENT_DATE,
        uc.source_system,
        uc.source_entity
    FROM unique_countries uc
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_COUNTRIES 
        WHERE COUNTRY_SRC_ID = uc.country_src_id
    );

    -- Capture rows affected by the insert
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    PERFORM BL_CL.log_procedure_action('load_countries', rows_affected, 'Countries loaded successfully');
    
EXCEPTION
    WHEN unique_violation THEN
        PERFORM BL_CL.log_procedure_action('load_countries', 0, 'Unique constraint violation occurred');
    WHEN OTHERS THEN
        PERFORM BL_CL.log_procedure_action('load_countries', 0, 'Error occurred during countries load: ' || SQLERRM);
        RAISE;
END;
$$;



call BL_cl.load_countries();
select * from BL_3NF.CE_COUNTRIES;
delete from BL_3NF.CE_COUNTRIES;


-- Creating procedure to load data into CE_STATES

CREATE OR REPLACE PROCEDURE BL_cl.load_states()
LANGUAGE plpgsql AS $$
DECLARE
    rows_affected INT := 0;
BEGIN
    -- Combine and deduplicate states from the single available source
    WITH combined_states AS (
        SELECT DISTINCT
            us.state AS STATE_NAME,
            COALESCE(us.state, 'n. a.') AS STATE_SRC_ID,
            COALESCE(c.country_id, -1) AS COUNTRY_ID,
            'sa_us_orders' AS SOURCE_SYSTEM,
            'src_us_order' AS SOURCE_ENTITY
        FROM sa_us_orders.src_us_order us
        LEFT JOIN BL_3NF.CE_COUNTRIES c
        ON us.country = c.country_src_id
        AND c.source_system = 'sa_us_orders'
        AND c.source_entity = 'src_us_order'
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
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_STATES
        WHERE STATE_NAME = s.STATE_NAME
          AND SOURCE_SYSTEM = s.SOURCE_SYSTEM
          AND SOURCE_ENTITY = s.SOURCE_ENTITY
    );

    -- Capture rows affected by the insert
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    RAISE NOTICE 'Inserted % row(s) into CE_STATES', rows_affected;

    -- Log the operation
    PERFORM BL_CL.log_procedure_action('load_states', rows_affected, 'States loaded successfully');
    
EXCEPTION
    WHEN OTHERS THEN
        PERFORM BL_CL.log_procedure_action('load_states', 0, 'Error occurred during states load: ' || SQLERRM);
        RAISE;
END;
$$;


call BL_cl.load_states();
select * from BL_3NF.CE_STATES;
delete from BL_3NF.CE_STATES;
-- Creating procedure to load data into CE_CITIES
CREATE OR REPLACE PROCEDURE BL_cl.load_cities()
LANGUAGE plpgsql AS $$
DECLARE
    rows_affected INT := 0;
BEGIN
    -- Combine and deduplicate cities from both sources
    WITH combined_cities AS (
        SELECT 
            COALESCE(LOWER(TRIM(us.city)), 'n. a.') AS city_name, 
            COALESCE(LOWER(TRIM(us.city)), 'n. a.') AS city_src_id, 
            COALESCE(s.state_id, -1) AS state_id, 
            'sa_us_orders' AS source_system, 
            'src_us_order' AS source_entity
        FROM sa_us_orders.src_us_order us
        LEFT JOIN BL_3NF.CE_STATES s 
        ON LOWER(TRIM(us.state)) = LOWER(TRIM(s.STATE_SRC_ID))
        AND s.source_system = 'sa_us_orders'
        AND s.source_entity = 'src_us_order'
        
        UNION
        
        SELECT 
            COALESCE(LOWER(TRIM(nous.city_name)), 'n. a.') AS city_name, 
            COALESCE(LOWER(TRIM(nous.city_name)), 'n. a.') AS city_src_id, 
            -1 AS state_id, 
            'sa_no_usa_orders' AS source_system, 
            'src_no_usa_order' AS source_entity
        FROM sa_no_usa_orders.src_no_usa_order nous
    ),
    unique_cities AS (
        SELECT DISTINCT ON (city_src_id)
            city_name,
            city_src_id,
            state_id,
            source_system,
            source_entity
        FROM combined_cities
        ORDER BY city_src_id
    )
    INSERT INTO BL_3NF.CE_CITIES (
        CITY_ID, CITY_NAME, CITY_SRC_ID, STATE_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
    )
    SELECT
        nextval('BL_3NF.city_id_seq'),
        uc.city_name,
        uc.city_src_id,
        uc.state_id,
        CURRENT_DATE,
        CURRENT_DATE,
        uc.source_system,
        uc.source_entity
    FROM unique_cities uc
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_CITIES 
        WHERE LOWER(TRIM(CITY_SRC_ID)) = uc.city_src_id
          AND LOWER(TRIM(SOURCE_SYSTEM)) = uc.source_system
          AND LOWER(TRIM(SOURCE_ENTITY)) = uc.source_entity
    );

    -- Capture rows affected by the insert
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    PERFORM BL_CL.log_procedure_action('load_cities', rows_affected, 'Cities loaded successfully');
    
EXCEPTION
    WHEN OTHERS THEN
        PERFORM BL_CL.log_procedure_action('load_cities', 0, 'Error occurred during cities load: ' || SQLERRM);
        RAISE;
END;
$$;






call BL_cl.load_cities();
select * from BL_3NF.CE_CITIES;
delete from BL_3NF.CE_CITIES ;

-- Creating procedure to load data into CE_ADDRESSES
CREATE OR REPLACE PROCEDURE BL_cl.load_addresses()
LANGUAGE plpgsql AS $$
DECLARE
    rows_affected INT := 0;
BEGIN
    -- Combine and deduplicate addresses from both sources
    WITH combined_addresses AS (
        SELECT 
            COALESCE(us.addressline1, 'n. a.') AS addressline1, 
            COALESCE(us.address_id::VARCHAR, 'n. a.') AS address_src_id, 
            c.city_id AS city_id, 
            'sa_us_orders' AS source_system, 
            'src_us_order' AS source_entity
        FROM sa_us_orders.src_us_order us
        LEFT JOIN BL_3NF.CE_CITIES c 
        ON LOWER(TRIM(us.city)) = LOWER(TRIM(c.CITY_SRC_ID))
        AND c.source_system = 'sa_us_orders'
        AND c.source_entity = 'src_us_order'
        
        UNION
        
        SELECT 
            COALESCE(nous.address_line, 'n. a.') AS addressline1, 
            COALESCE(nous.address_id_num::VARCHAR, 'n. a.') AS address_src_id, 
            c.city_id AS city_id, 
            'sa_no_usa_orders' AS source_system, 
            'src_no_usa_order' AS source_entity
        FROM sa_no_usa_orders.src_no_usa_order nous
        LEFT JOIN BL_3NF.CE_CITIES c 
        ON LOWER(TRIM(nous.city_name)) = LOWER(TRIM(c.CITY_SRC_ID))
        AND c.source_system = 'sa_no_usa_orders'
        AND c.source_entity = 'src_no_usa_order'
    ),
    unique_addresses AS (
        SELECT DISTINCT ON (addressline1, address_src_id, city_id)
            addressline1,
            address_src_id,
            COALESCE(city_id, -1) AS city_id,  -- Keeping -1 if city is still not matched
            source_system,
            source_entity
        FROM combined_addresses
        WHERE addressline1 IS NOT NULL
        ORDER BY addressline1, address_src_id, city_id
    )
    INSERT INTO BL_3NF.CE_ADDRESSES (
        ADDRESS_ID, ADDRESSLINE1, ADDRESS_SRC_ID, CITY_ID, TA_INSERT_DT, TA_UPDATE_DT, SOURCE_SYSTEM, SOURCE_ENTITY
    )
    SELECT
        nextval('BL_3NF.address_id_seq'),
        ua.addressline1,
        ua.address_src_id,
        ua.city_id,
        CURRENT_DATE,
        CURRENT_DATE,
        ua.source_system,
        ua.source_entity
    FROM unique_addresses ua
    WHERE NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_ADDRESSES 
        WHERE ADDRESS_SRC_ID = ua.address_src_id
          AND SOURCE_SYSTEM = ua.source_system
          AND SOURCE_ENTITY = ua.source_entity
    );

    -- Capture rows affected by the insert
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    PERFORM BL_CL.log_procedure_action('load_addresses', rows_affected, 'Addresses loaded successfully');
EXCEPTION
    WHEN OTHERS THEN
        PERFORM BL_CL.log_procedure_action('load_addresses', 0, 'Error occurred during addresses load: ' || SQLERRM);
        RAISE;
END;
$$;



CALL BL_cl.load_addresses();
select *  from bl_3nf.ce_addresses ca ;


-- customersss------------------------------------------

CREATE OR REPLACE PROCEDURE BL_cl.load_customers()
LANGUAGE plpgsql AS $$
DECLARE
    max_receive_date_us timestamp;
    max_receive_date_no_us timestamp;
    rows_affected INT := 0;
BEGIN
    -- Step 1: Get the max receive_date for each source beforehand
    SELECT COALESCE(MAX(receive_date), '1900-01-01'::timestamp) 
    INTO max_receive_date_us
    FROM sa_us_orders.src_us_order;

    SELECT COALESCE(MAX(receive_date), '1900-01-01'::timestamp) 
    INTO max_receive_date_no_us
    FROM sa_no_usa_orders.src_no_usa_order;

    -- Step 2: Update existing records that have changed
    UPDATE BL_3NF.CE_CUSTOMERS_SCD t
    SET END_DT = CURRENT_DATE,
        IS_ACTIVE = 'N'
    WHERE t.IS_ACTIVE = 'Y'
      AND EXISTS (
        SELECT 1
        FROM sa_us_orders.src_us_order us
        WHERE  us.is_processed = false
          AND us.customer_id::VARCHAR = t.CUSTOMER_SRC_ID
          AND ('sa_us_orders', 'src_us_order') = (t.source_system, t.source_entity)
        UNION ALL
        SELECT 1
        FROM sa_no_usa_orders.src_no_usa_order nous
        WHERE nous.receive_date >= max_receive_date_no_us
          AND nous.is_processed = false
          AND nous.customers_id::VARCHAR = t.CUSTOMER_SRC_ID
          AND ('sa_no_usa_orders', 'src_no_usa_order') = (t.source_system, t.source_entity)
    );
    
    -- Capture rows affected by the update
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    RAISE NOTICE 'Updated % row(s)', rows_affected;

    -- Step 3: Insert new records if they don't already exist
    INSERT INTO BL_3NF.CE_CUSTOMERS_SCD (
        CUSTOMER_ID, CUSTOMERNAME, CONTACTFIRSTNAME, CONTACTLASTNAME, PHONE, 
        CUSTOMER_SRC_ID, ADDRESS_ID, START_DT, END_DT, IS_ACTIVE, 
        TA_INSERT_DT, SOURCE_SYSTEM, SOURCE_ENTITY
    )
    SELECT nextval('BL_3NF.customer_id_seq') AS CUSTOMER_ID,
    		us.customername,
           us.contactfirstname,
           us.contactlastname,
           us.phone,
           us.customer_id::VARCHAR AS customer_src_id,
           a.address_id AS address_id, 
           CURRENT_DATE AS START_DT,
           DATE '9999-12-31' AS END_DT,
           'Y' AS IS_ACTIVE,
           CURRENT_DATE AS TA_INSERT_DT,
           'sa_us_orders' AS source_system,
           'src_us_order' AS source_entity
    FROM sa_us_orders.src_us_order us
    left join bl_3nf.ce_addresses a on us.address_id=a.address_src_id 
    and a.source_system = 'sa_us_orders'
    AND a.source_entity = 'src_us_order'    
   WHERE  us.is_processed = false
      group by us.customername,  us.contactfirstname, us.contactlastname, a.address_id,  us.phone, us.customer_id
           UNION ALL
    SELECt nextval('BL_3NF.customer_id_seq') AS CUSTOMER_ID,
    		nous.cust_name,
           nous.cust_firstname,
           nous.cust_lastname,
           nous.phone_number AS phone,
           nous.customers_id::VARCHAR AS customer_src_id,
           ad.address_id AS address_id,
           CURRENT_DATE AS START_DT,
           DATE '9999-12-31' AS END_DT,
           'Y' AS IS_ACTIVE,
           CURRENT_DATE AS TA_INSERT_DT,
           'sa_no_usa_orders' AS source_system,
           'src_no_usa_order' AS source_entity
    FROM sa_no_usa_orders.src_no_usa_order nous
    left join bl_3nf.ce_addresses ad on nous.address_id_num=ad.address_src_id 
    and ad.source_system = 'sa_no_usa_orders'
    AND ad.source_entity = 'src_no_usa_order'
    WHERE  nous.is_processed = false    
    group by nous.cust_name, nous.cust_firstname, nous.cust_lastname, nous.phone_number, nous.customers_id, ad.address_id ;
      
        
		   
      
    -- Capture rows affected by the insert
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    RAISE NOTICE 'Inserted % row(s)', rows_affected;

    
    
    --  Log the operation
    PERFORM BL_CL.log_procedure_action('load_customers', rows_affected, 'Customers loaded successfully with SCD Type 2');

EXCEPTION
    WHEN OTHERS THEN
        PERFORM BL_CL.log_procedure_action('load_customers', 0, 'Error occurred during customers load: ' || SQLERRM);
        RAISE;
END;
$$;

CALL BL_cl.load_customers();
select * from bl_3nf.ce_customers_scd ;



-- Creating procedure to load data into CE_ORDERS with full incremental logic
CREATE OR REPLACE PROCEDURE BL_cl.load_orders()
LANGUAGE plpgsql AS $$
DECLARE
    rows_affected INT := 0;
BEGIN

    -- Insert new records
    INSERT INTO BL_3NF.CE_ORDERS (
        ORDERNUMBER, QUANTITYORDERED, SALES, PAYMENT_METHOD_ID, DEALSIZE_ID, PRODUCT_ID, CUSTOMER_ID, EVENT_DT, TA_INSERT_DT, TA_UPDATE_DT, ORDER_SRC_ID, SOURCE_SYSTEM, SOURCE_ENTITY
    )
    SELECT DISTINCT
        COALESCE(
            (SELECT ORDERNUMBER FROM BL_3NF.CE_ORDERS 
             WHERE ORDER_SRC_ID = us.ordernumber::VARCHAR
               AND SOURCE_SYSTEM = 'sa_us_orders'
               AND SOURCE_ENTITY = 'src_us_order'),
            nextval('BL_3NF.ordernumber_seq')
        ) AS ordernumber,
        us.quantityordered::INTEGER AS quantityordered,
        us.sales::NUMERIC AS sales,
        pm.PAYMENT_METHOD_ID AS payment_method_id,
        ds.DEALSIZE_ID AS dealsize_id,
        p.PRODUCT_ID AS product_id,
        c.CUSTOMER_ID AS customer_id,
        us.orderdate::DATE AS event_dt,
        CURRENT_DATE AS ta_insert_dt,
        CURRENT_TIMESTAMP AS ta_update_dt,
        us.ordernumber::VARCHAR AS order_src_id,
        'sa_us_orders' AS source_system,
        'src_us_order' AS source_entity
    FROM sa_us_orders.src_us_order us
    LEFT JOIN BL_3NF.CE_PAYMENT_METHODS pm 
    ON  pm.payment_src_id = us.payment_method
    AND pm.source_system = 'sa_us_orders'
    AND pm.source_entity = 'src_us_order'
    LEFT JOIN BL_3NF.CE_DEALSIZES ds 
    ON  ds.dealsize_src_id = us.dealsize
    AND ds.source_system = 'sa_us_orders'
    AND ds.source_entity = 'src_us_order'
    LEFT JOIN BL_3NF.CE_PRODUCTS p 
    ON  p.product_src_id = us.productcode
    AND p.source_system = 'sa_us_orders'
    AND p.source_entity = 'src_us_order'
    LEFT JOIN BL_3NF.CE_CUSTOMERS_SCD c 
    ON  c.customer_src_id = us.customer_id::VARCHAR
    AND c.source_system = 'sa_us_orders'
    AND c.source_entity = 'src_us_order'
    WHERE us.is_processed =  false -- incremental logic here , where is_processed is true, it wont insert again 
    and NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_ORDERS o 
        WHERE o.ORDER_SRC_ID = us.ordernumber::VARCHAR
          AND o.SOURCE_SYSTEM = 'sa_us_orders'
          AND o.SOURCE_ENTITY = 'src_us_order'
    )
    UNION ALL
    SELECT DISTINCT
        COALESCE(
            (SELECT ORDERNUMBER FROM BL_3NF.CE_ORDERS 
             WHERE ORDER_SRC_ID = nous.order_id::VARCHAR
               AND SOURCE_SYSTEM = 'sa_no_usa_orders'
               AND SOURCE_ENTITY = 'src_no_usa_order'),
            nextval('BL_3NF.ordernumber_seq')
        ) AS ordernumber,
        nous.quantity::INTEGER AS quantityordered,
        nous.sales_amount::NUMERIC AS sales,
        pm.PAYMENT_METHOD_ID AS payment_method_id,
        ds.DEALSIZE_ID AS dealsize_id,
        p.PRODUCT_ID AS product_id,
        c.CUSTOMER_ID AS customer_id,
        nous.date_of_order::DATE AS event_dt,
        CURRENT_DATE AS ta_insert_dt,
        CURRENT_TIMESTAMP AS ta_update_dt,
        nous.order_id::VARCHAR AS order_src_id,
        'sa_no_usa_orders' AS source_system,
        'src_no_usa_order' AS source_entity
    FROM sa_no_usa_orders.src_no_usa_order nous
    LEFT JOIN BL_3NF.CE_PAYMENT_METHODS pm 
    ON  pm.payment_src_id = nous.payment_method
    AND pm.source_system = 'sa_no_usa_orders'
    AND pm.source_entity = 'src_no_usa_order'
    LEFT JOIN BL_3NF.CE_DEALSIZES ds 
    ON  ds.dealsize_src_id = nous.deal_size
    AND ds.source_system = 'sa_no_usa_orders'
    AND ds.source_entity = 'src_no_usa_order'
    LEFT JOIN BL_3NF.CE_PRODUCTS p 
    ON  p.product_src_id = nous.product_model
    AND p.source_system = 'sa_no_usa_orders'
    AND p.source_entity = 'src_no_usa_order'
    LEFT JOIN BL_3NF.CE_CUSTOMERS_SCD c 
    ON  c.customer_src_id = nous.customers_id::VARCHAR
    AND c.source_system = 'sa_no_usa_orders'
    AND c.source_entity = 'src_no_usa_order'
    where nous.is_processed = false
    and NOT EXISTS (
        SELECT 1 FROM BL_3NF.CE_ORDERS o 
        WHERE o.ORDER_SRC_ID = nous.order_id::VARCHAR
          AND o.SOURCE_SYSTEM = 'sa_no_usa_orders'
          AND o.SOURCE_ENTITY = 'src_no_usa_order'
    );

   -- setting is_processed  to true where it was false
   UPDATE sa_us_orders.src_us_order
    SET is_processed = true
    WHERE  is_processed = false;

    UPDATE sa_no_usa_orders.src_no_usa_order
    SET is_processed = true
    WHERE  is_processed = false;

   -- updating references to customer so it will reference to new updated customer instead of old one. 
   UPDATE BL_3NF.CE_ORDERS o
		SET customer_id = cust_new.customer_id
		FROM BL_3NF.CE_CUSTOMERS_SCD cust_old
		JOIN BL_3NF.CE_CUSTOMERS_SCD cust_new 
		    ON cust_old.customer_src_id = cust_new.customer_src_id
		    AND cust_old.source_system = cust_new.source_system
		    AND cust_old.source_entity = cust_new.source_entity
		WHERE o.customer_id = cust_old.customer_id
		AND cust_new.is_active = true;   
  

    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    PERFORM BL_CL.log_procedure_action('load_orders', rows_affected, 'Orders loaded successfully');
EXCEPTION
    WHEN unique_violation THEN
        PERFORM BL_CL.log_procedure_action('load_orders', 0, 'Duplicate order number found and skipped');
    WHEN OTHERS THEN
        PERFORM BL_CL.log_procedure_action('load_orders', 0, 'Error occurred during orders load', SQLERRM);
        RAISE;
END;
$$;








-- Call the procedure to insert data into CE_DEALSIZES
CALL BL_cl.load_dealsizes();
select * from bl_3nf.ce_dealsizes cd ;

-- Call the procedure to insert data into CE_PAYMENT_METHODS
CALL BL_cl.load_payment_methods();
select * from bl_3nf.ce_payment_methods cpm ;

-- Call the procedure to insert data into CE_PRODUCTS
CALL BL_cl.load_products();
select * from bl_3nf.ce_products cp ;

-- Call the procedure to insert data into CE_COUNTRIES
CALL BL_cl.load_countries();
select * from bl_3nf.ce_countries cc;

-- Call the procedure to insert data into CE_STATES
CALL BL_cl.load_states();
select * from bl_3nf.ce_states cs ;

-- Call the procedure to insert data into CE_CITIES
CALL BL_cl.load_cities();
select * from bl_3nf.ce_cities cc ;

-- Call the procedure to insert data into CE_ADDRESSES
CALL BL_cl.load_addresses();
select *  from bl_3nf.ce_addresses ca ;
-- Call the procedure to insert data into CE_CUSTOMERS_SCD
CALL BL_cl.load_customers();
select * from bl_3nf.ce_customers_scd  where customer_src_id ='29';

-- Call the procedure to insert data into CE_ORDERS

CALL BL_cl.load_orders();




-- Check if the missing addresses are now in the CE_ADDRESSES table



select * from bl_3nf.ce_orders co  where order_src_id  ='40050060' ;


select * from ce_orders co  where customer_id= '29';

