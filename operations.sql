SELECT * FROM branch;
SELECT * FROM books;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- project task

-- Task 1. Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books 
			(isbn, book_title, category, rental_price, status, author, publisher)
		VALUES 
			('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '123 south st'
WHERE member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status 
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_member_id, count(issued_member_id) AS total_issued
FROM issued_status 
GROUP BY issued_member_id
HAVING total_issued >1
ORDER BY 2 DESC;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE book_cnts
AS 
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS no_issue
FROM books as b
JOIN issued_status as ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1
ORDER BY 1,2;
SELECT * FROM book_cnts;

-- Task 7: Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'fiction';

-- Task 8: Find Total Rental Income by Category:
SELECT category, SUM(rental_price), COUNT(*) 
FROM  books as b
JOIN issued_status as ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1
ORDER BY 1;

-- Task 9: List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT 	
		emp.emp_id,
        emp.emp_name,
        CASE WHEN emp.emp_name = emp2.emp_name THEN ''
        ELSE emp2.emp_name END as manager,
        emp.salary,
        b.*
FROM employees as emp
JOIN branch as b
ON emp.branch_id = b.branch_id
JOIN employees as emp2 
ON emp2.emp_id = b.manager_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7 usd:

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
		ist.issued_id,
        ist.issued_book_name
FROM issued_status AS ist 
LEFT JOIN return_status as rst
ON ist.issued_id = rst.issued_id
WHERE rst.issued_id is null;

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
 Display the member's_id, member's name, book title, issue date, and days overdue. */

SELECT 
		ist.issued_member_id,
        m.member_name,
        bk.book_title,
        ist.issued_date,
        rst.return_date,
       DATEDIFF(CURDATE(), ist.issued_date) AS over_due_days
	FROM issued_status AS ist
JOIN 
members AS m
ON ist.issued_member_id = m.member_id
JOIN 
books AS bk
ON ist.issued_book_isbn = bk.isbn
LEFT JOIN 
return_status AS rst
on ist.issued_id = rst.issued_id
WHERE 
	rst.return_date is NULL
    AND
    (DATEDIFF(CURDATE(), ist.issued_date)) >30
    ORDER BY 1;

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned 
(based on entries in the return_status table).*/

use challenge20_2;
DELIMITER $$
CREATE PROCEDURE add_return_records(
				IN p_return_id VARCHAR(20),
                IN p_issued_id VARCHAR(20))
	BEGIN
		DECLARE v_isbn VARCHAR(50);
        DECLARE v_book_name VARCHAR(50);
        
		-- Insert into return_status table
		INSERT INTO return_status(return_id , issued_id, return_date)
        VALUES (p_return_id, p_issued_id, current_date());
        
        -- get isbn number & book name from issued_status table
        SELECT issued_book_isbn, issued_book_name
        INTO v_isbn, v_book_name
        FROM issued_status
        WHERE issued_id = p_issued_id;
        
        -- update book status
        UPDATE books
        SET status = 'yes'
        WHERE isbn = v_isbn;
        
         -- Simulate output (MySQL doesn't support RAISE NOTICE, so use SELECT)
         SELECT concat('Thank you for returning the book: ', v_book_name) AS message;
    
    END $$
DELIMITER ;

call add_return_records('RS121', 'IS128');

SHOW PROCEDURE STATUS WHERE Db = 'challenge20_2';

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

CREATE TABLE branch_report
AS
SELECT 
	emp.branch_id AS branch,
    COUNT(ist.issued_id),
    COUNT(rst.issued_id),
    SUM(bk.rental_price)
FROM employees AS emp
RIGHT JOIN
issued_status AS ist 
ON emp.emp_id = ist.issued_emp_id
LEFT JOIN
return_status AS rst
ON ist.issued_id = rst.issued_id
LEFT JOIN 
books AS bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1;

SELECT * FROM branch_report;

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 2 months. */


CREATE TABLE active_members
AS
SELECT * 
	FROM members
    WHERE member_id IN (SELECT
							 DISTINCT issued_member_id 
                             FROM issued_status
                             WHERE issued_date >= curdate() - INTERVAL 2 MONTH);

SELECT * FROM active_members;


/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

SELECT  
		emp.emp_id AS id,
        emp.emp_name AS name,
        emp.branch_id AS branch_id,
        COUNT(ist.issued_id) AS total_processed
FROM issued_status ist
JOIN 
employees AS emp
ON ist.issued_emp_id = emp.emp_id
GROUP BY 1,2 
ORDER BY 4 DESC
LIMIT 3;

/*
Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). If the book is available, 
it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that 
the book is currently not available.*/

use challenge20_2;
DELIMITER $$

CREATE PROCEDURE book_issue(
					IN p_issued_id VARCHAR(20),
					IN p_issued_member_id VARCHAR(20),
					IN p_issued_book_isbn VARCHAR(50),
					IN p_issued_emp_id VARCHAR(20)
					)
	BEGIN
		DECLARE v_status VARCHAR(20);
        -- Check if book is available
        SELECT status
        INTO v_status
        FROM books
        WHERE isbn = p_issued_book_isbn;
	IF
		v_status = "yes" THEN
                -- Insert record into issued_status table
		INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUE (p_issued_id, p_issued_member_id, curdate(), p_issued_book_isbn, p_issued_emp_id);
        
        -- Update book status to 'no'
		UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;
        
        -- Show success message
        SELECT CONCAT('✅ Book issued suffessfil. ISBN', p_issued_book_isbn) AS message;
	ELSE
                -- Show error message
		SELECT CONCAT('✅ Book unavailable. ISBN', p_issued_book_isbn) AS message;
	END IF;

    
    END $$
DELIMITER ;
-- test for unavailable books.
CALL book_issue('IS141', 'C105','978-0-345-39180-3','E110');

-- test for available books.
CALL book_issue('IS141', 'C105','978-0-06-112241-5','E110');

SHOW PROCEDURE STATUS WHERE Db = 'challenge20_2';
