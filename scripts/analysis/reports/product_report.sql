  /*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

----1. Base Query
WITH base_query AS(
SELECT
fs.order_number,
fs.order_date,
fs.customer_key,
fs.sales_amount,
fs.quantity,
fs.product_key,
dp.product_name,
dp.category,
dp.subcategory,
dp.cost
FROM gold.fact_sales fs LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
WHERE fs.order_date IS NOT NULL),

----2. product aggregations
product_aggregation AS(
SELECT
product_key,
product_name,
category,
subcategory,
cost,
MAX(order_date) AS last_sale_date,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT customer_key) AS total_customers,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY product_key, product_name, category, subcategory, cost
)

----3. Final Result
SELECT 
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
CASE
	WHEN total_sales > 50000 THEN 'High-Performer'
	WHEN total_sales >= 10000 THEN 'Mid-Range'
	ELSE 'Low-Performer'
END AS product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
CASE 
	WHEN total_orders = 0 THEN 0
	ELSE total_sales / total_orders
END AS avg_order_revenue,
CASE
	WHEN lifespan = 0 THEN total_sales
	ELSE total_sales / lifespan
END AS avg_monthly_revenue
FROM product_aggregation;
