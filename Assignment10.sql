/*List of Customers and their phone number, together with the primary contact person’s name, 
 to whom we did not sell more than 10  mugs (search by name) in the year 2016.**/

SELECT c.CustomerName, p.FullName, c.PhoneNumber
FROM Application.People AS p
JOIN Sales.Customers AS c
ON p.PersonID = c.PrimaryContactPersonID 
WHERE c.CustomerID NOT IN 
(SELECT CustomerID
        FROM (SELECT o.CustomerID,
              SUM(Quantity) AS TotalQuantity
                    FROM Sales.OrderLines as l
                    JOIN Sales.Orders as o
                    ON o.OrderID = l.OrderID 
                    WHERE l.Description LIKE '%mug%' 
					 AND o.OrderDate < '20170101' AND o.OrderDate >'20151231'
                    GROUP BY  o.CustomerID
                    HAVING SUM(Quantity) > 10) AS d)