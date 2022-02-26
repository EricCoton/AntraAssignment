--List of stock items that have at least 10 characters in description

USE WideWorldImporters;

SELECT DISTINCT s.StockItemID, l.Description
FROM Warehouse.StockItems AS s
JOIN Purchasing.PurchaseOrderLines AS l 
ON l.StockItemID = s.StockItemID
WHERE LEN(l.Description) >=10; 
