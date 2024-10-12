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

INSTRUCTIONS
------------------

The Database should contain the following tables:
1) Order
2) Customer
3) Product
4) Category
5) OrderItem
6) Department
7) Shipping Mode

*/
USE dataco;

--- 1) CREATE ORDERS TABLE
DROP TABLE IF EXISTS orders;

CREATE TABLE IF NOT EXISTS orders(
	order_id VARCHAR(255),
    order_customer_id VARCHAR(255),
    order_date DATE,
    order_status VARCHAR(255),
	order_profit_per_order DECIMAL(10, 2),
    market VARCHAR(255),
    order_city VARCHAR(255),
    order_state VARCHAR(255),
    order_country VARCHAR(255),
    order_region VARCHAR(255),
    shipping_date DATE,
    department_id INTEGER,
    PRIMARY KEY(order_id),
    FOREIGN KEY(department_id) REFERENCES department(department_id)
    FOREIGN KEY(order_customer_id) REFERENCES customer(customer_id)
    );
    
SHOW VARIABLES WHERE Variable_Name LIKE "%dir" ;

 
-- Loading data into the Orders Table since 
LOAD DATA LOCAL INFILE 'C/ProgramData/MySQL/MySQL Server 8.0/Data/dataco_db/orders.csv'
INTO TABLE Orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS; -- Skip header row if present

SHOW GRANTS;

-- 2) CREATE CUSTOMER TABLE

DROP TABLE IF EXISTS Customer;

CREATE TABLE Customer (
	CustomerId VARCHAR(255),
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    CustomerCity VARCHAR(255),
    CustomerCountry VARCHAR(255),
    CustomerState VARCHAR(255),
    CustomerStreet VARCHAR(255) NOT NULL,
    CustomerZipCode VARCHAR(255),
    Latitude DECIMAL(10, 6),
    Longitude DECIMAL(10, 6),
    CustomerSegment VARCHAR(255),
    CustomerEmail VARCHAR(255),
    CustomerPassword VARCHAR(255),
    PRIMARY KEY (CustomerId)
    );
    
-- 3) CREATE PRODUCT TABLE

DROP TABLE IF EXISTS Product;

CREATE TABLE Product (
	ProductCardId VARCHAR(255),
    Categoryid VARCHAR(255) NOT NULL,
    ProductName VARCHAR(255),
    ProductDesc VARCHAR(255),
    ProductImage VARCHAR(255),
    ProductPrice DECIMAL(10, 2),
    ProductStatus VARCHAR(255) NOT NULL,
    PRIMARY KEY (ProductCardId)
    );
    
-- 4) CREATE CATEGORY TABLE

DROP TABLE IF EXISTS Category;

CREATE TABLE Category (
	CategoryId VARCHAR(255),
    CategoryName VARCHAR(255),
    PRIMARY KEY (CategoryId)
    );
    
    
-- 5) CREATE ORDER_ITEM TABLE

DROP TABLE IF EXISTS Order_Item;

CREATE TABLE Order_Item (
	OrderItemId  VARCHAR(255),
    OrderId VARCHAR(255) NOT NULL,
    ProdcutCardId VARCHAR(255),
    OrderItemCardprodId VARCHAR(255),
    OrderItemDiscount DECIMAL(10, 2),
    OrderItemDiscountRate DECIMAL(5, 2),
    OrderItemProductPrice DECIMAL(10, 2),
    OrderItemProfitRatio DECIMAL(5, 2),
    OrderItemQuantity INT,
	OrderItemTotal DECIMAL(10, 2),
    Sales DECIMAL(10, 2),
    OrderProfitPerOrder DECIMAL(10, 2),
    PRIMARY KEY (OrderItemId)
    );
    
    
-- 6) CREATE DEPARTMENT TABLE

DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
	DepartmentId INT,
    DepartmentName VARCHAR(255),
    PRIMARY KEY (DepartmentId)
    );
    

-- 7) CREATE ORDERS PROCESSING TABLE

DROP TABLE IF EXISTS OrdersProcessing;

CREATE TABLE OrdersProcessing (
	OrderId VARCHAR(255),
    TransactionType VARCHAR(255),
    RealShippingDays INT,
    ScheduledShipmentDays INT,
    BenefitPerOrder DECIMAL(10, 2),
    ShippingMode VARCHAR(255),
    DeliveryStatus VARCHAR(255),
    OrderStatus VARCHAR(255),
    LateDeliveryRisk BOOLEAN,
    PRIMARY KEY (OrderId)
    );    
    
    
-- TO VERIFY IF ALL THE TABLES WERE CREATED 
SELECT * 
FROM information_schema.columns
WHERE TABLE_SCHEMA = "dataco_db";
    

    
-- B) ALTERING TABLE CONSTRAINTS


-- 1) ORDERS TABLE FOREIGN KEY: CustomerId
/*
For the `CustomerId` column in the foreign key, the rule to create this foreign key is given below

RULE APPLIED
When the record in the Customer table is updated or deleted, the record in the Orders table will also be updated or
deleted accordingly. 

*/

-- Altering the Orders table to add foreign key
ALTER TABLE Orders 
  ADD CONSTRAINT customer_fk 
  FOREIGN KEY (OrderCustomerId) 
  REFERENCES Customer(CustomerId) 
  ON DELETE CASCADE
  ON UPDATE CASCADE;
  

-- 2) ORDER_ITEM TABLE FOREIGN KEY: OrderId
/*
For the `OrderId` column in the foreign key, the rule to create this foreign key is given below

RULE APPLIED
When the record in the Order table is updated or deleted, the record in the Order_Item table will also be updated or
deleted accordingly. 

*/

-- Altering the Order_Item table to add foreign key
ALTER TABLE Order_Item 
  ADD CONSTRAINT order_item_fk
  FOREIGN KEY (OrderId) 
  REFERENCES Orders(OrderId) 
  ON DELETE CASCADE
  ON UPDATE CASCADE;
 


-- 3) Altering the Orders_Processing table to add foreign key (OrderId)
/*
For the `OrderId` column in the foreign key, the rule to create this foreign key is given below

RULE APPLIED
When the record in the Order table is updated or deleted, the record in the Orders_Processing table 
will also be updated or deleted accordingly. 

*/
ALTER TABLE OrdersProcessing
  ADD CONSTRAINT orders_processing_fk
  FOREIGN KEY (OrderId) 
  REFERENCES Orders(OrderId) 
  ON DELETE CASCADE
  ON UPDATE CASCADE;
  
-- 4) Altering the Product table to add foreign key (CategoryId)
/*
For the `CategoryId` column in the foreign key, the rule to create this foreign key is given below

RULE APPLIED
When the record in the Category table is updated or deleted, the record in the Product table 
will also be updated or deleted accordingly. 

*/
ALTER TABLE Product
  ADD CONSTRAINT product_fk
  FOREIGN KEY (CategoryId) 
  REFERENCES Category(CategoryId) 
  ON DELETE CASCADE
  ON UPDATE CASCADE;
  

-- 5) Altering the Order table to add foreign key (DepartmentId)
/*
For the `DepartmentId` column in the foreign key, the rule to create this foreign key is given below

RULE APPLIED
When the record in the Department table is updated or deleted, the record in the Order table 
will also be updated or deleted accordingly. 

*/
ALTER TABLE Orders
  ADD CONSTRAINT department_fk
  FOREIGN KEY (DepartmentId) 
  REFERENCES Department(DepartmentId) 
  ON DELETE CASCADE
  ON UPDATE CASCADE;
  
-- 6) Altering the Order table to add foreign key (ProductCardId)
/*
For the `ProductCardId` column in the foreign key, the rule to create this foreign key is given below

RULE APPLIED
When the record in the Product table is updated or deleted, the record in the Order_Item table 
will also be updated or deleted accordingly. 

*/
ALTER TABLE Order_Item
  ADD CONSTRAINT product_card_fk
  FOREIGN KEY (ProdcutCardId) 
  REFERENCES Product(ProductCardId) 
  ON DELETE CASCADE
  ON UPDATE CASCADE;
  
-- To check if the tables were created and constraints are properly placed
DESCRIBE orders;
DESCRIBE order_item;
DESCRIBE customer;
DESCRIBE product;
DESCRIBE category;
DESCRIBE department;