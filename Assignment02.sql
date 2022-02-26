--list customer name if primary contact peope have the same phonenumber with company

USE WideWorldImporters;

SELECT c.CustomerName 
FROM Sales.Customers as C
join Application.People as A
On c.PrimaryContactPersonID = a.PersonID
Where C.PhoneNumber = a.PhoneNumber

