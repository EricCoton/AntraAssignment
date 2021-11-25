/*Create a new table called ods.Orders. Create a stored procedure, with proper error handling 
and transactions, that input is a date; when executed, it would find orders of that day, calculate
order total, and save the information (order id, order date, order total, customer id) into the 
new table. If a given date is already existing in the new table, throw an error and roll back. 
Execute the stored procedure 5 times using different dates. **/

DROP TABLE IF EXISTS ods.Orders
DROP SCHEMA IF EXISTS ods
GO
CREATE SCHEMA ods
GO 

CREATE TABLE ods.Orders
(CustomerID int, 
 OrderID int, 
 OrderDate Date , 
 Total Decimal(18,2), 
 )

DROP PROC IF EXISTS spOrderDetail
GO

CREATE PROC  spOrderDetail @OrderDate Date
AS 
BEGIN 
    DECLARE @ExistedRows AS INT
	SET @ExistedRows = (SELECT Count(*) from ods.Orders
	WHERE OrderDate = @OrderDate)  --check if @orderdate arleady existed in the target table
	BEGIN TRY 
		BEGIN TRAN 
			INSERT INTO ods.Orders(CustomerID, OrderID, OrderDate, Total)
			SELECT c.CustomerID, o.OrderID, o.OrderDate,
			SUM((l.UnitPrice * l.Quantity)) AS Total
			FROM Sales.OrderLines AS l
			JOIN Sales.Orders AS o
			ON o.OrderID = l.OrderID
			JOIN Sales.Customers AS c
			ON c.CustomerID = o.CustomerID
			WHERE o.OrderDate = @OrderDate 
			GROUP BY c.CustomerID, o.OrderID, o.OrderDate

			IF @ExistedRows > 0
			   RAISERROR('The OrderDate already existed', 16, 1)
	
			PRINT 'Orders in ' +cast( @OrderDate as varchar(20)) + ' are successfully inserted'
	
		COMMIT TRAN 
	END TRY

	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		 BEGIN 
			 PRINT ERROR_MESSAGE()
			 ROLLBACK TRAN 
		 END 
	END CATCH 

END 

GO

/*exec spOrderDetail '20130101'
exec spOrderDetail '20140701'
exec spOrderDetail '20160701'
exec spOrderDetail '20131211'
exec spOrderDetail '20130101'**/