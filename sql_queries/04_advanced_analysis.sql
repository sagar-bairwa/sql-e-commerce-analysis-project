--04_advanced_analysis.sql

USE E_Commerce

SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM products;


--=======================================================================================
--Question 16: Top 3 customers per city (revenue)
--Description: Retrieved the top 3 customers by revenue within each city using joins,
--             aggregation, CTEs, and the DENSE_RANK() window function with PARTITION BY.
--=======================================================================================

WITH total_revenue AS (
	SELECT
		c.city,
		c.customer_id,
		c.customer_name,
		SUM(oi.quantity * p.price) AS revenue,
		DENSE_RANK() OVER ( 
			PARTITION BY c.city
			ORDER BY SUM(oi.quantity * p.price) DESC
		) AS ranks
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
		c.city,
		c.customer_id,
		c.customer_name
	)
SELECT 
	city,
	customer_id,
	customer_name,
	revenue
FROM
	total_revenue
WHERE
	ranks <=3
ORDER BY
	city,
	revenue DESC;



--===========================================================================================
--Question 17: Top-selling product per category
--Description: Identified the top-selling product in each category by calculating total sales
--             and applying DENSE_RANK() with PARTITION BY for category-wise ranking.
--===========================================================================================

WITH top_products AS (

	SELECT
		p.category,
		oi.product_id,
		p.product_name,
		SUM(oi.quantity * p.price) as total_sales,
		DENSE_RANK() OVER (
			PARTITION BY p.category
			ORDER BY SUM(oi.quantity * p.price) DESC
		) AS ranks
	FROM
		order_items AS oi
	JOIN
		products AS p
		ON oi.product_id = p.product_id
	GROUP BY
		p.category,
		oi.product_id,
		p.product_name
)
SELECT
	category,	
	product_id,
	product_name,
	total_sales
FROM
	top_products
WHERE
	ranks =1
ORDER BY
	category;




--===========================================================================================
--Question 18: Running total revenue
--Description: Calculates date-wise total sales revenue and cumulative running total revenue
--             using window functions.
--===========================================================================================

WITH total_revenue AS (
	
	SELECT
		o.order_date,
		SUM(oi.quantity * p.price) AS total_sales
	FROM
		orders AS o
	JOIN
		order_items AS oi
		ON o.order_id = oi.order_id
	JOIN
		products AS p
		ON oi.product_id = p.product_id
	GROUP BY
		o.order_date
)
SELECT 
	order_date,
	total_sales,
	FORMAT
    (
        SUM(total_sales) OVER(
            ORDER BY order_date
        ),
        'N0',
        'en-IN'
    ) AS running_total_revenue
FROM
	total_revenue
ORDER BY
	order_date;




--====================================================================================
--Question 19: First & last order per customer
--Description: Calculates date-wise sales revenue and cumulative running total revenue 
--             using aggregate and window functions.
--====================================================================================

SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM
	customers AS c
JOIN 
	orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name;




--====================================================================================
--Question 20: Customers ordering same product multiple times
--Description: 
--====================================================================================

SELECT 
	c.customer_id,
	c.customer_name,
	p.product_id,
	p.product_name,
	COUNT(DISTINCT o.order_id) AS number_of_orders
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
	c.customer_id,
	c.customer_name,
	p.product_id,
	p.product_name
HAVING
	COUNT(DISTINCT o.order_id) > 1
ORDER BY
	number_of_orders DESC;