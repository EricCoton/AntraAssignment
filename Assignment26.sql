--Revisit your answer in (19). Convert the result into an XML string and save it to the server using TSQL
--FOR XML PATH.
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

SELECT
	FiscalYear AS [@Year], Clothing,[Computing Novelties] AS Computing_Novelties, 
	[Furry Footwear] AS [Furry_Footwear], Mugs, [Novelty Items] AS [Novelty_Items], 
	[Packaging Materials] AS [Packaging_Materials], 
	Toys, [T-Shirts], [USB Novelties] AS [USB_Novelties]
FROM vw_StockItem_Sold_By_Group
FOR XML PATH('FiscalYear'), ROOT('Sold_Total_By_Year')
