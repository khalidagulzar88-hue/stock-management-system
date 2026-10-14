Create DATABASE STOCK_management_system;
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT,
    UnitPrice DECIMAL(10,2),

    FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID)
);
CREATE TABLE SalesOrder (
    SalesOrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID INT,

    FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
);

CREATE TABLE SalesOrderLine (
    SalesOrderLineID INT PRIMARY KEY,
    SalesOrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10,2),

    FOREIGN KEY (SalesOrderID)
        REFERENCES SalesOrder(SalesOrderID),

    FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID)
);

CREATE TABLE Warehouse (
    WarehouseID INT PRIMARY KEY,
    WarehouseLocation VARCHAR(100) NOT NULL
);
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY,
    WarehouseID INT,
    ProductID INT,
    QuantityOnHand INT,

    FOREIGN KEY (WarehouseID)
        REFERENCES Warehouse(WarehouseID),

    FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID)
);
INSERT INTO Inventory
(InventoryID, WarehouseID, ProductID, QuantityOnHand)
VALUES
(1, 1, 1, 15),
(2, 1, 2, 8),
(3, 1, 3, 20),
(4, 2, 1, 10),
(5, 2, 4, 25),
(6, 2, 5, 7),
(7, 3, 2, 12),
(8, 3, 3, 5),
(9, 3, 4, 30);

INSERT INTO Warehouse (WarehouseID, WarehouseLocation)
VALUES
(1, 'Lahore'),
(2, 'Islamabad'),
(3, 'Karachi');

INSERT INTO Category (CategoryID, CategoryName)
VALUES
(1, 'Electronics'),
(2, 'Stationery'),
(3, 'Furniture');

INSERT INTO Customer (CustomerID, CustomerName)
VALUES
(1, 'Ali Khan'),
(2, 'Sara Ahmed'),
(3, 'Hamza Malik');

INSERT INTO Product
(ProductID, ProductName, CategoryID, UnitPrice)
VALUES
(1, 'Laptop', 1, 120000.00),
(2, 'Mouse', 1, 1500.00),
(3, 'Keyboard', 1, 3000.00),
(4, 'Notebook', 2, 250.00),
(5, 'Office Chair', 3, 18000.00);

INSERT INTO SalesOrder
(SalesOrderID, OrderDate, CustomerID)
VALUES
(101, '2026-10-01', 1),
(102, '2026-10-02', 2),
(103, '2026-10-03', 3);

INSERT INTO SalesOrderLine
(SalesOrderLineID, SalesOrderID, ProductID, Quantity, Price)
VALUES
(1, 101, 1, 1, 120000.00),
(2, 101, 2, 2, 1500.00),
(3, 102, 3, 1, 3000.00),
(4, 102, 4, 5, 250.00),
(5, 103, 5, 2, 18000.00),
(6, 103, 2, 3, 1500.00);

ALTER TABLE Product
ADD COLUMN DefaultSupplierID INT;

CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL
);

INSERT INTO Supplier (SupplierID, SupplierName)
VALUES
(1, 'Tech Supplies Pakistan'),
(2, 'Office World'),
(3, 'Furniture House');

ALTER TABLE Product
ADD CONSTRAINT fk_product_supplier
FOREIGN KEY (DefaultSupplierID)
REFERENCES Supplier(SupplierID);

UPDATE Product
SET DefaultSupplierID = 1
WHERE ProductID IN (1, 2, 3);

UPDATE Product
SET DefaultSupplierID = 2
WHERE ProductID = 4;

UPDATE Product
SET DefaultSupplierID = 3
WHERE ProductID = 5;


SELECT
    so.SalesOrderID,
    so.OrderDate,
    c.CustomerName,
    p.ProductName,
    cat.CategoryName,
    sol.Quantity,
    sol.Price,
    (sol.Quantity * sol.Price) AS LineTotal
FROM SalesOrder so
JOIN Customer c ON c.CustomerID = so.CustomerID
JOIN SalesOrderLine sol ON sol.SalesOrderID = so.SalesOrderID
JOIN Product p ON p.ProductID = sol.ProductID
JOIN Category cat ON cat.CategoryID = p.CategoryID
ORDER BY so.SalesOrderID, p.ProductName;


SELECT
    w.WarehouseLocation,
    p.ProductName,
    cat.CategoryName,
    i.QuantityOnHand
FROM Inventory i
JOIN Warehouse w ON w.WarehouseID = i.WarehouseID
JOIN Product p ON p.ProductID = i.ProductID
JOIN Category cat ON cat.CategoryID = p.CategoryID
ORDER BY w.WarehouseLocation, p.ProductName;

SELECT
    w.WarehouseLocation,
    p.ProductName,
    i.QuantityOnHand,
    s.SupplierName AS DefaultSupplier
FROM Inventory i
JOIN Warehouse w ON w.WarehouseID = i.WarehouseID
JOIN Product p ON p.ProductID = i.ProductID
LEFT JOIN Supplier s ON s.SupplierID = p.DefaultSupplierID
WHERE i.QuantityOnHand <= 10
ORDER BY i.QuantityOnHand ASC;


SELECT ProductName, UnitPrice
FROM Product
WHERE UnitPrice > (
    SELECT AVG(UnitPrice)
    FROM Product
);


SELECT ProductID, ProductName
FROM Product
WHERE ProductID IN (
    SELECT ProductID
    FROM SalesOrderLine
);

SELECT p.ProductID, p.ProductName
FROM Product p
WHERE NOT EXISTS (
    SELECT 1
    FROM SalesOrderLine sol
    WHERE sol.ProductID = p.ProductID
);


SELECT ProductName AS Name
FROM Product
UNION
SELECT CategoryName AS Name
FROM Category;

SELECT
    p.ProductName,
    SUM(sol.Quantity) AS TotalUnitsSold
FROM SalesOrderLine sol
JOIN Product p ON sol.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalUnitsSold DESC;




CREATE TABLE IF NOT EXISTS PurchaseOrderLine (
    PurchaseOrderLineID SERIAL PRIMARY KEY,
    PurchaseOrderID INTEGER REFERENCES PurchaseOrder(PurchaseOrderID),
    ProductID INTEGER REFERENCES Product(ProductID),
    Quantity INTEGER NOT NULL CHECK (Quantity > 0),
    UnitCost NUMERIC(10,2) NOT NULL CHECK (UnitCost >= 0)
);



SELECT * FROM PurchaseOrder;

SELECT * FROM Supplier;


INSERT INTO PurchaseOrder (SupplierID, OrderDate, Status)
VALUES (1, CURRENT_DATE, 'Pending')
RETURNING PurchaseOrderID;

INSERT INTO PurchaseOrderLine
    (PurchaseOrderID, ProductID, Quantity, UnitCost)
VALUES
    (1, 1, 10, 500.00),
    (1, 2, 5, 750.00),
    (1, 3, 8, 300.00);





SELECT
    s.SupplierID,
    s.SupplierName,
SUM(pol.Quantity * pol.UnitCost) AS TotalPurchaseAmount
FROM Supplier s
JOIN PurchaseOrder po ON s.SupplierID = po.SupplierID
JOIN PurchaseOrderLine pol ON po.PurchaseOrderID = pol.PurchaseOrderID
GROUP BY s.SupplierID, s.SupplierName
ORDER BY TotalPurchaseAmount DESC;


SELECT
    p.ProductID,
    p.ProductName,
    i.QuantityOnHand
FROM Product p
JOIN Inventory i ON p.ProductID = i.ProductID
WHERE i.QuantityOnHand < 50
ORDER BY i.QuantityOnHand ASC;


SELECT DISTINCT
    c.CustomerID,
    c.CustomerName
FROM Customer c
JOIN SalesOrder s ON c.CustomerID = s.CustomerID
JOIN SalesOrderLine sol ON s.SalesOrderID = sol.SalesOrderID
JOIN Product p ON sol.ProductID = p.ProductID
JOIN Category cat ON p.CategoryID = cat.CategoryID
WHERE cat.CategoryName = 'Electronics';




CREATE TABLE IF NOT EXISTS PurchaseOrderLine (
    PurchaseOrderLineID SERIAL PRIMARY KEY,
    PurchaseOrderID INTEGER REFERENCES PurchaseOrder(PurchaseOrderID),
    ProductID INTEGER REFERENCES Product(ProductID),
    Quantity INTEGER NOT NULL CHECK (Quantity > 0),
    UnitCost NUMERIC(10,2) NOT NULL CHECK (UnitCost >= 0)
);



SELECT * FROM PurchaseOrder;

SELECT * FROM Supplier;


INSERT INTO PurchaseOrder (SupplierID, OrderDate, Status)
VALUES (1, CURRENT_DATE, 'Pending')
RETURNING PurchaseOrderID;

INSERT INTO PurchaseOrderLine
    (PurchaseOrderID, ProductID, Quantity, UnitCost)
VALUES
    (1, 1, 10, 500.00),
    (1, 2, 5, 750.00),
    (1, 3, 8, 300.00);





SELECT
    s.SupplierID,
    s.SupplierName,
SUM(pol.Quantity * pol.UnitCost) AS TotalPurchaseAmount
FROM Supplier s
JOIN PurchaseOrder po ON s.SupplierID = po.SupplierID
JOIN PurchaseOrderLine pol ON po.PurchaseOrderID = pol.PurchaseOrderID
GROUP BY s.SupplierID, s.SupplierName
ORDER BY TotalPurchaseAmount DESC;

SELECT
    p.ProductName,
    SUM(sol.Quantity) AS TotalSold,
    AVG(sol.Quantity) AS AvgQuantity,
    MAX(sol.Quantity) AS MaxSale
FROM SalesOrderLine sol
JOIN Product p ON sol.ProductID = p.ProductID
GROUP BY p.ProductName;


SELECT DISTINCT c.CustomerName
FROM Customer c
JOIN SalesOrder s ON c.CustomerID = s.CustomerID
JOIN SalesOrderLine sol ON s.SalesOrderID = sol.SalesOrderID
WHERE sol.ProductID = (
    SELECT ProductID
    FROM Product
    WHERE UnitPrice = (
        SELECT MAX(UnitPrice)
        FROM Product
    )
);

SELECT
    p.ProductName,
    SUM(sol.Quantity) AS TotalSold,
    RANK() OVER (ORDER BY SUM(sol.Quantity) DESC) AS SalesRank
FROM SalesOrderLine sol
JOIN Product p ON sol.ProductID = p.ProductID
GROUP BY p.ProductName;

CREATE INDEX idx_product_category
ON Product(CategoryID);
