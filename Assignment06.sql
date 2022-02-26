--List of stock items that are not sold to the state of Alabama and Georgia in 2014

USE WideWorldImporters;

SELECT StockItemID         --solution 1 with set operator
FROM Warehouse.StockItems

EXCEPT

SELECT StockItemID
FROM Sales.OrderLines AS l
JOIN Sales.Orders AS o
ON l.OrderLineID = o.OrderID
JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
JOIN Application.Cities AS t
ON c.PostalCityID = t.CityID
JOIN Application.StateProvinces AS s
ON t.StateProvinceID = s.StateProvinceID 
WHERE s.StateProvinceName IN ('Alabama', 'Georgia') AND o.OrderDate > '20131231' AND o.OrderDate < '20150101'


SELECT StockItemID         --solution 2 with subquery 
FROM Warehouse.StockItems
WHERE StockItemID NOT IN 
(SELECT StockItemID
FROM Sales.OrderLines AS l
JOIN Sales.Orders AS o
ON l.OrderLineID = o.OrderID
JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
JOIN Application.Cities AS t
ON c.PostalCityID = t.CityID
JOIN Application.StateProvinces AS s
ON t.StateProvinceID = s.StateProvinceID 
AND s.StateProvinceName IN ('Alabama', 'Georgia')
WHERE o.OrderDate > '20131231' and o.OrderDate < '20150101')






