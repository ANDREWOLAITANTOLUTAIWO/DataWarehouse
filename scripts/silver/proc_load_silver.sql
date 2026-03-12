/* 
_______________________________________________________________________________________
Stored Procedure: Load bronze layer (Source --> Bronze)
________________________________________________________________________________________

Script Purpose:
This stored procedure loads data into the silver tables from bronze tables
It performs the following actions: 
	- Truncates the silver tables before loading data
	- Uses the BULK INSERT command to load data into the silver tables

Parameters: None
This stored procedure does not accept any parameters nor return any value

Usage Example: 
EXEC silver.load_silver
___________________________________________________________________________________________
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	
	BEGIN TRY
	SET @batch_start_time = GETDATE();
	PRINT '================================================================';
	PRINT 'Loading silver Layer';
	PRINT '================================================================';

	PRINT '================================================================';
	PRINT 'Loading CRM Tables';
	PRINT '================================================================';

	SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting data into silver.crm_cust_info';
		-- Use INSERT INTO to write the cleaned data values of bronze.crm_cust_info into silver layer's silver.crm_cust_info
		insert into silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date) 
		-- In our data warehouse, we aim to store clear and meaningful values instead of using abreviated terms
		-- and 'n/a' instead of null
		-- We also apply trim() and upper() in case future values are not upper case and need to be trimmed
		-- In order to clean the spaces, we use TRIM() on each column where we discovered spaces
		select
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname, --Remoove spaces from cst_firstname
		trim(cst_lastname) as cst_lastname, --Remove spaces from cst_lastname

		case when upper(trim(cst_gndr)) = 'F' then 'Female'
				when upper(trim(cst_gndr)) = 'M' then 'Male'
				else 'n/a'
			end as cst_gndr, -- Normalize gender value to readable format

		case when upper(trim(cst_marital_status)) = 'S' then 'Single'
				when upper(trim(cst_marital_status)) = 'M' then 'Married'
				else 'n/a'
			end as cst_marital_status, -- Normalize marital status to readable format

		cst_create_date
		from
		(select
		*,
		row_number() over (partition by cst_id order by cst_create_date desc) as most_recent
		from bronze.crm_cust_info
		where cst_id is not null
		) t
		where most_recent = 1;
	SET @end_time = GETDATE();
	PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT'>> -------------------'

	
	SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting data into silver.crm_prd_info';
		-- Use INSERT INTO to write the cleaned data values of bronze.crm_prd_info into silver layer's silver.crm_prd_info
		insert into silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		select 
		prd_id,
		replace (substring(prd_key, 1, 5), '-', '_') as cat_id, -- Extract category id (derived column)
		substring(prd_key, 7, len(prd_key)) as prd_key, -- Extract product key (derived column)
		prd_nm,
		isnull (prd_cost, 0) as prd_cost, -- Replace null or missing values with zero
		case upper(trim(prd_line))
			when 'R' then 'Road'
			when 'S' then 'Other Sales'
			when 'M' then 'Mountain'
			when 'T' then 'Touring'
			else 'n/a' -- Handle null or missing values
			end as prd_line, -- Map prd_line abbreviation to descriptive values (data normalization)
		cast(prd_start_dt as date) as prd_start_dt,
		-- this line of code returns the next prd_start_dt minus a day as the prd_end_dt of the present row
		cast(
			dateadd(day, -1, lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)
					) as date
			) as prd_end_dt --Calculate end date as one day before the next start date (data enrichment)
		from bronze.crm_prd_info
	SET @end_time = GETDATE();
	PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT'>> -------------------'


	SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting data into silver.crm_sales_details';
		-- Use INSERT INTO to write the cleaned data values of bronze.crm_sales_details into silver layer's silver.crm_sales_details
		insert into silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
		select 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		case when sls_order_dt <= 0 or len(sls_order_dt) != 8 then null
			else cast(cast(sls_order_dt as varchar) as date) -- Int cannot be cast to date in SQLSERVER; we first cast to varchar
		end as sls_order_dt,
		case when sls_ship_dt <= 0 or len(sls_ship_dt) != 8 then null
			else cast(cast(sls_ship_dt as varchar) as date) -- Int cannot be cast to date in SQLSERVER; we first cast to varchar
		end as sls_ship_dt,
		case when sls_due_dt <= 0 or len(sls_due_dt) != 8 then null
			else cast(cast(sls_due_dt as varchar) as date) -- Int cannot be cast to date in SQLSERVER; we first cast to varchar
		end as sls_due_dt,
		case when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity * abs(sls_price) then sls_quantity * abs(sls_price)
			else sls_sales
		end as sls_sales,
		sls_quantity,
		case when sls_price = 0 or sls_price is null then sls_sales/nullif(sls_quantity, 0)
			 when sls_price < 0 then sls_price * -1
			else sls_price
		end as sls_price
		from bronze.crm_sales_details
	SET @end_time = GETDATE();
	PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT'>> -------------------'


	PRINT '================================================================';
	PRINT 'Loading ERP Tables';
	PRINT '================================================================';

	SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_azi2';
		TRUNCATE TABLE silver.erp_cust_azi2;
		PRINT '>> Inserting data into silver.erp_cust_azi2';
		-- Use INSERT INTO to write the cleaned data values of bronze.erp_cust_azi2 into silver layer's silver.erp_cust_azi2
		insert into silver.erp_cust_azi2(
		cid,
		bdate,
		gen
		)
		select 
		upper(trim(substring(cid, 4, len(cid)))) as cid,
		bdate,
		case when upper(trim(gen))  in ('F', '', 'Female') then 'Female' 
			when gen in ('M', 'Male') then 'Male'
			else 'n/a'
		end as gen
		from bronze.erp_cust_azi2
	SET @end_time = GETDATE();
	PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT'>> -------------------'


	SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting data into silver.erp_loc_a101';
		-- Use INSERT INTO to write the cleaned data values of bronze.erp_loc_a101 into silver layer's silver.erp_loc_a101
		insert into silver.erp_loc_a101(
		cid,
		cntry
		)
		select
		replace(cid, '-', '') as cid,
		case when trim(cntry) = 'DE' then 'Germany'
			when trim(cntry) in ('US', 'USA', 'United States') then 'United States'
			when trim(cntry) in ('NULL', '') then 'n/a'
			else trim(cntry)
		end as cntry
		from bronze.erp_loc_a101
	SET @end_time = GETDATE();
	PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT'>> -------------------'


	SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting data into silver.erp_px_cat_g1v2';
		-- Use INSERT INTO to write the cleaned data values of bronze.erp_px_cat_g1v2 into silver layer's silver.erp_px_cat_g1v2
		insert into silver.erp_px_cat_g1v2(
		id,
		cat,
		subcat,
		maintenance
		)
		select
		id,
		trim(cat) as cat,
		trim(subcat) as subcat,
		trim(maintenance)
		from bronze.erp_px_cat_g1v2
	SET @end_time = GETDATE();
	PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT'>> -------------------'

	SET @batch_end_time = GETDATE();
		PRINT '================================================================';
		PRINT 'Loading Silver Layer is complete';
		PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================================================';
	END TRY
	BEGIN CATCH
		PRINT '================================================================';
		PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Number' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '================================================================';
	END CATCH
END
