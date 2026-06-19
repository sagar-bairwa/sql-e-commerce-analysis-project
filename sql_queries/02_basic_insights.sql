--02_basic_insights.sql

SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM products;


--======================================================================================
-- Question No: 6) Total Revenue
-- Description: Calculated total revenue by joining order and product tables and summing 
--              quantity-wise sales using SQL joins and aggregates.
--======================================================================================

SELECT
	SUM(oi.quantity * p.price) AS total_revenue
FROM 
	order_items AS oi
JOIN 
	products AS p
	ON oi.product_id = p.product_id;



--====================================================================================
--Question no: 7) Order per customer
--Description: Counted total orders placed by each customer using SQL joins, grouping,
--             and aggregate functions, and sorted customers based on order frequency.
--====================================================================================

SELECT 
	c.customer_id,
	c.customer_name,
	COUNT(o.order_id) AS total_orders
FROM 
	customers AS c
JOIN 
	orders AS o
	ON c.customer_id = o.customer_id
GROUP BY
	c.customer_id,
	c.customer_name
ORDER BY 
	total_orders DESc;



--====================================================================================
--Question 8 : Top 5 customers by number of orders
--Description: Identified the top 5 customers with the highest number of orders using 
--             SQL joins,aggregation, and sorting techniques.
--====================================================================================

WITH ranked_customers AS (
	SELECT	
		c.customer_id,
		c.customer_name,
		COUNT(o.order_id) AS total_orders,
		DENSE_RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS ranks
	FROM 
		customers AS c
	JOIN 
		orders AS o
		ON c.customer_id = o.customer_id
	GROUP BY
		c.customer_id,
		c.customer_name
)
SELECT 
	customer_id,
	customer_name,
	total_orders
FROM
	ranked_customers
WHERE
	ranks <=5
ORDER BY 
	total_orders DESC;




--==========================================================================================
--Question 9 :  Top 5 most sold products
--Description : Identified the top 5 most sold products by calculating total quantities sold
--              using SQL joins, aggregation, window functions, and ranking techniques.
--==========================================================================================

WITH ranked_products AS (
	SELECT 
		oi.product_id,
		p.product_name,
		SUM(oi.quantity) AS total_quantity,
		DENSE_RANK() OVER (
			ORDER BY SUM(oi.quantity) DESC
		) AS ranks
	FROM
		order_items AS oi
	JOIN
		products AS p
		ON oi.product_id = p.product_id
	GROUP BY
		oi.product_id,
		p.product_name
)
SELECT 
	product_id,
	product_name,
	total_quantity
FROM
	ranked_products
WHERE
	ranks <= 5
ORDER BY
	total_quantity DESC;




--==========================================================================================
--Question 10 :  Category-wise revenue
--Description :  Calculated category-wise revenue by aggregating sales amounts using 
--               SQL joins, grouping, and revenue calculation techniques.
--==========================================================================================

SELECT
	p.category,
	SUM(oi.quantity * p.price) AS total_revenue
FROM 
	order_items AS oi
JOIN 
	products AS p
	ON oi.product_id = p.product_id 
GROUP BY
	p.category
ORDER BY 
	total_revenue DESC;