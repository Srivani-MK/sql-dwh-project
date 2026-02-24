/*
=======================================================================
Quality Checks
=======================================================================
Script Purpose: This script performs various quality checks for data consistency, accuracy and standardization across the 'silver' schemas.
It includes checks for:
	- Null or duplicare primary keys.
	- unwanted spaces in string fields.
	- Data standardization and consistency in categorical fields.
	- Invalid date ranges and orders.
	- Data consistenct between related fields (e.g., sales, quantity, price).

Usage Notes:
- Run this script after the silver layer has been populated to validate the data quality.
- Review the results of each query to identify and address any data quality issues before proceeding with downstream.
- Investigate and resolve any discrepancies found during the checks.
=======================================================================

*/


-- =========================================================================
-- Checkking 'silver.crm_cust_info'
-- =========================================================================
-- Check for Null or Duplicate Primary Keys
-- Expectation: No Results

SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


SELECT
*
FROM(
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM silver.crm_cust_info
)t WHERE flag_last = 1


-- Check for unwanted spaces
-- Expectation: No Results

SELECT
cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)


SELECT
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT
cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)


-- Data Standardizatio & Consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_material_status
FROM silver.crm_cust_info


SELECT *
FROM silver.crm_cust_info

-- =========================================================================
-- Checkking 'silver.crm_sales_details'
-- =========================================================================

-- Check for Invalid Dates

SELECT
NULLIF (sls_order_dt, 0) sls_orde_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

-- For due date

SELECT
NULLIF (sls_due_dt, 0) sls_orde_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- Ship Date

SELECT
NULLIF (sls_ship_dt, 0) sls_orde_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8 
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101


-- Check for Invalid date orders

SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Between Sales, Quantity and Price
-->> Sales = Quantity * Price
-->> Values must not be NULL, zero, or negative

SELECT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- Fix

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0 
 THEN sls_sales / NULLIF(sls_quantity, 0)
 ELSE sls_price
 END AS sls_price
FROM bronze.crm_sales_details

--  Final validation point in silver layer

SELECT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details



SELECT *
FROM silver.crm_sales_details

-- =========================================================================
-- Checkking 'silver.erp_cust_az12'
-- =========================================================================

-- Identifiy Out-of-Range Dates

SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data standardization & Consistency

SELECT DISTINCT gen
FROM bronze.erp_cust_az12


SELECT DISTINCT
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
	ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12


-- Quality Check of the silver Table

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()


SELECT DISTINCT gen
FROM silver.erp_cust_az12

SELECT * FROM silver.erp_cust_az12

-- =========================================================================
-- Checkking 'silver.erp_loc_a101'
-- =========================================================================

-- Data Standardization and consistancy

SELECT DISTINCT
cntry,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101

-- Quality check in silver layer

SELECT DISTINCT
cntry
FROM silver.erp_loc_a101
ORDER BY cntry


SELECT
*
FROM silver.erp_loc_a101

-- =========================================================================
-- Checkking 'silver.erp_px_cat_g1v2'
-- =========================================================================

-- Check unwanted spaces

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data standardization & consistancy

SELECT DISTINCT
cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2


-- Check Data Quality in silver layer


SELECT *
FROM silver.erp_px_cat_g1v2

-- =========================================================================
-- Checkking 'silver.crm_prd_info'
-- =========================================================================

-- Data Standardization & Consistency

SELECT DISTINCT prd_line
FROM silver.crm_prd_info


SELECT distinct id from silver.erp_px_cat_g1v2

SELECT sls_prd_key FROM silver.crm_sales_details

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No results

SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- Expectation: No Results

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLs or Negative Numbers
-- Expectations: No Results

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL


-- Cross Check with Sales Table

WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) IN
(SELECT sls_prd_key FROM silver.crm_sales_details)


-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


-- Start date and end date validation

SELECT
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')

SELECT * FROM silver.crm_prd_info