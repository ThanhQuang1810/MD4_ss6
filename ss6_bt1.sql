use ss6_bt1;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    contact_number VARCHAR(15) NOT NULL,
    birthdate DATE NOT NULL,
    is_active TINYINT(1) DEFAULT 1
);

CREATE TABLE items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    item_price DECIMAL(10, 2) NOT NULL,
    available_quantity INT NOT NULL,
    item_status TINYINT(1) DEFAULT 1
);

CREATE TABLE cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    item_id INT,
    quantity_ordered INT,
    total_price DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);

INSERT INTO customers (full_name, email, contact_number, birthdate, is_active) VALUES
('Tran Thi Thu', 'thu.tran@gmail.com', '0987654321', '1985-12-15', 1),
('Nguyen Van Hoang', 'hoang.nguyen@yahoo.com', '0976543210', '1992-05-20', 1),
('Pham Thi Minh', 'minh.pham@outlook.com', '0965432109', '1988-09-30', 1);

INSERT INTO items (item_name, item_price, available_quantity, item_status) VALUES
('Item A', 100.00, 50, 1),
('Item B', 200.00, 30, 1),
('Item C', 300.00, 20, 1);

INSERT INTO cart (customer_id, item_id, quantity_ordered, total_price) VALUES
(1, 1, 2, 200.00),
(2, 2, 1, 200.00),
(3, 3, 3, 900.00);

DELIMITER //

CREATE TRIGGER trg_update_total_price_on_item_price_change
AFTER UPDATE ON items
FOR EACH ROW
BEGIN
    UPDATE cart
    SET total_price = quantity_ordered * NEW.item_price
    WHERE item_id = NEW.item_id;
END;

//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_delete_cart_entries_on_item_delete
AFTER DELETE ON items
FOR EACH ROW
BEGIN
    DELETE FROM cart
    WHERE item_id = OLD.item_id;
END;

//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_update_quantity_on_cart_insert
AFTER INSERT ON cart
FOR EACH ROW
BEGIN
    UPDATE items
    SET available_quantity = available_quantity - NEW.quantity_ordered
    WHERE item_id = NEW.item_id;
END;

//

DELIMITER ;
