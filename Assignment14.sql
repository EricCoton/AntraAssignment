/*List of Cities in the US and the stock item that the city got the most deliveries
in 2016. If the city did not purchase any stock items in 2016, print “No Sales”. **/

WITH ItemForCity AS 
(SELECT l.StockItemID, l.Description, c.PostalCityID, SUM(Quantity) AS Total, 
RANK() OVER(PARTITION BY PostalCityID ORDER BY SUM(Quantity)DESC ) AS StockItemRank
FROM Sales.Orderlines AS l
JOIN Sales.Orders AS o
ON l.OrderID = o.OrderID
JOIN Sales.Customers AS c
ON o.CustomerID = c.CustomerID
WHERE o.OrderDate <'20170101' AND o.OrderDate > '20151231'
GROUP BY c.PostalCityID,l.StockItemID, l.Description)

SELECT ac.CityID, ac.CityName, co.CountryName, ISNULL(Description, 'No Sales') AS ItemName
FROM Application.Cities AS ac
LEFT JOIN (
SELECT  Description, PostalCityID FROM ItemForCity  WHERE ItemForCity.StockItemRank=1) AS i
ON i.PostalCityID = ac.CityID 
JOIN Application.StateProvinces AS st
ON ac.StateProvinceID = st.StateProvinceID
JOIN Application.Countries AS co
ON st.CountryID = co.CountryID
WHERE co.CountryName = 'United States'
ORDER BY CityID





