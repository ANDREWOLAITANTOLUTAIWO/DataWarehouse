/* 
__________________________________
Create Database and Schemas
__________________________________

Script Purpose:
This script creates a new database named DataWarehouse after checking if it already exists.
If the database exists, it is dropped and recreated. The script also sets up three schemas 
within the database: 'bronze', 'silver' and 'gold'. 

WARNING!
Runnning this script will drop the entire database if it exists. 
All data in the database will be permanently deleted. Proceed with
caution and ensure you have proper backup before running this script.

*/

use master
GO

-- Drop and recreate database DataWarehouse
If exists (select 1 from sys.databases where name = 'DataWarehouse')
Begin
	alter database DataWarehouse set single_user with rollback immediate
	drop database DataWarehouse
end
GO

-- Create the database named DataWarehouse
create database DataWarehouse
GO

use DataWarehouse
GO

-- Create schemas
create schema bronze
GO

create schema silver
GO

create schema gold



