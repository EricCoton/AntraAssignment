--List any orders that had more than one delivery attempt (located in invoice table).
select INVOICEID, JSON_VALUE(ReturnedDeliveryData, '$.Events[1].Event') AS Attemp,
JSON_VALUE(ReturnedDeliveryData, '$.Events[1].EventTime') AS AttemptTime,
JSON_VALUE(ReturnedDeliveryData, '$.Events[1].Status') AS DeliveredStatus,
JSON_VALUE(ReturnedDeliveryData, '$.Events[1].Comment') AS Note,
JSON_VALUE(ReturnedDeliveryData, '$.DeliveredWhen') AS DeliveredTime,
ConfirmedDeliveryTime

FROM sales.invoices
WHERE JSON_VALUE(ReturnedDeliveryData, '$.Events[1].EventTime') <> ConfirmedDeliveryTime