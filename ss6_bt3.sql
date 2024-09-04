create database ss6_bt3;
use ss6_bt3;

CREATE TABLE AccountHolders (
    AccountID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100) NOT NULL,
    HomeAddress VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(11) NOT NULL UNIQUE,
    BirthDate DATE NOT NULL,
    AccountStatus BIT,
    CurrentBalance DOUBLE DEFAULT 0.0
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    SenderAccountID INT,
    ReceiverAccountID INT,
    AmountTransferred DOUBLE,
    TransactionDate DATE,
    FOREIGN KEY (SenderAccountID) REFERENCES AccountHolders(AccountID),
    FOREIGN KEY (ReceiverAccountID) REFERENCES AccountHolders(AccountID)
);
DELIMITER //

CREATE PROCEDURE PerformTransfer(
    IN p_sender_id INT, 
    IN p_receiver_id INT, 
    IN p_transfer_amount DOUBLE
)
BEGIN
    DECLARE v_sender_balance DOUBLE;
    
    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- Lấy số dư tài khoản của người gửi
    SELECT CurrentBalance INTO v_sender_balance 
    FROM AccountHolders 
    WHERE AccountID = p_sender_id;

    -- Kiểm tra số dư và thực hiện chuyển khoản
    IF v_sender_balance >= p_transfer_amount THEN
        -- Trừ số tiền từ tài khoản người gửi
        UPDATE AccountHolders 
        SET CurrentBalance = CurrentBalance - p_transfer_amount 
        WHERE AccountID = p_sender_id;

        -- Cộng số tiền vào tài khoản người nhận
        UPDATE AccountHolders 
        SET CurrentBalance = CurrentBalance + p_transfer_amount 
        WHERE AccountID = p_receiver_id;

        -- Ghi lại giao dịch
        INSERT INTO Transactions (SenderAccountID, ReceiverAccountID, AmountTransferred, TransactionDate)
        VALUES (p_sender_id, p_receiver_id, p_transfer_amount, CURDATE());

        -- Xác nhận giao dịch
        COMMIT;
    ELSE
        -- Hủy giao dịch nếu số dư không đủ
        ROLLBACK;
    END IF;
END //

DELIMITER ;

CALL PerformTransfer(1, 2, 100.0);
