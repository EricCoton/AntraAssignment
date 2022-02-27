/* List of stock item groups and total quantity purchased, total quantity sold, 
and the remaining stock quantity (quantity purchased – quantity sold)**/

USE WideWorldImporters

SELECT p.StockItemID, p.Description,
SUM(p.OrderedOuters) AS TotalQuantityBought, 
SUM(o.Quantity)  AS TotalQuantitySold, 
SUM(p.OrderedOuters) - SUM(o.Quantity) AS RemainingQuantity
FROM Purchasing.PurchaseOrderLines AS p
JOIN Sales.OrderLines AS o
ON o.StockItemID = p.StockItemID
GROUP BY p.StockItemID, p.Description
ORDER BY StockItemID
