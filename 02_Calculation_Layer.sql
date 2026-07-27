-- ============================================================
-- ERP ANALYTICS & OPERATIONS PLATFORM
-- Database: Olist Brazilian E-Commerce Public Dataset (MySQL)
-- ============================================================

-- ============================================================
-- LAYER 2: CALCULATION LAYER (Scalar Functions)
-- ============================================================

-- fn_CalculateLateDeliveryPenalty
drop function if exists fn_CalculateLateDeliveryPenalty;
delimiter //
create function fn_CalculateLateDeliveryPenalty (p_order_id VARCHAR(50) )
returns DECIMAL(10,2) 
DETERMINISTIC

BEGIN
	DECLARE v_estimate DATETIME; 
    DECLARE v_delivered DATETIME;
    
    SELECT order_estimated_delivery_date , order_delivered_customer_date INTO v_estimate , v_delivered  from orders where order_id = p_order_id;

    IF v_estimate is null or v_delivered is null or DATEDIFF(v_delivered ,v_estimate) <= 0 THEN
		return 0 ;	
	ELSE 
		Return DATEDIFF(v_delivered ,v_estimate) * 5 ;
	END IF ;

END//
delimiter ; 

-- fn_GetPaymentTier
drop function if exists fn_GetPaymentTier;
delimiter //
create function fn_GetPaymentTier (p_order_id VARCHAR(50)) 
returns VARCHAR(50) 
DETERMINISTIC

BEGIN
	DECLARE v_payment_value DECIMAL(10,2);
    Select SUM(payment_value) INTO v_payment_value from order_payments where order_id = p_order_id;
    
	IF v_payment_value IS NULL THEN
		RETURN 'Unknown';
	ELSEIF v_payment_value > 1000 THEN
		RETURN 'Gold';
	ELSEIF v_payment_value > 500 THEN
		RETURN 'Silver';
	ELSE
		RETURN 'Bronze';
	END IF;
    
END // 
delimiter ; 

-- fn_GetShippingDurationCategory
drop function if exists fn_GetShippingDurationCategory;
delimiter //
create function fn_GetShippingDurationCategory (p_order_id VARCHAR(50))
returns VARCHAR(50)
DETERMINISTIC

BEGIN
	DECLARE v_delivered_carrier DATETIME;
    DECLARE v_delivered_customer DATETIME;
	SELECT order_delivered_carrier_date, order_delivered_customer_date 	INTO v_delivered_carrier, v_delivered_customer FROM orders WHERE order_id = p_order_id;

    IF v_delivered_carrier is null or v_delivered_customer is null THEN
		RETURN 'Not Delivered';
	ELSEIF DATEDIFF(v_delivered_customer,v_delivered_carrier) <= 3 THEN
		RETURN 'Fast';
	ELSEIF DATEDIFF(v_delivered_customer,v_delivered_carrier) <= 7 THEN
		RETURN 'Normal'; 
	ELSE
		RETURN 'Slow';
	END IF;
	
END // 
delimiter ;