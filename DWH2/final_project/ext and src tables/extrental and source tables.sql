-- Create Schemas
CREATE SCHEMA IF NOT EXISTS sa_no_usa_orders;
CREATE SCHEMA IF NOT EXISTS sa_us_orders;

-- Create Extension for file_fdw if not already present
CREATE EXTENSION IF NOT EXISTS file_fdw;

-- Drop Foreign Tables if they exist
DROP FOREIGN TABLE IF EXISTS sa_no_usa_orders.ext_no_usa_order;
DROP FOREIGN TABLE IF EXISTS sa_us_orders.ext_us_order;

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

-- Create Source Tables

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
    payment_method VARCHAR(150),
    receive_date date,
    is_processed boolean default false
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
    payment_method VARCHAR(150),
    receive_date date,
    is_processed boolean default false
);

-- Create Logging Table
CREATE TABLE IF NOT EXISTS public.logging (
    log_id SERIAL PRIMARY KEY,
    log_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    procedure_name VARCHAR(255),
    rows_affected INT,
    message TEXT
);

-- Log operation procedure
CREATE OR REPLACE PROCEDURE public.log_operation(
    procedure_name VARCHAR(255),
    rows_affected INT,
    message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.logging (
        log_datetime, 
        procedure_name, 
        rows_affected, 
        message
    )
    VALUES (
        CLOCK_TIMESTAMP(),
        procedure_name,
        rows_affected,
        message
    );
END;
$$;

-- Inserting data into no USA orders
CREATE OR REPLACE PROCEDURE sa_no_usa_orders.insert_data_into_src_no_usa_procedure()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO sa_no_usa_orders.src_no_usa_order (
        order_id, quantity, price_for_each, sales_amount, date_of_order, 
        deal_size, quarter, day, month, year, productline_id, product_line, 
        ms_rp, product_model, customers_id, cust_name, cust_firstname, 
        cust_lastname, phone_number, address_id_num, address_line, 
        city_name, postcode, country_name, payment_method, receive_date
    )
    SELECT DISTINCT
        nous.order_id,
        nous.quantity,
        nous.price_for_each,
        nous.sales_amount,
        nous.date_of_order,
        nous.deal_size,
        nous.quarter,
        nous.day,
        nous.month,
        nous.year,
        nous.productline_id,
        nous.product_line,
        nous.ms_rp,
        nous.product_model,
        nous.customers_id,
        nous.cust_name,
        nous.cust_firstname,
        nous.cust_lastname,
        nous.phone_number,
        nous.address_id_num,
        nous.address_line,
        nous.city_name,
        nous.postcode,
        nous.country_name,
        nous.payment_method,
        current_date 
    FROM sa_no_usa_orders.ext_no_usa_order nous;
END;
$$;

-- Procedure for inserting data into USA Orders
CREATE OR REPLACE PROCEDURE sa_us_orders.insert_data_into_src_us_procedure()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO sa_us_orders.src_us_order (
        ordernumber, quantityordered, priceeach, sales, orderdate, dealsize, 
        qtr_id, day_id, month_id, year_id, productline_id, productline, 
        msrp, productcode, customer_id, customername, contactfirstname, 
        contactlastname, phone, address_id, addressline1, city, state, 
        postalcode, country, payment_method, receive_date
    )
    SELECT DISTINCT
        us.ordernumber,
        us.quantityordered,
        us.priceeach,
        us.sales,
        us.orderdate,
        us.dealsize,
        us.qtr_id,
        us.day_id,
        us.month_id,
        us.year_id,
        us.productline_id,
        us.productline,
        us.msrp,
        us.productcode,
        us.customer_id,
        us.customername,
        us.contactfirstname,
        us.contactlastname,
        us.phone,
        us.address_id,
        us.addressline1,
        us.city,
        us.state,
        us.postalcode,
        us.country,
        us.payment_method,
        CURRENT_DATE 
    FROM sa_us_orders.ext_us_order us;
END;
$$;


CALL sa_no_usa_orders.insert_data_into_src_no_usa_procedure();
CALL sa_us_orders.insert_data_into_src_us_procedure();





--  Verify the Data Insertion

SELECT distinct contactlastname  FROM sa_no_usa_orders.src_no_usa_order snuo  where customer_id ='29' and is_processed=false ;



