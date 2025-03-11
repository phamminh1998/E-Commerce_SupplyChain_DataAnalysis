USE dataco;

-- C) DATA ANALYSIS ON DATACO DB
/*  There are several insightful questions you can explore through SQL queries 
	and visualize using Power BI
    
    Data Analysis on DataCo DB data was done based on these sections
		1) SHIPMENT DELAY ANALYSIS
        2) LATE DELIVERY ANALYSIS
        3) INVENTORY ANALYSIS
        4) INVENTORY REPLENISHMENT ANALYSIS
        5) CUSTOMER ANALYSIS
        6) PRODUCT ANALYSIS
        7) GEOGRAPHICAL ANALYSIS
        8) SHIPPING MODE ANALYSIS
        9) ORDER ANALYSIS
*/

-- 1) SHIPMENT DELAY ANALYSIS

-- 1.1) What is the average delay in shipment days for different shipping mode and regions?
-- Calculate the average delay in shipment days for different shipping modes and regions
SELECT 
    shipping_mode,
    order_region,
    AVG(DATEDIFF(shipping_date, order_date)) AS avg_delay_days
FROM 
    fact_item fi
LEFT JOIN dim_order_shipping dos USING(order_id)
LEFT JOIN dim_location dl USING(location_id)
WHERE 
    shipping_date IS NOT NULL 
    AND order_date IS NOT NULL
GROUP BY 
    shipping_mode, 
    order_region
ORDER BY 
    avg_delay_days ASC;


-- 1.2) How does the average shipment delay vary across different market location?
-- Calculate the average delay in shipment days across different market locations
SELECT 
    market,
    AVG(DATEDIFF(shipping_date, order_date)) AS avg_delay_days
FROM 
    fact_item fi
LEFT JOIN dim_order_shipping dos USING(order_id)
LEFT JOIN dim_location dl USING(location_id)
WHERE 
    shipping_date IS NOT NULL 
    AND order_date IS NOT NULL
GROUP BY 
    market
ORDER BY 
    avg_delay_days DESC;


-- 1.3) What is the average time take between shipment and delivery?
-- Calculate the average time taken between shipment and delivery
SELECT 
    AVG(DATEDIFF(shipping_date,order_date)) AS avg_time_between_shipment_and_delivery
FROM fact_item fi 
LEFT JOIN dim_order_shipping dos USING(order_id)
WHERE 
    shipping_date IS NOT NULL 
    AND order_date IS NOT NULL;



-- 2) LATE DELIVERY ANALYSIS

-- 2.1) How have late delivery rates changed over time? (e.g., monthly trend)
-- Calculate the monthly late delivery rate trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month, -- Extract year and month from order_date
    COUNT(CASE WHEN late_delivery_risk = 1 THEN 1 END) / COUNT(*) * 100 AS late_delivery_rate
FROM fact_item fi 
LEFT JOIN dim_order_shipping dos USING(order_id)
WHERE 
    order_date IS NOT NULL
GROUP BY 
    month
ORDER BY 
    month;


-- 2.2) What is the percentage of late deliveries in each market location?
-- Calculate the percentage of late deliveries in each market location
SELECT 
    market,
    COUNT(CASE WHEN late_delivery_risk = 1 THEN 1 END) / COUNT(*) * 100 AS late_delivery_percentage
FROM fact_item fi 
LEFT JOIN dim_order_shipping dos USING(order_id)
LEFT JOIN dim_location dl
USING(location_id)
GROUP BY 
    market
ORDER BY 
    late_delivery_percentage DESC;


-- 2.3) What is the late delivery rate for each shipping mode?
-- Calculate the late delivery rate for each shipping mode
SELECT 
    shipping_mode,
    COUNT(CASE WHEN late_delivery_risk = 1 THEN 1 END) AS late_delivery_count,
    COUNT(*) AS total_deliveries,
    (COUNT(CASE WHEN late_delivery_risk = 1 THEN 1 END) / COUNT(*)) * 100 AS late_delivery_rate_percentage
FROM fact_item fi 
LEFT JOIN dim_order_shipping dos USING(order_id)
GROUP BY 
    shipping_mode
ORDER BY 
    late_delivery_rate_percentage DESC;



-- 2.5) What is the percentage of orders shipped on time versus late, and how does it vary by market location?
-- Calculate the percentage of orders shipped on time versus late by market location
SELECT 
    market,
    COUNT(CASE WHEN late_delivery_risk = 1 THEN 1 END) AS late_delivery_count,
    COUNT(CASE WHEN late_delivery_risk = 0 THEN 1 END) AS on_time_delivery_count,
    COUNT(*) AS total_deliveries,
    (COUNT(CASE WHEN late_delivery_risk = 1 THEN 1 END) / COUNT(*)) * 100 AS late_delivery_percentage,
    (COUNT(CASE WHEN late_delivery_risk = 0 THEN 1 END) / COUNT(*)) * 100 AS on_time_delivery_percentage
FROM fact_item fi 
LEFT JOIN dim_order_shipping dos USING(order_id)
LEFT JOIN dim_location dl
USING(location_id)
GROUP BY 
    market
ORDER BY 
    late_delivery_percentage DESC;

   
-- 2.6) What are the main reasons for shipment cancellations, and how do they vary by order status?

SELECT dos.order_status , dos.delivery_status , COUNT(*) AS Cancellation_Count
FROM dim_order_shipping dos 
WHERE delivery_status = 'Shipping canceled'
GROUP BY order_status, delivery_status;

-- 2.7) Are certain customer segments more prone to late deliveries?
SELECT dc.customer_segment , COUNT(*) AS Late_Deliveries
FROM dim_order_shipping dos
LEFT JOIN dim_customer dc ON dos.order_customer_id = dc.customer_id
WHERE dos.delivery_status = 'Late delivery'
GROUP BY dc.customer_segment
ORDER BY COUNT(*) DESC;



-- 3) INVENTORY ANALYSIS

-- KPI QUESTION
-- Q1: What is the overall average inventory turnover rate across all customer segment?
SELECT dc.customer_segment, 
       AVG(fi.order_item_quantity ) AS Avg_Inventory_Level
FROM fact_item fi
LEFT JOIN dim_order_shipping dos USING(order_id)
LEFT JOIN dim_customer dc ON dc.customer_id = dos.order_customer_id
GROUP BY dc.customer_segment;

-- Q2: How does the on-time delivery rate vary across different product categories?
SELECT dc.category_name , 
       (COUNT(CASE WHEN dos.delivery_status = 'Shipping on time' THEN dos.order_id END) * 100.0 / COUNT(dos.order_id)) AS On_Time_Delivery_Rate
FROM dim_order_shipping dos
JOIN fact_item fi USING(order_id)
JOIN dim_product dp ON fi.order_item_cardprod_id = dp.product_card_id
JOIN dim_category dc ON dp.product_category_id = dc.category_id
GROUP BY dc.category_name
ORDER BY On_Time_Delivery_Rate DESC;


-- 3.1) What is the current inventory level of each product category
SELECT dc.category_name, 
	COUNT(*) AS Inventory_Level
FROM dim_category dc
JOIN dim_product dp ON dc.category_id = dp.product_category_id
JOIN fact_item fi ON dp.product_card_id = fi.order_item_cardprod_id
JOIN dim_order_shipping dos USING(order_id)
WHERE order_id IN (SELECT order_id FROM dim_order_shipping WHERE order_status = 'COMPLETE')
GROUP BY dc.category_name;


-- 3.2) What is the average number of days it takes to sell out the entire inventory for each product category?
SELECT dc.category_name, 
       AVG(DATEDIFF(max_order_date, min_order_date)) AS Avg_Days_To_Sell_Out
FROM dim_category dc
JOIN dim_product dp ON dc.category_id = dp.product_category_id
JOIN fact_item fi ON dp.product_card_id = fi.order_item_cardprod_id
JOIN (
    SELECT fi.order_item_cardprod_id ,
           MIN(dos.order_date) AS min_order_date,
           MAX(dos.order_date) AS max_order_date
    FROM dim_order_shipping dos
    JOIN fact_item fi USING(order_id)
    GROUP BY fi.order_item_cardprod_id 
) AS order_dates ON dp.product_card_id = order_dates.order_item_cardprod_id
GROUP BY dc.category_name;


-- 3.3) What is the average inventory turnover rate for each product category?
SELECT dc.category_name,
       COUNT(DISTINCT order_id) / COUNT(DISTINCT dp.product_card_id) AS Avg_Inventory_Turnover_Rate
FROM dim_category dc
JOIN dim_product dp ON dc.category_id = dp.product_category_id
JOIN fact_item fi ON dp.product_card_id = fi.order_item_cardprod_id
JOIN dim_order_shipping dos USING(order_id)
GROUP BY dc.category_name;


-- 3.4) What is the average inventory turnover rate for the entire inventory?
SELECT 
    SUM(fi.order_item_quantity ) AS Total_Quantity,
    COUNT(DISTINCT order_id) AS Total_Orders,
    SUM(fi.order_item_quantity ) / COUNT(DISTINCT order_id) AS Avg_Inventory_Turnover_Rate
FROM fact_item fi;


-- 3.5) Which products have the highest sales volume relative to inventory levels, categorized by product category?
SELECT dc.category_name, 
       dp.product_name,
       SUM(fi.order_item_quantity) AS Total_Sales,
       AVG(fi.order_item_quantity) AS Avg_Inventory_Level
FROM dim_product dp
JOIN fact_item fi ON dp.product_card_id = fi.order_item_cardprod_id
JOIN dim_category dc ON dp.product_category_id = dc.category_id
GROUP BY dc.category_name, dp.product_name
ORDER BY (SUM(fi.order_item_quantity) / AVG(fi.order_item_quantity)) DESC;


-- 3.6) Which products have been in stock for the longest duration without being sold?
-- Note: Inventory Age = Difference in Days between the maximum order date (when the product was sold) and the minimum order date (when the product was added to inventory).
WITH Inventory_Age AS (
    SELECT dp.product_category_id, 
           dp.product_name,
           DATEDIFF(MAX(dos.order_date), MIN(dos.order_date)) AS Inventory_Age
    FROM dim_product dp
    JOIN fact_item fi ON dp.product_card_id = fi.order_item_cardprod_id
    JOIN dim_order_shipping dos USING(order_id)
    GROUP BY dp.product_category_id, dp.product_name
)
SELECT dc.category_name, 
       ia.product_name,
       ia.Inventory_Age
FROM Inventory_Age ia
JOIN dim_category dc ON ia.product_category_id = dc.category_id
ORDER BY ia.Inventory_Age DESC;


-- 4) How many times does the inventory turn over in a year for each product category?
SELECT dc.category_name, 
       COUNT(DISTINCT order_id) / COUNT(DISTINCT dp.product_card_id) AS Inventory_Turnover_Rate
FROM dim_product dp
LEFT JOIN fact_item fi ON dp.product_card_id = fi.order_item_cardprod_id
LEFT JOIN dim_category dc ON dp.product_category_id = dc.category_id
LEFT JOIN dim_order_shipping dos USING(order_id)
WHERE dos.order_status = 'COMPLETE'
GROUP BY dc.category_name;


-- 5) CUSTOMER ANALYSIS

-- 5.1) What are the top 10 customers based on the total sales amount?
SELECT
    dc.customer_id,
    CONCAT(customer_fname, ' ', customer_lname) AS CustomerName,
    SUM(fi.sales) AS TotalSales
FROM
    dim_customer dc
    INNER JOIN dim_order_shipping dos ON dc.customer_id = dos.order_customer_id
    INNER JOIN fact_item fi USING(order_id)
GROUP BY
    dc.customer_id, CustomerName
ORDER BY
    TotalSales DESC
LIMIT 10;

-- 5.2) Which customer segments generate the highest profit for the company?
SELECT dc.customer_segment, ROUND(SUM(fi.order_profit_per_order),2) AS Total_Profit
FROM dim_customer dc
INNER JOIN dim_order_shipping dos ON dc.customer_id = dos.order_customer_id
LEFT JOIN fact_item fi USING(order_id)
GROUP BY dc.customer_segment
ORDER BY Total_Profit DESC;



-- 6) PRODUCT ANALYSIS

-- 6.1) What are the top 5 most profitable products?

SELECT
    dp.product_card_id,
    dp.product_name,
    SUM(fi.order_item_profit_ratio * dp.product_price) AS TotalProfit
FROM
    dim_product dp
    INNER JOIN fact_item fi ON dp.product_card_id = fi.order_item_cardprod_id
GROUP BY
    dp.product_card_id, dp.product_name
ORDER BY
    TotalProfit DESC
LIMIT 5;

-- 6.2) What are the top-selling products by quantity and revenue?  
SELECT dp.product_name, 
	SUM(fi.order_item_quantity) AS Total_Quantity, 
	SUM(fi.sales) AS Total_Revenue
FROM fact_item fi
JOIN dim_product dp ON fi.order_item_cardprod_id = dp.product_card_id
GROUP BY dp.product_name
ORDER BY Total_Quantity DESC, Total_Revenue DESC;

-- 6.3) What is the average profit ratio for each product category?
SELECT
    dc.category_name,
    AVG(fi.order_item_profit_ratio) AS AvgProfitRatio
FROM
    dim_category dc
    INNER JOIN dim_product dp ON dc.category_id = dp.product_category_id
    INNER JOIN fact_item fi ON dp.product_card_id = fi.order_item_cardprod_id
GROUP BY
    dc.category_name;
    
-- 6.3) What are the top-selling products based on total sales amount?
SELECT 
    dp.product_name,
    SUM(fi.order_item_total) AS Total_Sales
FROM fact_item fi
JOIN dim_product dp ON fi.order_item_cardprod_id = dp.product_card_id
GROUP BY dp.product_name
ORDER BY Total_Sales DESC;


-- 7) GEOGRAPHICAL SALES ANALYSIS
    
-- 7.1) What are the total sales for each country?
SELECT
    dl.order_country,
    SUM(fi.sales) AS TotalSales
FROM
    dim_order_shipping dos
    INNER JOIN fact_item fi USING(order_id)
    LEFT JOIN dim_location dl USING(location_id)
GROUP BY
    dl.order_country
ORDER BY
    TotalSales DESC;

-- 7.2) What are the top regions in terms of sales revenue?
SELECT dl.order_region, SUM(fi.sales) AS Total_Revenue
FROM dim_order_shipping dos
JOIN fact_item fi USING(order_id)
LEFT JOIN dim_location dl USING(location_id)
GROUP BY dl.order_region
ORDER BY Total_Revenue DESC;
 
 
-- 8) SHIPPING MODE ANALYSIS

-- 8.1) What is the average profit per order for each shipping mode?
SELECT dos.shipping_mode, 
       AVG(fi.order_profit_per_order) AS Avg_Profit_Per_Order
FROM dim_order_shipping dos
JOIN fact_item fi USING(order_id)
GROUP BY dos.shipping_mode;


-- 8.2) How many orders were shipped late for each shipping mode?
    
SELECT
    dos.shipping_mode,
    COUNT(*) AS LateOrders
FROM
    dim_order_shipping dos
WHERE
    dos.late_delivery_risk = 1
GROUP BY
    dos.shipping_mode;

-- 8.3) Which shipping mode is associated with the highest profit per order?
SELECT dos.shipping_mode, AVG(fi.order_profit_per_order) AS Avg_Profit_Per_Order
FROM dim_order_shipping dos
JOIN fact_item fi USING(order_id)
GROUP BY dos.shipping_mode
ORDER BY Avg_Profit_Per_Order DESC;
   
   
   
-- 9) ORDER ANALYSIS

-- KPI
-- Q1: What is the distribution of order statuses for all orders?
SELECT dos.order_status, 
       (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dim_order_shipping)) AS Percentage_Order_Status
FROM dim_order_shipping dos 
GROUP BY dos.order_status;

-- 9.1) What is the percentage distribution of different order statuses?
SELECT 
    dos.order_status,
    COUNT(*) AS Orders_Count,
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM dim_order_shipping) AS Status_Percentage
FROM dim_order_shipping dos
GROUP BY dos.order_status;

-- 9.2) What is the average processing time for each shipping mode?
SELECT shipping_mode, 
       AVG(dos.days_for_shipping_real) AS Avg_Processing_Time
FROM dim_order_shipping dos
GROUP BY dos.shipping_mode;