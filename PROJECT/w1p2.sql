USE SalesDB;
SELECT
    IFNULL(ProductCategory, 'Total') AS ProductCategory,
    IFNULL(ProductName, 'Total') AS ProductName,
    SUM(SaleAmount) AS TotalSales
FROM
    Sales
GROUP BY
    ProductCategory WITH ROLLUP, ProductName WITH ROLLUP
ORDER BY
    (ProductCategory IS NULL), ProductCategory,
    (ProductName IS NULL), ProductName;
