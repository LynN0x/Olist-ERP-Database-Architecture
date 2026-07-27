-- ============================================================
-- ERP ANALYTICS & OPERATIONS PLATFORM
-- Database: Olist Brazilian E-Commerce Public Dataset (MySQL)
-- ============================================================

-- ============================================================
-- LAYER 3: AUDIT LAYER (Triggers)
-- ============================================================

-- Order_Payments table + trg_PreventNegativePayment
DROP TRIGGER IF EXISTS trg_PreventNegativePayment;
delimiter //
create trigger trg_PreventNegativePayment
BEFORE UPDATE ON order_payments
FOR EACH ROW
BEGIN 
	IF NEW.payment_value < 0 or NEW.payment_value is null THEN
		Signal SQLSTATE '45000'
			SET message_text = 'ERROR : Payment value can not be negative or null value';
	END IF;

END //
delimiter ;

-- Order_Payments table + trg_LogPaymentValueChange
DROP TABLE IF EXISTS payment_log;
CREATE TABLE payment_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    old_payment_value DECIMAL(10,2),
    new_payment_value DECIMAL(10,2),
    log_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_LogPaymentValueChange;
delimiter //
create trigger trg_LogPaymentValueChange 
AFTER UPDATE ON Order_Payments
FOR EACH ROW
BEGIN
	IF OLD.payment_value <> NEW.payment_value THEN
		INSERT INTO payment_log (
		order_id,
		old_payment_value,
		new_payment_value
		)
		VALUES (
		NEW.order_id,
		OLD.payment_value,
		NEW.payment_value
		);
    END IF;
END //
delimiter ;

-- Orders Table + trg_LogOrderStatusChange
Drop table if exists order_status_log;
Create Table order_status_log ( 
	log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    old_order_status VARCHAR(50),
    new_order_status VARCHAR(50),
	log_date DATETIME DEFAULT CURRENT_TIMESTAMP

);

drop trigger if exists trg_LogOrderStatusChange;
delimiter //
create trigger trg_LogOrderStatusChange
AFTER UPDATE ON Orders
For each row
BEGIN
	IF Old.order_status <> New.order_status THEN
			INSERT INTO order_status_log (
		order_id,
		old_order_status,
		new_order_status
		)
			VALUES (
		NEW.order_id,
		OLD.order_status,
		NEW.order_status
		);
	END IF ;
		
END//
delimiter ;