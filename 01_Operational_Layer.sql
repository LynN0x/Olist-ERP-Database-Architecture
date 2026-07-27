-- ============================================================
-- ERP ANALYTICS & OPERATIONS PLATFORM
-- Database: Olist Brazilian E-Commerce Public Dataset (MySQL)
-- ============================================================
 
 
-- ============================================================
-- LAYER 1: OPERATIONAL LAYER (Stored Procedures)
-- ============================================================

-- sp_ProcessPartialRefund
-- Processes a partial refund on an order's payment.
drop procedure if exists sp_ProcessPartialRefund;
delimiter //
create procedure sp_ProcessPartialRefund(
IN p_order_id VARCHAR(50),
IN p_refund_amount DECIMAL(10,2),
OUT p_TransactionStatus VARCHAR(150))
BEGIN
	DECLARE v_payment_value DECIMAL(10,2);
	Select payment_value INTO v_payment_value
    from order_payments
    where p_order_id = order_id;
	
    IF v_payment_value is null or v_payment_value= 0 THEN
		SET p_TransactionStatus = 'ERROR : Payment has not been received';
	ELSEIF p_refund_amount > v_payment_value THEN
		SET p_TransactionStatus = 'The refund amount exceeded the payment value.';
	ELSE
		START transaction ;
			UPDATE order_payments
			SET payment_value = payment_value - p_refund_amount
            where p_order_id = order_id;
            COMMIT ;
            SET p_TransactionStatus = 'SUCCESS : Return is completed';
	END IF ;
END //
delimiter ;

-- sp_IncreasePaymentValue
-- Increases an order's payment value by a given amount.
drop procedure if exists sp_IncreasePaymentValue;
delimiter //
create procedure sp_IncreasePaymentValue(	
IN p_order_id VARCHAR(50),
IN p_additional_amount DECIMAL(10,2),
OUT p_TransactionStatus VARCHAR(150)
)
BEGIN
	DECLARE v_payment_value DECIMAL(10,2);
    DECLARE v_order_exists INT;
    
	SELECT COUNT(*) INTO v_order_exists 
    FROM orders 
    WHERE order_id = p_order_id;
    
    Select payment_value INTO v_payment_value
    from order_payments
    where order_id = p_order_id;
    
	IF v_order_exists = 0 Then
		SET p_TransactionStatus = 'ERROR : There is not order';
    ELSEIF v_payment_value is null THEN
		SET p_TransactionStatus = 'ERROR : Payment has not been received';
	ELSEIF p_additional_amount <= 0 THEN 
		SET p_TransactionStatus = 'ERROR : Amount is negative';
	ELSE
		START transaction;
			Update order_payments
            SET payment_value = payment_value + p_additional_amount
            Where order_id = p_order_id;
            COMMIT ;
            SET p_TransactionStatus = 'SUCCESS: Payment value increased.';
	END IF ; 
END //
delimiter ;


-- sp_CancelOrderFullRefund
-- Cancels an order and resets its payment to zero.
drop procedure if exists sp_CancelOrderFullRefund;
delimiter //
create procedure sp_CancelOrderFullRefund (
IN p_order_id VARCHAR(50),
OUT p_TransactionStatus VARCHAR(150))
BEGIN
	DECLARE v_order_exists INT;
    DECLARE v_order_status VARCHAR(50);
    DECLARE v_total_canceled INT;
   Declare v_customer_id VARCHAR(50);
   
    SELECT customer_id INTO v_customer_id FROM orders WHERE order_id = p_order_id;
    Select order_status INTO v_order_status from orders	where order_id = p_order_id ;
    
	SELECT COUNT(*) INTO v_order_exists 
    from orders 
    where order_id = p_order_id ;
    
    Select COUNT(*) INTO v_total_canceled
    from orders
    where customer_id = v_customer_id 
		and order_status = 'canceled' ;
    
	IF v_order_exists = 0 Then
		SET p_TransactionStatus = 'ERROR : There is not order';
	ELSEIf v_order_status = 'canceled' THEN
		SET p_TransactionStatus = 'ERROR : Order already canceled';
	ELSEIf v_order_status = 'delivered' THEN
		SET p_TransactionStatus = 'ERROR : Order already delivered' ;
	ELSEIF v_total_canceled >= 3 THEN
		SET p_TransactionStatus = 'ERROR : 3 or more than 3 order canceled' ;
	ELSE
		Start transaction;
			Update orders
            SET order_status = 'canceled' 
            where order_id = p_order_id ;
            
            Update order_payments
            Set payment_value = 0
            where order_id = p_order_id ;
            COMMIT;
			SET p_TransactionStatus = 'SUCCESS: Order is canceled.';

    END IF;
END//