/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS Customer_ey,
	ci.cst_id			AS Customer_ID,
	ci.cst_key			AS Customer_key,
	ci.cst_firstname	AS First_name,
	ci.cst_lastname		AS Last_name,
	la.cntry			AS Country,
	ci.cst_marital_status AS Marital_status,
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen,'n/a')
	END					AS Gender,
	ca.bdate			AS Birthdate,
	ci.cst_create_date	AS Create_Date
FROM Silver.crm_cust_info AS ci
LEFT JOIN Silver.erp_cust_az12 AS ca
	on ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 AS la
	on ci.cst_key = la.cid;
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
	pn.prd_id			AS Product_ID,
	pn.prd_key			AS Product_number,
	pn.prd_nm			AS Product_name,
	pn.cat_id			AS Category_ID,
	pc.cat				AS Category,
	pc.subcat			AS SubCategory,
	pc.maintenance		AS Maintenance,
	pn.prd_cost			AS Cost,
	pn.prd_line			AS Product_line,
	pn.prd_start_dt		AS Start_date
FROM Silver.crm_prd_info AS pn
LEFT JOIN Silver.erp_px_cat_g1v2 AS pc
	on pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;
GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS Order_number,
    pr.product_key  AS Product_key,
    cu.customer_key AS Customer_key,
    sd.sls_order_dt AS Order_date,
    sd.sls_ship_dt  AS Shipping_date,
    sd.sls_due_dt   AS Due_date,
    sd.sls_sales    AS Sales_amount,
    sd.sls_quantity AS Quantity,
    sd.sls_price    AS Price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO
