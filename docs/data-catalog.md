# Data Dictionary for Gold Layer

## Overview

The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables and fact tables for specific business metrics. 

---

## 1. gold.dim_customers
###  Purpose: Stores customers details enriched with demographic and geographic data 

| Column Name | Data Type| Description |
|---|---|---|
| customer_key | INT | Surrogate key uniquely identifying each customer record in the dimension tables |
| customer_id | INT | Unique numerical identifier attached to each customer |
| lustomer_number | NVARCHAR | Alphanumeric identifier representing the customer, used for tracking and referencing |
| first_name | NVARCHAR | The customer's firs name as recorded in the system |
| last_name | NVARCHAR | The customer's last name or family name |
| country | NVARCHAR | The country of residence for the customer (e.g 'Australia' |
| marital_status | NVARCHAR | The marital status of the customer (e.g 'Single', 'Married' |
| gender | NVARCHAR | The gender of the customer (e.g. 'Male', 'Female', 'n/a') |
| birthdate | DATE | The date of birth of the customer, formatted as 'YYYY:MM:DD (e.g. 1971-10-06 |
| create_date | DATE | The date and time when the customer record was created in the system |

---

## 2. gold.dim_products
### *  Purpose: Provides information about the products and the attributes
| Column Name | Data Type| Description |
|---|---|---|
| product_key | INT | Surrogate key uniquely identifying each product record in the dimension tables |
| product_id | INT | Unique numerical identifier attached to each product |
| product_number | NVARCHAR| A structured alphanumeric key representing the product, often used for categorization or inventory |
| product_name | NVARCHAR| Descriptive name of the product, including key details such as type, color and size |
| category_id | NVARCHAR| A unique identifier for the product's category, linking to its high-level classification |
| category | NVARCHAR| The broader classification for the product (e.g. Bike, Components) to group related items |
| subcategory | NVARCHAR| A more detailed classification of the product within the category, such as product type |
| maintenance-required | NVARCHAR| Indicates whether the product required maintenance (e.g. 'Yes' or 'No' |
| cost | INT| The cost or base price of the product, measured in monetary unit |
| product_line | NVARCHAR| The specific product line or series to which the product belong (e.g. Road, Mountain) |
| start_date | DATE| The date when the product became available for sale or use |

---

## 3. gold.fact_sales
### *  Purpose: Stores transactional sales for analytical purposes
| Column Name | Data Type| Description |
|---|---|---|
| order_number | NVARCHAR | A unique alphanumeric identifier for each sales order (e.g. 'SOS4496') |
| product_key | INT | Surrogate key linking the order to the product dimension table |
| customer_key | INT | Surrogate key linking the order to the customer dimension table |
| order_date | DATE | The date when the order was placed |
| shipping_date | DATE | The date when the order was shipped to the customer |
| due_date | DATE | The date when the order payment was due |
| sales_amount | INT | The total monetary value of the sale for the line item in whole currency units (e.g. 25) |
| quantity | INT | The number of units of the products ordered for the line item (e.g. 1) |
| price | INT | The price per unit of the product for the line item in whole currency units (e.g. 25) |
