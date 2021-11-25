--List of stock items that have at least 10 characters in description
SELECT StockItemID, StockItemName
FROM Warehouse.StockItems
WHERE len(StockItemName) > 10
GROUP BY StockItemID, StockItemName
ORDER BY StockItemID 