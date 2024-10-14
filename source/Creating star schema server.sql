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
2) dim_customer: Information related to customers
3) dim_product: Details about products
4) dim_location: Locations (combining customer and order information)
5) dim_date: Dates for various events (order, shipping)
6) dim_order_status: Order statuses
7) dim_market: Market information
8) dim_category: Product category


*/
USE dataco;

--- 1) CREATE DIM_CUSTOMER TABLE

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id INT PRIMARY KEY,
    customer_fname VARCHAR(50),
    customer_lname VARCHAR(50),
    customer_email VARCHAR(150),
    customer_password VARCHAR(100),
    customer_segment VARCHAR(50)
);

INSERT INTO dim_customer (customer_id, customer_fname, customer_lname, customer_email, customer_password, customer_segment)
SELECT DISTINCT customer_id, customer_fname, customer_lname, customer_email, customer_password, customer_segment
FROM interim_data;


-- 2) CREATE dim_product TABLE

CREATE TABLE IF NOT EXISTS dim_product (
    product_card_id INT PRIMARY KEY,
    product_name VARCHAR(150),
    product_category_id INT,
    product_image VARCHAR(255),
    product_price DECIMAL(18, 10)
);

INSERT INTO dim_product (product_card_id, product_name, product_category_id, product_image, product_price)
SELECT DISTINCT product_card_id, product_name, product_category_id, product_image, product_price
FROM interim_data;


    
-- 3) CREATE dim_location TABLE

-- CREATE dim_location TABLE with customer_id and order_id as the composite primary key
CREATE TABLE IF NOT EXISTS dim_location (
    customer_id INT,
    order_id INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(50),
    customer_zipcode VARCHAR(10),
    order_city VARCHAR(100),
    order_state VARCHAR(50),
    order_zipcode VARCHAR(10),
    order_region VARCHAR(50),
    order_country VARCHAR(100),
    PRIMARY KEY (customer_id, order_id)
);


-- INSERT data into dim_location
INSERT INTO dim_location (customer_id, order_id, customer_city, customer_state, customer_zipcode, 
                          order_city, order_state, order_zipcode, order_region, order_country)
SELECT DISTINCT customer_id, order_id, customer_city, customer_state, customer_zipcode, 
                order_city, order_state, order_zipcode, order_region, order_country
FROM interim_data;


    
-- 4) CREATE dim_date TABLE

CREATE TABLE IF NOT EXISTS dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    date_value DATE,
    year INT,
    month INT,
    day INT,
    day_of_week VARCHAR(10)
);

-- Populate dim_date for order and shipping dates
INSERT INTO dim_date (date_value, year, month, day, day_of_week)
SELECT DISTINCT DATE(order_date), YEAR(DATE(order_date)), MONTH(DATE(order_date)), DAY(DATE(order_date)), DAYNAME(DATE(order_date))
FROM interim_data
WHERE order_date IS NOT NULL;

INSERT INTO dim_date (date_value, year, month, day, day_of_week)
SELECT DISTINCT DATE(shipping_date), YEAR(DATE(shipping_date)), MONTH(DATE(shipping_date)), DAY(DATE(shipping_date)), DAYNAME(DATE(shipping_date))
FROM interim_data
WHERE shipping_date IS NOT NULL;

    
    
-- 5) CREATE dim_market TABLE

CREATE TABLE IF NOT EXISTS dim_market (
    market_id INT AUTO_INCREMENT PRIMARY KEY,
    market VARCHAR(50)
);

INSERT INTO dim_market (market)
SELECT DISTINCT market
FROM interim_data;

    
    
-- 6) CREATE dim_category TABLE

CREATE TABLE dim_category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100)
);

INSERT INTO dim_category (category_id, category_name)
SELECT DISTINCT 
    category_id, 
    category_name
FROM interim_data;

    

-- 7) CREATE dim_department TABLE

CREATE TABLE dim_department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

INSERT INTO dim_department (department_id, department_name)
SELECT DISTINCT 
    department_id, 
    department_name
FROM interim_data;
   
-- 8) CREATE fact_order TABLE

-- Create fact_order table
CREATE TABLE IF NOT EXISTS fact_order (
    order_id INT,
    order_item_id INT,
    order_date DATE,
    shipping_date DATE,
    sales DECIMAL(18, 10),
    order_item_discount DECIMAL(18, 10),
    order_item_discount_rate DECIMAL(18, 10),
    order_item_product_price DECIMAL(18, 10),
    order_item_profit_ratio DECIMAL(18, 10),
    order_item_quantity INT,
    order_item_total DECIMAL(18, 10),
    order_profit_per_order DECIMAL(18, 10),
    delivery_status VARCHAR(50),
    late_delivery_risk INT,
    latitude DECIMAL(18, 10),
    longitude DECIMAL(18, 10), 
    market VARCHAR(50),
    order_region VARCHAR(50),
    order_state VARCHAR(50),
    order_zipcode VARCHAR(10),
    shipping_mode VARCHAR(50),
    order_status VARCHAR(50),

    -- Foreign keys
    customer_id INT,
    product_card_id INT,
    category_id INT,
    department_id INT,

    PRIMARY KEY (order_id, order_item_id),
    
    -- References to dimension tables
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_card_id) REFERENCES dim_product(product_card_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
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
    order_item_product_price,
    order_item_profit_ratio,
    order_item_quantity,
    order_item_total,
    order_profit_per_order,
    delivery_status,
    late_delivery_risk,
    latitude,
    longitude,
    market,
    order_region,
    order_state,
    order_zipcode,
    shipping_mode,
    order_status,
    customer_id,
    product_card_id,
    category_id,
    department_id
)
SELECT 
    order_id,
    order_item_id,
    order_date,
    shipping_date,
    sales,
    order_item_discount,
    order_item_discount_rate,
    order_item_product_price,
    order_item_profit_ratio,
    order_item_quantity,
    order_item_total,
    order_profit_per_order,
    delivery_status,
    late_delivery_risk,
    latitude,
    longitude,
    market,
    order_region,
    order_state,
    order_zipcode,
    shipping_mode,
    order_status,
    customer_id,
    product_card_id,
    category_id,
    department_id
FROM interim_data;

-- TO VERIFY IF ALL THE TABLES WERE CREATED 
SELECT * 
FROM information_schema.columns
WHERE TABLE_SCHEMA = "dataco";
    
  
-- To check if the tables were created and constraints are properly placed
DESCRIBE INTERIM_DATA ;
DESCRIBE DIM_CATEGORY;
DESCRIBE DIM_CUSTOMER;
DESCRIBE DIM_DATE ;
DESCRIBE DIM_DEPARTMENT ;
DESCRIBE DIM_LOCATION ;
DESCRIBE DIM_MARKET ;
DESCRIBE DIM_PRODUCT ;
DESCRIBE FACT_ORDER ;