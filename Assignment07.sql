--List of States and Avg dates for processing (confirmed delivery date – order date).
SELECT s.StateProvinceName,
AVG(DATEDIFF(DAY, o.Orderdate, i.ConfirmedDeliveryTime)) AS Avg_Date
FROM Sales.Invoices AS i
JOIN Sales.Orders AS o
ON i.OrderID = o.OrderID
JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
JOIN Application.Cities AS t
ON c.PostalCityID = t.CityID
JOIN Application.StateProvinces AS s
ON t.StateProvinceID = s.StateProvinceID
GROUP BY s.StateProvinceName