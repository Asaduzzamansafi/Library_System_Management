             -- Library Managrment system Challenge20_2
-- creat database
CREATE DATABASE challenge20_2;
USE challenge20_2;

-- CREATE TABLES

-- BRANCH TABLE
CREATE TABLE branch
				(
                branch_id VARCHAR(20) PRIMARY KEY,
                manager_id VARCHAR(20),
                branch_address VARCHAR(50),
                contact_no VARCHAR(20)
                );
-- EMPLOYESS TABLE
CREATE TABLE employees 
					(
                    emp_id VARCHAR(20) PRIMARY KEY,
                    emp_name VARCHAR (30),
                    position VARCHAR (30),
                    salary INT,
                    branch_id VARCHAR (30)
                    );
-- ISSUE DATE TABLE
CREATE TABLE issued_status
						(
                        issued_id VARCHAR(20) PRIMARY KEY,
                        issued_member_id VARCHAR(20),
                        issued_book_name VARCHAR(50),
                        issued_date DATE,
                        issued_book_isbn VARCHAR(50),
                        issued_emp_id VARCHAR(20)
                        );
-- MEMBERS TABLE
CREATE TABLE members
				(
                member_id VARCHAR(30) PRIMARY KEY,
                member_name VARCHAR(30),
                member_address VARCHAR(50),	
                reg_date DATE
                );
-- RETURN STATUS TABLE
CREATE TABLE return_status
					(
                    return_id VARCHAR(20) PRIMARY KEY,
                    issued_id VARCHAR(20),
                    return_book_name VARCHAR(20),
                    return_date DATE,
                    return_book_isbn VARCHAR(20)
                    );
-- BOOKS TABLE
CREATE TABLE books
				(
                isbn VARCHAR(30) PRIMARY KEY,
                book_title VARCHAR(20),
                category VARCHAR(20),	
                rental_price FLOAT,
                status VARCHAR(20),	author	VARCHAR(50),
                publisher VARCHAR(50)
                );

ALTER TABLE books
MODIFY book_title VARCHAR(50);

-- FOREIGN KEY
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);
--
ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);                    
                    