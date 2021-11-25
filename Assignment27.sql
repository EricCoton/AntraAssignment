/*Create a new table called ods.ConfirmedDeviveryJson with 3 columns (id, date, value) . 
Create a stored procedure, input is a date. The logic would load invoice information (all columns) 
as well as invoice line information (all columns) and forge them into a JSON string and then insert 
into the new table just created. Then write a query to run the stored procedure for each DATE that 
customer id 1 got something delivered to him.**/

DROP TABLE IF EXISTS ods.ConfirmedDeliveryJson
CREATE TABLE ods.ConfirmedDeliveryJson
 ( ID INT, 
   [date] DATE, 
  [Value] VARCHAR(MAX)
)
GO
DROP PROC IF EXISTS spConfirmedOrderByDate
GO
CREATE PROC spConfirmedOrderByDate @date AS date = NULL
AS 
BEGIN 

--Get all the column names in table 'Invoices' different from table 'OrderLines' 
	DECLARE @columnName AS NVARCHAR(MAX)
	SELECT @columnName = COALESCE( @columnName + ',',  '') + QUOTENAME(COLUMN_NAME)
	FROM (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'Invoices'
		  Except SELECT  COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'InvoiceLines')
		  AS T

	--Using dynamic Sql to pull all the data from table 'orders' and table 'orderlines' into a table 
	--NewSourceTable for specific date only
	DECLARE @MySql AS NVARCHAR(MAX)
	DROP TABLE IF EXISTS NewSourceTable
	 SET @MySql =  N'SELECT l.*, ' + @columnName + 'INTO NewSourceTable
	  FROM Sales.Invoices AS i
	  JOIN Sales.InvoiceLines as l
	  ON i.InvoiceId = L.InvoiceID'
	

	EXEC sp_executesql @stat = @MySql

	--turn each row in NewSourceTable into a json object and load into the target table
	INSERT INTO ods.ConfirmedDeliveryJson(ID, [Date], [Value])
	SELECT o.CustomerID,  CAST(o.ConfirmedDeliveryTime AS Date) AS ORDERDATE, (SELECT * 
		   FROM NewSourceTable AS s
		   WHERE S.InvoiceLineID = o.InvoiceLineID
		   FOR JSON PATH 
		   ) AS jString
	FROM NewSourceTable AS o

	--return all the date which customer 1 got something if no specific input date
	IF @date IS NULL
	   SELECT DISTINCT [Date] From ods.ConfirmedDeliveryJson WHERE ID = 1 ORDER BY [Date]
	
	--return the date if cutomer 1 got something on the input date
    ELSE 
	   select DISTINCT [Date] from ods.ConfirmedDeliveryJson where ID = 1 AND [Date] = @date
END
GO

--test
exec spConfirmedOrderByDate '20140715'
exec spConfirmedOrderByDate 