create database ss6_bt2;
use ss6_bt2;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    home_address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) NOT NULL UNIQUE,
    birth_date DATE NOT NULL,
    is_active TINYINT(1) DEFAULT 1
);
CREATE TABLE inventory (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    item_price DECIMAL(10, 2) NOT NULL,
    available_stock INT NOT NULL,
    item_status TINYINT(1) DEFAULT 1
);
CREATE TABLE cart_items (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    item_id INT,
    quantity INT,
    total_price DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (item_id) REFERENCES inventory(item_id)
);
START TRANSACTION;
SET @customer_id = 2;
SET @item_id = 2;
SET @quantity_to_add = 5;

-- Kiểm tra xem sản phẩm có đủ số lượng trong kho không
SET @current_stock = (SELECT available_stock FROM inventory WHERE item_id = @item_id);
IF @current_stock >= @quantity_to_add THEN
    -- Cập nhật số lượng tồn kho
    UPDATE inventory
    SET available_stock = available_stock - @quantity_to_add
    WHERE item_id = @item_id;
    
    -- Thêm sản phẩm vào giỏ hàng
    INSERT INTO cart_items (customer_id, item_id, quantity, total_price)
    VALUES (@customer_id, @item_id, @quantity_to_add, (SELECT item_price FROM inventory WHERE item_id = @item_id) * @quantity_to_add);
    COMMIT;
ELSE
    -- Nếu không đủ số lượng thì rollback
    ROLLBACK;
END IF;

START TRANSACTION;
SET @cart_item_to_remove = 2;

-- Lấy thông tin về sản phẩm và số lượng từ giỏ hàng
SELECT item_id, quantity INTO @item_id_to_update, @quantity_to_restore 
FROM cart_items 
WHERE cart_item_id = @cart_item_to_remove;

-- Xóa sản phẩm từ giỏ hàng
DELETE FROM cart_items WHERE cart_item_id = @cart_item_to_remove;

-- Cập nhật lại số lượng tồn kho
UPDATE inventory 
SET available_stock = available_stock + @quantity_to_restore 
WHERE item_id = @item_id_to_update;

COMMIT;
