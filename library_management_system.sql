-- Library Management System Database
-- Created by Ian Otieno
-- This SQL script creates a complete database for managing a library system

-- Drop database if it exists and create a new one
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- Create Members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    address VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    membership_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_status ENUM('active', 'expired', 'suspended') NOT NULL DEFAULT 'active',
    INDEX idx_member_name (last_name, first_name)
) COMMENT 'Stores information about library members';

-- Create Authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    INDEX idx_author_name (last_name, first_name)
) COMMENT 'Stores information about book authors';

-- Create Publishers table
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255),
    UNIQUE KEY unique_publisher_name (name)
) COMMENT 'Stores information about book publishers';

-- Create Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    parent_category_id INT NULL,
    description VARCHAR(255),
    UNIQUE KEY unique_category_name (name),
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
) COMMENT 'Stores book categories with hierarchical structure';

-- Create Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    publisher_id INT,
    publication_date DATE,
    edition VARCHAR(20),
    pages INT,
    language VARCHAR(50) DEFAULT 'English',
    description TEXT,
    cover_image_url VARCHAR(255),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    INDEX idx_book_title (title)
) COMMENT 'Stores information about books';

-- Create Book_Authors junction table (Many-to-Many relationship)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    role ENUM('primary', 'co-author', 'editor', 'translator') DEFAULT 'primary',
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
) COMMENT 'Junction table for many-to-many relationship between books and authors';

-- Create Book_Categories junction table (Many-to-Many relationship)
CREATE TABLE book_categories (
    book_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
) COMMENT 'Junction table for many-to-many relationship between books and categories';

-- Create Book_Items table (represents physical copies of books)
CREATE TABLE book_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    location VARCHAR(50) NOT NULL,
    status ENUM('available', 'loaned', 'reserved', 'lost', 'under_maintenance') NOT NULL DEFAULT 'available',
    acquisition_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    price DECIMAL(10, 2),
    condition ENUM('new', 'good', 'fair', 'poor') NOT NULL DEFAULT 'new',
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    INDEX idx_book_item_status (status)
) COMMENT 'Stores information about individual physical copies of books';

-- Create Loans table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    return_date DATETIME NULL,
    renewal_count INT NOT NULL DEFAULT 0,
    FOREIGN KEY (item_id) REFERENCES book_items(item_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    INDEX idx_loan_dates (loan_date, due_date, return_date)
) COMMENT 'Stores information about book loans';

-- Create Reservations table
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE NOT NULL,
    status ENUM('pending', 'fulfilled', 'cancelled', 'expired') NOT NULL DEFAULT 'pending',
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    INDEX idx_reservation_status (status)
) COMMENT 'Stores information about book reservations';

-- Create Fines table
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    member_id INT NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL,
    fine_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    payment_date DATE NULL,
    payment_amount DECIMAL(10, 2) NULL,
    fine_status ENUM('pending', 'paid', 'waived') NOT NULL DEFAULT 'pending',
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    INDEX idx_fine_status (fine_status)
) COMMENT 'Stores information about fines for overdue books';

-- Create Staff table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    INDEX idx_staff_name (last_name, first_name)
) COMMENT 'Stores information about library staff';

-- Create Events table
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(100) NOT NULL,
    max_attendees INT,
    staff_id INT,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    INDEX idx_event_date (event_date)
) COMMENT 'Stores information about library events';

-- Create Event_Registrations junction table
CREATE TABLE event_registrations (
    event_id INT NOT NULL,
    member_id INT NOT NULL,
    registration_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('registered', 'attended', 'no_show') DEFAULT 'registered',
    PRIMARY KEY (event_id, member_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
) COMMENT 'Junction table for many-to-many relationship between events and members';

-- Create Audit_Log table for tracking important changes
CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action_type ENUM('insert', 'update', 'delete') NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    staff_id INT,
    action_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    INDEX idx_audit_timestamp (action_timestamp)
) COMMENT 'Tracks changes made to important tables for auditing purposes';

-- Create Views

-- View for available books
CREATE VIEW available_books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
    p.name AS publisher,
    COUNT(bi.item_id) AS available_copies
FROM 
    books b
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN book_items bi ON b.book_id = bi.book_id AND bi.status = 'available'
GROUP BY 
    b.book_id, b.title, b.isbn, p.name;

-- View for overdue loans
CREATE VIEW overdue_loans AS
SELECT 
    l.loan_id,
    b.title,
    bi.barcode,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.email AS member_email,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue
FROM 
    loans l
JOIN book_items bi ON l.item_id = bi.item_id
JOIN books b ON bi.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE 
    l.return_date IS NULL AND l.due_date < CURRENT_DATE
ORDER BY 
    days_overdue DESC;

-- View for member activity
CREATE VIEW member_activity AS
SELECT 
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    m.email,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    SUM(CASE WHEN l.return_date IS NULL AND l.due_date < CURRENT_DATE THEN 1 ELSE 0 END) AS current_overdue,
    COUNT(DISTINCT r.reservation_id) AS total_reservations,
    SUM(CASE WHEN f.fine_status = 'pending' THEN f.fine_amount ELSE 0 END) AS pending_fines
FROM 
    members m
LEFT JOIN loans l ON m.member_id = l.member_id
LEFT JOIN reservations r ON m.member_id = r.member_id
LEFT JOIN fines f ON m.member_id = f.member_id
GROUP BY 
    m.member_id, member_name, m.email;

-- Create Stored Procedures

-- Procedure to check out a book
DELIMITER //
CREATE PROCEDURE check_out_book(
    IN p_item_id INT,
    IN p_member_id INT,
    IN p_loan_days INT
)
BEGIN
    DECLARE item_status VARCHAR(20);
    DECLARE member_status VARCHAR(20);
    DECLARE pending_fines DECIMAL(10, 2);
    
    -- Check if book item is available
    SELECT status INTO item_status FROM book_items WHERE item_id = p_item_id;
    
    -- Check member status
    SELECT membership_status INTO member_status FROM members WHERE member_id = p_member_id;
    
    -- Check for pending fines
    SELECT COALESCE(SUM(fine_amount), 0) INTO pending_fines 
    FROM fines 
    WHERE member_id = p_member_id AND fine_status = 'pending';
    
    -- Validate conditions
    IF item_status != 'available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book item is not available for checkout';
    ELSEIF member_status != 'active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member account is not active';
    ELSEIF pending_fines > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member has pending fines that must be paid first';
    ELSE
        -- Create loan record
        INSERT INTO loans (item_id, member_id, loan_date, due_date)
        VALUES (p_item_id, p_member_id, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_DATE, INTERVAL p_loan_days DAY));
        
        -- Update book item status
        UPDATE book_items SET status = 'loaned' WHERE item_id = p_item_id;
        
        SELECT 'Book checked out successfully' AS message;
    END IF;
END //
DELIMITER ;

-- Procedure to return a book
DELIMITER //
CREATE PROCEDURE return_book(
    IN p_item_id INT
)
BEGIN
    DECLARE loan_id_val INT;
    DECLARE member_id_val INT;
    DECLARE due_date_val DATE;
    DECLARE days_overdue INT;
    DECLARE fine_amount_val DECIMAL(10, 2);
    
    -- Get loan information
    SELECT loan_id, member_id, due_date 
    INTO loan_id_val, member_id_val, due_date_val
    FROM loans 
    WHERE item_id = p_item_id AND return_date IS NULL;
    
    IF loan_id_val IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No active loan found for this item';
    ELSE
        -- Update loan with return date
        UPDATE loans SET return_date = CURRENT_TIMESTAMP WHERE loan_id = loan_id_val;
        
        -- Update book item status
        UPDATE book_items SET status = 'available' WHERE item_id = p_item_id;
        
        -- Check if book is overdue and create fine if necessary
        SET days_overdue = DATEDIFF(CURRENT_DATE, due_date_val);
        
        IF days_overdue > 0 THEN
            -- Calculate fine (e.g., $0.50 per day)
            SET fine_amount_val = days_overdue * 0.50;
            
            -- Create fine record
            INSERT INTO fines (loan_id, member_id, fine_amount, fine_date, fine_status)
            VALUES (loan_id_val, member_id_val, fine_amount_val, CURRENT_DATE, 'pending');
            
            SELECT CONCAT('Book returned successfully. Overdue fine of $', fine_amount_val, ' applied.') AS message;
        ELSE
            SELECT 'Book returned successfully' AS message;
        END IF;
    END IF;
END //
DELIMITER ;

-- Procedure to renew a book loan
DELIMITER //
CREATE PROCEDURE renew_book_loan(
    IN p_loan_id INT,
    IN p_additional_days INT
)
BEGIN
    DECLARE current_due_date DATE;
    DECLARE renewal_count_val INT;
    DECLARE max_renewals INT DEFAULT 2;
    
    -- Get current loan information
    SELECT due_date, renewal_count 
    INTO current_due_date, renewal_count_val
    FROM loans 
    WHERE loan_id = p_loan_id AND return_date IS NULL;
    
    IF current_due_date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No active loan found with this ID';
    ELSEIF renewal_count_val >= max_renewals THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maximum number of renewals reached for this loan';
    ELSE
        -- Update due date and increment renewal count
        UPDATE loans 
        SET due_date = DATE_ADD(current_due_date, INTERVAL p_additional_days DAY),
            renewal_count = renewal_count + 1
        WHERE loan_id = p_loan_id;
        
        SELECT CONCAT('Loan renewed successfully. New due date: ', 
                     DATE_FORMAT(DATE_ADD(current_due_date, INTERVAL p_additional_days DAY), '%Y-%m-%d')) AS message;
    END IF;
END //
DELIMITER ;

-- Create Triggers

-- Trigger to update book status when a reservation is fulfilled
DELIMITER //
CREATE TRIGGER after_reservation_update
AFTER UPDATE ON reservations
FOR EACH ROW
BEGIN
    IF NEW.status = 'fulfilled' AND OLD.status != 'fulfilled' THEN
        -- Find an available copy of the book
        DECLARE available_item_id INT;
        
        SELECT item_id INTO available_item_id
        FROM book_items
        WHERE book_id = NEW.book_id AND status = 'available'
        LIMIT 1;
        
        IF available_item_id IS NOT NULL THEN
            -- Update the book item status to reserved
            UPDATE book_items
            SET status = 'reserved'
            WHERE item_id = available_item_id;
        END IF;
    END IF;
END //
DELIMITER ;

-- Trigger to log changes to the books table
DELIMITER //
CREATE TRIGGER after_book_change
AFTER UPDATE ON books
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (action_type, table_name, record_id, action_timestamp, description)
    VALUES ('update', 'books', NEW.book_id, CURRENT_TIMESTAMP, 
            CONCAT('Book updated: ', NEW.title));
END //
DELIMITER ;

-- Event to automatically check for overdue books and create fines
DELIMITER //
CREATE EVENT check_overdue_books
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE l_loan_id INT;
    DECLARE l_member_id INT;
    DECLARE l_due_date DATE;
    DECLARE days_overdue INT;
    
    -- Cursor for overdue loans without fines
    DECLARE overdue_cursor CURSOR FOR
        SELECT l.loan_id, l.member_id, l.due_date
        FROM loans l
        LEFT JOIN fines f ON l.loan_id = f.loan_id
        WHERE l.return_date IS NULL 
          AND l.due_date < CURRENT_DATE
          AND f.fine_id IS NULL;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN overdue_cursor;
    
    overdue_loop: LOOP
        FETCH overdue_cursor INTO l_loan_id, l_member_id, l_due_date;
        
        IF done THEN
            LEAVE overdue_loop;
        END IF;
        
        -- Calculate days overdue
        SET days_overdue = DATEDIFF(CURRENT_DATE, l_due_date);
        
        -- Create fine record ($0.50 per day)
        INSERT INTO fines (loan_id, member_id, fine_amount, fine_date, fine_status)
        VALUES (l_loan_id, l_member_id, days_overdue * 0.50, CURRENT_DATE, 'pending');
    END LOOP;
    
    CLOSE overdue_cursor;
END //
DELIMITER ;

-- End of Library Management System Database