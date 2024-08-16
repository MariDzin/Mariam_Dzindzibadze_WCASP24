
-- creating dm
CREATE OR REPLACE PROCEDURE bl_dm.create_dim_and_fct_tables_procedure()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Create dim_dealsizes table
    CREATE TABLE IF NOT EXISTS bl_dm.dim_dealsizes (
        dealsize_surr_id BIGINT PRIMARY KEY,
        dealsize_src_id VARCHAR(100) NOT NULL UNIQUE,
        dealsize VARCHAR(50) NOT NULL,
        ta_insert_dt DATE NOT NULL,
        ta_update_dt DATE NOT NULL,
        source_system VARCHAR(100) NOT NULL,
        source_entity VARCHAR(100) NOT NULL
    );

    -- Create dim_payment_methods table
    CREATE TABLE IF NOT EXISTS bl_dm.dim_payment_methods (
        payment_method_surr_id BIGINT PRIMARY KEY,
        payment_method_src_id VARCHAR(100) NOT NULL UNIQUE,
        payment_method VARCHAR(50) NOT NULL,
        ta_insert_dt DATE NOT NULL,
        ta_update_dt DATE NOT NULL,
        source_system VARCHAR(100) NOT NULL,
        source_entity VARCHAR(100) NOT NULL
    );

    -- Create dim_customers table
    CREATE TABLE IF NOT EXISTS bl_dm.dim_customers_scd (
        customer_surr_id BIGINT PRIMARY KEY,
        customer_src_id VARCHAR(100) NOT NULL,
        customername VARCHAR(100) NOT NULL,
        contactfirstname VARCHAR(100) NOT NULL,
        contactlastname VARCHAR(100) NOT NULL,
        phone VARCHAR(100) NOT NULL,
        addressline1 VARCHAR(100) NOT NULL,
        city_id BIGINT NOT NULL,
        city VARCHAR(100) NOT NULL,
        state_id BIGINT NOT NULL,
        state VARCHAR(100) NOT NULL,
        country_id BIGINT NOT NULL,
        country VARCHAR(100) NOT NULL,
        start_dt DATE NOT NULL,
        end_dt DATE NOT NULL,
        is_active VARCHAR(1) NOT NULL,
        ta_insert_dt DATE NOT NULL,
        ta_update_dt DATE NOT NULL,
        source_system VARCHAR(100) NOT NULL,
        source_entity VARCHAR(100) NOT NULL
    );

    -- Create dim_products table
    CREATE TABLE IF NOT EXISTS bl_dm.dim_products (
        product_surr_id BIGINT PRIMARY KEY,
        product_src_id VARCHAR(100) NOT NULL UNIQUE,
        productcode VARCHAR(50) NOT NULL UNIQUE,
        productline VARCHAR(100) NOT NULL,
        priceeach DECIMAL(15,2) NOT NULL,
        msrp DECIMAL(15,2) NOT NULL,
        ta_insert_dt DATE NOT NULL,
        ta_update_dt DATE NOT NULL,
        source_system VARCHAR(100) NOT NULL,
        source_entity VARCHAR(100) NOT NULL
    );

    -- Create dim_dates table
    CREATE TABLE IF NOT EXISTS bl_dm.dim_dates (
        date_src_id VARCHAR(100) PRIMARY KEY,
        day_id INTEGER NOT NULL,
        month_id INTEGER NOT NULL,
        year_id INTEGER NOT NULL,
        qrt_id INTEGER NOT NULL,
        week_id INTEGER NOT NULL
    );

    -- Create fct_orders table
    CREATE TABLE IF NOT EXISTS bl_dm.fct_orders (
        ordernumber_src_id VARCHAR(100) PRIMARY KEY,
        payment_method_surr_id BIGINT NOT NULL,
        dealsize_surr_id BIGINT NOT NULL,
        product_surr_id BIGINT NOT NULL,
        customer_surr_id BIGINT NOT NULL,
        date_src_id VARCHAR(100) NOT NULL,
        sales DECIMAL(15,2) NOT NULL,
        quantityordered INTEGER NOT NULL,
        total_cost DECIMAL(15,2) NOT NULL,
        ta_insert_dt DATE NOT NULL,
        ta_update_dt DATE NOT NULL,
        event_dt DATE NOT NULL,
        source_system VARCHAR(100) NOT NULL,
        source_entity VARCHAR(100) NOT NULL,
        FOREIGN KEY (payment_method_surr_id) REFERENCES bl_dm.dim_payment_methods(payment_method_surr_id),
        FOREIGN KEY (dealsize_surr_id) REFERENCES bl_dm.dim_dealsizes(dealsize_surr_id),
        FOREIGN KEY (product_surr_id) REFERENCES bl_dm.dim_products(product_surr_id),
        FOREIGN KEY (customer_surr_id) REFERENCES bl_dm.dim_customers_scd(customer_surr_id),
        FOREIGN KEY (date_src_id) REFERENCES bl_dm.dim_dates(date_src_id)
    );

    RAISE NOTICE 'Tables created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error occurred during table creation: %', SQLERRM;
END;
$$;




CREATE OR REPLACE PROCEDURE bl_dm.insert_default_values_procedure()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert default row into dim_dealsizes
    INSERT INTO bl_dm.dim_dealsizes (
        dealsize_surr_id, dealsize_src_id, dealsize, ta_insert_dt, ta_update_dt, source_system, source_entity
    )
    SELECT -1, 'n. a.', 'n. a.', '1900-01-01', '1900-01-01', 'n. a.', 'n. a.'
    WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_dealsizes WHERE dealsize_surr_id = -1);

    -- Insert default row into dim_payment_methods
    INSERT INTO bl_dm.dim_payment_methods (
        payment_method_surr_id, payment_method_src_id, payment_method, ta_insert_dt, ta_update_dt, source_system, source_entity
    )
    SELECT -1, 'n. a.', 'n. a.', '1900-01-01', '1900-01-01', 'n. a.', 'n. a.'
    WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_payment_methods WHERE payment_method_surr_id = -1);

    -- Insert default row into dim_customers
    INSERT INTO bl_dm.dim_customers_scd (
        customer_surr_id, customer_src_id, customername, contactfirstname, contactlastname, phone, addressline1, city_id, city, state_id, state, country_id, country, start_dt, end_dt, is_active, ta_insert_dt, ta_update_dt, source_system, source_entity
    )
    SELECT -1, 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', -1, 'n. a.', -1, 'n. a.', -1, 'n. a.', '1900-01-01', '9999-12-31', 'Y', '1900-01-01', '1900-01-01', 'n. a.', 'n. a.'
    WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_customers_scd WHERE customer_surr_id = -1);

    -- Insert default row into dim_products
    INSERT INTO bl_dm.dim_products (
        product_surr_id, product_src_id, productcode, productline, priceeach, msrp, ta_insert_dt, ta_update_dt, source_system, source_entity
    )
    SELECT -1, 'n. a.', 'n. a.', 'n. a.', -1, -1, '1900-01-01', '1900-01-01', 'n. a.', 'n. a.'
    WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_products WHERE product_surr_id = -1);

    -- Insert default row into dim_dates
    INSERT INTO bl_dm.dim_dates (
        date_src_id, day_id, month_id, year_id, qrt_id, week_id
    )
    SELECT 'n. a.', -1, -1, -1, -1, -1
    WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_dates WHERE date_src_id = 'n. a.');

    -- Insert default row into fct_orders
    INSERT INTO bl_dm.fct_orders (
        ordernumber_src_id, payment_method_surr_id, dealsize_surr_id, product_surr_id, customer_surr_id, date_src_id, sales, quantityordered, total_cost, ta_insert_dt, ta_update_dt, event_dt, source_system, source_entity
    )
    SELECT 'n. a.', -1, -1, -1, -1, 'n. a.', -1, 1, -1, '1900-01-01', '1900-01-01', '1900-01-01', 'n. a.', 'n. a.'
    WHERE NOT EXISTS (SELECT 1 FROM bl_dm.fct_orders WHERE ordernumber_src_id = 'n. a.');

    RAISE NOTICE 'Default values inserted successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error occurred during default value insertion: %', SQLERRM;
END;
$$;



CALL bl_dm.create_dim_and_fct_tables_procedure();
CALL bl_dm.insert_default_values_procedure();

