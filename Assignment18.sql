/*Create a view that shows the total quantity of stock items of each stock group sold (in orders) 
by year 2013-2017. [Stock Group Name, 2013, 2014, 2015, 2016, 2017] **/

USE WideWorldImporters;

IF OBJECT_ID(N'vw_StockGroup_Sold_By_Year', N'V') IS NOT NULL
DROP VIEW vw_StockGroup_Sold_By_Year
GO
CREATE VIEW vw_StockGroup_Sold_By_Year
AS 
WITH SouceTable as 
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

SELECT StockGroupName, [2013], [2014], [2015], [2016], [2017]
FROM SouceTable
PIVOT (MAX(total)
      FOR FiscalYear in ([2013], [2014], [2015], [2016], [2017])
	  ) AS p
GO
SELECT * FROM vw_StockGroup_Sold_By_Year

