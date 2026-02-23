# Summary of Data Quality and Consistency Checks (quality_checks_silver.sql)

## 1. Date Validity Checks
- Checks for invalid or out-of-range dates (order, due, ship) in `bronze.crm_sales_details`.
- Checks for date logic errors (e.g., order date after ship/due date) in `silver.crm_sales_details`.
- Checks for out-of-range birthdates in bronze and silver ERP customer tables.

## 2. Sales Data Consistency
- Ensures `sales = quantity × price`, and none are NULL, zero, or negative in both bronze and silver layers.
- Provides a fix suggestion for inconsistent sales or price values.

## 3. Data Standardization
- Standardizes gender values (e.g., 'F', 'FEMALE' → 'Female') in `bronze.erp_cust_az12`.
- Standardizes country codes (e.g., 'DE' → 'Germany') in `bronze.erp_loc_a101`.

## 4. Quality Checks in Silver Layer
- Validates that standardized and cleaned data is present in the silver tables for customers, locations, and product categories.

## 5. Whitespace Checks
- Detects unwanted spaces in category, subcategory, and maintenance fields in `bronze.erp_px_cat_g1v2`.

## 6. General Data Exploration
- Uses `SELECT DISTINCT` and `SELECT *` to review unique values and all records in various silver and bronze tables.

---
Let me know if you want details on any specific query or logic!