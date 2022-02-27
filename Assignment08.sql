--use CTE to get average processing days for each month by each state

USE WideWorldImporters;

WITH PivotSource                   --solution 1: hard coded pivot table
AS 
(SELECT DISTINCT s.StateProvinceName,LEFT(DATENAME(MM, o.OrderDate),3)  AS OrderByMonth, 
AVG(DATEDIFF(DAY, o.Orderdate, i.ConfirmedDeliveryTime))
OVER(PARTITION BY s.StateProvinceName, MONTH(o.orderdate))
AS AvgDate
FROM Sales.Invoices AS i
JOIN Sales.Orders AS o
ON i.OrderID = o.OrderID
JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
JOIN Application.Cities AS t
ON c.PostalCityID = t.CityID
JOIN Application.StateProvinces AS s
ON t.StateProvinceID = s.StateProvinceID )

--pivot table to make months become columns

SELECT *
FROM PivotSource
PIVOT (
MAX(AvgDATE)
FOR OrderByMonth in (Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec))
AS p
ORDER BY StateProvinceName
GO 

---use CTE to get average processing days for each month by each state

USE WideWorldImporters;                  --solution 2: using dynamic pivot table 
GO
DROP VIEW IF EXISTS VW_PivotSource
GO
CREATE VIEW VW_PivotSource 
AS 
SELECT DISTINCT s.StateProvinceName,LEFT(DATENAME(MM, o.OrderDate),3)  AS OrderByMonth,
AVG(DATEDIFF(DAY, o.Orderdate, i.ConfirmedDeliveryTime))
OVER(PARTITION BY s.StateProvinceName, MONTH(o.orderdate))
AS AvgDate
FROM Sales.Invoices AS i
JOIN Sales.Orders AS o
ON i.OrderID = o.OrderID
JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
JOIN Application.Cities AS t
ON c.PostalCityID = t.CityID
JOIN Application.StateProvinces AS s
ON t.StateProvinceID = s.StateProvinceID

DECLARE @sql AS NVARCHAR(5000), @columnName AS NVARCHAR(5000);
SELECT @columnName = STRING_AGG(QUOTENAME(OrderByMonth), ',') FROM VW_PivotSource;
SET @sql = N' SELECT * FROM VW_PivotSource PIVOT ( MAX(AvgDate) FOR OrderByMonth IN ( ' 
        + @columnName + N'))AS p ORDER BY StateProvinceName';



