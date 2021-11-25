--List people's full name, fax, phonenumber, company's phonenumber, and company's faxnumber if any
--Get data for people not working for client company
SELECT FullName, p.PhoneNumber AS PhoneNumber,p.FaxNumber AS FaxNumber, c.PhoneNumber AS CompanyPhoneNumber, c.FaxNumber AS CompanyFaxNumber
FROM Application.People AS p
LEFT JOIN Sales.Customers AS c
ON p.PersonID = c.PrimaryContactPersonID


UNION 

--Get data for WWI employee
SELECT FullName, PhoneNumber, FaxNumber, PhoneNumber AS CompanyPhoneNumber, FaxNumber AS CompanyFaxNumber
FROM Application.People
WHERE IsEmployee = 1

UNION 

--Get data for people working for supply company
SELECT FullName, p.PhoneNumber AS PhoneNumber,p.FaxNumber AS FaxNumber, s.PhoneNumber AS CompanyPhoneNumber, s.FaxNumber AS CompanyFaxNumber
FROM Application.People AS p
join Purchasing.Suppliers AS s
ON p.PersonID = s.PrimaryContactPersonID


