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

*/
-- Create the dataco database if it doesn't exist
CREATE DATABASE IF NOT EXISTS dataco;

-- Use the dataco database
USE dataco;

-- Create the raw_data table with standardized column names
CREATE TABLE IF NOT EXISTS raw_data (
    type VARCHAR(50),
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,
    benefit_per_order DECIMAL(18, 10), 
    sales_per_customer DECIMAL(18, 10), 
    delivery_status VARCHAR(50),
    late_delivery_risk INT,
    category_id INT,
    category_name VARCHAR(100),
    customer_city VARCHAR(100),
    customer_country VARCHAR(100),
    customer_email VARCHAR(150),
    customer_fname VARCHAR(50),
    customer_id INT,
    customer_lname VARCHAR(50),
    customer_password VARCHAR(100),
    customer_segment VARCHAR(50),
    customer_state VARCHAR(50),
    customer_street VARCHAR(150),
    customer_zipcode VARCHAR(10),
    department_id INT,
    department_name VARCHAR(100),
    latitude DECIMAL(18, 10), 
    longitude DECIMAL(18, 10),
    market VARCHAR(50),
    order_city VARCHAR(100),
    order_country VARCHAR(100),
    order_customer_id INT,
    order_date VARCHAR(50),
    order_id INT,
    order_item_cardprod_id INT,
    order_item_discount DECIMAL(18, 10), 
    order_item_discount_rate DECIMAL(18, 10), 
    order_item_id INT,
    order_item_product_price DECIMAL(18, 10), 
    order_item_profit_ratio DECIMAL(18, 10), 
    order_item_quantity INT,
    sales DECIMAL(18, 10), 
    order_item_total DECIMAL(18, 10), 
    order_profit_per_order DECIMAL(18, 10), 
    order_region VARCHAR(50),
    order_state VARCHAR(50),
    order_status VARCHAR(50),
    order_zipcode VARCHAR(10),
    product_card_id INT,
    product_category_id INT,
    product_description VARCHAR(255),
    product_image VARCHAR(255),
    product_name VARCHAR(150),
    product_price DECIMAL(18, 10), 
    product_status VARCHAR(50),
    shipping_date VARCHAR(50),
    shipping_mode VARCHAR(50),
    PRIMARY KEY (order_id, order_item_id)
);

-- Grant necessary file permissions to MySQL (optional)
SHOW VARIABLES LIKE "secure_file_priv";
SHOW GLOBAL VARIABLES LIKE 'local_infile';


-- Modify the import to handle date formats
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DataCoSupplyChainDataset.csv'
INTO TABLE raw_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Create the interim_data table with the same structure as raw_data
CREATE TABLE IF NOT EXISTS interim_data LIKE raw_data;

-- Insert all the data from raw_data into interim_data
INSERT INTO interim_data
SELECT * FROM raw_data;

-- Update the order_date column by converting it to a proper DATETIME format
UPDATE interim_data
SET order_date = STR_TO_DATE(order_date, '%m/%d/%Y %H:%i');

-- Update the shipping_date column similarly
UPDATE interim_data
SET shipping_date = STR_TO_DATE(shipping_date, '%m/%d/%Y %H:%i');

-- Alter the columns to the correct DATETIME type after cleaning
ALTER TABLE interim_data
MODIFY order_date DATETIME,
MODIFY shipping_date DATETIME;

-- Remove product_status and product_description from interim_data table
ALTER TABLE interim_data
DROP COLUMN product_status,
DROP COLUMN product_description,
DROP COLUMN customer_country;

-- Update each VARCHAR column to trim leading and trailing whitespace
UPDATE interim_data
SET 
    type = TRIM(type),
    delivery_status = TRIM(delivery_status),
    category_name = TRIM(category_name),
    customer_city = TRIM(customer_city),
    customer_email = TRIM(customer_email),
    customer_fname = TRIM(customer_fname),
    customer_lname = TRIM(customer_lname),
    customer_password = TRIM(customer_password),
    customer_segment = TRIM(customer_segment),
    customer_state = TRIM(customer_state),
    customer_street = TRIM(customer_street),
    customer_zipcode = TRIM(customer_zipcode),
    department_name = TRIM(department_name),
    market = TRIM(market),
    order_city = TRIM(order_city),
    order_country = TRIM(order_country),
    order_region = TRIM(order_region),
    order_state = TRIM(order_state),
    order_status = TRIM(order_status),
    order_zipcode = TRIM(order_zipcode),
    product_image = TRIM(product_image),
    product_name = TRIM(product_name),
    shipping_mode = TRIM(shipping_mode);
   
-- Update customer_state column where the value is a zip code (91732 or 95758)
UPDATE interim_data
SET customer_state = 'CA'
WHERE customer_state IN ('91732', '95758');

-- Update market column, replacing LATAM with Latin America and USCA with North America
UPDATE interim_data
SET market = CASE
    WHEN market = 'LATAM' THEN 'Latin America'
    WHEN market = 'USCA' THEN 'North America'
END
WHERE market IN ('LATAM', 'USCA');

-- Update order_city column with correct names
UPDATE interim_data
SET order_city = CASE
    WHEN order_city = 'Aew?l-li' THEN 'Aewŏl-li'
    WHEN order_city = 'Cox’s B?z?r' THEN 'Cox’s Bāzār'
    WHEN order_city = 'Klaip?da' THEN 'Klaipėda'
    WHEN order_city = 'Bra?ov' THEN 'Brașov'
    WHEN order_city = 'Gy?r' THEN 'Győr'
    WHEN order_city = 'Kahramanmara?' THEN 'Kahramanmaraş'
END
WHERE order_city IN ('Aew?l-li', 'Cox’s B?z?r', 'Klaip?da', 'Bra?ov', 'Gy?r', 'Kahramanmara?');

-- Update order_country column with correct English names
UPDATE interim_data
SET order_country = CASE
    WHEN order_country = 'Afganistán' THEN 'Afghanistan'
    WHEN order_country = 'Alemania' THEN 'Germany'
    WHEN order_country = 'Arabia Saudí' THEN 'Saudi Arabia'
    WHEN order_country = 'Argelia' THEN 'Algeria'
    WHEN order_country = 'Azerbaiyán' THEN 'Azerbaijan'
    WHEN order_country = 'Bangladés' THEN 'Bangladesh'
    WHEN order_country = 'Baréin' THEN 'Bahrain'
    WHEN order_country = 'Bélgica' THEN 'Belgium'
    WHEN order_country = 'Belice' THEN 'Belize'
    WHEN order_country = 'Benín' THEN 'Benin'
    WHEN order_country = 'Bielorrusia' THEN 'Belarus'
    WHEN order_country = 'Bolivia' THEN 'Bolivia'
    WHEN order_country = 'Bosnia y Herzegovina' THEN 'Bosnia and Herzegovina'
    WHEN order_country = 'Botsuana' THEN 'Botswana'
    WHEN order_country = 'Brasil' THEN 'Brazil'
    WHEN order_country = 'Bulgaria' THEN 'Bulgaria'
    WHEN order_country = 'Burkina Faso' THEN 'Burkina Faso'
    WHEN order_country = 'Burundi' THEN 'Burundi'
    WHEN order_country = 'Bután' THEN 'Bhutan'
    WHEN order_country = 'Camboya' THEN 'Cambodia'
    WHEN order_country = 'Camerún' THEN 'Cameroon'
    WHEN order_country = 'Canada' THEN 'Canada'
    WHEN order_country = 'Chad' THEN 'Chad'
    WHEN order_country = 'Chile' THEN 'Chile'
    WHEN order_country = 'China' THEN 'China'
    WHEN order_country = 'Chipre' THEN 'Cyprus'
    WHEN order_country = 'Colombia' THEN 'Colombia'
    WHEN order_country = 'Corea del Sur' THEN 'South Korea'
    WHEN order_country = 'Costa de Marfil' THEN 'Ivory Coast'
    WHEN order_country = 'Costa Rica' THEN 'Costa Rica'
    WHEN order_country = 'Croacia' THEN 'Croatia'
    WHEN order_country = 'Cuba' THEN 'Cuba'
    WHEN order_country = 'Dinamarca' THEN 'Denmark'
    WHEN order_country = 'Ecuador' THEN 'Ecuador'
    WHEN order_country = 'Egipto' THEN 'Egypt'
    WHEN order_country = 'El Salvador' THEN 'El Salvador'
    WHEN order_country = 'Emiratos Árabes Unidos' THEN 'United Arab Emirates'
    WHEN order_country = 'Eritrea' THEN 'Eritrea'
    WHEN order_country = 'Eslovaquia' THEN 'Slovakia'
    WHEN order_country = 'Eslovenia' THEN 'Slovenia'
    WHEN order_country = 'España' THEN 'Spain'
    WHEN order_country = 'Estados Unidos' THEN 'United States'
    WHEN order_country = 'Estonia' THEN 'Estonia'
    WHEN order_country = 'Etiopía' THEN 'Ethiopia'
    WHEN order_country = 'Filipinas' THEN 'Philippines'
    WHEN order_country = 'Finlandia' THEN 'Finland'
    WHEN order_country = 'Francia' THEN 'France'
    WHEN order_country = 'Gabón' THEN 'Gabon'
    WHEN order_country = 'Georgia' THEN 'Georgia'
    WHEN order_country = 'Ghana' THEN 'Ghana'
    WHEN order_country = 'Grecia' THEN 'Greece'
    WHEN order_country = 'Guadalupe' THEN 'Guadeloupe'
    WHEN order_country = 'Guatemala' THEN 'Guatemala'
    WHEN order_country = 'Guayana Francesa' THEN 'French Guiana'
    WHEN order_country = 'Guinea' THEN 'Guinea'
    WHEN order_country = 'Guinea Ecuatorial' THEN 'Equatorial Guinea'
    WHEN order_country = 'Guinea-Bissau' THEN 'Guinea-Bissau'
    WHEN order_country = 'Guyana' THEN 'Guyana'
    WHEN order_country = 'Haití' THEN 'Haiti'
    WHEN order_country = 'Honduras' THEN 'Honduras'
    WHEN order_country = 'Hong Kong' THEN 'Hong Kong'
    WHEN order_country = 'Hungría' THEN 'Hungary'
    WHEN order_country = 'India' THEN 'India'
    WHEN order_country = 'Indonesia' THEN 'Indonesia'
    WHEN order_country = 'Irak' THEN 'Iraq'
    WHEN order_country = 'Irán' THEN 'Iran'
    WHEN order_country = 'Irlanda' THEN 'Ireland'
    WHEN order_country = 'Israel' THEN 'Israel'
    WHEN order_country = 'Italia' THEN 'Italy'
    WHEN order_country = 'Japón' THEN 'Japan'
    WHEN order_country = 'Jordania' THEN 'Jordan'
    WHEN order_country = 'Kazajistán' THEN 'Kazakhstan'
    WHEN order_country = 'Kenia' THEN 'Kenya'
    WHEN order_country = 'Kirguistán' THEN 'Kyrgyzstan'
    WHEN order_country = 'Kuwait' THEN 'Kuwait'
    WHEN order_country = 'Laos' THEN 'Laos'
    WHEN order_country = 'Lesoto' THEN 'Lesotho'
    WHEN order_country = 'Líbano' THEN 'Lebanon'
    WHEN order_country = 'Liberia' THEN 'Liberia'
    WHEN order_country = 'Libia' THEN 'Libya'
    WHEN order_country = 'Lituania' THEN 'Lithuania'
    WHEN order_country = 'Luxemburgo' THEN 'Luxembourg'
    WHEN order_country = 'Macedonia' THEN 'North Macedonia'
    WHEN order_country = 'Madagascar' THEN 'Madagascar'
    WHEN order_country = 'Malasia' THEN 'Malaysia'
    WHEN order_country = 'Mali' THEN 'Mali'
    WHEN order_country = 'Marruecos' THEN 'Morocco'
    WHEN order_country = 'Martinica' THEN 'Martinique'
    WHEN order_country = 'Mauritania' THEN 'Mauritania'
    WHEN order_country = 'México' THEN 'Mexico'
    WHEN order_country = 'Moldavia' THEN 'Moldova'
    WHEN order_country = 'Mongolia' THEN 'Mongolia'
    WHEN order_country = 'Montenegro' THEN 'Montenegro'
    WHEN order_country = 'Mozambique' THEN 'Mozambique'
    WHEN order_country = 'Myanmar (Birmania)' THEN 'Myanmar'
    WHEN order_country = 'Namibia' THEN 'Namibia'
    WHEN order_country = 'Nepal' THEN 'Nepal'
    WHEN order_country = 'Nicaragua' THEN 'Nicaragua'
    WHEN order_country = 'Níger' THEN 'Niger'
    WHEN order_country = 'Nigeria' THEN 'Nigeria'
    WHEN order_country = 'Noruega' THEN 'Norway'
    WHEN order_country = 'Nueva Zelanda' THEN 'New Zealand'
    WHEN order_country = 'Omán' THEN 'Oman'
    WHEN order_country = 'Países Bajos' THEN 'Netherlands'
    WHEN order_country = 'Pakistán' THEN 'Pakistan'
    WHEN order_country = 'Panamá' THEN 'Panama'
    WHEN order_country = 'Papúa Nueva Guinea' THEN 'Papua New Guinea'
    WHEN order_country = 'Paraguay' THEN 'Paraguay'
    WHEN order_country = 'Perú' THEN 'Peru'
    WHEN order_country = 'Polonia' THEN 'Poland'
    WHEN order_country = 'Portugal' THEN 'Portugal'
    WHEN order_country = 'Qatar' THEN 'Qatar'
    WHEN order_country = 'Reino Unido' THEN 'United Kingdom'
    WHEN order_country = 'República Centroafricana' THEN 'Central African Republic'
    WHEN order_country = 'República Checa' THEN 'Czech Republic'
    WHEN order_country = 'República de Gambia' THEN 'Gambia'
    WHEN order_country = 'República del Congo' THEN 'Republic of the Congo'
    WHEN order_country = 'República Democrática del Congo' THEN 'Democratic Republic of the Congo'
    WHEN order_country = 'República Dominicana' THEN 'Dominican Republic'
    WHEN order_country = 'Ruanda' THEN 'Rwanda'
    WHEN order_country = 'Rumania' THEN 'Romania'
    WHEN order_country = 'Rusia' THEN 'Russia'
    WHEN order_country = 'Sáhara Occidental' THEN 'Western Sahara'
    WHEN order_country = 'Senegal' THEN 'Senegal'
    WHEN order_country = 'Serbia' THEN 'Serbia'
    WHEN order_country = 'Sierra Leona' THEN 'Sierra Leone'
    WHEN order_country = 'Singapur' THEN 'Singapore'
    WHEN order_country = 'Siria' THEN 'Syria'
    WHEN order_country = 'Somalia' THEN 'Somalia'
    WHEN order_country = 'Sri Lanka' THEN 'Sri Lanka'
    WHEN order_country = 'Suazilandia' THEN 'Eswatini'
    WHEN order_country = 'SudAfrica' THEN 'South Africa'
    WHEN order_country = 'Sudán' THEN 'Sudan'
    WHEN order_country = 'Sudán del Sur' THEN 'South Sudan'
    WHEN order_country = 'Suecia' THEN 'Sweden'
    WHEN order_country = 'Suiza' THEN 'Switzerland'
    WHEN order_country = 'Surinam' THEN 'Suriname'
    WHEN order_country = 'Tailandia' THEN 'Thailand'
    WHEN order_country = 'Taiwán' THEN 'Taiwan'
    WHEN order_country = 'Tanzania' THEN 'Tanzania'
    WHEN order_country = 'Tayikistán' THEN 'Tajikistan'
    WHEN order_country = 'Togo' THEN 'Togo'
    WHEN order_country = 'Trinidad y Tobago' THEN 'Trinidad and Tobago'
    WHEN order_country = 'Túnez' THEN 'Tunisia'
    WHEN order_country = 'Turkmenistán' THEN 'Turkmenistan'
    WHEN order_country = 'Turquía' THEN 'Turkey'
    WHEN order_country = 'Ucrania' THEN 'Ukraine'
    WHEN order_country = 'Uganda' THEN 'Uganda'
    WHEN order_country = 'Uruguay' THEN 'Uruguay'
    WHEN order_country = 'Uzbekistán' THEN 'Uzbekistan'
    WHEN order_country = 'Venezuela' THEN 'Venezuela'
    WHEN order_country = 'Vietnam' THEN 'Vietnam'
    WHEN order_country = 'Yemen' THEN 'Yemen'
    WHEN order_country = 'Yibuti' THEN 'Djibouti'
    WHEN order_country = 'Zambia' THEN 'Zambia'
    WHEN order_country = 'Zimbabue' THEN 'Zimbabwe'
END
WHERE order_country IN ('Afganistán', 'Alemania', 'Arabia Saudí', 'Argelia', 'Azerbaiyán', 'Bangladés', 
                        'Baréin', 'Bélgica', 'Belice', 'Benín', 'Bielorrusia', 'Bolivia', 'Bosnia y Herzegovina', 
                        'Botsuana', 'Brasil', 'Bulgaria', 'Burkina Faso', 'Burundi', 'Bután', 'Camboya', 'Camerún', 
                        'Canada', 'Chad', 'Chile', 'China', 'Chipre', 'Colombia', 'Corea del Sur', 'Costa de Marfil', 
                        'Costa Rica', 'Croacia', 'Cuba', 'Dinamarca', 'Ecuador', 'Egipto', 'El Salvador', 
                        'Emiratos Árabes Unidos', 'Eritrea', 'Eslovaquia', 'Eslovenia', 'España', 'Estados Unidos', 
                        'Estonia', 'Etiopía', 'Filipinas', 'Finlandia', 'Francia', 'Gabón', 'Georgia', 'Ghana', 
                        'Grecia', 'Guadalupe', 'Guatemala', 'Guayana Francesa', 'Guinea', 'Guinea Ecuatorial', 
                        'Guinea-Bissau', 'Guyana', 'Haití', 'Honduras', 'Hong Kong', 'Hungría', 'India', 'Indonesia', 
                        'Irak', 'Irán', 'Irlanda', 'Israel', 'Italia', 'Japón', 'Jordania', 'Kazajistán', 'Kenia', 
                        'Kirguistán', 'Kuwait', 'Laos', 'Lesoto', 'Líbano', 'Liberia', 'Libia', 'Lituania', 'Luxemburgo', 
                        'Macedonia', 'Madagascar', 'Malasia', 'Mali', 'Marruecos', 'Martinica', 'Mauritania', 'México', 
                        'Moldavia', 'Mongolia', 'Montenegro', 'Mozambique', 'Myanmar (Birmania)', 'Namibia', 'Nepal', 
                        'Nicaragua', 'Níger', 'Nigeria', 'Noruega', 'Nueva Zelanda', 'Omán', 'Países Bajos', 'Pakistán', 
                        'Panamá', 'Papúa Nueva Guinea', 'Paraguay', 'Perú', 'Polonia', 'Portugal', 'Qatar', 'Reino Unido', 
                        'República Centroafricana', 'República Checa', 'República de Gambia', 'República del Congo', 
                        'República Democrática del Congo', 'República Dominicana', 'Ruanda', 'Rumania', 'Rusia', 
                        'Sáhara Occidental', 'Senegal', 'Serbia', 'Sierra Leona', 'Singapur', 'Siria', 'Somalia', 
                        'Sri Lanka', 'Suazilandia', 'SudAfrica', 'Sudán', 'Sudán del Sur', 'Suecia', 'Suiza', 'Surinam', 
                        'Tailandia', 'Taiwán', 'Tanzania', 'Tayikistán', 'Togo', 'Trinidad y Tobago', 'Túnez', 
                        'Turkmenistán', 'Turquía', 'Ucrania', 'Uganda', 'Uruguay', 'Uzbekistán', 'Venezuela', 'Vietnam', 
                        'Yemen', 'Yibuti', 'Zambia', 'Zimbabue');




