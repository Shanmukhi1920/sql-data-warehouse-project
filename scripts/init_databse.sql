/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.

*/

USE master;
GO   -- GO is used to separate batches when working with multiple SQL statements

-- drop and recreate the database 'DataWarehouse'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO
  
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create schema's for the layers
CREATE SCHEMA bronze; -- schema is like a folder or container that helps you keep things organized
GO

CREATE SCHEMA silver;
GO
  
CREATE SCHEMA gold;
GO

