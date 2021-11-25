--use CTE to get average processing days for each month by each state
WITH PivotSouce 
AS 
(SELECT DISTINCT s.StateProvinceName,MONTH(o.OrderDate) AS Order_by_Month,
AVG(DATEDIFF(DAY, o.Orderdate, i.ConfirmedDeliveryTime))
OVER(PARTITION BY s.StateProvinceName, MONTH(o.orderdate))
AS Avg_Date
FROM Sales.Invoices AS i
JOIN Sales.Orders AS o
ON i.OrderID = o.OrderID
JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
JOIN Application.Cities AS t
ON c.PostalCityID = t.CityID
JOIN Application.StateProvinces AS s
ON t.StateProvinceID = s.StateProvinceID )

--pivot table to make months become columns

SELECT StateProvinceName,
[1] AS JAN, [2] AS FEB, [3] AS March, [4] AS APRIL, [5] AS MAY, 
[6] AS JUN, [7] AS JUL , [8] AS  AUG, [9] AS [SEP], [10] AS OCT, 
[11] AS NOV, [12] AS DEC
FROM PivotSouce
PIVOT (
MAX(AVG_DATE)
FOR ORDER_BY_MONTH in ([1], [2], [3], [4], [5], [6], [7], [8],[9],[10],[11],[12]))
AS p
ORDER BY StateProvinceName