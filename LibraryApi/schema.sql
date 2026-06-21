DROP DATABASE IF EXISTS  `2024_TU_Lab1`;
CREATE DATABASE `2024_TU_Lab1`;
USE `2024_TU_Lab1`;
 
CREATE TABLE publisher (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  country VARCHAR(20) NOT NULL
);
 
CREATE TABLE book (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ISBN CHAR(13) NOT NULL UNIQUE,
  title VARCHAR(100) NOT NULL,
  price DECIMAL(10,0) NOT NULL DEFAULT '0',
  category VARCHAR(20) NOT NULL,
  publisher_id INT NOT NULL
);
 
CREATE TABLE reader (
  id INT AUTO_INCREMENT  PRIMARY KEY,
  email VARCHAR(320) NOT NULL UNIQUE,
  first_name VARCHAR(20) NOT NULL,
  last_name VARCHAR(20) NOT NULL,
  address VARCHAR(100) NOT NULL,
  sex ENUM('male','female','other') NOT NULL,
  phone_no VARCHAR(100)
);
 
CREATE TABLE staff (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);
 
CREATE TABLE account (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(320) UNIQUE,
  password VARCHAR(100) NOT NULL
);
 
 
CREATE TABLE book_reader (
  book_id INT NOT NULL,
  reader_id INT NOT NULL,
  date_taken DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_returned DATETIME,
  PRIMARY KEY (book_id,reader_id),
  CONSTRAINT FOREIGN KEY (book_id) REFERENCES book(id),
  CONSTRAINT FOREIGN KEY (reader_id) REFERENCES reader(id)
);
 
ALTER TABLE book
ADD CONSTRAINT FOREIGN KEY(publisher_id) REFERENCES publisher(id);
 
ALTER TABLE reader
ADD account_id INT UNIQUE;
ALTER TABLE reader
ADD CONSTRAINT FOREIGN KEY(account_id) REFERENCES account(id);
 
ALTER TABLE staff
ADD account_id INT UNIQUE;
ALTER TABLE staff
ADD CONSTRAINT FOREIGN KEY(account_id) REFERENCES account(id);
 
ALTER TABLE reader
ADD staff_id INT;
ALTER TABLE reader
ADD CONSTRAINT FOREIGN KEY(staff_id) REFERENCES staff(id);
 
ALTER TABLE book
ADD maintained_by INT;
ALTER TABLE book
ADD CONSTRAINT FOREIGN KEY(maintained_by) REFERENCES staff(id);
 
-- Lab 2
CREATE TABLE author (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) UNIQUE
);
ALTER TABLE book
ADD author_id INT;
ALTER TABLE book
ADD CONSTRAINT FOREIGN KEY(author_id) REFERENCES author(id);
 
INSERT INTO publisher (name, country)
VALUES
    ('Penguin Random House', 'USA'),
    ('HarperCollins', 'USA'),
    ('Hachette Livre', 'France'),
    ('Springer Nature', 'Germany'),
    ('Macmillan Publishers', 'UK'),
    ('Simon & Schuster', 'USA'),
    ('Pearson', 'UK'),
    ('Wiley', 'USA'),
    ('Oxford University Press', 'UK'),
    ('Random House', 'USA'),
    ('Scholastic', 'USA'),
    ('Cambridge University Press', 'UK'),
    ('Elsevier', 'Netherlands'),
    ('Bloomsbury Publishing', 'UK'),
    ('McGraw-Hill Education', 'USA'),
    ('Cengage Learning', 'USA'),
    ('Penguin Books', 'UK'),
    ('Houghton Mifflin Harcourt', 'USA'),
    ('Taylor & Francis', 'UK'),
    ('John Wiley & Sons', 'USA');
 
INSERT INTO account (username, password)
VALUES
    ('john_doe', 'JD@2024'),
    ('jane_smith', 'JS@1234'),
    ('mike_jones', 'MJpass987'),
    ('sara_williams', 'SW@password'),
    ('chris_brown', 'CBpass@123'),
    ('emily_jackson', 'EJ!pass'),
    ('david_clark', 'DCpass#789'),
    ('amy_taylor', 'AT@2024'),
    ('kevin_white', 'KWpass123!'),
    ('lisa_johnson', 'LJpass5678'),
    ('steve_miller', 'SM@pass2024'),
    ('rachel_green', 'RG!pass123'),
    ('alex_thompson', 'AT123@pass'),
    ('olivia_harris', 'OH@9876pass'),
    ('brandon_lee', 'BLpass#2024'),
    ('natalie_baker', 'NBpass!4321'),
    ('adam_robinson', 'ARpass@2024'),
    ('jennifer_davis', 'JDpass#2024'),
    ('ryan_moore', 'RM@pass123'),
    ('sophia_martin', 'SMpass@987');
 
INSERT INTO author (name)
VALUES
    ('John Smith'),
    ('Jane Doe'),
    ('Michael Johnson'),
    ('Sarah Williams'),
    ('Chris Brown'),
    ('Emily Wilson'),
    ('David Clark'),
    ('Amy Taylor'),
    ('Kevin White'),
    ('Lisa Johnson'),
    ('Steven Miller'),
    ('Rachel Green'),
    ('Alex Thompson'),
    ('Olivia Harris'),
    ('Brandon Lee'),
    ('Natalie Baker'),
    ('Adam Robinson'),
    ('Jennifer Davis'),
    ('Ryan Moore'),
    ('Sophia Martin');
 
INSERT INTO staff (name, account_id)
VALUES
    ('John Admin', 1),
    ('Jane Admin', 2),
    ('Michael Manager', 3),
    ('Samantha Smith', 4),
    ('David Johnson', 5),
    ('Emily Brown', 6),
    ('Robert Davis', 7),
    ('Jessica Wilson', 8),
    ('Christopher Taylor', 9),
    ('Ashley Martinez', 10),
    ('Daniel Anderson', 11),
    ('Jennifer Thomas', 12),
    ('Matthew Lee', 13),
    ('Amanda Harris', 14),
    ('Kevin White', 15),
    ('Laura Garcia', 16),
    ('James Martinez', 17),
    ('Michelle Robinson', 18),
    ('Brian Clark', 19),
    ('Stephanie Lewis', 20);
 
INSERT INTO book (ISBN, title, price, category, publisher_id, maintained_by, author_id)
VALUES
    ('9780547928227', 'Harry Potter and the Sorcerer''s Stone', 20, 'Fiction', 1, 1, 1),
    ('9780439064866', 'Harry Potter and the Chamber of Secrets', 22, 'Fiction', 2, 2, 1),
    ('9780439136365', 'Harry Potter and the Prisoner of Azkaban', 25, 'Fiction', 3, 3, 1),
    ('9780439139601', 'Harry Potter and the Goblet of Fire', 30, 'Fiction', 4, 4, 1),
    ('9780439358071', 'Harry Potter and the Order of the Phoenix', 28, 'Fiction', 5, 5, 1),
    ('9780439784542', 'Harry Potter and the Half-Blood Prince', 27, 'Fiction', 6, 6, 1),
    ('9780545010221', 'Harry Potter and the Deathly Hallows', 32, 'Fiction', 7, 7, 1),
    ('9780312676849', 'The Hunger Games', 18, 'Young Adult', 8, 8, 2),
    ('9780439023481', 'Twilight', 15, 'Young Adult', 9, 9, 2),
    ('9780375831003', 'Eragon', 20, 'Fantasy', 10, 10, 2),
    ('9780141439600', 'Pride and Prejudice', 12, 'Classic', 1, 1, 3),
    ('9780140620590', 'To Kill a Mockingbird', 13, 'Classic', 2, 2, 3),
    ('9780743273565', 'The Da Vinci Code', 16, 'Mystery', 3, 3, 4),
    ('9780385514231', 'The Girl with the Dragon Tattoo', 18, 'Mystery', 4, 4, NULL),
    ('9780385537858', 'Inferno', 19, 'Mystery', 5, 5, NULL),
    ('9780547577319', 'The Hobbit', 22, 'Fantasy', 6, 6, NULL),
    ('9780553283686', 'A Game of Thrones', 25, 'Fantasy', 7, 7, NULL),
    ('9780345337664', 'The Fellowship of the Ring', 21, 'Fantasy', 8, 8, NULL),
    ('9780345339705', 'The Two Towers', 20, 'Fantasy', 9, 9, NULL),
    ('9780345342965', 'The Return of the King', 23, 'Fantasy', 10, 10, NULL);
 
INSERT INTO reader (email, first_name, last_name, address, sex, phone_no, account_id, staff_id)
VALUES
    ('john.doe@example.com', 'John', 'Doe', '123 Main St, Anytown, USA', 'male', '123-456-7890', 1, 1),
    ('jane.smith@example.com', 'Jane', 'Smith', '456 Elm St, Othertown, USA', 'female', '987-654-3210', 2, 2),
    ('mike.jones@example.com', 'Mike', 'Jones', '789 Oak St, Another Town, USA', 'male', '555-123-4567', 3, 3),
    ('sarah.williams@example.com', 'Sarah', 'Williams', '321 Maple St, Somewhere, USA', 'female', '777-888-9999', 4, 4),
    ('chris.brown@example.com', 'Chris', 'Brown', '654 Pine St, Anywhere, USA', 'male', '444-555-6666', 5, 5),
    ('emily.wilson@example.com', 'Emily', 'Wilson', '987 Cedar St, Nowhere, USA', 'female', '222-333-4444', 6, 6),
    ('david.clark@example.com', 'David', 'Clark', '456 Birch St, Elsewhere, USA', 'male', '111-222-3333', 7, 7),
    ('amy.taylor@example.com', 'Amy', 'Taylor', '789 Spruce St, Here, USA', 'female', '999-888-7777', 8, 8),
    ('kevin.white@example.com', 'Kevin', 'White', '147 Oakwood Dr, Anytown, USA', 'male', '777-666-5555', 9, 9),
    ('lisa.johnson@example.com', 'Lisa', 'Johnson', '258 Maplewood Dr, Anywhere, USA', 'female', '333-222-1111', 10, 10),
    ('steven.miller@example.com', 'Steven', 'Miller', '369 Elmwood Dr, Anywhere, USA', 'male', '111-222-3333', 11, 1),
    ('rachel.green@example.com', 'Rachel', 'Green', '987 Birchwood Dr, Anywhere, USA', 'female', '444-555-6666', 12, 2),
    ('alex.thompson@example.com', 'Alex', 'Thompson', '741 Pinebrook Dr, Anywhere, USA', 'male', '777-888-9999', 13, 3),
    ('olivia.harris@example.com', 'Olivia', 'Harris', '852 Maplehurst Dr, Anywhere, USA', 'female', '333-444-5555', 14, 4),
    ('brandon.lee@example.com', 'Brandon', 'Lee', '963 Cedarhurst Dr, Anywhere, USA', 'male', '999-888-7777', 15, 5),
    ('natalie.baker@example.com', 'Natalie', 'Baker', '147 Birchhill Dr, Anywhere, USA', 'female', '666-555-4444', 16, 6),
    ('adam.robinson@example.com', 'Adam', 'Robinson', '258 Elmwood Dr, Anywhere, USA', 'male', '222-333-4444', 17, 7),
    ('jennifer.davis@example.com', 'Jennifer', 'Davis', '369 Maplewood Dr, Anywhere, USA', 'female', '555-666-7777', 18, 8),
    ('ryan.moore@example.com', 'Ryan', 'Moore', '741 Oakwood Dr, Anywhere, USA', 'male', '888-999-0000', 19, 9),
    ('sophia.martin@example.com', 'Sophia', 'Martin', '852 Pinebrook Dr, Anywhere, USA', 'female', '111-222-3333', 20, 10);
 
INSERT INTO book_reader (book_id, reader_id, date_taken, date_returned)
VALUES
    (1, 1, '2023-01-05', '2023-01-15'),
    (2, 2, '2023-02-10', NULL),
    (3, 3, '2023-03-20', '2023-03-30'),
    (4, 4, '2023-04-25', NULL),
    (5, 5, '2023-05-03', '2023-05-13'),
    (6, 6, '2023-06-15', NULL),
    (7, 7, '2023-07-20', '2023-07-30'),
    (8, 8, '2023-08-08', NULL),
    (9, 9, '2023-09-12', '2023-09-22'),
    (10, 10, '2023-10-30', NULL),
    (1, 2, '2023-01-10', '2023-01-20'),
    (2, 3, '2023-02-15', NULL),
    (3, 4, '2023-03-25', '2023-04-05'),
    (4, 5, '2023-04-10', NULL),
    (5, 6, '2023-05-20', '2023-05-30'),
    (6, 7, '2023-06-01', NULL),
    (7, 8, '2023-07-05', '2023-07-15'),
    (8, 9, '2023-08-18', NULL),
    (9, 10, '2023-09-22', '2023-10-02'),
    (10, 1, '2023-10-05', NULL);

CREATE TABLE IF NOT EXISTS deleted_book_reader_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    book_title VARCHAR(100) NOT NULL,
    reader_id INT,
    reader_name VARCHAR(50),
    logged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER trg_before_delete_book
BEFORE DELETE ON book
FOR EACH ROW
BEGIN
    INSERT INTO deleted_book_reader_log (book_id, book_title, reader_id, reader_name)
    SELECT 
        OLD.id,
        OLD.title,
        r.id,
        CONCAT(r.first_name, ' ', r.last_name)
    FROM book_reader br
    JOIN reader r ON r.id = br.reader_id
    WHERE br.book_id = OLD.id;

    IF NOT EXISTS (
        SELECT 1
        FROM book_reader
        WHERE book_id = OLD.id
    ) THEN
        INSERT INTO deleted_book_reader_log (book_id, book_title, reader_id, reader_name)
        VALUES (OLD.id, OLD.title, NULL, 'No readers rented this book');
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_before_update_book_price
BEFORE UPDATE ON book
FOR EACH ROW
BEGIN
    DECLARE readers_count INT DEFAULT 0;
    DECLARE discount_percent INT DEFAULT 0;

    IF OLD.price <> NEW.price THEN

        IF OLD.price > NEW.price THEN
            SET NEW.price = ROUND(NEW.price * 1.05, 0);

        ELSEIF OLD.price < NEW.price THEN
            SELECT COUNT(*)
            INTO readers_count
            FROM book_reader
            WHERE book_id = OLD.id;

            SET discount_percent = readers_count * 3;

            IF discount_percent > 9 THEN
                SET discount_percent = 9;
            END IF;

            SET NEW.price = ROUND(NEW.price * (1 - discount_percent / 100), 0);
        END IF;

    END IF;
END$$

DELIMITER ;	

DELIMITER $$

CREATE EVENT ev_daily_book_price_check
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE book b
    JOIN (
        SELECT 
            br.book_id,
            CASE
                WHEN MAX(TIMESTAMPDIFF(MONTH, br.date_taken, NOW())) >= 2 THEN 10
                WHEN MAX(TIMESTAMPDIFF(DAY, br.date_taken, NOW())) > 30 THEN 2
                ELSE 0
            END AS increase_amount
        FROM book_reader br
        WHERE br.date_returned IS NULL
        GROUP BY br.book_id
    ) x ON b.id = x.book_id
    SET b.price = b.price + x.increase_amount
    WHERE x.increase_amount > 0;
END$$

DELIMITER ;
