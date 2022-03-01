--List all stock items that are manufactured in China. (Country of Manufacture)

USE WideWorldImporters;

SELECT * FROM
(SELECT StockItemID, StockItemName, 
JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS Country
FROM Warehouse.StockItems ) AS temp
WHERE Country = 'China'
