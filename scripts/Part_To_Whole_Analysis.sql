-- which categories contribute the most of overall sales?

WITH Category_Sales AS 
(
SELECT
category,
SUM(sales_amount) as total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products_Analytics p
ON p.product_key = f.product_key
GROUP BY category
)

SELECT
category,
total_sales,
SUM(total_sales) OVER ()  overall_sales,
CONCAT(ROUND ((CAST (total_sales AS FLOAT) / SUM(total_sales) OVER () ) * 100, 2),'%') AS percentage_of_total
FROM Category_Sales

-- To display aggregations at multiple levels in the results, use window functions



