/*List all the Order Detail (Stock Item name, delivery address, delivery state, city, country, 
customer name, customer contact person name, customer phone, quantity) for the date of 2014-07-01. 
Info should be relevant to that date.**/

SELECT l.Description AS StockItemName, 
c.DeliveryAddressLine1 + c.DeliveryAddressLine1 AS DeliveryAddress, 
ac.CityName, st.StateProvinceName AS StateName, 
co.CountryName, c.CustomerName, 
p.FullName AS CustomerContactPersonName, 
c.PhoneNumber AS CustomerPhoneNumber, 
l.Quantity
FROM Sales.OrderLines AS l
JOIN Sales.Orders AS o
ON o.OrderID = l.OrderID
JOIN Sales.Customers AS c
ON o.CustomerID = C.CustomerID
JOIN Application.People AS p
ON c.PrimaryContactPersonID = p.PersonID
JOIN Application.Cities AS ac
ON c.PostalCityID = ac.CityID
JOIN Application.StateProvinces AS st
ON ac.StateProvinceID = st.StateProvinceID
JOIN Application.Countries AS co
ON co.CountryID = st.CountryID
WHERE o.OrderDate = '20140701'
