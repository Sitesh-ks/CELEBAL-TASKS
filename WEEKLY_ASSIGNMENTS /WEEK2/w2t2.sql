1. Insert Order Details


CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount FLOAT = 0
AS
BEGIN
    DECLARE @ProductUnitPrice MONEY

    IF @UnitPrice IS NULL
        SELECT @UnitPrice = UnitPrice FROM Products WHERE ProductID = @ProductID

    IF @Discount IS NULL
        SET @Discount = 0

    DECLARE @Stock INT
    SELECT @Stock = UnitsInStock FROM Products WHERE ProductID = @ProductID

    IF @Stock < @Quantity
    BEGIN
        PRINT 'Failed to place the order. Not enough stock.'
        RETURN
    END

    INSERT INTO [Order Details](OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount)

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to insert the order detail.'
        RETURN
    END

    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID

    DECLARE @ReorderLevel INT
    SELECT @ReorderLevel = ReorderLevel FROM Products WHERE ProductID = @ProductID

    IF EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID AND UnitsInStock < @ReorderLevel)
        PRINT 'Warning: Product stock below reorder level!'
END


2. Update Order Details


CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
    UPDATE [Order Details]
    SET
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        Quantity = ISNULL(@Quantity, Quantity),
        Discount = ISNULL(@Discount, Discount)
    WHERE OrderID = @OrderID AND ProductID = @ProductID

    -- Optionally update UnitsInStock here if quantity changes
END


3. Get Orde rDetails


CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [Order Details] WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist.'
        RETURN 1
    END

    SELECT * FROM [Order Details] WHERE OrderID = @OrderID
END


4. Delete Order Details


CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [Order Details] WHERE OrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        PRINT 'Invalid parameters.'
        RETURN -1
    END

    DELETE FROM [Order Details]
    WHERE OrderID = @OrderID AND ProductID = @ProductID
END


1. Format to MM/DD/YYYY


CREATE FUNCTION fn_FormatDate_MMDDYYYY (@input DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN CONVERT(VARCHAR(10), @input, 101)
END


2. Format to YYYYMMDD


CREATE FUNCTION fn_FormatDate_YYYYMMDD (@input DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN CONVERT(VARCHAR(8), @input, 112)
END



1. view Customer Orders


CREATE VIEW vwCustomerOrders AS
SELECT
    c.CompanyName,
    o.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice) AS Total
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Customers c ON o.CustomerID = c.CustomerID


2. Yesterday Orders View


CREATE VIEW vwYesterdayOrders AS
SELECT *
FROM vwCustomerOrders
WHERE CAST(OrderDate AS DATE) = CAST(GETDATE() - 1 AS DATE)


3. My Products View


CREATE VIEW MyProducts AS
SELECT
    p.ProductID,
    p.ProductName,
    p.QuantityPerUnit,
    p.UnitPrice,
    s.CompanyName,
    c.CategoryName
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE p.Discontinued = 0



1. Instead Of Delete Trigger


CREATE TRIGGER trg_InsteadOfDeleteOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM [Order Details]
    WHERE OrderID IN (SELECT OrderID FROM DELETED)

    DELETE FROM Orders
    WHERE OrderID IN (SELECT OrderID FROM DELETED)
END


2. Stock Check Trigger


CREATE TRIGGER trg_CheckStockBeforeInsert
ON [Order Details]
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity INT, @Stock INT

    SELECT @ProductID = ProductID, @Quantity = Quantity FROM INSERTED
    SELECT @Stock = UnitsInStock FROM Products WHERE ProductID = @ProductID

    IF @Stock < @Quantity
    BEGIN
        PRINT 'Insufficient stock. Order cannot be placed.'
        RETURN
    END

    INSERT INTO [Order Details]
    SELECT * FROM INSERTED

    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID
END