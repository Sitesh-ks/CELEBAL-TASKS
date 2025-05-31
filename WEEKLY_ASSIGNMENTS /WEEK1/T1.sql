1.List of all customers

SELECT * FROM Sales.Customer;


2. List of all customers where company name ends with 'N'

SELECT * FROM Sales.Customer
WHERE CompanyName LIKE '%N';


3. List of all customers who live in Berlin or London

SELECT c.*
FROM Sales.Customer c
JOIN Person.Address a ON c.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');


4. List of all customers who live in UK or USA

SELECT c.*
FROM Sales.Customer c
JOIN Person.Address a ON c.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');


5. List of all products sorted by product name

SELECT * FROM Production.Product
ORDER BY Name;


6. List of all products where product name starts with an 'A'

SELECT * FROM Production.Product
WHERE Name LIKE 'A%';


7. List of customers who ever placed an order

SELECT DISTINCT c.*
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID;


8. List of customers who live in London and have bought 'Chai'

SELECT DISTINCT c.*
FROM Sales.Customer c
JOIN Person.Address a ON c.AddressID = a.AddressID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE a.City = 'London' AND p.Name = 'Chai';


9. List of customers who never placed an order

SELECT c.*
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE soh.SalesOrderID IS NULL;


10. List of customers who ordered 'Tofu'

SELECT DISTINCT c.*
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.Name = 'Tofu';


11. Details of the first order in the system

SELECT TOP 1 *
FROM Sales.SalesOrderHeader
ORDER BY OrderDate ASC;


12. Find the details of the most expensive order date

SELECT TOP 1 OrderDate, SUM(LineTotal) AS TotalAmount
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY OrderDate
ORDER BY TotalAmount DESC;


13. For each order, get the OrderID and average quantity of items in that order

SELECT SalesOrderID, AVG(OrderQty) AS AverageQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;


14. For each order, get the OrderID, minimum quantity, and maximum quantity for that order

SELECT SalesOrderID, MIN(OrderQty) AS MinQuantity, MAX(OrderQty) AS MaxQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;


15. Get a list of all managers and the total number of employees who report to them  
                            
SELECT Manager.BusinessEntityID AS ManagerID, COUNT(Employee.BusinessEntityID) AS NumberOfReports
FROM HumanResources.Employee AS Employee
JOIN HumanResources.Employee AS Manager ON Employee.ManagerID = Manager.BusinessEntityID
GROUP BY Manager.BusinessEntityID; 
   
           
16. Get the OrderID and the total quantity for each order that has a total quantity greater than 300

SELECT SalesOrderID, SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;


17. List of all orders placed on or after 1996-12-31

SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';


18. List of all orders shipped to Canada

SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';


19. List of all orders with order total greater than 200

SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN (
    SELECT SalesOrderID, SUM(LineTotal) AS OrderTotal
    FROM Sales.SalesOrderDetail
    GROUP BY SalesOrderID
) AS OrderTotals ON soh.SalesOrderID = OrderTotals.SalesOrderID
WHERE OrderTotals.OrderTotal > 200;


20. List of countries and sales made in each country

SELECT cr.Name AS Country, SUM(sod.LineTotal) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Person.Address a ON soh.BillToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name;


21. List of Customer ContactName and number of orders they placed

SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName;


22. List of customer contact names who have placed more than 3 orders

SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 3;


23. List of discontinued products which were ordered between 1997-01-01 and 1998-01-01

SELECT DISTINCT p.*
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.DiscontinuedDate IS NOT NULL
  AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';


24. List of employee first name, last name, supervisor first name, last name

SELECT e.BusinessEntityID AS EmployeeID, ep.FirstName AS EmployeeFirstName, ep.LastName AS EmployeeLastName,
       sp.FirstName AS SupervisorFirstName, sp.LastName AS SupervisorLastName
FROM HumanResources.Employee e
JOIN Person.Person ep ON e.BusinessEntityID = ep.BusinessEntityID
LEFT JOIN HumanResources.Employee s ON e.ManagerID = s.BusinessEntityID
LEFT JOIN Person.Person sp ON s.BusinessEntityID = sp.BusinessEntityID;


25. List of employee IDs and total sales conducted by each employee

SELECT e.BusinessEntityID AS EmployeeID, SUM(sod.LineTotal) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
GROUP BY e.BusinessEntityID;


26. List of employees whose first name contains the character 'a'

SELECT e.*
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE '%a%';


27. List of managers who have more than four people reporting to them

SELECT Manager.BusinessEntityID AS ManagerID, COUNT(Employee.BusinessEntityID) AS NumberOfReports
FROM HumanResources.Employee AS Employee
JOIN HumanResources.Employee AS Manager ON Employee.ManagerID = Manager.BusinessEntityID
GROUP BY Manager.BusinessEntityID
HAVING COUNT(Employee.BusinessEntityID) > 4;


28. List of Orders and Product Names

SELECT soh.SalesOrderID, p.Name AS ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID;


29. List of orders placed by the best customer

WITH CustomerSales AS (
    SELECT c.CustomerID, SUM(sod.LineTotal) AS TotalSales
    FROM Sales.Customer c
    JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY c.CustomerID
),
BestCustomer AS (
    SELECT TOP 1 CustomerID
    FROM CustomerSales
    ORDER BY TotalSales DESC
)
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN BestCustomer bc ON soh.CustomerID = bc.CustomerID;


30. List of orders placed by customers who do not have a Fax number

SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE p.FaxNumber IS NULL;


31. List of postal codes where the product 'Tofu' was shipped

SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.S
::contentReference[oaicite:0]{index=0}

32.Product names shipped to France

SELECT DISTINCT p.Name
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';


33. ProductNames and Categories for the supplier 'Specialty Biscuits, Ltd.'

SELECT p.Name, pc.Name AS Category
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN Production.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.';


34. Products that were never ordered

SELECT * 
FROM Production.Product 
WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM Sales.SalesOrderDetail);


35. Products where units in stock < 10 and units on order = 0

SELECT * 
FROM Production.Product 
WHERE SafetyStockLevel < 10 AND ReorderPoint = 0;


36. Top 10 countries by sales

SELECT TOP 10 cr.Name AS Country, SUM(soh.TotalDue) AS Sales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY Sales DESC;


37. Number of orders each employee has taken for customers with CustomerIDs between A and AO

SELECT SalesPersonID, COUNT(*) AS OrdersCount
FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN 'A' AND 'AO'
GROUP BY SalesPersonID;


38. Order date of most expensive order

SELECT TOP 1 OrderDate
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;


39. Product name and total revenue from that product

SELECT p.Name, SUM(sod.LineTotal) AS Revenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name;


40. SupplierID and number of products offered

SELECT BusinessEntityID AS SupplierID, COUNT(*) AS ProductCount
FROM Production.ProductVendor
GROUP BY BusinessEntityID;


41. Top 10 customers based on their business

SELECT TOP 10 CustomerID, SUM(TotalDue) AS TotalBusiness
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY TotalBusiness DESC;


42. Total revenue of the company

SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;

