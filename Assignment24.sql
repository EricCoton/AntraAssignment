--Tranform the data from Json file and insert them into the related tables in database
SET NOCOUNT ON 
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

	--create 3 tables which has same structure with 3 target tables to hold the data about to be inserted
	DROP TABLE IF EXISTS #StockItemTemp
	DROP TABLE IF EXISTS #PurchaseOrderTemp
	DROP TABLE IF EXISTS #PurchaseOrderLinesTemp
	GO
	SELECT * INTO #StockItemTemp
	FROM Warehouse.StockItems  WHERE 1 <> 1 ;
	SELECT * INTO #PurchaseOrderTemp
	FROM Purchasing.PurchaseOrders WHERE 1 <> 1 ; 
	SELECT * INTO #PurchaseOrderLinesTemp
	FROM Purchasing.PurchaseOrderLines WHERE 1<>1 ;

	--find the missing data for column StockItemId in Warehouse.StockItems
	--StockItemName in StockItems table has a unique index, so in order to insert data into table, 
	--have to make each name unique in the ItemStagingTableNew 
	ALTER TABLE #ItemStagingTableNew ADD StockItemID INT NOT NULL DEFAULT(0)
	GO
	Declare @StockItemID AS INT --hold the stockItemId for Warehouse.StockItems if Exist	        
	SELECT @stockItemID = s.StockItemID
			FROM Warehouse.StockItems AS s 
			JOIN  #ItemStagingTableNew AS t
			ON s.StockItemName = t.StockItemName
	IF @StockItemID IS NULL
	   BEGIN 
	        DECLARE @var_string AS varchar(50), @var_int AS INT 
	        DECLARE update_cursor CURSOR FOR 
			SELECT StockItemID, StockItemName FROM #ItemStagingTableNew 
			ORDER BY StockItemID, StockItemName;
			DECLARE @First AS INT = 1;
			OPEN update_cursor 
			FETCH NEXT FROM update_cursor INTO @var_int,  @var_string
			WHILE @@FETCH_STATUS = 0 
			   BEGIN 
					UPDATE #ItemStagingTableNew 
					SET StockItemID = NEXT VALUE FOR Sequences.StockItemID, 
						StockItemName = StockItemName + CAST(@First AS VARCHAR(2))
			        WHERE CURRENT OF update_Cursor
					SET @First += 1
					FETCH NEXT FROM update_Cursor INTO @var_int, @var_string
			   END 
			CLOSE update_Cursor
			DEALLOCATE update_Cursor 
		END 
       ELSE 
	     BEGIN 
		   DECLARE update_cursor CURSOR FOR 
			SELECT StockItemID, StockItemName FROM #ItemStagingTableNew 
			ORDER BY StockItemID, StockItemName;
			DECLARE @Second AS INT = 0;
			OPEN update_cursor 
			FETCH NEXT FROM update_cursor
			WHILE @@FETCH_STATUS = 0 
			   BEGIN 
					UPDATE #ItemStagingTableNew 
					SET StockItemID =  @StockItemID + @Second, 
						StockItemName = StockItemName + CAST(@First AS VARCHAR(2))
			        WHERE CURRENT OF update_Cursor
					SET @First += 1
					FETCH NEXT FROM update_Cursor
			   END 
			CLOSE update_Cursor
			DEALLOCATE update_Cursor 
		END 
		   	
	--Insert all the data to Warehouse.StockItems table and #StockItemTemp
	INSERT INTO  warehouse.stockItems(StockItemID, StockItemName, SupplierID, 
	UnitPackageID, OuterPackageID, Brand, LeadTimeDays, QuantityPerOuter, IsChillerStock,
	TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, 
	CustomFields, LastEditedBy)
	OUTPUT 
	inserted.* 
	INTO #StockItemTemp
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
	WHERE SupplierID IN (5, 7)  --5,7 are only two supplier in Json file and both points to same contactpersonID
	
	UPDATE #ItemStagingTableNew
	SET ContactPersonID = @ContactPersonID

	SELECT @deliveryMethodID = DeliveryMethodID
	FROM Application.DeliveryMethods
	WHERE DeliveryMethodName = 'POST' --'Post' is the only deliveryMethod in Json file
	UPDATE #ItemStagingTableNew
	SET DeliveryMethodID = @deliveryMethodID
	
	/* add the PurchaseOrderID column to ItemStagingTableNew, and use cusor to update purchaseOrderID, then 
	insert all the data into Purchasing.purchaseOrders table  and #purchaseorderTemp table**/
	ALTER TABLE #ItemStagingTableNew ADD PurchaseOrderID INT NOT NULL DEFAULT(1);
	GO
	DECLARE @orderID AS INT 
	DECLARE update_cursor CURSOR FOR 
			SELECT PurchaseOrderID FROM #ItemStagingTableNew 	
			ORDER BY PurchaseOrderID;
			OPEN update_cursor 
			FETCH NEXT FROM update_cursor INTO @orderID
			WHILE @@FETCH_STATUS = 0 
			   BEGIN 
					UPDATE #ItemStagingTableNew 
					SET PurchaseOrderID = NEXT VALUE FOR Sequences.PurchaseOrderID 
			        WHERE CURRENT OF update_Cursor
					FETCH NEXT FROM update_Cursor INTO @orderID
			   END 
			CLOSE update_Cursor
			DEALLOCATE update_Cursor 
        INSERT INTO Purchasing.PurchaseOrders(PurchaseOrderid, SupplierID, OrderDate, DeliveryMethodID, ContactPersonID, 
	SupplierReference, IsOrderFinalized, LastEditedBy)
	OUTPUT 
	inserted.* 
	INTO #PurchaseOrderTemp
	SELECT PurchaseOrderID, Supplier, OrderDate, DeliveryMethodID, ContactPersonID,  SupplierReference, 0, 1	           
	FROM #ItemStagingTableNew;

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
	
	--insert all the data to Purchasing.purchaseOrderLines table and #purchaseOrderLinesTemp table
	INSERT INTO Purchasing.PurchaseOrderLines(PurchaseOrderID, StockItemID, OrderedOuters, Description,
	ReceivedOuters, PackageTypeID, IsOrderLineFinalized, LastEditedBy)
	OUTPUT 
	inserted.*
	INTO #PurchaseOrderLinesTemp
	SELECT PurchaseOrderID, StockItemID, OuterPackageId, StockItemName, OuterPackageId, PackageTypeID, 0, 1
	FROM #ItemStagingTableNew

	--test result 
        SELECT * FROM #StockItemTemp
	SELECT * FROM #PurchaseOrderTemp
	SELECT * FROM #PurchaseOrderLinesTemp
	
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

	SET NOCOUNT OFF 



	

	
    
    



	
