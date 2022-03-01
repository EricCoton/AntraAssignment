--Total quantity of stock items sold in 2015, group by country of manufacturing

USE WideWorldImporters;

WITH SourceTable AS 
(SELECT l.StockItemID, w.StockItemName, l.Quantity, 
JSON_VALUE(w.CustomFields, '$.CountryOfManufacture') AS Country
FROM Sales.OrderLines AS l
JOIN Sales.Orders AS o
ON o.OrderID = l.OrderID
JOIN Warehouse.StockItems AS w
ON l.StockItemID = W.StockItemID
WHERE o.OrderDate <'20160101' and o.OrderDate > '20141231')

SELECT  StockItemName, SUM(Quantity) AS total, Country
FROM SourceTable
GROUP BY GROUPING SETS((StockItemName, Country), Country)
ORDER BY Country
