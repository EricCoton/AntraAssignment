--List of StockItems that the company purchased more than sold in the year of 2015

USE WideWorldImporters;

WITH Item_Purchased_2015(StockItemID, Descrition, ItemQuantity)
AS
(SELECT l.StockItemID, l.Description, 
 SUM(l.ReceivedOuters) 
	 AS ItemQuantity
FROM Purchasing.PurchaseOrderLines AS l
JOIN Purchasing.PurchaseOrders AS o
ON l.PurchaseOrderID = o.PurchaseOrderID
WHERE OrderDate > '20141231' AND OrderDate < '20160101'
GROUP BY l.StockItemID, l.Description
), 

Item_Sold_2015(StockItemID, Descrition, ItemQuantity)
AS
(SELECT l.StockItemID, l.Description,
 SUM(l.Quantity) AS ItemQuantity
FROM Sales.OrderLines AS l
JOIN Sales.Orders AS o
ON l.OrderID = o.OrderID
WHERE o.OrderDate > '20141231' AND o.OrderDate < '20160101'
GROUP BY l.StockItemID, l.Description
)

SELECT p.StockItemID 
FROM Item_Purchased_2015 AS p
JOIN Item_Sold_2015 AS s
ON p.StockItemID = s.StockItemID 
WHERE p.ItemQuantity > s.ItemQuantity
ORDER BY StockItemID
