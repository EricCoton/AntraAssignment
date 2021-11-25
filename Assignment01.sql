--List people's full name, fax, phonenumber, company's phonenumber, and company's faxnumber if any

SELECT a.FullName, a.PhoneNumber, a.FaxNumber, b.CompanyPhoneNumber, b.CompanyFaxNumber 
FROM Application.people AS a
LEFT JOIN     --get all the people
(SELECT p.PersonID, FullName, p.PhoneNumber AS PhoneNumber,p.FaxNumber AS FaxNumber, c.PhoneNumber AS CompanyPhoneNumber, c.FaxNumber AS CompanyFaxNumber
FROM Application.People AS p
JOIN Sales.Customers AS c
ON p.PersonID = c.PrimaryContactPersonID
WHERE IsEmployee = 0               --people working for customer company
UNION

SELECT PersonID, FullName, PhoneNumber, FaxNumber, PhoneNumber AS CompanyPhoneNumber, FaxNumber AS CompanyFaxNumber
FROM Application.People
WHERE IsEmployee = 1              --people working for WWI

UNION 

SELECT p.PersonID, FullName, p.PhoneNumber AS PhoneNumber,p.FaxNumber AS FaxNumber, s.PhoneNumber AS CompanyPhoneNumber, s.FaxNumber AS CompanyFaxNumber
FROM Application.People AS p
join Purchasing.Suppliers AS s
ON p.PersonID = s.PrimaryContactPersonID
WHERE IsEmployee = 0 ) AS b       --people working for supplier company 
ON a.PersonID = b.PersonID 
WHERE a.PhoneNumber IS NOT NULL 





