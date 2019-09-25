create database if not exists ClsFinalProject;
-- Create a new table called 'TableName' in schema 'SchemaName'
-- Drop the table if it already exists
-- IF OBJECT_ID('ClsFinalProject.APIData', 'U') IS NOT NULL
DROP TABLE IF EXISTS ClsFinalProject.APIData;

-- Create the table in the specified schema
CREATE TABLE ClsFinalProject.APIData
(
    EndPointName CHAR(10) NOT NULL,
    EndPointId INT NOT NULL,
    EndPointData JSON NOT NULL
);
