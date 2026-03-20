-- Cumulative Analysis : Aggregate the data progressively over time
-- Helps to understand whether our business is growing or declining.


-- Calculate the total sales per month
-- and the running total of sales over time


	SELECT
	DATETRUNC(MONTH, order_date) AS Order_Month,
	SUM(sales_amount) as Total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
	ORDER BY DATETRUNC(MONTH, order_date)


SELECT
order_date,
total_sales,
-- Window function
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM 
(
	SELECT
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales_amount) as total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
)t

-- Running total Over years

SELECT
order_date,
total_sales,
-- Window function
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM 
(
	SELECT
	DATETRUNC(YEAR, order_date) AS order_date,
	SUM(sales_amount) as total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR, order_date)
)t


-- Moving Average

SELECT
order_date,
total_sales,
-- Window function
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
AVG(Avg_price) OVER (ORDER BY order_date) AS Moving_Average_price
FROM 
(
	SELECT
	DATETRUNC(YEAR, order_date) AS order_date,
	SUM(sales_amount) as total_sales,
	AVG(price) as Avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR, order_date)
)t