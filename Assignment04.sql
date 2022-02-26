--List of Stock Items and total quantity for each stock item in Purchase Orders in Year 2013.

USE WideWorldImporters;

SELECT l.StockItemID, l.Description, 
 SUM(l.ReceivedOuters)  AS ItemQuantity
FROM Purchasing.PurchaseOrderLines AS l
JOIN Purchasing.PurchaseOrders AS o
ON l.PurchaseOrderID = o.PurchaseOrderID
WHERE OrderDate > '20121231' AND OrderDate < '20140101'
GROUP BY l.StockItemID, l.Description
ORDER BY l.StockItemID
