-- SQL PROJECT: DATABASE DESIGN FOR A SUPPLY CHAIN COMPANY (DataCo)

/*
PROJECT OVERVIEW
------------------

This project goal is to build a simple database to help us track and manage customer orders 
of a e-commerce company called DataCo. The system will provide insights into sales 
performance, delivery status, and customer behavior, enabling better decision-making for 
the organization, and support automactic reporting and dashboard. This system aims 
to streamline the entire supply chain process, from order placement to product delivery, 
thus enhancing overall operational efficiency.

DATABASE STRUCTURE
------------------

The Database will contain 6 dimension tables and 1 fact table for order information
1) dim_location: stores geographical details of orders, including city, state, region, country, and market classification.
2) dim_customer: contains detailed customer information, including personal details, location, and segmentation for analysis.
3) dim_category: Product category
4) dim_product: Details about products
5) dim_department: Department name and their id
6) dim_order_shipping: Information related to order
7) fact_item: 



*/
USE dataco;

-- 1) CREATE dim_location TABLE with an AUTO_INCREMENT primary key
CREATE TABLE IF NOT EXISTS dim_location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    order_city VARCHAR(100),
    order_state VARCHAR(50),
    order_zipcode VARCHAR(10),
    order_region VARCHAR(50),
    order_country VARCHAR(100),
    market VARCHAR(20),
    UNIQUE (order_city, order_state, order_zipcode, order_region, order_country, market)  -- Ensure uniqueness
);

-- INSERT only distinct location records
INSERT INTO dim_location (order_city, order_state, order_zipcode, order_region, order_country, market)
SELECT DISTINCT order_city, order_state, order_zipcode, order_region, order_country, market
FROM interim_data;

SELECT COUNT(*)
FROM dataco.dim_location dl ;

--- 2) CREATE dim_customer TABLE

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id INT PRIMARY KEY,
    customer_fname VARCHAR(50),
    customer_lname VARCHAR(50),
    customer_email VARCHAR(150),
    customer_password VARCHAR(100),
    customer_segment VARCHAR(50),
    customer_street VARCHAR(100),
    customer_city VARCHAR(100),
    customer_state VARCHAR(50),
    customer_zipcode VARCHAR(10),
    latitude DECIMAL(18, 10), 
    longitude DECIMAL(18, 10)
);

INSERT INTO dim_customer (	customer_id, customer_fname, customer_lname, customer_email, customer_password, customer_segment, customer_city, customer_street, customer_state, customer_zipcode, latitude, longitude)
SELECT DISTINCT				customer_id, customer_fname, customer_lname, customer_email, customer_password, customer_segment, customer_city, customer_street, customer_state, customer_zipcode, latitude, longitude
FROM interim_data;

SELECT COUNT(*)
FROM dim_customer;


-- 3) CREATE dim_category TABLE

CREATE TABLE dim_category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100)
);

INSERT INTO dim_category (	category_id, category_name)
SELECT DISTINCT 			category_id, category_name
FROM interim_data;

SELECT COUNT(*)
FROM dim_category;


-- 4) CREATE dim_product TABLE

CREATE TABLE IF NOT EXISTS dim_product (
    product_card_id INT PRIMARY KEY,
    product_name VARCHAR(150),
    product_category_id INT,
    product_image VARCHAR(255),
    product_price DECIMAL(18, 10),
    FOREIGN KEY (product_category_id) REFERENCES dim_category(category_id)
);


INSERT INTO dim_product (	product_card_id, product_name, product_category_id, product_image, product_price)
SELECT DISTINCT 			product_card_id, product_name, product_category_id, product_image, product_price
FROM interim_data;

SELECT COUNT(*)
FROM dim_product;
    
    
-- 5) CREATE dim_department TABLE

CREATE TABLE dim_department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

INSERT INTO dim_department (department_id, department_name)
SELECT DISTINCT     		department_id, department_name
FROM interim_data;

SELECT COUNT(*)
FROM dim_department;


-- 6) CREATE dim_order_shipping TABLE

-- Create dim_order_shipping table
CREATE TABLE IF NOT EXISTS dim_order_shipping (
    order_id INT PRIMARY KEY,
    order_customer_id INT,
    order_date DATETIME,
    order_status VARCHAR(50),
    type VARCHAR(50),
    market VARCHAR(50),
    order_region VARCHAR(50),
    order_country VARCHAR(100),
    order_state VARCHAR(50),
    order_city VARCHAR(100),
    order_zipcode VARCHAR(10),
    location_id INT,
    shipping_mode VARCHAR(50),
    delivery_status VARCHAR(50),
    late_delivery_risk INT,
    shipping_date DATETIME,
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,
    FOREIGN KEY (order_customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id)
);




INSERT INTO dim_order_shipping (
    order_id,
    order_customer_id,
    order_date,
    order_status,
    type,
    market,
    order_region,
    order_country,
    order_state,
    order_city,
    order_zipcode,
    shipping_mode,
    delivery_status,
    late_delivery_risk,
    shipping_date,
    days_for_shipping_real,
    days_for_shipment_scheduled
)
SELECT DISTINCT
    order_id,
    customer_id,
    order_date,
    order_status,
    type,
    market,
    order_region,
    order_country,
    order_state,
    order_city,
    order_zipcode,
    shipping_mode,
    delivery_status,
    late_delivery_risk,
    shipping_date,
    days_for_shipping_real,
    days_for_shipment_scheduled
FROM interim_data;


UPDATE dim_order_shipping dos
JOIN dim_location dl
ON dos.order_city = dl.order_city
AND dos.order_state = dl.order_state
AND (dos.order_zipcode = dl.order_zipcode OR dos.order_zipcode IS NULL OR dl.order_zipcode IS NULL)
AND dos.order_region = dl.order_region
AND dos.order_country = dl.order_country
AND dos.market = dl.market
SET dos.location_id = dl.location_id;


ALTER TABLE dim_order_shipping 
DROP COLUMN order_city,
DROP COLUMN order_state,
DROP COLUMN order_zipcode,
DROP COLUMN order_region,
DROP COLUMN order_country,
DROP COLUMN market;

select * from dim_order_shipping ORDER BY order_id limit 5;

-- 7) CREATE fact_item TABLE
-- Create dim_order_shipping table
CREATE TABLE IF NOT EXISTS fact_item (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    order_item_cardprod_id INT,
    order_item_discount DECIMAL(18, 10),
    order_item_discount_rate DECIMAL(18, 10),
    order_item_profit_ratio DECIMAL(18, 10),
    order_item_quantity INT,
    order_item_total DECIMAL(18, 10),
    sales_per_customer DECIMAL(18, 10),
    sales DECIMAL(18, 10),
    benefit_per_order DECIMAL(18, 10),
    order_profit_per_order DECIMAL(18, 10),
    department_id INT,
    FOREIGN KEY (order_id) REFERENCES dim_order_shipping(order_id),
    FOREIGN KEY (order_item_cardprod_id) REFERENCES dim_product(product_card_id),
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id)
);

INSERT INTO fact_item (
    order_item_id,
    order_id,
    order_item_cardprod_id,
    department_id,
    order_item_discount,
    order_item_discount_rate,
    order_item_profit_ratio,
    order_item_quantity,
    order_item_total,
    sales_per_customer,
    sales,
    benefit_per_order,
    order_profit_per_order
)
SELECT 
    order_item_id,
    order_id,
    order_item_cardprod_id,
    department_id,
    order_item_discount,
    order_item_discount_rate,
    order_item_profit_ratio,
    order_item_quantity,
    order_item_total,
    sales_per_customer,
    sales,
    benefit_per_order,
    order_profit_per_order
FROM interim_data;


SELECT COUNT(*) FROM fact_item;
SELECT COUNT(*) FROM raw_data rd ;


-- TO VERIFY IF ALL THE TABLES WERE CREATED 
SELECT * 
FROM information_schema.columns
WHERE TABLE_SCHEMA = "dataco";
    
  
-- To check if the tables were created and constraints are properly placed
DESCRIBE INTERIM_DATA;
DESCRIBE DIM_CATEGORY;
DESCRIBE DIM_CUSTOMER;
DESCRIBE DIM_DEPARTMENT ;
DESCRIBE DIM_LOCATION ;
DESCRIBE DIM_PRODUCT ;
DESCRIBE FACT_ORDER ;