--List people's full name, fax, phonenumber, company's phonenumber, and company's faxnumber if they have any
--second version

USE WideWorldImporters;

SELECT a.FullName, a.PhoneNumber, a.FaxNumber, b.CompanyPhoneNumber, b.CompanyFaxNumber 
FROM Application.people AS a
LEFT JOIN                          --get all the people' info from people table 
(SELECT p.PersonID, c.PhoneNumber AS CompanyPhoneNumber, c.FaxNumber AS CompanyFaxNumber
FROM Application.People AS p
JOIN Sales.Customers AS c
ON p.PersonID = c.PrimaryContactPersonID
OR p.PersonID = c.AlternateContactPersonID
WHERE IsEmployee = 0               --get all the people working for customer company

UNION

SELECT PersonID,  PhoneNumber AS CompanyPhoneNumber, FaxNumber AS CompanyFaxNumber
FROM Application.People
WHERE IsEmployee = 1              --get all the people working for WWI company 

UNION 

SELECT p.PersonID,  s.PhoneNumber AS CompanyPhoneNumber, s.FaxNumber AS CompanyFaxNumber
FROM Application.People AS p
join Purchasing.Suppliers AS s
ON p.PersonID = s.PrimaryContactPersonID 
OR p.PersonID = s.AlternateContactPersonID
WHERE IsEmployee = 0 ) AS b       --get all the people working for supplier company 
ON a.PersonID = b.PersonID 
WHERE a.PhoneNumber IS NOT NULL  --filter out the 'Date Conversion Only' record from people table







