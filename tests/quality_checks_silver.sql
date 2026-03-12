/*
===============================================================================================
Quality Checks 
===============================================================================================
This script performs various quality checks for data consistency, acciracy and standardization 
across the silver schemas. It includes for:
- Null and duplicate primary keys
- Unwanted spaces in string fields
- Data standardization and consistency
- Invalid dates ranges and orders
- Data consistency between related fields

Usage Notes:
 - Run these checks after data loading silver layer
 - Investigate and resolve any discrepancies found during the checks
 ================================================================================================
*/

-- ===========================================
-- Checking silver.crm_cust_info
-- ===========================================
-- Quality Check 1. Check for nulls and duplicates in the primary key
	-- Aggregate the data by the primary key. If a key shows more than once
	-- it means there is duplicate
	-- Expectation: No result
select 
cst_id,
count(*)
from silver.crm_cust_info
group by cst_id
having count(*) < 1 or cst_id is null


-- To remove duplicates, we rank the values based on creation date and pick the most recent
-- We use window function ROW_NUMBER()
select
*
from
(select
*,
row_number() over (partition by cst_id order by cst_create_date desc) as most_recent
from silver.crm_cust_info
) t
where most_recent = 1 --This picks the most recent value for each primary key

-- Quality Check 2. Check for unwanted spaces in string values
	-- Check for unwanted spaces
	-- Expectation: No result
	select
	cst_firstname
	from silver.crm_cust_info
	where cst_firstname != trim(cst_firstname)

	select
	cst_lastname
	from silver.crm_cust_info
	where cst_lastname != trim(cst_lastname)

	-- Quality Check 3: Check for nulls and negative numbers
	-- This  is done only on number values
	-- Expectation: No results
	select 
	cst_id
	from silver.crm_cust_info
	where cst_id < 1 or cst_id is null


-- Quality Check 4: Check the consistency of values in low cardinality columns
	-- Data normalization / standardization and consistency
select 
distinct cst_marital_status
from silver.crm_cust_info

select 
distinct cst_gndr
from silver.crm_cust_info

-- ===========================================
-- Checking silver.crm_prd_info
-- ===========================================
-- Quality Check 1. Check for nulls and duplicates in the primary key
	-- Aggregate the data by the primary key. If a key shows more than once
	-- it means there is duplicate
	-- Expectation: No result
select 
prd_id,
count(*)
from silver.crm_prd_info
group by prd_id
having count(*) < 1 or prd_id is null

-- Quality Check 2: Check for inconsistent in prd_key values
	-- Derive cat key from prd_key
select
prd_key,
replace (substring(prd_key, 1, 5), '-', '_') as cat_id, -- Extract category id (derived column)
substring(prd_key, 7, len(prd_key)) as prd_key -- Extract product key (derived column)
from bronze.crm_prd_info

-- Quality Check 3: Check for invalid date orders
	-- End date should not be earlier than start date
	-- Expecttion: No results
select * 
from silver.crm_prd_info
where prd_end_dt < prd_start_dt

	-- If the order of date is invalid, carry out data enrichment by reordering the date
select 
prd_start_dt,
prd_end_dt,
	-- next line returns the next start_dt minus a day as the end_dt of the present row
dateadd(day, -1, lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)) as prd_end_dt 
from silver.crm_prd_info
where prd_key in ('AC-HE-HL-U509-R', 'AC-HE-HL-U509') 

-- ===========================================
-- Checking silver.crm_sales_details
-- ===========================================
-- Quality Check 1: Check invalid dates
select * 
from silver.crm_sales_details
where sls_order_dt = 0

	-- Replace zero with null
select *,
nullif(sls_due_dt, 0) as sls_due_dt
from silver.crm_sales_details

-- Quality Check 2: Check if sls_order_dt is less or equal to 0 
-- or the length of the digit is not equal to zero
select *
from silver.crm_sales_details
where sls_due_dt <= 0 or len(sls_due_dt) != 8 

-- Quality Check 3: Check if order_dt is greater than ship_dt and order_dt is greater than due_dt
	-- Expectation: No Result
select *
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

-- Quality Check 4: Check data consistency between sales, quantity and price
	-- Sales = Quantity * Price
	-- Values must not be zero, negative or null
select
sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
group by sls_sales, sls_quantity, sls_price

	-- Implement the following rules:
	-- If Sales is zero, negative or null, derive it using quantity and price
	-- If Price is zero or null, calculate it from Sales and Quantity
	-- If Price is negative convert it to positive number
select
sls_sales,
sls_quantity,
sls_price,
case when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity * abs(sls_price) then sls_quantity * abs(sls_price)
	else sls_sales
end as sls_sales,
case when sls_price = 0 or sls_price is null then sls_sales/nullif(sls_quantity, 0)
	 when sls_price < 0 then sls_price * -1
	else sls_price
end as sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
group by sls_sales, sls_quantity, sls_price


-- ===========================================
-- Checking silver.erp_cust_azi2
-- ===========================================
-- Quality Check 1. Check for nulls and duplicates in the primary key
	-- Aggregate the data by the primary key. If a key shows more than once
	-- it means there is duplicate
	-- Expectation: No result
select 
cid,
count(*)
from silver.erp_cust_azi2
group by cid
having count(*) < 1 or cid is null

-- Quality Check 2: Check invalid primary key
	-- Remove extra values 'NAS' from primary key values

select *,
upper(trim(substring(cid, 4, len(cid)))) as cid
from [bronze].[erp_cust_azi2]

	-- Check that 'NAS' has been removed
select 
cid
from silver.erp_cust_azi2

-- Quality Check 2: Check for unique values in 'gen'
select distinct gen from silver.erp_cust_azi2

-- ===========================================
-- Checking silver.erp_loc_a101
-- ===========================================
-- Quality Check 1. Check for nulls and duplicates in the primary key
	-- Aggregate the data by the primary key. If a key shows more than once
	-- it means there is duplicate
	-- Expectation: No result
select 
cid,
count(*)
from silver.erp_loc_a101
group by cid
having count(*) < 1 or cid is null

-- Quality Check 2: Check for unique values in 'gen'
select distinct cntry from silver.erp_loc_a101

-- ===========================================
-- Checking silver.erp_px_cat_g1v2
-- ===========================================
-- Quality Check 1. Check for nulls and duplicates in the primary key
	-- Aggregate the data by the primary key. If a key shows more than once
	-- it means there is duplicate
	-- Expectation: No result
select 
id,
count(*)
from silver.erp_px_cat_g1v2
group by id
having count(*) < 1 or id is null

-- Quality Check 2: Check for unique values in 'cat' and 'maintenance'
select distinct cat from silver.erp_px_cat_g1v2

select distinct maintenance from silver.erp_px_cat_g1v2
