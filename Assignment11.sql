--List all the cities that were updated after 2015-01-01.

USE WideWorldImporters

SELECT CityName, ValidFrom, ValidTo    --solution1 
From Application.Cities  AS c
WHERE validFrom > '20141231'
AND CityName IN (SELECT CityName FROM Application.Cities_Archive AS ca 
WHERE ValidTo > '20141231')
GO


SELECT distinct co.CityName, co.ValidFrom, co.ValidTo        --solution 2 
FROM Application.Cities AS co
JOIN Application.Cities_Archive AS ca 
ON co.CityID = co.CityID AND co.ValidFrom = ca.ValidTo
WHERE co.ValidFrom > '20141231'
