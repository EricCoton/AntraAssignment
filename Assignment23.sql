/* Rewrite your stored procedure in (21). Now with a given date, it should wipe out 
all the order data prior to the input date and load the order data that was placed in
the next 7 days following the input date.**/

DROP TABLE IF EXISTS ods.NewOrders
CREATE TABLE ods.NewOrders
(CustomerID int, 
 OrderID int, 
 OrderDate Date , 
 Total Decimal(18,2), 
)
DROP PROC IF EXISTS spMultiOrders
GO
CREATE PROC  spMultiOrders @OrderDate Date
AS 
BEGIN 
    BEGIN TRY
		BEGIN TRAN 
			DELETE FROM ods.NewOrders
			WHERE  OrderDate < @OrderDate

			INSERT INTO ods.NewOrders(CustomerID, OrderID, OrderDate, Total)
			SELECT c.CustomerID, o.OrderID, o.OrderDate,
			SUM((l.UnitPrice * l.Quantity)) AS Total
			FROM Sales.OrderLines AS l
			JOIN Sales.Orders AS o
			ON o.OrderID = l.OrderID
			JOIN Sales.Customers AS c
			ON c.CustomerID = o.CustomerID
			WHERE o.OrderDate > @OrderDate AND 
			o.OrderDate < CAST(DATEADD(DAY, 8, @OrderDate) AS Date)
			GROUP BY c.CustomerID, o.OrderID, o.OrderDate
		COMMIT TRAN
	END TRY

	BEGIN CATCH
	IF @@TRANCOUNT > 0
	   PRINT @@TRANCOUNT
	   ROLLBACK TRAN
	   PRINT ERROR_MESSAGE()
	END CATCH
END 
GO

/*select * from ods.neworders
exec spMultiOrders '20140901'**/