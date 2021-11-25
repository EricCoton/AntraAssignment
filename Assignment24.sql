--Tranform the data from Json file and insert them into the related tables in database
DECLARE @JSON AS Varchar(max) = N'{
   "PurchaseOrders":[
      {
         "StockItemName":"Panzer Video Game",
         "Supplier":"7",
         "UnitPackageId":"1",
         "OuterPackageId":[6, 7 ],
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-01",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"WWI2308"
      },
      {
         "StockItemName":"Panzer Video Game",
         "Supplier":"5",
         "UnitPackageId":"1",
         "OuterPackageId":"7",
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-025",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"269622390"
      }
   ]
}';

IF ISJSON(@JSON) = 1         --test whether JSON type or not 
	BEGIN
	   --create well formed json file which every key has the same data type
	    DECLARE @JSONTemp AS VARCHAR(MAX) = @JSON
		
		SET @JSON = JSON_MODIFY(@JSON, '$.PurchaseOrders[0].OuterPackageId', '6')
		SET @JSONTemp = JSON_MODIFY(@JSONTemp, '$.PurchaseOrders[0].OuterPackageId', '7')
	    
		--pull all the data from json file to a table
		DROP TABLE IF EXISTS #ItemStagingTable
		DROP TABLE IF EXISTS #ItemStagingTableNew
		
		SELECT * INTO #ItemStagingTable
		FROM 
		(SELECT * 
	    FROM OPENJSON(@JSON, '$.PurchaseOrders')
		WITH 
		(StockItemName Varchar(50) '$.StockItemName', 
		"Supplier" Int '$.Supplier', 
         "UnitPackageId" Int '$.UnitPackageId', 
         "OuterPackageId" Int '$.OuterPackageId', 
         "Brand" Varchar(50) '$.Brand',
         "LeadTimeDays" Int '$.LeadTimeDays', 
         "QuantityPerOuter"Int '$.QuantityPerOuter', 
         "TaxRate" Decimal(18,3) '$.TaxRate',
         "UnitPrice" Decimal(18,2) '$.UnitPrice', 
         "RecommendedRetailPrice" Decimal(18,2) '$.RecommendedRetailPrice', 
         "TypicalWeightPerUnit" Decimal(18,3) '$.TypicalWeightPerUnit', 
         "CountryOfManufacture" Varchar(20) '$.CountryOfManufacture',
         "Range" Varchar(50) '$.Range',
         "OrderDate" DateTime '$.OrderDate',
         "DeliveryMethod" Varchar(50) '$.DeliveryMethod', 
         "ExpectedDeliveryDate" Date '$.ExpectedDeliveryDate', 
         "SupplierReference" Varchar(50) '$.SupplierReference'
		)

		UNION 

		SELECT * 
		FROM OPENJSON(@JSONTEMP, '$.PurchaseOrders')
        WITH 
		(StockItemName Varchar(50) '$.StockItemName', 
		"Supplier" Int '$.Supplier', 
         "UnitPackageId" Int '$.UnitPackageId', 
         "OuterPackageId" Int '$.OuterPackageId', 
         "Brand" Varchar(50) '$.Brand',
         "LeadTimeDays" Int '$.LeadTimeDays', 
         "QuantityPerOuter"int '$.QuantityPerOuter', 
         "TaxRate" Decimal(18,3) '$.TaxRate',
         "UnitPrice" Decimal(18,2) '$.UnitPrice', 
         "RecommendedRetailPrice" Decimal(18,2) '$.RecommendedRetailPrice', 
         "TypicalWeightPerUnit" Decimal(18,3) '$.TypicalWeightPerUnit', 
         "CountryOfManufacture" Varchar(20) '$.CountryOfManufacture',
         "Range" Varchar(50) '$.Range',
         "OrderDate" DateTime '$.OrderDate',
         "DeliveryMethod" Varchar(50) '$.DeliveryMethod', 
         "ExpectedDeliveryDate" Date '$.ExpectedDeliveryDate', 
         "SupplierReference" Varchar(50) '$.SupplierReference'
		)) AS t
	END
	
	--form a json data type column from related columns of ItemStagingTable and migrate all the data to a new table
	
	SELECT *, 
	(SELECT s.CountryofManufacture, s.[Range]
	FROM #ItemStagingTable as s 
	WHERE s.supplier = t.supplier AND s.UnitPackageid = t.UnitPackageid and S.outerPackageid = t.outerpackageid
	FOR JSON PATH) AS CustomFields 
	INTO #ItemStagingTableNew 
	FROM #ItemStagingTable AS t;

	--find the missing data for column StockItemId in Warehouse.StockItems
	ALTER TABLE #ItemStagingTableNew ADD StockItemID INT NOT NULL DEFAULT(0)
	GO
	Declare @StockItemID AS INT, --hold the stockItemId for Warehouse.StockItems 
	        @temp AS INT = (SELECT top 1 StockItemId from Warehouse.StockItems order by StockItemID DESC)
	SELECT @stockItemID = s.StockItemID
			FROM Warehouse.StockItems AS s 
			JOIN  #ItemStagingTableNew AS t
			ON s.StockItemName = t.StockItemName
	IF @StockItemID IS NULL
	  SET  @StockItemID = @temp + 1
	
	/*using cursor to create a unique StockItemId and StockItemName, because Warehouse.StockItems 
	has a unique index on the StockItemName**/
    DECLARE update_Cursor CURSOR FOR 
	SELECT StockItemID, StockItemName FROM #ItemStagingTableNew;
	OPEN update_Cursor 
	FETCH FROM update_Cursor
	Declare @First AS INT = 0
	WHILE @@FETCH_STATUS = 0 	     
	BEGIN	    
		UPDATE #ItemStagingTableNew
		SET StockItemID = @StockItemId +@First, StockItemName = StockItemName + CAST(@First AS VARCHAR(5))
		WHERE CURRENT OF update_Cursor 
		SET @First += 1
		FETCH NEXT FROM update_Cursor
	END 
	CLOSE update_Cursor
	DEALLOCATE update_Cursor

	--Insert all the data to Warehouse.StockItems table
	INSERT INTO  warehouse.stockItems(StockItemID, StockItemName, SupplierID, 
	UnitPackageID, OuterPackageID, Brand, LeadTimeDays, QuantityPerOuter, IsChillerStock,
	TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, 
	CustomFields, LastEditedBy)
	SELECT StockItemID, StockItemName, Supplier, UnitPackageID, OuterPackageID, 
	Brand, LeadTimeDays, QuantityPerOuter,0, TaxRate, UnitPrice, RecommendedRetailPrice, 
	TypicalWeightPerUnit, 
	CustomFields, 1
	from #ItemStagingTableNew 
	
	--Find the missing data for ContactPersonId and DiliveryMethodID in PurchaseOrders
	ALTER TABLE #ItemStagingTableNew add ContactPersonID INT NOT NULL DEFAULT(0)
	ALTER TABLE #ItemStagingTableNew add DeliveryMethodID INT NOT NULL DEFAULT(0)
	GO
	DECLARE @ContactPersonID AS INT, @deliveryMethodID AS INT
	SELECT @ContactPersonID = ContactPersonID 
	FROM Purchasing.PurchaseOrders
	WHERE SupplierID IN (5, 7)  --5,7 are only two supplier in Json file and points to same contactpersonID
	
	UPDATE #ItemStagingTableNew
	SET ContactPersonID = @ContactPersonID

	SELECT @deliveryMethodID = DeliveryMethodID
	FROM Application.DeliveryMethods
	WHERE DeliveryMethodName = 'POST' --'Post' is the only deliveryMethod in Json file
	UPDATE #ItemStagingTableNew
	SET DeliveryMethodID = @deliveryMethodID
	
	/* add the PurchaseOrderID column to ItemStagingTableNew, then 
	insert all the data into Purchasing.purchaseOrders table and at the time, get
	the PurchaseOrderID column value back from PurchaseOrders table to update the 
	PurchaseOrderID column in ItemStaingTableNew **/
	ALTER TABLE #ItemStagingTableNew ADD PurchaseOrderID INT NOT NULL DEFAULT(1);
	DROP TABLE IF EXISTS #TempForPurchaseOrder
	CREATE TABLE #TempForPurchaseOrder
	(purchaseOrderID int, 
	SupplierID int)
	GO
    INSERT INTO Purchasing.PurchaseOrders(SupplierID, OrderDate, DeliveryMethodID, ContactPersonID, 
	            SupplierReference, IsOrderFinalized, LastEditedBy)
	OUTPUT
	     inserted.PurchaseOrderID, inserted.SupplierID
		 INTO #TempForPurchaseOrder
	SELECT Supplier, OrderDate, DeliveryMethodID, ContactPersonID,  SupplierReference, 0, 1	           
	FROM #ItemStagingTableNew;

    --the purchaseOrder from the Purchasing.PurchaseOrders table for each row in ItemStageingTableNew
	Declare @orderID AS INT 

	SELECT @orderID = purchaseOrderID FROM #TempForPurchaseOrder WHERE SupplierID = 5
	UPDATE #ItemStagingTableNew
	SET PurchaseOrderID = @orderID
	WHERE supplier  = 5
   

	SELECT @orderID = purchaseOrderID FROM #TempForPurchaseOrder WHERE SupplierID = 7
	UPDATE #ItemStagingTableNew
	SET PurchaseOrderID = @orderID
	WHERE OuterPackageID = 6 AND supplier =7
    DELETE FROM #TempForPurchaseOrder WHERE purchaseOrderID = @orderID

	SELECT  @orderID = purchaseOrderID FROM #TempForPurchaseOrder WHERE SupplierID = 7
	UPDATE #ItemStagingTableNew
	SET PurchaseOrderID = @orderID
	WHERE OuterPackageID = 7 and supplier = 7 
	
	--find the missing data for column PackageTypeID in Purchasing.PurchaseOrderlines table
	--since the item is video game, so assume the packageType name is box
	--add the PurchaseOrderID column to ItemStagingTableNew 
	ALTER TABLE #ItemStagingTableNew ADD PackageTypeID INT NOT NULL DEFAULT(0)
	GO
	Declare @PackageTypeID AS INT 
	SELECT @PackageTypeID = PackageTypeID 
	FROM Warehouse.PackageTypes  
	WHERE PackageTypeName LIKE 'Box'
	
	UPDATE #ItemStagingTableNew
	SET PackageTypeID = @PackageTypeID
	
	--insert all the data to Purchasing.purchaseOrderLines table
	INSERT INTO Purchasing.PurchaseOrderLines(PurchaseOrderID, StockItemID, OrderedOuters, Description,
	ReceivedOuters, PackageTypeID, IsOrderLineFinalized, LastEditedBy)
	SELECT PurchaseOrderID, StockItemID, OuterPackageId, StockItemName, OuterPackageId, PackageTypeID, 0, 1
	FROM #ItemStagingTableNew

	--clean up.delete all the inserted data. 
	DELETE FROM o
	FROM Purchasing.PurchaseOrderLines AS o
	JOIN #ItemStagingTableNew AS i
	ON i.StockItemID = O.StockItemID

	DELETE FROM o
	FROM Purchasing.PurchaseOrders AS o
	JOIN #ItemStagingTableNew AS i
	ON i.PurchaseOrderID = o.PurchaseOrderID

	DELETE FROM s
	FROM Warehouse.StockItems AS s
	JOIN #ItemStagingTableNew AS i
	ON i.StockItemName = S.StockItemName

	

	
    
    



	