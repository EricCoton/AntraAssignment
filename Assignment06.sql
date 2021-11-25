--List of stock items that are not sold to the state of Alabama and Georgia in 2014
SELECT StockItemID
FROM Sales.OrderLines AS l
join Sales.Orders AS o
ON l.OrderID = o.OrderID
WHERE o.OrderDate > '20131231' and o.OrderDate < '20150101' 


EXCEPT

SELECT StockItemID
FROM Sales.OrderLines AS l
JOIN Sales.Orders AS o
ON l.OrderLineID = o.OrderID
JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
JOIN Application.Cities AS t
ON c.PostalCityID = t.CityID
JOIN Application.StateProvinces AS s
ON t.StateProvinceID = s.StateProvinceID 
AND s.StateProvinceName IN ('Alabama', 'Georgia')
WHERE o.OrderDate > '20131231' and o.OrderDate < '20150101'


