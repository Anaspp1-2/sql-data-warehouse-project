/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/



--create database 'DataWareHouse'

use master;
Go


--Drop and recreate the 'DataWarehouse' Database--

IF EXISTS(select 1 from sys.databases WHERE name='DataWarehouse')
BEGIN
	Alter Database DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP Database DataWarehouse;
END
GO

Create Database DataWarehouse;

use DataWarehouse;

--Create schemas

Create Schema bronze;
go
Create Schema Silver;
go
Create Schema Gold;
go
