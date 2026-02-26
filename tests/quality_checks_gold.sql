
/*

=======================================================================
Quality Checks for Gold Layer
=======================================================================
Script Purpose:
    This script performs quality checks on the 'gold' layer of the data warehouse. 
    The Gold Layer represents the final dimension and fact tables (Star Schema) that are used for reporting and analytics.
    
    The checks include:
    1. Uniqueness of surrogate keys in dimension tables.
    2. Referential integrity between fact and dimension tables.
    3. Data consistency and completeness in the fact table.
    4. Validation of relationships in the data model for analytical purposes.

Usage Notes:
- Run this script after successfully creating the 'gold' layer views.
- Investigate and resolve any discrepancies found during the checks before using the data for reporting or analytics.
=======================================================================
*/


-- ===========================================================================
-- Checking 'gold.dim_customers'
-- ===========================================================================
-- Check for uniqueness of customer key in gold.dim_customers
-- Expectation : No results

SELECT 
    customer_key, 
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ===========================================================================
-- checking 'gold.dim_products'
-- ===========================================================================
-- Check for uniqueness of product key in gold.dim_products
-- Expectation : No results

SELECT 
    product_key, 
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ===========================================================================
-- CHecking 'gold.fact_sales'
-- ===========================================================================

-- CHeck the data model connectivity between fact and dimensions

SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL


