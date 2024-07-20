-- install FDW extension
CREATE EXTENSION IF NOT EXISTS file_fdw;

-- create server for file_fdw
CREATE server if not exists  file_server
FOREIGN DATA WRAPPER file_fdw
OPTIONS (program 'file_fdw');

-- creating schema for no usa orders 
CREATE SCHEMA IF NOT EXISTS sa_no_usa_orders;
-- creating first foreign table
CREATE SCHEMA IF NOT EXISTS sa_no_usa_orders;

-- creating first foreign table
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
) SERVER file_server OPTIONS (
    filename 'C:\\Program Files\\PostgreSQL\\16\\data\\updated_csvfile_no_usa.csv',
    format 'csv',
    header 'true',
    delimiter ',',
    quote '"',
    escape '\\',
    null 'NULL',
    encoding 'UTF8'
);

-- creating schema for usa orders dataset
CREATE SCHEMA IF NOT EXISTS sa_us_orders;

-- creating foreign table for the usa orders dataset
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
) SERVER file_server OPTIONS (
    filename 'C:\\Program Files\\PostgreSQL\\16\\data\\updated_csvfile.csv',
    format 'csv',
    header 'true',
    delimiter ',',
    quote '"',
    escape '\\',
    null 'NULL',
    encoding 'UTF8'
);

-- create source tables
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

-- creating source table for usa orders
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

-- now inserting 

INSERT INTO sa_no_usa_orders.src_no_usa_order (
    order_id,
    quantity,
    price_for_each,
    sales_amount,
    date_of_order,
    deal_size,
    quarter,
    day,
    month,
    year,
    productline_id,
    product_line,
    ms_rp,
    product_model,
    customers_id,
    cust_name,
    cust_firstname,
    cust_lastname,
    phone_number,
    address_id_num,
    address_line,
    city_name,
    postcode,
    country_name,
    payment_method
)
SELECT DISTINCT
    order_id::VARCHAR(150),
    quantity::VARCHAR(150),
    price_for_each::VARCHAR(150),
    sales_amount::VARCHAR(150),
    date_of_order::VARCHAR(150),
    deal_size::VARCHAR(150),
    quarter::VARCHAR(150),
    day::VARCHAR(150),
    month::VARCHAR(150),
    year::VARCHAR(150),
    productline_id::VARCHAR(150),
    product_line::VARCHAR(150),
    ms_rp::VARCHAR(150),
    product_model::VARCHAR(150),
    customers_id::VARCHAR(150),
    cust_name::VARCHAR(150),
    cust_firstname::VARCHAR(150),
    cust_lastname::VARCHAR(150),
    phone_number::VARCHAR(150),
    address_id_num::VARCHAR(150),
    address_line::VARCHAR(150),
    city_name::VARCHAR(150),
    postcode::VARCHAR(150),
    country_name::VARCHAR(150),
    payment_method::VARCHAR(150)
FROM sa_no_usa_orders.ext_no_usa_order;
COMMIT;

SELECT * FROM sa_no_usa_orders.ext_no_usa_order LIMIT 10;

-- inserting in usa orders 
INSERT INTO sa_us_orders.src_us_order (
    ordernumber,
    quantityordered,
    priceeach,
    sales,
    orderdate,
    dealsize,
    qtr_id,
    day_id,
    month_id,
    year_id,
    productline_id,
    productline,
    msrp,
    productcode,
    customer_id,
    customername,
    contactfirstname,
    contactlastname,
    phone,
    address_id,
    addressline1,
    city,
    state,
    postalcode,
    country,
    payment_method
)
SELECT DISTINCT
    ordernumber::VARCHAR(150),
    quantityordered::VARCHAR(150),
    priceeach::VARCHAR(150),
    sales::VARCHAR(150),
    orderdate::VARCHAR(150),
    dealsize::VARCHAR(150),
    qtr_id::VARCHAR(150),
    day_id::VARCHAR(150),
    month_id::VARCHAR(150),
    year_id::VARCHAR(150),
    productline_id::VARCHAR(150),
    productline::VARCHAR(150),
    msrp::VARCHAR(150),
    productcode::VARCHAR(150),
    customer_id::VARCHAR(150),
    customername::VARCHAR(150),
    contactfirstname::VARCHAR(150),
    contactlastname::VARCHAR(150),
    phone::VARCHAR(150),
    address_id::VARCHAR(150),
    addressline1::VARCHAR(150),
    city::VARCHAR(150),
    state::VARCHAR(150),
    postalcode::VARCHAR(150),
    country::VARCHAR(150),
    payment_method::VARCHAR(150)
FROM sa_us_orders.ext_us_order;
COMMIT;

SELECT * FROM sa_us_orders.ext_us_order LIMIT 10;