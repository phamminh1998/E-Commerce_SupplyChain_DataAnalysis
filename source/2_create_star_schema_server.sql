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
1) Order
2) dim_location: Normalize Order locations
3) dim_customer: Information related to customers
4) dim_category: Product category
5) dim_product: Details about products
6) dim_department: Order statuses


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

-- 2) INSERT only distinct location records
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


-- 6) CREATE fact_order TABLE

-- Create fact_order table
CREATE TABLE IF NOT EXISTS fact_order (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    order_date DATETIME,
    order_item_discount DECIMAL(18, 10),
    order_item_discount_rate DECIMAL(18, 10),
    order_item_profit_ratio DECIMAL(18, 10),
    order_item_quantity INT,
    sales DECIMAL(18, 10),
    benefit_per_order DECIMAL(18, 10),
    sales_per_customer DECIMAL(18, 10),
    order_item_total DECIMAL(18, 10),
    order_profit_per_order DECIMAL(18, 10),
    order_status VARCHAR(50),
    market VARCHAR(50),
    order_region VARCHAR(50),
    order_country VARCHAR(100),
    order_state VARCHAR(50),
    order_city VARCHAR(100),
    order_zipcode VARCHAR(10),
    shipping_mode VARCHAR(50),
    delivery_status VARCHAR(50),
    late_delivery_risk INT,
    shipping_date DATETIME,
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,     
    type VARCHAR(50),
    customer_id INT,
    product_card_id INT,
    department_id INT,
    location_id INT,
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_card_id) REFERENCES dim_product(product_card_id),
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id)
);



INSERT INTO fact_order (
    order_id,
    order_item_id,
    order_date,
    shipping_date,
    sales,
    order_item_discount,
    order_item_discount_rate,
    order_item_profit_ratio,
    order_item_quantity,
    order_item_total,
    order_profit_per_order,
    delivery_status,
    late_delivery_risk,
    market,
    order_region,
    order_country,
    order_state,
    order_city,
    order_zipcode,
    shipping_mode,
    order_status,
    customer_id,
    product_card_id,
    department_id,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    benefit_per_order,
    sales_per_customer,
    type
)
SELECT 
    order_id,
    order_item_id,
    order_date,
    shipping_date,
    sales,
    order_item_discount,
    order_item_discount_rate,
    order_item_profit_ratio,
    order_item_quantity,
    order_item_total,
    order_profit_per_order,
    delivery_status,
    late_delivery_risk,
    market,
    order_region,
    order_country,
    order_state,
    order_city,
    order_zipcode,
    shipping_mode,
    order_status,
    customer_id,
    product_card_id,
    department_id,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    benefit_per_order,
    sales_per_customer,
    type
FROM interim_data;

UPDATE fact_order fo
JOIN dim_location dl
ON fo.order_city = dl.order_city
AND fo.order_state = dl.order_state
AND fo.order_zipcode = dl.order_zipcode
AND fo.order_region = dl.order_region
AND fo.order_country = dl.order_country
AND fo.market = dl.market
SET fo.location_id = dl.location_id;

ALTER TABLE fact_order 
DROP COLUMN order_city,
DROP COLUMN order_state,
DROP COLUMN order_zipcode,
DROP COLUMN order_region,
DROP COLUMN order_country,
DROP COLUMN market;

select * from fact_order fo limit 5;

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