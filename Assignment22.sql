/*Create a new table called ods.StockItem. It has following columns: [StockItemID], 
[StockItemName] ,[SupplierID] ,[ColorID] ,[UnitPackageID] ,[OuterPackageID] ,[Brand] ,[Size] ,
[LeadTimeDays] ,[QuantityPerOuter] ,[IsChillerStock] ,[Barcode] ,[TaxRate]  ,[UnitPrice],
[RecommendedRetailPrice] ,[TypicalWeightPerUnit] ,[MarketingComments]  ,[InternalComments], 
[CountryOfManufacture], [Range], [Shelflife]. Migrate all the data in the original stock item table.**/

USE WideWorldImporters;

DROP TABLE IF EXISTS ods.StockItem
SELECT  
[StockItemID], [StockItemName] ,[SupplierID] ,[ColorID] ,
[UnitPackageID] ,[OuterPackageID] ,[Brand] ,[Size] ,
[LeadTimeDays] ,[QuantityPerOuter] ,[IsChillerStock] ,
[Barcode] ,[TaxRate]  ,[UnitPrice],[RecommendedRetailPrice] ,
[TypicalWeightPerUnit] ,[MarketingComments]  ,
[InternalComments], 
JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOFManufacutre, 
JSON_VALUE(CustomFields,'$.Range') AS Range, 
JSON_VALUE(CustomFields,'$.ShelfLife') AS ShelfLife
INTO ods.StockItem
FROM Warehouse.StockItems

--test 
SELECT * FROM ods.StockItem
