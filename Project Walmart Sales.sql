# Data Analysis Project Walmart

CREATE DATABASE IF NOT EXISTS SalesWalmart;

# Create Data Table

CREATE TABLE IF NOT EXISTS sales
(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

# Importing data using the function import

#Verifying import

SELECT *
FROM sales;

#Create a working data table

CREATE TABLE sales_staging
LIKE sales;

INSERT sales_staging
SELECT *
FROM sales;

SELECT *
FROM sales_staging;

#Data cleaning
-- IN THIS CASE THERE IS NO NEED TO CHECK FOR NULL DATA, BECAUSE OF THE CODE USE TO CREATE THE TABLE.

-- Verifying empty data

SELECT *
FROM sales_staging
WHERE invoice_id = ' '
	OR branch = ' '
    OR city = ' '
    OR customer_type = ' '
    OR gender = ' '
    OR product_line = ' '
    OR unit_price = ' '
    OR quantity = ' '
    OR tax_pct = ' '
    OR total = ' ';

# Checking for duplicate data

SELECT invoice_id, branch, city, customer_type, gender, COUNT(*) as count_dup
FROM sales_staging
GROUP BY invoice_id, branch, city, customer_type, gender
HAVING COUNT(*) > 1; 

# The data does not show empty rows or duplicate data or the need for standardization or columns elimination. 

-- GENERATING NEW COLUMNS, data with information about the time of day, day name and month of sale.

# Time of day

SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

ALTER TABLE sales_staging ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales_staging
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

# Day Name

SELECT
	date,
	DAYNAME(date)
FROM sales_staging;

ALTER TABLE sales_staging ADD COLUMN day_name VARCHAR(10);

UPDATE sales_staging
SET day_name = DAYNAME(date);

# Mont of sale

SELECT
	date,
	MONTHNAME(date)
FROM sales_staging;

ALTER TABLE sales_staging ADD COLUMN month_name VARCHAR(10);

UPDATE sales_staging
SET month_name = MONTHNAME(date);

#EXPLORATORY DATA ANALYSIS

-- Most selling product line

SELECT SUM(quantity) as total_qty, product_line
FROM sales_staging
GROUP BY product_line
ORDER BY total_qty DESC;

-- Total revenue by month

SELECT month_name AS month, SUM(total) AS total_revenue
FROM sales_staging
GROUP BY month_name 
ORDER BY total_revenue DESC;

-- Product line with largest revenue

SELECT product_line, SUM(total) as total_revenue
FROM sales_staging
GROUP BY product_line
ORDER BY total_revenue DESC;

-- Categorizing product line according to average quantity sales

SELECT product_line, quantity,
	CASE 
		WHEN quantity > (SELECT AVG(quantity) FROM sales_staging) THEN 'Good'
        ELSE 'Bad'
	END AS perfomance
FROM sales_staging;

-- The branch sold more products than average product sold

SELECT branch, 
    SUM(quantity) AS sum_quantity
FROM sales_staging
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales_staging);

-- Type of customer by sales

SELECT DISTINCT(customer_type), COUNT(customer_type)
FROM sales_staging
GROUP BY customer_type;

-- Type of costumer by gender

SELECT gender,
	COUNT(*) as gender_cnt
FROM sales_staging
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Besth day by average revenue

SELECT day_name, AVG(total) AS avg_revenue
FROM sales_staging
GROUP BY day_name 
ORDER BY avg_revenue DESC;

-- City that has the largest tax/VAT percent

SELECT city, ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales_staging
GROUP BY city 
ORDER BY avg_tax_pct DESC;

SELECT *
FROM sales_staging;