/* 
____________________________________________________
Create Table Structures in 'bronze' layer with DDL
____________________________________________________

Script Purpose:
This script creates tables in the bronze layer, dropping existing tables
if they already exist.
It uses DDL to create table structure for each of the files in the source system.

*/

-- Create table structure for cust_info
if object_id('bronze.crm_cust_info', 'u') is not null
	drop table bronze.crm_cust_info
create table bronze.crm_cust_info(
cst_id int,
cst_key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_marital_status nvarchar(50),
cst_gndr nvarchar(50),
cst_create_date date
);

-- Create table structure for prd_info
if object_id('bronze.crm_prd_info', 'u') is not null
	drop table bronze.crm_prd_info
create table bronze.crm_prd_info(
prd_id int,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost nvarchar(50),
prd_line nvarchar(50),
prd_start_dt date,
prd_end_dt date
);


-- Create table structure for sales_details
if object_id('bronze.crm_sales_details', 'u') is not null
	drop table bronze.crm_sales_details
create table bronze.crm_sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt nvarchar(50),
sls_ship_dt nvarchar(50),
sls_due_dt nvarchar(50),
sls_sales int,
sls_quantity int,
sls_price int
);


-- Create table structure for CUST_AZ12
if object_id('bronze.erp_cust_azi2', 'u') is not null
	drop table bronze.erp_cust_azi2
create table bronze.erp_cust_azi2(
CID nvarchar(50),
BDATE date,
GEN nvarchar(50)
);


-- Create table structure for LOC_A101
if object_id('bronze.erp_loc_a101', 'u') is not null
	drop table bronze.erp_loc_a101
create table bronze.erp_loc_a101(
CID nvarchar(50),
CNTRY nvarchar(50)
);


-- Create table structure for PX_CAT_G1V2
if object_id('bronze.erp_px_cat_g1v2', 'u') is not null
	drop table bronze.erp_px_cat_g1v2
create table bronze.erp_px_cat_g1v2(
ID nvarchar(50),
CAT nvarchar(50),
SUBCAT nvarchar(50),
MAINTENANCE nvarchar(50)
);

