--List of customers to whom we made a sale prior to 2016 but no sale since 2016-01-01.
WITH Customers_2016(Customerid) AS
(SELECT CustomerID FROM Sales.Orders
WHERE OrderDate < '20160101' 
GROUP BY CustomerID

EXCEPT

SELECT Customerid  FROM Sales.Orders
WHERE OrderDate >'20151231'
GROUP BY CustomerID
)

SELECT c.Customerid, s.CustomerName
FROM Customers_2016 AS c 
join Sales.Customers AS s
ON c.Customerid = s.CustomerID