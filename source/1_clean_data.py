# Loading the required functions
import pandas as pd
import os
import numpy as np
os.chdir(r"C:\Users\PC\Documents\GitHub\E-Commerce_SupplyChain_DataAnalysis")
print("Current working directory:", os.getcwd())


# Define the path using a raw string and expand the ~ to the full path
file_path = os.path.expanduser(r'~\Documents\GitHub\E-Commerce_SupplyChain_DataAnalysis\data\raw\DataCoSupplyChainDataset.csv')

# Load the dataset with the specified encoding
df = pd.read_csv(file_path, encoding='Windows-1252')

# Cleaning Steps
newdf = df.drop(columns = ["Product Status", 'Product Description','Customer Country'])

# Trim white spaces from all string columns
newdf = newdf.map(lambda x: x.strip() if isinstance(x, str) else x)

# Standardize column names: make all lowercase and replace spaces with underscores
newdf.columns = newdf.columns.str.lower().str.replace(' ', '_')

# Fill missing values with a placeholder
newdf[['customer_zipcode', 'order_zipcode']] = newdf[['customer_zipcode', 'order_zipcode']].fillna(0)

# Remove the decimal part and convert to string
newdf[['customer_zipcode', 'order_zipcode']] = newdf[['customer_zipcode', 'order_zipcode']].astype(float).astype(int).astype(str)

# Replace common placeholders with NaN (pandas treats NaN as NULL)
newdf.replace(['', ' ', 'NaN', 'NULL', 'N/A', 'None', '?', '-', '0', 'Unknown'], pd.NA, inplace=True)

# Convert the columns to datetime
newdf['order_date_(dateorders)'] = pd.to_datetime(newdf['order_date_(dateorders)'], format='%m/%d/%Y %H:%M')
newdf['shipping_date_(dateorders)'] = pd.to_datetime(newdf['shipping_date_(dateorders)'], format='%m/%d/%Y %H:%M')

# Convert the datetime columns to ISO 8601 format
newdf['order_date_(dateorders)'] = newdf['order_date_(dateorders)'].dt.strftime('%Y-%m-%d %H:%M:%S')
newdf['shipping_date_(dateorders)'] = newdf['shipping_date_(dateorders)'].dt.strftime('%Y-%m-%d %H:%M:%S')

# Update 'customer_state' column where the value is '91732' or '95758' to 'CA'
newdf['customer_state'] = newdf['customer_state'].replace(['91732', '95758'], 'CA')

# Update the 'market' column, replacing 'LATAM' with 'Latin America' and 'USCA' with 'North America'
newdf['market'] = newdf['market'].replace({
    'LATAM': 'Latin America',
    'USCA': 'North America'
})

# Update the 'order_city' column with correct names
newdf['order_city'] = newdf['order_city'].replace({
    'Aew?l-li': 'Aewŏl-li',
    'Cox’s B?z?r': 'Cox’s Bāzār',
    'Klaip?da': 'Klaipėda',
    'Bra?ov': 'Brașov',
    'Gy?r': 'Győr',
    'Kahramanmara?': 'Kahramanmaraş'
})

# Mapping of Spanish country names to English country names
country_mapping = {
    'Afganistán': 'Afghanistan', 'Alemania': 'Germany', 'Arabia Saudí': 'Saudi Arabia', 'Argelia': 'Algeria',
    'Azerbaiyán': 'Azerbaijan', 'Bangladés': 'Bangladesh', 'Baréin': 'Bahrain', 'Bélgica': 'Belgium',
    'Belice': 'Belize', 'Benín': 'Benin', 'Bielorrusia': 'Belarus', 'Bolivia': 'Bolivia',
    'Bosnia y Herzegovina': 'Bosnia and Herzegovina', 'Botsuana': 'Botswana', 'Brasil': 'Brazil',
    'Bulgaria': 'Bulgaria', 'Burkina Faso': 'Burkina Faso', 'Burundi': 'Burundi', 'Bután': 'Bhutan',
    'Camboya': 'Cambodia', 'Camerún': 'Cameroon', 'Canada': 'Canada', 'Chad': 'Chad', 'Chile': 'Chile',
    'China': 'China', 'Chipre': 'Cyprus', 'Colombia': 'Colombia', 'Corea del Sur': 'South Korea',
    'Costa de Marfil': 'Ivory Coast', 'Costa Rica': 'Costa Rica', 'Croacia': 'Croatia', 'Cuba': 'Cuba',
    'Dinamarca': 'Denmark', 'Ecuador': 'Ecuador', 'Egipto': 'Egypt', 'El Salvador': 'El Salvador',
    'Emiratos Árabes Unidos': 'United Arab Emirates', 'Eritrea': 'Eritrea', 'Eslovaquia': 'Slovakia',
    'Eslovenia': 'Slovenia', 'España': 'Spain', 'Estados Unidos': 'United States', 'Estonia': 'Estonia',
    'Etiopía': 'Ethiopia', 'Filipinas': 'Philippines', 'Finlandia': 'Finland', 'Francia': 'France',
    'Gabón': 'Gabon', 'Georgia': 'Georgia', 'Ghana': 'Ghana', 'Grecia': 'Greece', 'Guadalupe': 'Guadeloupe',
    'Guatemala': 'Guatemala', 'Guayana Francesa': 'French Guiana', 'Guinea': 'Guinea',
    'Guinea Ecuatorial': 'Equatorial Guinea', 'Guinea-Bissau': 'Guinea-Bissau', 'Guyana': 'Guyana',
    'Haití': 'Haiti', 'Honduras': 'Honduras', 'Hong Kong': 'Hong Kong', 'Hungría': 'Hungary', 'India': 'India',
    'Indonesia': 'Indonesia', 'Irak': 'Iraq', 'Irán': 'Iran', 'Irlanda': 'Ireland', 'Israel': 'Israel',
    'Italia': 'Italy', 'Japón': 'Japan', 'Jordania': 'Jordan', 'Kazajistán': 'Kazakhstan', 'Kenia': 'Kenya',
    'Kirguistán': 'Kyrgyzstan', 'Kuwait': 'Kuwait', 'Laos': 'Laos', 'Lesoto': 'Lesotho', 'Líbano': 'Lebanon',
    'Liberia': 'Liberia', 'Libia': 'Libya', 'Lituania': 'Lithuania', 'Luxemburgo': 'Luxembourg',
    'Macedonia': 'North Macedonia', 'Madagascar': 'Madagascar', 'Malasia': 'Malaysia', 'Mali': 'Mali',
    'Marruecos': 'Morocco', 'Martinica': 'Martinique', 'Mauritania': 'Mauritania', 'México': 'Mexico',
    'Moldavia': 'Moldova', 'Mongolia': 'Mongolia', 'Montenegro': 'Montenegro', 'Mozambique': 'Mozambique',
    'Myanmar (Birmania)': 'Myanmar', 'Namibia': 'Namibia', 'Nepal': 'Nepal', 'Nicaragua': 'Nicaragua',
    'Níger': 'Niger', 'Nigeria': 'Nigeria', 'Noruega': 'Norway', 'Nueva Zelanda': 'New Zealand', 'Omán': 'Oman',
    'Países Bajos': 'Netherlands', 'Pakistán': 'Pakistan', 'Panamá': 'Panama', 'Papúa Nueva Guinea': 'Papua New Guinea',
    'Paraguay': 'Paraguay', 'Perú': 'Peru', 'Polonia': 'Poland', 'Portugal': 'Portugal', 'Qatar': 'Qatar',
    'Reino Unido': 'United Kingdom', 'República Centroafricana': 'Central African Republic', 'República Checa': 'Czech Republic',
    'República de Gambia': 'Gambia', 'República del Congo': 'Republic of the Congo', 'República Democrática del Congo': 'Democratic Republic of the Congo',
    'República Dominicana': 'Dominican Republic', 'Ruanda': 'Rwanda', 'Rumania': 'Romania', 'Rusia': 'Russia',
    'Sáhara Occidental': 'Western Sahara', 'Senegal': 'Senegal', 'Serbia': 'Serbia', 'Sierra Leona': 'Sierra Leone',
    'Singapur': 'Singapore', 'Siria': 'Syria', 'Somalia': 'Somalia', 'Sri Lanka': 'Sri Lanka', 'Suazilandia': 'Eswatini',
    'SudAfrica': 'South Africa', 'Sudán': 'Sudan', 'Sudán del Sur': 'South Sudan', 'Suecia': 'Sweden', 'Suiza': 'Switzerland',
    'Surinam': 'Suriname', 'Tailandia': 'Thailand', 'Taiwán': 'Taiwan', 'Tanzania': 'Tanzania', 'Tayikistán': 'Tajikistan',
    'Togo': 'Togo', 'Trinidad y Tobago': 'Trinidad and Tobago', 'Túnez': 'Tunisia', 'Turkmenistán': 'Turkmenistan',
    'Turquía': 'Turkey', 'Ucrania': 'Ukraine', 'Uganda': 'Uganda', 'Uruguay': 'Uruguay', 'Uzbekistán': 'Uzbekistan',
    'Venezuela': 'Venezuela', 'Vietnam': 'Vietnam', 'Yemen': 'Yemen', 'Yibuti': 'Djibouti', 'Zambia': 'Zambia',
    'Zimbabue': 'Zimbabwe'
}

# Update the 'order_country' column with the correct English names
newdf['order_country'] = newdf['order_country'].replace(country_mapping)

# Save cleaned dataset
output_path = os.path.expanduser(r'~\Documents\GitHub\E-Commerce_SupplyChain_DataAnalysis\data\interim\cleaned_data.csv')
if os.path.exists(output_path):
    os.remove(output_path)
os.makedirs(output_path, exist_ok=True)
newdf.to_csv(output_path, index=False)

print("Data cleaning complete. Cleaned file saved as:", output_path)
