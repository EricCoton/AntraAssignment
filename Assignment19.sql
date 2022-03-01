/*Create a view that shows the total quantity of stock items of each stock group sold (in orders) by year
2013-2017. [Year, Stock Group Name1, Stock Group Name2, Stock Group Name3, … ,Stock Group Name10] **/

USE WideWorldImporters;

IF OBJECT_ID(N'vw_StockItem_Sold_By_Group', N'V') IS NOT NULL
DROP VIEW vw_StockItem_Sold_By_Group
GO
CREATE VIEW vw_StockItem_Sold_By_Group
AS 
WITH SourceTable 
AS 
(SELECT SUM(l.Quantity) AS total, sg.StockGroupName, 
Year(o.OrderDate) AS FiscalYear
FROM Sales.OrderLines as l
JOIN Sales.Orders AS o
ON o.OrderID = l.OrderID
JOIN Warehouse.StockItemStockGroups AS si
ON l.StockItemID = si.StockItemID
JOIN Warehouse.StockGroups AS sg
ON si.StockGroupID = Sg.StockGroupID
GROUP BY sg.StockGroupName, Year(o.OrderDate)
)

SELECT FiscalYear, Clothing, [Computing Novelties], 
[Furry Footwear], Mugs, [Novelty Items], [Packaging Materials], 
Toys, [T-Shirts], [USB Novelties]
FROM SourceTable
PIVOT (
     MIN(total)
	 FOR StockGroupName IN (Clothing, [Computing Novelties], 
[Furry Footwear], Mugs, [Novelty Items], [Packaging Materials], 
Toys, [T-Shirts], [USB Novelties])) AS p
GO

--to test result
SELECT * FROM vw_StockItem_Sold_By_Group
