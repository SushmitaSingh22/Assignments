CREATE DATABASE Orgg;
USE Orgg;
CREATE TABLE Customers (
CustomerID INT PRIMARY KEY,
Name VARCHAR(255),
Email VARCHAR(255),
JoinDate DATE
);
CREATE TABLE Products (
ProductID INT PRIMARY KEY,
Name VARCHAR(255),
Category VARCHAR(255),
Price DECIMAL(10, 2)
);
CREATE TABLE Orders (
OrderID INT PRIMARY KEY,
CustomerID INT,
OrderDate DATE,
TotalAmount DECIMAL(10, 2),
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
CREATE TABLE OrderDetails (
OrderDetailID INT PRIMARY KEY,
OrderID INT,
ProductID INT,
Quantity INT,
PricePerUnit DECIMAL(10, 2),
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
INSERT INTO Customers (CustomerID, Name, Email, JoinDate) VALUES
(1, 'John Doe', 'johndoe@example.com', '2020-01-10'),
(2, 'Jane Smith', 'janesmith@example.com', '2020-01-15'),
(3, 'Harman Singh', 'harmansingh@example.com', '2020-02-11'),
(4, 'Tara joe', 'tarajoe@example.com', '2020-02-14'),
(5,'Sana Roy','sanaroy@example.com','2020-02-14'),
(6,'Sameer Sinha','sameersinha@example.com','2020-05-18'),
(7,'Devendra Singh','devendrasingh@exapmle.com','2020-01-21'),
(8,'David Jonhson','davidjonhsonexample.com','2020-03-07'),
(9,'Elijah Wilson','elijahwilson@example.com','2020-02-17'),
(10, 'Alice Johnson', 'alicejohnson@example.com', '2020-03-05');

INSERT INTO Products (ProductID, Name, Category, Price) VALUES
(61, 'Laptop', 'Electronics', 999.99),
(62, 'Smartphone', 'Electronics', 499.99),
(63,'Camera','Electronics', 1999.99),
(64,'Painting','Home Decor', 899.99),
(65,'Tablet','Electronics', 998.99),
(66,'Cover','Home Decor', 599.00),
(67,'Table','Furniture', 399.00),
(68,'Candles','Home Decor', 199.00),
(69,'Paint','Home Decor', 499.99),
(70, 'DeskLamp','Electronics', 29.99);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES
(11, 1, '2020-02-15', 1999.98),
(12, 2, '2020-02-17', 1797.00),
(13, 5,'2020-03-11', 3990.00),
(14, 6,'2020-04-22', 499.99),
(15, 10,'2020-01-12', 499.99),
(16, 5,'2020-05-21', 299.90),
(17, 2,'2020-03-30', 899.99),
(18, 4,'2020-09-08',995.00),
(19, 3,'2020-03-12',998.99),
(20, 5, '2020-03-21', 29.99);

INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity,
PricePerUnit) VALUES
(31, 11, 61, 2,999.99),
(32, 12, 66, 3, 599.00),
(33,13,67,10, 399.00),
(34,14,62,1, 499.99),
(35,15,62,1, 499.99),
(36,16,70,10, 29.99),
(37,17,64,1, 899.99),
(38,18,68,5, 199.00),
(39,19,65,1, 998.99),
(40,20,70,1, 29.99);


/*Basic Queries*/
-- 1.1

USE Orgg;
Select * FROM CUSTOMERS;

-- 1.2
SELECT * FROM PRODUCTS WHERE CATEGORY = 'Electronics';

-- 1.3
select sum(quantity) from orderdetails ;

-- 1.4
select * from orders order by OrderDate desc limit 1;

/*Joins and Relationships queries*/

-- 2.1
SELECT p.ProductID, p.Name AS ProductName , c.Name AS CustomerName
FROM products p
JOIN orderdetails od ON p.ProductID = od.ProductID
JOIN orders o ON od.OrderID = o.OrderID
JOIN customers c ON o.CustomerID = c.CustomerID;

-- 2.2

SELECT * FROM orders
WHERE OrderID IN (
SELECT OrderID
FROM orderdetails
GROUP BY OrderID
HAVING COUNT(DISTINCT ProductID) > 1
);

-- 2.3
SELECT CustomerID, SUM(TotalAmount) AS TotalSalesAmount
FROM orders
GROUP BY CustomerID;


/*Aggregation and Grouping queries*/

-- 3.1
SELECT p.Category, SUM(od.Quantity * od.PricePerUnit) AS TotalRevenue
FROM orders o
JOIN orderdetails od ON o.OrderID = od.OrderID
JOIN products p ON od.ProductID = p.ProductID
GROUP BY p.Category;

-- 3.2
SELECT AVG(TotalAmount) AS AverageOrderValue
FROM orders;

-- 3.3
SELECT DATE_FORMAT(OrderDate, '%Y-%m') AS Month, COUNT(OrderID) AS TotalOrders
FROM orders
GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY TotalOrders DESC
LIMIT 1; 


/*Subqueries and Nested Queries*/

-- 4.1
SELECT CustomerID, Name
FROM Customers
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders);


-- 4.2 
SELECT ProductID, Name
FROM Products
WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM OrderDetails);

-- 4.3
SELECT ProductID, SUM(Quantity) AS QuantitySold, SUM(Quantity * PricePerUnit) AS TotalRevenue
FROM OrderDetails
GROUP BY ProductID
ORDER BY QuantitySold DESC
LIMIT 3;


/*Date and Time Functions queries */

-- 5.1
SELECT *
FROM Orders
WHERE orderdate >= DATE_SUB(LAST_DAY(CURRENT_DATE), INTERVAL 1 MONTH) + INTERVAL 1 DAY
AND orderdate <= LAST_DAY(CURRENT_DATE);
  
-- 5.2
SELECT *
FROM Customers
ORDER BY joindate ASC
LIMIT 3;


/* Advanced Queries */

-- 6.1 
SELECT c.customerid, c.name, SUM(o.totalamount) AS total_spending,
RANK() OVER (ORDER BY SUM(o.totalamount) DESC) AS spending_rank
FROM Customers c
JOIN Orders o ON c.customerid = o.customerid
GROUP BY c.customerid, c.name
ORDER BY spending_rank;

-- 6.2 
SELECT Category, COUNT(*) AS total_orders
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY Category
ORDER BY total_orders DESC
LIMIT 1;

-- 6.3
SELECT
current_month.month AS current_month,
current_month.total_sales AS current_sales,
previous_month.month AS previous_month,
previous_month.total_sales AS previous_sales,
((current_month.total_sales - previous_month.total_sales) / previous_month.total_sales) * 100 AS growth_rate
FROM (SELECT DATE_FORMAT(o1.OrderDate, '%Y-%m') AS month,
SUM(od1.Quantity * od1.PricePerUnit) AS total_sales
FROM OrderDetails od1
JOIN Orders o1 ON od1.OrderID = o1.OrderID
WHERE o1.OrderDate >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
AND o1.OrderDate < CURRENT_DATE
GROUP BY DATE_FORMAT(o1.OrderDate, '%Y-%m')) AS current_month
LEFT JOIN (SELECT DATE_FORMAT(o2.OrderDate, '%Y-%m') AS month,
SUM(od2.Quantity * od2.PricePerUnit) AS total_sales
FROM OrderDetails od2
JOIN Orders o2 ON od2.OrderID = o2.OrderID
WHERE o2.OrderDate >= DATE_SUB(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH), INTERVAL 1 MONTH)
AND o2.OrderDate < DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
GROUP BY DATE_FORMAT(o2.OrderDate, '%Y-%m')) AS previous_month
ON current_month.month = DATE_SUB(previous_month.month, INTERVAL 1 MONTH);


/* Data manipulation and updates queries */

-- 7.1
INSERT INTO Customers (CustomerID, Name, Email, JoinDate) VALUES
(110, 'Johnson johnson', 'johnsonjohnson@example.com', '2020-01-13');

-- 7.2
update products 
set price = 300.00
where productID= '66';

/* complete*/
