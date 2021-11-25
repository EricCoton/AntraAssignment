--List all the cities that were updated after 2015-01-01.
SELECT CityName, ValidFrom, ValidTo
From Application.Cities
FOR SYSTEM_TIME ALL
WHERE validFrom > '20141231 23:59:59.9999999'
