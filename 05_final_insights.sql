--05_final_insights.sql

USE E_Commerce

SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM products;



--============================================================================================
--Question 21: Highest revenue generating city
--Description: Calculated city-wise total revenue using joins and aggregation, then identified 
--             the highest revenue-generating city using the DENSE_RANK() window function.
--============================================================================================

WITH revenue_of_cities AS (
	SELECT
		c.city,
		SUM(oi.quantity * p.price) AS total_revenue,
		DENSE_RANK() OVER ( 
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
		c.city
)
SELECT 
	city,
	total_revenue
FROM
	revenue_of_cities
WHERE
	ranks = 1;




--========================================================================================
--Question 22: Most profitable category
--Description: Calculated category-wise total revenue using aggregation and identified the 
--             highest revenue-generating category using sorting and TOP 1 filtering.
--========================================================================================

SELECT TOP 1
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




--=====================================================================================
--Question 23: -- Top 5 high-value customers based on total revenue
--Description: Identified top 5 high-value customers by calculating customer-wise total 
--             revenue using joins, aggregation, and DENSE_RANK() window function.
--=====================================================================================

WITH total_revenue AS (
	SELECT
		c.customer_id,
		c.customer_name,
		SUM(oi.quantity * p.price) AS revenue,
		DENSE_RANK() OVER ( 
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
		c.customer_id,
		c.customer_name
	)
SELECT 
	customer_id,
	customer_name,
	revenue
FROM
	total_revenue
WHERE
	ranks <=5
ORDER BY
	revenue DESC;




--============================================================================
--Question 24: Inactive customers
--Description: Identified inactive customers who never placed any orders using
--             a LEFT JOIN and NULL filtering technique.
--============================================================================

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




--=======================================================================================
--Question 25: Month with highest growth
--Description: Calculated month-over-month revenue growth using aggregation and the LAG()
--             window function to identify the month with the highest sales growth
--========================================================================================

WITH monthly_revenue AS (

    SELECT
        YEAR(o.order_date) AS ordered_year,
        
        DATENAME(MONTH, o.order_date) AS ordered_month,

        MONTH(o.order_date) AS month_number,

        SUM(oi.quantity * p.price) AS total_revenue

    FROM orders AS o

    JOIN order_items AS oi
        ON o.order_id = oi.order_id

    JOIN products AS p
        ON oi.product_id = p.product_id

    GROUP BY
        YEAR(o.order_date),
        DATENAME(MONTH, o.order_date),
        MONTH(o.order_date)
)

SELECT TOP 1
    ordered_year,
    ordered_month,
    total_revenue,
    total_revenue
    -
    LAG(total_revenue) OVER (
        ORDER BY ordered_year, month_number
    ) AS growth
FROM 
	monthly_revenue
ORDER BY 
	growth DESC;
