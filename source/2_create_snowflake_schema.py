# Loading the required functions
import pandas as pd
import os
import numpy as np
# Import the cleaned data with specified data types
file_path = os.path.expanduser(r'~\Documents\GitHub\E-Commerce_SupplyChain_DataAnalysis\data\interim\cleaned_data.csv')
clean_df = pd.read_csv(file_path, dtype={
    'customer_zipcode': str,
    'order_zipcode': str
})

## dim_location table
# Extract the required columns for customer and order locations
dim_location = clean_df[['order_city', 'order_state', 'order_zipcode', 'order_region', 'order_country','market']].copy()

# Drop duplicates to ensure unique locations then Generate a unique location_id
dim_location = dim_location.drop_duplicates().reset_index(drop=True)
dim_location['location_id'] = range(1, len(dim_location) + 1)

# dim_customer Table
dim_customer = clean_df.filter(regex='^customer_').copy()
dim_customer = dim_customer.drop_duplicates().reset_index(drop=True)

# dim_category Table
dim_category = clean_df[['category_id', 'category_name']]
dim_category = dim_category.drop_duplicates().sort_values(by='category_id').reset_index(drop=True)

# dim_product Table
dim_product = clean_df.filter(regex='^product_').copy()
dim_product = dim_product.drop_duplicates().reset_index(drop=True).sort_values(by='product_card_id')

# dim_department Table
dim_department = clean_df[['department_id', 'department_name']]
dim_department = dim_department.drop_duplicates().sort_values(by='department_id').reset_index(drop=True)    

# Orders Table
orders_fact = clean_df.drop(columns=['category_id','category_name', 'department_name','product_name','product_image','product_card_id','product_category_id','product_price','order_item_product_price'])
orders_fact = pd.merge(orders_fact, dim_location, how='left',
                       on=['order_city','order_zipcode','order_state','order_country','order_region','market'])
orders_fact = orders_fact.drop(columns=['order_city','order_state','order_zipcode','order_country','order_region','market'])
orders_fact = orders_fact.drop(columns=['customer_id','customer_city','customer_state','customer_zipcode','customer_fname','customer_lname','customer_segment','customer_street','customer_email','customer_password'])
orders_fact = orders_fact.drop_duplicates().sort_values(by='order_id').reset_index(drop=True)

# Save cleaned dataset
# Replace 'output_path' with the desired output directory
output_path = r'~\Documents\GitHub\E-Commerce_SupplyChain_DataAnalysis\data\processed'

# Save each DataFrame to a separate CSV file
dim_location.to_csv(os.path.join(output_path, 'dim_location.csv'), index=False)
dim_customer.to_csv(os.path.join(output_path, 'dim_customer.csv'), index=False)
dim_category.to_csv(os.path.join(output_path, 'dim_category.csv'), index=False)
dim_department.to_csv(os.path.join(output_path, 'dim_department.csv'), index=False)
dim_product.to_csv(os.path.join(output_path, 'dim_product.csv'), index=False)
orders_fact.to_csv(os.path.join(output_path, 'orders_fact.csv'), index=False)

print("Data cleaning complete. Cleaned file saved as:", output_path)
