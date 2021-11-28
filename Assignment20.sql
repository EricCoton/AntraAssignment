/* Create a function, input: order id; return: total of that order. List invoices and use that 
function to attach the order total to the other fields of invoices. **/
DROP FUNCTION IF EXISTS fn_Total_By_OrderId
GO
CREATE FUNCTION fn_Total_By_OrderId(@OrderID INT)
RETURNS DECIMAL(18, 2)
BEGIN 
DECLARE @TotalAmount AS DECIMAL(18,2)
SELECT @TotalAmount = SUM((l.UnitPrice * l.Quantity)) 
FROM Sales.OrderLines AS l
JOIN Sales.Orders AS o
ON o.OrderID = l.OrderID
JOIN Sales.Customers AS c
ON c.CustomerID = o.CustomerID
WHERE o.OrderID = @OrderID
GROUP BY c.CustomerID, o.OrderID, o.OrderDate
RETURN @TotalAmount 
END
GO 

SELECT *, dbo.fn_Total_By_OrderId(orderID) AS totalAmount
FROM Sales.Invoices

