-- ============================================================
-- LAYER 4: PERFORMANCE LAYER (Indexes)
-- ============================================================

-- idx_orders_purchase_timestamp
create INDEX idx_orders_purchase_timestamp on orders (order_purchase_timestamp);
EXPLAIN SELECT * FROM orders ORDER BY order_purchase_timestamp DESC LIMIT 100;
