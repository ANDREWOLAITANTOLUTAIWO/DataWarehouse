/* 
_______________________________________________________________________________________
Stored Procedure: Load bronze layer (Source --> Bronze)
________________________________________________________________________________________

Script Purpose:
This stored procedure loads data into the bronze schema from external CSV files
It performs the following actions: 
	- Truncates the bronze tables before loading data
	- Uses the BULK INSERT command to load data into the bronze tables

Parameters: None
This stored procedure does not accept any parameters nor return any value

Usage Example: 
EXEC bronze.load_bronze
___________________________________________________________________________________________

*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================================';
		PRINT 'Loading bronze Layer';
		PRINT '================================================================';

		PRINT '================================================================';
		PRINT 'Loading CRM Tables';
		PRINT '================================================================';

		SET @start_time = GETDATE();
		-- Make the table bronze.crm_cust_info before loading data in
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		truncate table bronze.crm_cust_info;

		-- Load data in bulk using BULK INSERT
		PRINT '>> Inserting data into bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\ADMIN\Documents\DATA ANALYSIS TRAINING\sql with baraa\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ','
		);
		SET @end_time = GETDATE();
		PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'>> -------------------'

		SET @start_time = GETDATE();
		-- Make the table bronze.crm_prd_info before loading data in
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		truncate table bronze.crm_prd_info;

		-- Load data in bulk using BULK INSERT
		PRINT '>> Inserting data into bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\ADMIN\Documents\DATA ANALYSIS TRAINING\sql with baraa\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ','
		)
		SET @end_time = GETDATE();
		PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'>> -------------------'

		SET @start_time = GETDATE();
		-- Make the table bronze.crm_sales_details before loading data in
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		truncate table bronze.crm_sales_details;

		-- Load data in bulk using BULK INSERT
		PRINT '>> Inserting data into bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\ADMIN\Documents\DATA ANALYSIS TRAINING\sql with baraa\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ','
		)
		SET @end_time = GETDATE();
		PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'>> -------------------'

		PRINT '================================================================';
		PRINT 'Loading ERP Tables';
		PRINT '================================================================';

		SET @start_time = GETDATE();
		-- Make the table bronze.erp_cust_azi2 before loading data in
		PRINT '>> Truncating Table: bronze.erp_cust_azi2';
		truncate table bronze.erp_cust_azi2;

		-- Load data in bulk using BULK INSERT
		PRINT '>> Inserting data into bronze.erp_cust_azi2';
		BULK INSERT bronze.erp_cust_azi2
		FROM 'C:\Users\ADMIN\Documents\DATA ANALYSIS TRAINING\sql with baraa\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ','
		)
		SET @end_time = GETDATE();
		PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'>> -------------------'

		SET @start_time = GETDATE();
		-- Make the table bronze.erp_loc_a101 before loading data in
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		truncate table bronze.erp_loc_a101;

		-- Load data in bulk using BULK INSERT
		PRINT '>> Inserting data into bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\ADMIN\Documents\DATA ANALYSIS TRAINING\sql with baraa\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ','
		)
		SET @end_time = GETDATE();
		PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'>> -------------------'

		SET @start_time = GETDATE();
		-- Make the table bronze.erp_px_cat_g1v2 before loading data in
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		truncate table bronze.erp_px_cat_g1v2;

		-- Load data in bulk using BULK INSERT
		PRINT '>> Inserting data into bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\ADMIN\Documents\DATA ANALYSIS TRAINING\sql with baraa\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ','
		)
		SET @end_time = GETDATE();
		PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'>> -------------------'
	
		SET @batch_end_time = GETDATE();
		PRINT '================================================================';
		PRINT 'Loading Bronze Layer is complete';
		PRINT'>> Loading duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================================================';
	END TRY
	BEGIN CATCH
		PRINT '================================================================';
		PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Number' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '================================================================';
	END CATCH
END
