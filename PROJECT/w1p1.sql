CREATE DATABASE SalesDB;
USE SalesDB;
CREATE TABLE Sales (
    ProductCategory VARCHAR(50),
    ProductName VARCHAR(50),
    SaleAmount DECIMAL(10,2));
INSERT INTO Sales (ProductCategory, ProductName, SaleAmount) VALUES
('Electronics', 'Laptop', 1000),
('Electronics', 'Phone', 800),
('Electronics', 'Tablet', 500),
('Clothing', 'Shirt', 300),
('Clothing', 'Pants', 400),
('Furniture', 'Sofa', 1200),
('Furniture', 'Bed', 900);
