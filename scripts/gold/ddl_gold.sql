/* 
_______________________________________________________________________________________
DDL script: Create Gold Views
________________________________________________________________________________________

Script Purpose:
This script creates views for the gold layer in the warehouse
The gold layer represents the final dmension and fact tables (Star Schema)

Each view performas transformations and combines data from the silver layer
to produce clean, enriched and business-ready data sets.

Usage:
These views can be queried directly for analytics and reporting
___________________________________________________________________________________________
*/

-- ===========================================================================
-- Data Integration: gold.dim_customers
-- ===========================================================================
-- Join the CUSTOMER tables (silver.crm_cust_info, silver.erp_cust_azi2, 
	-- and silver.erp_loc_a101) together
-- Integrate the two gender columns into one
-- Change the name of the columns to friendly meaningful names
-- Add a surrogate key
-- Create object, view

if object_id('gold.dim_customers', 'v') is not null
	drop view gold.dim_customers;
go

create view gold.dim_customers as

select

	row_number() over (order by cst_id) as customer_key, -- surrogate key
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	cl.cntry as country,
	ci.cst_marital_status as marital_status,
	case when ci.cst_gndr != 'n/a' then ci.cst_gndr		-- There are two columns with the same values: gender
		else coalesce(ca.gen, 'n/a')					-- Integrate the two columns into one
	end as gender,										--CRM is the master table for customer info
	ca.bdate as birthdate,
	ci.cst_create_date as create_date
from silver.crm_cust_info as ci
left join silver.erp_cust_azi2 as ca
on ci.cst_key = ca.cid
left join silver.erp_loc_a101 as cl
on ci.cst_key = cl.cid

go


-- ===========================================================================
-- Data Integration: gold.dim_products
-- ===========================================================================
-- Filter out alll historical data; that is, retaining only where prd_end_dt has a a NULL value
-- Remname columns to friendly meaningful names

if object_id('gold.dim_products', 'v') is not null
	drop view gold.dim_products;
go

 create view gold.dim_products as 

select 
	row_number() over (order by prd_id) as product_key, -- surrogate key
	pn.prd_id as product_id,
	prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcategory,
	pc.maintenance,
	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date
from silver.crm_prd_info as pn
left join silver.erp_px_cat_g1v2 as pc
on pn.cat_id = pc.id
where prd_end_dt is null  -- Filter out all historical data

go


-- ===========================================================================
-- Data Integration: gold.fact_sales
-- ===========================================================================
-- Use dimension's surrogate keys instead of IDs in order to connect fact table with dimensiion tables
-- Replace sls_cust_id and sls_prd_key that came from the source with surrogate keys (customer_key and product_key)
-- Remname columns to friendly meaningful names

if object_id('gold.fact_sales', 'v') is not null
	drop view gold.fact_sales;
go

create view gold.fact_sales as
select 
sl.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sl.sls_order_dt as order_date,
sl.sls_ship_dt as shipping_date,
sl.sls_due_dt as due_date,
sl.sls_sales as sales_amount,
sl.sls_quantity as quantity,
sl.sls_price as price
from silver.crm_sales_details as sl
left join gold.dim_customers as cu -- Joined with gold.dim_customers to connect the customer_key
on sl.sls_cust_id = cu.customer_id
left join gold.dim_products as pr -- Joined with gold.dim_products to connect the product_key
on sl.sls_prd_key = pr.product_number

go
