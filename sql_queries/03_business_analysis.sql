--03_business_analysis.sql

SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM products;


--====================================================================================
--Question 11: Monthly revenue trend
--Description: Analyzed monthly revenue trends by grouping sales data month-wise using
--             SQL joins, aggregation, and date functions.
--====================================================================================

SELECT 
	YEAR(o.order_date) AS ordered_year,
	DATENAME(MONTH,o.order_date) AS ordered_month,
	SUM(oi.quantity * p.price) AS total_revenue
FROM
	orders AS o
JOIN
	order_items AS oi
	ON o.order_id = oi.order_id
JOIN
	products AS p
	ON oi.product_id = p.product_id
GROUP BY
	YEAR(o.order_date),
	DATENAME(MONTH,o.order_date),
	MONTH(o.order_date)
ORDER BY
	ordered_year,
	MONTH(o.order_date);




--=======================================================================================
--Question 12: Repeat customers
--Description: Identified repeat customers by counting customers with more than one order
--             using SQL joins, aggregation, grouping, and filtering techniques.
--=======================================================================================

SELECT 
	c.customer_name,
	COUNT(o.order_id) AS total_orders
FROM
	customers AS C
JOIN
	orders AS o
	ON c.customer_id = o.customer_id
GROUP BY
	c.customer_name
HAVING
	COUNT(o.order_id) > 1
ORDER BY
	total_orders DESC;
	


--=====================================================================================
--Question 13: Customers with no orders
--Description: Retrieve customers who have never placed any orders by using a LEFT JOIN
--             and filtering unmatched records with NULL values.
--=====================================================================================

SELECT
	c.customer_id,
	c.customer_name
FROM 
	customers AS c
LEFT JOIN
	orders AS o
	ON c.customer_id = o.customer_id
WHERE
	o.order_id IS NULL
ORDER BY
	c.customer_name;




--==============================================================================================
--Question 14: Average order value per customer
--Description: Calculated the average order value per customer by first determining total order
--             amounts using multiple table joins and aggregation, then computing customer-wise 
--             averages with a CTE and GROUP BY.
--==============================================================================================

WITH total_prices AS (
	SELECT 
		o.order_id,
		c.customer_id,
		c.customer_name,
		SUM(oi.quantity * p.price) AS total_price
	FROM
		customers AS c
	JOIN
		orders AS o
		on c.customer_id = o.customer_id
	JOIN
		order_items AS oi
		ON o.order_id = oi.order_id
	JOIN
		products AS p
		ON oi.product_id = p.product_id
	GROUP BY
		o.order_id,
		C.customer_id,
		c.customer_name
)
SELECT 
	customer_id,
	customer_name,
	AVG(total_price) AS avg_order_value
FROM
	total_prices
GROUP BY
	customer_id,
	customer_name
ORDER BY
	customer_id,
	customer_name;




--==============================================================================================
--Question 15: Total amount per order
--Description: Calculated the total amount for each order by multiplying product prices with
--             quantities and aggregating the results using GROUP BY.
--==============================================================================================

SELECT 
	oi.order_id,
	SUM(oi.quantity * p.price) AS total_price
FROM
	order_items AS oi
JOIN
	products AS p
	ON oi.product_id = p.product_id
GROUP BY	
	oi.order_id
ORDER BY
	total_price DESC;