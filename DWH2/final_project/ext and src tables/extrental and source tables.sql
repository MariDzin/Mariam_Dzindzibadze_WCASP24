CREATE SCHEMA IF NOT EXISTS sa_no_usa_orders;
CREATE SCHEMA IF NOT EXISTS sa_us_orders;
CREATE EXTENSION IF NOT EXISTS file_fdw;  


    -- Drop Foreign Tables if they exist
    DROP FOREIGN TABLE IF EXISTS sa_no_usa_orders.ext_no_usa_order;
    DROP FOREIGN TABLE IF  EXISTS sa_us_orders.ext_us_order;



    -- Create Foreign Table for Non-USA Orders
    CREATE FOREIGN TABLE IF NOT EXISTS sa_no_usa_orders.ext_no_usa_order (
        order_id VARCHAR(150),
        quantity VARCHAR(150),
        price_for_each VARCHAR(150),
        sales_amount VARCHAR(150),
        date_of_order VARCHAR(150),
        deal_size VARCHAR(150),
        quarter VARCHAR(150),
        day VARCHAR(150),
        month VARCHAR(150),
        year VARCHAR(150),
        productline_id VARCHAR(150),
        product_line VARCHAR(150),
        ms_rp VARCHAR(150),
        product_model VARCHAR(150),
        customers_id VARCHAR(150),
        cust_name VARCHAR(150),
        cust_firstname VARCHAR(150),
        cust_lastname VARCHAR(150),
        phone_number VARCHAR(150),
        address_id_num VARCHAR(150),
        address_line VARCHAR(150),
        city_name VARCHAR(150),
        postcode VARCHAR(150),
        country_name VARCHAR(150),
        payment_method VARCHAR(150)
    ) SERVER file_server 
    OPTIONS (
        filename 'C:\\Program Files\\PostgreSQL\\16\\data\\updated_csvfile_no_usa.csv',
        format 'csv',
        header 'true',
        delimiter ',',
        quote '"',
        escape E'\\', 
        null 'NULL',
        encoding 'UTF8'
    );

    -- Create Foreign Table for USA Orders
    CREATE FOREIGN TABLE IF NOT EXISTS sa_us_orders.ext_us_order (
        ordernumber VARCHAR(150),
        quantityordered VARCHAR(150),
        priceeach VARCHAR(150),
        sales VARCHAR(150),
        orderdate VARCHAR(150),
        dealsize VARCHAR(150),
        qtr_id VARCHAR(150),
        day_id VARCHAR(150),
        month_id VARCHAR(150),
        year_id VARCHAR(150),
        productline_id VARCHAR(150),
        productline VARCHAR(150),
        msrp VARCHAR(150),
        productcode VARCHAR(150),
        customer_id VARCHAR(150),
        customername VARCHAR(150),
        contactfirstname VARCHAR(150),
        contactlastname VARCHAR(150),
        phone VARCHAR(150),
        address_id VARCHAR(150),
        addressline1 VARCHAR(150),
        city VARCHAR(150),
        state VARCHAR(150),
        postalcode VARCHAR(150),
        country VARCHAR(150),
        payment_method VARCHAR(150)
    ) SERVER file_server 
    OPTIONS (
        filename 'C:\\Program Files\\PostgreSQL\\16\\data\\updated_csvfile.csv',
        format 'csv',
        header 'true',
        delimiter ',',
        quote '"',
        escape E'\\', 
        null 'NULL',
        encoding 'UTF8'
    );





--  Procedure for Creating Source Tables


CREATE OR REPLACE PROCEDURE public.create_src_tables_procedure()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Create source table for non-USA orders
    CREATE TABLE IF NOT EXISTS sa_no_usa_orders.src_no_usa_order (
        order_id VARCHAR(150),
        quantity VARCHAR(150),
        price_for_each VARCHAR(150),
        sales_amount VARCHAR(150),
        date_of_order VARCHAR(150),
        deal_size VARCHAR(150),
        quarter VARCHAR(150),
        day VARCHAR(150),
        month VARCHAR(150),
        year VARCHAR(150),
        productline_id VARCHAR(150),
        product_line VARCHAR(150),
        ms_rp VARCHAR(150),
        product_model VARCHAR(150),
        customers_id VARCHAR(150),
        cust_name VARCHAR(150),
        cust_firstname VARCHAR(150),
        cust_lastname VARCHAR(150),
        phone_number VARCHAR(150),
        address_id_num VARCHAR(150),
        address_line VARCHAR(150),
        city_name VARCHAR(150),
        postcode VARCHAR(150),
        country_name VARCHAR(150),
        payment_method VARCHAR(150)
    );

    -- Create source table for USA orders
    CREATE TABLE IF NOT EXISTS sa_us_orders.src_us_order (
        ordernumber VARCHAR(150),
        quantityordered VARCHAR(150),
        priceeach VARCHAR(150),
        sales VARCHAR(150),
        orderdate VARCHAR(150),
        dealsize VARCHAR(150),
        qtr_id VARCHAR(150),
        day_id VARCHAR(150),
        month_id VARCHAR(150),
        year_id VARCHAR(150),
        productline_id VARCHAR(150),
        productline VARCHAR(150),
        msrp VARCHAR(150),
        productcode VARCHAR(150),
        customer_id VARCHAR(150),
        customername VARCHAR(150),
        contactfirstname VARCHAR(150),
        contactlastname VARCHAR(150),
        phone VARCHAR(150),
        address_id VARCHAR(150),
        addressline1 VARCHAR(150),
        city VARCHAR(150),
        state VARCHAR(150),
        postalcode VARCHAR(150),
        country VARCHAR(150),
        payment_method VARCHAR(150)
    );

    RAISE NOTICE 'Source tables created';
    
EXCEPTION
    WHEN OTHERS THEN
        -- Raise the exception to propagate the error
        RAISE NOTICE 'Source tables are not created: %', SQLERRM;
END;
$$;

-- Call the procedure to create source tables
CALL public.create_src_tables_procedure();



-- Create Logging Table
CREATE TABLE IF NOT EXISTS public.logging (
    log_id SERIAL PRIMARY KEY,
    log_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    procedure_name VARCHAR(255),
    rows_affected INT,
    message TEXT
);



-- Procedure for Non-USA Orders
CREATE OR REPLACE PROCEDURE sa_no_usa_orders.insert_data_into_src_no_usa_procedure()
LANGUAGE plpgsql
AS $$
DECLARE 
    inserted_count INTEGER;
BEGIN
    WITH inserted AS (
        INSERT INTO sa_no_usa_orders.src_no_usa_order (
            order_id, quantity, price_for_each, sales_amount, date_of_order, 
            deal_size, quarter, day, month, year, productline_id, product_line, 
            ms_rp, product_model, customers_id, cust_name, cust_firstname, 
            cust_lastname, phone_number, address_id_num, address_line, 
            city_name, postcode, country_name, payment_method
        )
        SELECT DISTINCT
            nous.order_id::VARCHAR(150),
            nous.quantity::VARCHAR(150),
            nous.price_for_each::VARCHAR(150),
            nous.sales_amount::VARCHAR(150),
            nous.date_of_order::VARCHAR(150),
            nous.deal_size::VARCHAR(150),
            nous.quarter::VARCHAR(150),
            nous.day::VARCHAR(150),
            nous.month::VARCHAR(150),
            nous.year::VARCHAR(150),
            nous.productline_id::VARCHAR(150),
            nous.product_line::VARCHAR(150),
            nous.ms_rp::VARCHAR(150),
            nous.product_model::VARCHAR(150),
            nous.customers_id::VARCHAR(150),
            nous.cust_name::VARCHAR(150),
            nous.cust_firstname::VARCHAR(150),
            nous.cust_lastname::VARCHAR(150),
            nous.phone_number::VARCHAR(150),
            nous.address_id_num::VARCHAR(150),
            nous.address_line::VARCHAR(150),
            nous.city_name::VARCHAR(150),
            nous.postcode::VARCHAR(150),
            nous.country_name::VARCHAR(150),
            nous.payment_method::VARCHAR(150)
        FROM sa_no_usa_orders.ext_no_usa_order nous
        WHERE NOT EXISTS (
            SELECT 1 
            FROM sa_no_usa_orders.src_no_usa_order src
            WHERE src.order_id = nous.order_id
        )
        RETURNING 1
    )
    SELECT COUNT(*) INTO inserted_count FROM inserted;
    
    -- Log the operation
    INSERT INTO public.logging (procedure_name, rows_affected, message)
    VALUES ('insert_data_into_src_no_usa_procedure', inserted_count, 'Inserted new data into src_no_usa_order table');

    RAISE NOTICE 'Inserted rows into src_no_usa_order: %', inserted_count;
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO public.logging (procedure_name, rows_affected, message)
        VALUES ('insert_data_into_src_no_usa_procedure', 0, 'Error occurred: ' || SQLERRM);
        RAISE NOTICE 'Error occurred while inserting data into src_no_usa_order: %', SQLERRM;
END;
$$;

-- Procedure for USA Orders
CREATE OR REPLACE PROCEDURE sa_us_orders.insert_data_into_src_us_procedure()
LANGUAGE plpgsql
AS $$
DECLARE 
    inserted_count INTEGER;
BEGIN
    WITH inserted AS (
        INSERT INTO sa_us_orders.src_us_order (
            ordernumber, quantityordered, priceeach, sales, orderdate, dealsize, 
            qtr_id, day_id, month_id, year_id, productline_id, productline, 
            msrp, productcode, customer_id, customername, contactfirstname, 
            contactlastname, phone, address_id, addressline1, city, state, 
            postalcode, country, payment_method
        )
        SELECT DISTINCT
            us.ordernumber::VARCHAR(150),
            us.quantityordered::VARCHAR(150),
            us.priceeach::VARCHAR(150),
            us.sales::VARCHAR(150),
            us.orderdate::VARCHAR(150),
            us.dealsize::VARCHAR(150),
            us.qtr_id::VARCHAR(150),
            us.day_id::VARCHAR(150),
            us.month_id::VARCHAR(150),
            us.year_id::VARCHAR(150),
            us.productline_id::VARCHAR(150),
            us.productline::VARCHAR(150),
            us.msrp::VARCHAR(150),
            us.productcode::VARCHAR(150),
            us.customer_id::VARCHAR(150),
            us.customername::VARCHAR(150),
            us.contactfirstname::VARCHAR(150),
            us.contactlastname::VARCHAR(150),
            us.phone::VARCHAR(150),
            us.address_id::VARCHAR(150),
            us.addressline1::VARCHAR(150),
            us.city::VARCHAR(150),
            us.state::VARCHAR(150),
            us.postalcode::VARCHAR(150),
            us.country::VARCHAR(150),
            us.payment_method::VARCHAR(150)
        FROM sa_us_orders.ext_us_order us
        WHERE NOT EXISTS (
            SELECT 1 
            FROM sa_us_orders.src_us_order src
            WHERE src.ordernumber = us.ordernumber
        )
        RETURNING 1
    )
    SELECT COUNT(*) INTO inserted_count FROM inserted;
    
    -- Log the operation
    INSERT INTO public.logging (procedure_name, rows_affected, message)
    VALUES ('insert_data_into_src_us_procedure', inserted_count, 'Inserted new data into src_us_order table');

    RAISE NOTICE 'Inserted rows into src_us_order: %', inserted_count;
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO public.logging (procedure_name, rows_affected, message)
        VALUES ('insert_data_into_src_us_procedure', 0, 'Error occurred: ' || SQLERRM);
        RAISE NOTICE 'Error occurred while inserting data into src_us_order: %', SQLERRM;
END;
$$;


-- Create Indexes for Efficient Lookup
CREATE INDEX IF NOT EXISTS order_id_index_no_usa 
    ON sa_no_usa_orders.src_no_usa_order(order_id);

CREATE INDEX IF NOT EXISTS ordernumber_index_us 
    ON sa_us_orders.src_us_order(ordernumber);

-- Call the Procedures to Insert Data
CALL sa_no_usa_orders.insert_data_into_src_no_usa_procedure();
CALL sa_us_orders.insert_data_into_src_us_procedure();


SELECT * FROM sa_us_orders.src_us_order LIMIT 10;
SELECT * FROM sa_no_usa_orders.src_no_usa_order LIMIT 10;