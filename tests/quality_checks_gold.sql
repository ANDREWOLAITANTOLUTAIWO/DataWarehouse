/*
===============================================================================================
Quality Checks 
===============================================================================================
This script performs various quality checks for data consistency, acciracy and standardization 
across the gold schemas. These checks ensure:
- uniqueness of surrogate keys in dimension tables
- referential integrity between fact and dimension tables
- validation of relationships in the data model for analytical purposes

Usage Notes:
 - Run these checks after data loading gold layer
 - Investigate and resolve any discrepancies found during the checks
 ================================================================================================
*/

-- ===========================================================================
-- Check gold.dim_customers
-- ===========================================================================
-- Check for duplicates in the joined table
-- Expectation: No result
select count(*) cst_id from (
select
ci.cst_id,
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,
ci.cst_marital_status,
ci.cst_gndr,
ci.cst_create_date,
ca.bdate,
ca.gen,
cl.cntry
from silver.crm_cust_info as ci
left join silver.erp_cust_azi2 as ca
on ci.cst_key = ca.cid
left join silver.erp_loc_a101 as cl
on ci.cst_key = cl.cid
) t
group by cst_id
having count(*) > 1


-- There are two columns with the same values: gender
-- Integrate the two columns into one
select distinct
ci.cst_gndr,
ca.gen,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr --CRM is the master table for customer info
	else coalesce(ca.gen, 'n/a')
end as new_gen
from silver.crm_cust_info as ci
left join silver.erp_cust_azi2 as ca
on ci.cst_key = ca.cid
left join silver.erp_loc_a101 as cl
on ci.cst_key = cl.cid
order by 1, 2


-- ===========================================================================
-- Check gold.dim_products
-- ===========================================================================
-- Check for duplicates in the joined table
-- Expectation: No result
select count(*) prd_key from (
	select 
		pn.prd_id,
		pn.cat_id,
		pn.prd_key,
		pn.prd_nm,
		pn.prd_cost,
		pn.prd_line,
		pn.prd_start_dt,
		pc.cat,
		pc.subcat,
		pc.maintenance
	from silver.crm_prd_info as pn
	left join silver.erp_px_cat_g1v2 as pc
	on pn.cat_id = pc.id
	where prd_end_dt is null  -- Filter out all historical data
) t
group by prd_key
having count(*) > 1


-- ===========================================================================
-- Check gold.fact_sales
-- ===========================================================================
-- Check if all dimension tables can successfully join to the fact table
-- Expectation: No result
select * from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where p.product_key is null
