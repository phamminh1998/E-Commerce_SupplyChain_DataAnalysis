## E-Commerce_SupplyChain_DataAnalysis

# DATACO SUPPLY-CHAIN ANALYSIS



---

## 📌 Overview of Project

With the rise of big data and advancements in data collection and storage, industries like retail, e-commerce, and supply chain management now have more opportunities to leverage data for analysis, optimization, and decision-making. However, to fully capitalize on these opportunities, businesses must invest in data analytics expertise, either by upskilling employees or hiring specialists.  

This project serves as a hands-on exercise in end-to-end data analysis, covering key stages such as ETL (Extract, Transform, Load), database structuring, exploratory analysis, and dashboard/report development. The analysis is conducted using widely used tools in the field, including SQL, Python, and Power BI.  

The dataset used for this project is the **DataCo SMART SUPPLY CHAIN FOR BIG DATA ANALYSIS**, provided by **Fabian Constante, Fernando Silva, and António Pereira** from **Universidad Central del Ecuador** and **Instituto Politécnico de Leiria, Centro de Investigação em Informática e Comunicações**. Please click [here](https://data.mendeley.com/datasets/8gx2fvg2k6/5) to access data.

## 📂 Project Organization

```
├── data
│   ├── external       <- Data from third party sources.
│   ├── interim        <- Intermediate data that has been transformed.
│   ├── processed      <- The final data sets for modeling and analysing.
│   └── raw            <- The original, immutable data dump from DataCo.
│
├── docs               <- A default mkdocs project; see www.mkdocs.org for details
│
├── notebooks          <- Jupyter notebooks for experimenting
│
├── pyproject.toml     <- Project configuration file with package metadata for 
│                         e_commerce_supplychain_dataanalysis and configuration for tools like black
│
├── references         <- Data dictionaries, manuals, and all other explanatory materials.
│
├── reports            <- Generated analysis as PBIX, TWBX, PDF, etc.
│   └── figures        <- Generated graphics and figures to be used in reporting
│
├── requirements.txt   <- The requirements file for reproducing the analysis environment, e.g.
│                         generated with `pip freeze > requirements.txt`
│
├── setup.cfg          <- Configuration file for flake8
│
└── source             <- Source code for use in this project, including Python and SQL script.
    
```
---


## 📊 Data Overview and Limitations  

The dataset contains **180,519 entries** with **53 attributes**, primarily capturing information on **orders, products, categories, locations, customers, and shipping details**. Each attribute is described in detail in the raw CSV file **`DescriptionDataCoSupplyChain`**.  
While the dataset provides valuable insights, it has some limitations:  

- **Missing Cost Data**: The dataset does not include details on product or operational costs. Without this information, it is difficult to perform profitability analysis or assess the financial efficiency of the supply chain.  
- **Limited Customer Demographics**: Customer segmentation is primarily based on geographic data. The dataset lacks detailed demographic attributes (such as age, gender, or purchasing behavior), which could enhance targeted marketing and product recommendations.

---

## 🛠 Tools & Technologies
List the tools used in the project.

- SQL (Oracle MySQL, DBeaver) – Data cleaning & transformation, Database creation and management.
- Python (Pandas, Matplotlib) – Exploratory Data Analysis
- Power BI (DAX, Tooltips, Bookmarking) – Dashboard and visualization

---

## 🚀 Steps to run Project  

This project follows a structured end-to-end data analysis workflow:  

1. **Data Cleaning & Transformation**  
   - Imported raw data into MySQL, Cleaned missing values, trim whitespace, normalize geographical data, handled data inconsistencies using SQL. SQL script: [1_clean_data](source/1_clean_data.sql)
   - Create a similar Python script to import, clean and handle data inconsistency: [1_clean_data.py](1_clean_data.py)

2. **Data Modeling & Schema Design**  
   - Designed a star schema with normalized dimension tables to reduce redundancy, optimize querying and modeling in Power BI/Tableau
   ![Database Diagram](<reports/figures/DataCo Supply Chain simple DB Diagram.png>)

      + orders_fact: detail on each order about item quantity, sales and profit, delivery detail.
      + dim_customer: customer information
      + dim_product: Details about products
      + dim_location: Normalize order location
      + dim_date: Dates for various events (order, shipping)
      + dim_department: Store_category
      + dim_market: Market information
      + dim_category: Product category
Detail can of SQL/Python Script can be seen in [2_create_star_schema_server.sql](source/2_create_star_schema_server.sql) and [2_create_star_schema.py](source/2_create_star_schema.py)

3. **Exploratory Data Analysis (EDA)**  
   - [Answer some adhoc questions by SQL](source/3_adhoc_Data_Analysis.sql)
   ![Preview of SQL adhoc](<reports/figures/adhoc with SQL.png>)
   - Identified key trends and patterns in orders, delivery performance, and customer behavior  with Python [Jupyter Notebook](notebooks/3_experiment_data_analysis.ipynb)
   - Visualized insights using Python (Matplotlib & Seaborn)

4. **Dashboard & Report Development**  
   - Built interactive Power BI dashboards to visualize key metrics  
   - Designed reports focusing on delivery performance and order trends  

5. **Insights & Recommendations**  
   - Interpreted findings and suggested actionable business improvements  
   - Identified areas for potential optimization in supply chain operations  


---
## 📌 Business Questions  

### 1️⃣ Sales & Profitability Analysis  
- Which products or product categories contribute the most to total sales and profitability?  
- Are there specific customer segments that generate a disproportionate share of revenue and profit?  
- How do discount levels affect sales and profitability? Is there an optimal discount strategy?  

### 2️⃣ Order Trends & Customer Behavior  
- How have order volumes changed over time? Are there any seasonal patterns or significant fluctuations?  
- Do order trends vary across different customer segments or product categories?  
- What is the relationship between order volume, sales, profit, and discount levels?  

### 3️⃣  Shipping & Delivery Performance  
- What are the most commonly used shipping methods, and how do they impact delivery timeliness?  
- Is there a correlation between order processing times and delivery delays? How does this affect late delivery rates? 

### 4️⃣  Geographic Performance & Regional Insights  
- Which geographical regions or cities generate the highest order volume and net sales?  
- How do regional factors influence supply chain logistics and delivery efficiency? 

---

## 🔍 Key Insights and findings

### 🚚 Shipping & Delivery Efficiency  
- **Shipping Modes & Late Deliveries**:  
  - **Standard Shipping**: Most used (~108,000 orders), also have the lowest late-delivery rate at **38% with ~42,000 orders were late**.  
  - **First-Class Shipping**: While is the second most used shipping method with 35,000 orders, have the highest late-delivery rate at **95.32% with 28,000 orders delayed**.  
  - **Same-Day Shipping**: 10,000 orders, but only 5,000 delivered on time.  
- **Order Processing & Timeliness**:  
  - **Faster processing (same-day, next-day)** leads to **on-time delivery**.  
  - Longer processing times (3rd–6th day) significantly increase **late delivery rates**.  
  - Improving **order processing efficiency** can enhance delivery performance. 

### 📦 Order Trends  
- Order volumes show **seasonal fluctuations**, with a sharp decline in **Q4 2017**, requiring further investigation. Monitoring and forecasting trends can help maintain a stable supply chain.  
- Customer segments exhibit **distinct ordering patterns**:  
  - **Consumers & Corporate**: High order volumes but declining over time.  
  - **Home Office**: Lower but more stable order volume.  
  - Product categories remain consistent across segments, suggesting opportunities for **targeted marketing & inventory management**.  
- **Discounts & Profitability**:  
  - Discounts drive sales but **closely match total profits**, affecting margins.  
  - Some categories show profits slightly exceeding discounts, indicating **effective cost control**.  
  - Optimizing discount strategies is crucial for maximizing profitability.  

### 💰 Sales & Profitability  
- **Top-performing products**:  
  - *Field & Stream Sportsman 16 Gun Fire Safe* leads in both **sales & profit**, followed by *Perfect Fitness Rip Deck* and *Diamondback Women's Comfort Bike*.  
  - Product selection and marketing play a vital role in success.  
- **Customer Segments & Revenue**:  
  - The **Consumers** category dominates **sales & profit**, outperforming Corporate and Home Office segments.  
- **Discount Strategy**:  
  - A **flat 10% discount** was applied across all categories, uniformly influencing sales.  
  - Profit margins align closely with discounts, showing a **trade-off between revenue & profitability**.  
  - Optimizing discount levels based on **customer segmentation & long-term sustainability** is essential.  

### 🌍 Geographic Performance  
- **Top regions by sales & profitability**:  
  - **Caguas (Puerto Rico)** leads in sales, presenting growth opportunities.  
  - **Chicago & Los Angeles** are key markets requiring continued focus.  
- **Delivery Delays & Regional Factors**:  
  - Shipping delays are **consistent across locations**, suggesting **internal operational inefficiencies** rather than regional logistics issues.  
  - Addressing **internal processing delays** is key to improving delivery performance.   

---

## ✅ Recommendations  

### 🎯 Pricing & Discounts  
- Implement **dynamic discounting** instead of a flat 10%:  
  - Adjust discounts based on **product demand, category, and customer behavior**.  
  - Offer **higher discounts** on low-demand items and **minimal or no discounts** on high-performing products.  
- Personalize discounts for **customer segments**:  
  - Introduce **loyalty programs** for frequent buyers to encourage repeat purchases.  

### 📍 Regional Growth & Customer Engagement  
- **Target high-performing regions** with **localized marketing strategies** to maximize sales.  
- Strengthen customer relationships through:  
  - **Loyalty programs, exclusive offers, and personalized support** to enhance retention.  
- Expand into **emerging markets** with growth potential to diversify revenue sources.  

### 🚛 Supply Chain & Shipping Optimization  
- **Streamline order fulfillment** by identifying and fixing bottlenecks in logistics and shipping.  
- **Optimize standard shipping processes** to reduce delays and improve efficiency.  
- Collect **customer feedback on first-class shipping** to refine the experience and meet expectations.  

---

## 🖥️ Visualization Preview

I have created two dashboard from this dataset.

- Executive Dashboard:
![Executive Dashboard](<reports/figures/sales  overview.png>)

- Shipping Dashboard:
![Shipping Dashboard](<reports/figures/Delivery performance.png>)


To interact with the dashboards, please download the PBIX book [here](reports/Dashboard.pbix)(Sorry I'm broke :( ) 

Thank you!

## 📌 Future Improvements  

- Automate ETL process with specialized tool (Apache Airflow, etc) to streamline data extraction, transformation, and loading.  
- Incorporate machine learning models for predictive analytics and trend forecasting.  
- Further normalize database design.

--------

