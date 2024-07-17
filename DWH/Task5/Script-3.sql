-- install FDW extension
CREATE EXTENSION IF NOT EXISTS file_fdw;

-- create server for file_fdw
CREATE server if not exists  file_server
FOREIGN DATA WRAPPER file_fdw
OPTIONS (program 'file_fdw');

-- creating schema for no usa orders 
CREATE SCHEMA IF NOT EXISTS sa_no_usa_orders;
-- creating first foreign table
CREATE FOREIGN TABLE if not exists sa_no_usa_orders.ext_no_usa_orders (
    order_id INTEGER,
    quantity INTEGER,
    price_for_each NUMERIC,
    sales_amount NUMERIC,
    date_of_order DATE,
    deal_size VARCHAR(50),
    quarter INTEGER,
    day INTEGER,
    month INTEGER,
    year INTEGER,
    productline_id INTEGER,
    product_line VARCHAR(100),
    ms_rp NUMERIC,
    product_model VARCHAR(100),
    customers_id INTEGER,
    cust_name VARCHAR(100),
    cust_firstname Varchar(100),
    cust_lastname VARCHAR(100),
    phone_number VARCHAR(20),
    address_id_num INTEGER,
    address_line VARCHAR(200),
    city_name VARCHAR(100),
    postcode VARCHAR(20),
    country_name VARCHAR(100),
    payment_method VARCHAR(10)
) SERVER file_server OPTIONS (
    filename 'C:\Program Files\PostgreSQL\16\data\updated_csvfile_no_usa.csv',
    format 'csv',
    header 'true',
    delimiter ',',
    quote '"',
    escape '\',
    null 'NULL',
    encoding 'UTF8'
);

-- creating schema for usa orders dataset

CREATE SCHEMA IF NOT EXISTS sa_us_orders;

-- creating foreign table for the usa orders dataset
CREATE FOREIGN table if not exists sa_us_orders.ext_us_orders (
    ordernumber INTEGER,
    quantityordered INTEGER,
    priceeach numeric,
    sales NUMERIC,
    orderdate DATE,
    dealsize VARCHAR(50),
    qtr_id INTEGER,
    day_id INTEGER,
    month_id INTEGER,
    year_id INTEGER,
    productline_id INTEGER,
    productline VARCHAR(100),
    msrp NUMERIC,
    productcode VARCHAR(100),
    customer_id INTEGER,
    customername VARCHAR(100),
    contactfirstname VARCHAR(100),
    contactlastname VARCHAR(100),
    phone VARCHAR(20),
    address_id INTEGER,
    addressline1 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    postalcode VARCHAR(20),
    country VARCHAR(100),
    payment_method VARCHAR(10)
) SERVER file_server OPTIONS (
 filename 'C:\Program Files\PostgreSQL\16\data\updated_csvfile.csv',
    format 'csv',
    header 'true',
    delimiter ',',
    quote '"',
    escape '\',
    null 'NULL',
    encoding 'UTF8'   
);


-- create source tables
CREATE TABLE IF NOT EXISTS sa_no_usa_orders.src_no_usa_orders (
    order_id INTEGER,
    quantity INTEGER,
    price_for_each NUMERIC,
    sales_amount NUMERIC,
    date_of_order DATE,
    deal_size VARCHAR(50),
    quarter INTEGER,
    day INTEGER,
    month INTEGER,
    year INTEGER,
    productline_id INTEGER,
    product_line VARCHAR(100),
    ms_rp NUMERIC,
    product_model VARCHAR(100),
    customers_id INTEGER,
    cust_name VARCHAR(100),
    cust_firstname Varchar(100),
    cust_lastname VARCHAR(100),
    phone_number VARCHAR(20),
    address_id_num INTEGER,
    address_line VARCHAR(200),
    city_name VARCHAR(100),
    postcode VARCHAR(20),
    country_name VARCHAR(100),
    payment_method VARCHAR(10)
);

-- creating source table for usa orders
CREATE TABLE IF NOT EXISTS sa_us_orders.src_us_orders (
    ordernumber INTEGER,
    quantityordered INTEGER,
    priceeach NUMERIC,
    sales NUMERIC,
    orderdate DATE,
    dealsize VARCHAR(50),
    qtr_id INTEGER,
    day_id INTEGER,
    month_id INTEGER,
    year_id INTEGER,
    productline_id INTEGER,
    productline VARCHAR(100),
    msrp NUMERIC,
    productcode VARCHAR(100),
    customer_id INTEGER,
    customername VARCHAR(100),
    contactfirstname VARCHAR(100),
    contactlastname VARCHAR(100),
    phone VARCHAR(20),
    address_id INTEGER,
    addressline1 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    postalcode VARCHAR(20),
    country VARCHAR(100),
    payment_method VARCHAR(10)
);




-- now inserting 

INSERT INTO sa_no_usa_orders.src_no_usa_orders (
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
FROM sa_no_usa_orders.ext_no_usa_orders;

select * from sa_no_usa_orders.ext_no_usa_orders limit 10



-- insterting in usa orders 

INSERT INTO sa_us_orders.src_us_orders (
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
FROM sa_us_orders.ext_us_orders;

select * from sa_us_orders.ext_us_orders limit 10
