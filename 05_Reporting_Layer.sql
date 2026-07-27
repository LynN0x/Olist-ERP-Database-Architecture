-- ============================================================
-- LAYER 5: REPORTING LAYER (Views)
-- ============================================================

-- vw_CustomerSegmentation
DROP VIEW IF EXISTS vw_CustomerSegmentation;
Create View vw_CustomerSegmentation AS

WITH OrderTotals AS (
    Select order_id, SUM(payment_value) AS order_total
    From order_payments
    Group By order_id
),
Order_Process AS (
Select
c.customer_unique_id,
COUNT(DISTINCT o.order_id) AS Total_Order,
SUM(ot.order_total) AS Total_Spent,
ROUND(SUM(ot.order_total) / COUNT(DISTINCT o.order_id), 2) AS Average_PaymentAmount,
CASE
	WHEN SUM(ot.order_total) >= 1000 THEN 'Gold'
	WHEN SUM(ot.order_total) >= 300 THEN 'Silver'
	ELSE 'Bronze'
END AS Rank_
From customers c
join orders o on c.customer_id = o.customer_id
join OrderTotals ot on ot.order_id = o.order_id
WHERE o.order_status <> 'canceled'
Group By c.customer_unique_id
)
Select *,
AVG(Total_Spent) OVER() AS Overall_Average,
CASE
	WHEN Total_Spent >= AVG(Total_Spent) OVER() THEN 'Above Average'
	ELSE 'Below Average'
END AS Spending_Level
From Order_Process;


-- vw_CategoryCancellationRate
DROP VIEW IF EXISTS vw_CategoryCancellationRate;
Create View vw_CategoryCancellationRate AS
with Total_Canceled_Table as(
select
	product_category_name_english as product_category, 
	SUM(CASE WHEN order_status = 'canceled' then 1 else 0 end) as Total_Canceled ,
    COUNT(DISTINCT o.order_id ) as Total_Order
from products p

join order_items oi on p.product_id = oi.product_id
join orders o on oi.order_id = o.order_id
join product_category_name_translation eng_translation on eng_translation.product_category_name = p.product_category_name

group by product_category_name_english
HAVING COUNT(*) >= 50)

Select 
	product_category , 
	Total_Order , 
	Total_Canceled , 
	ROUND(Total_Canceled/Total_Order * 100, 2) as Canceled_Ratio
from Total_Canceled_Table
order by Canceled_Ratio DESC;


-- vw_CustomerOrderFrequency
DROP VIEW IF EXISTS vw_CustomerOrderFrequency;
CREATE VIEW vw_CustomerOrderFrequency AS
SELECT * FROM (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        COUNT(*) OVER (PARTITION BY c.customer_unique_id) AS total_order,
        DATEDIFF(o.order_purchase_timestamp, LAG(o.order_purchase_timestamp) OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp)
            
        ) AS days_between_orders
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
) t
WHERE total_order > 1
ORDER BY customer_unique_id, order_purchase_timestamp;


-- vw_ShippingRoutePerformance
DROP VIEW IF EXISTS vw_ShippingRoutePerformance;
CREATE VIEW vw_ShippingRoutePerformance AS
SELECT
    s.seller_city,
    c.customer_city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date)), 2) AS avg_shipping_days,
    CASE
        when AVG(DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date)) <= 3 THEN 'Fast'
        when AVG(DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date)) <= 7 THEN 'Normal'
        else 'Slow'
    end as route_speed_category
FROM orders o
join order_items oi ON oi.order_id = o.order_id
join sellers s ON s.seller_id = oi.seller_id
join customers c ON c.customer_id = o.customer_id
where o.order_delivered_carrier_date IS NOT NULL
  and o.order_delivered_customer_date IS NOT NULL
GROUP BY s.seller_city, c.customer_city
having COUNT(DISTINCT o.order_id) >= 10
order by avg_shipping_days DESC;
