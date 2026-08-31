-- ============================================================
-- INSTACART ONLINE GROCERY BASKET ANALYSIS
-- 02 - DATA QUALITY CHECKS
-- Database: instacart_db
-- Purpose: Detect missing values, duplicates, invalid domains,
--          sequence problems, and product-classification issues.
-- ============================================================

USE instacart_db;

-- ------------------------------------------------------------
-- 1. Duplicate order-product pairs
-- Verified result: 0 duplicate pairs in train and prior.
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id, product_id) AS unique_order_product_pairs,
       COUNT(*) - COUNT(DISTINCT order_id, product_id) AS duplicate_pairs
FROM order_products__train;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id, product_id) AS unique_order_product_pairs,
       COUNT(*) - COUNT(DISTINCT order_id, product_id) AS duplicate_pairs
FROM order_products__prior;

-- ------------------------------------------------------------
-- 2. Missing values in reference tables and cleaned products
-- Verified result: 0 NULLs in required fields.
-- ------------------------------------------------------------
SELECT SUM(department_id IS NULL) AS null_department_id,
       SUM(department IS NULL) AS null_department_name
FROM departments;

SELECT SUM(aisle_id IS NULL) AS null_aisle_id,
       SUM(aisle IS NULL) AS null_aisle_name
FROM aisles;

SELECT SUM(product_id IS NULL) AS null_product_id,
       SUM(product_name IS NULL) AS null_product_name,
       SUM(aisle_id IS NULL) AS null_aisle_id,
       SUM(department_id IS NULL) AS null_department_id
FROM products_clean;

-- ------------------------------------------------------------
-- 3. Missing values in orders
-- Verified result: days_since_prior_order has 206,209 NULLs;
-- these are expected first-order records.
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_rows,
       SUM(order_id IS NULL) AS null_order_id,
       SUM(user_id IS NULL) AS null_user_id,
       SUM(eval_set IS NULL) AS null_eval_set,
       SUM(order_number IS NULL) AS null_order_number,
       SUM(order_dow IS NULL) AS null_order_dow,
       SUM(order_hour_of_day IS NULL) AS null_order_hour,
       SUM(days_since_prior_order IS NULL) AS null_days_since_prior
FROM orders;

-- Confirm that NULL days_since_prior_order only occurs for first orders.
SELECT order_number,
       COUNT(*) AS null_records
FROM orders
WHERE days_since_prior_order IS NULL
GROUP BY order_number
ORDER BY order_number;

SELECT COUNT(*) AS first_orders,
       SUM(days_since_prior_order IS NULL) AS null_days_first_orders,
       SUM(days_since_prior_order IS NOT NULL) AS nonnull_days_first_orders
FROM orders
WHERE order_number = 1;

-- ------------------------------------------------------------
-- 4. Missing values in transaction tables
-- Verified result: 0 NULLs in all essential fields.
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_rows,
       SUM(order_id IS NULL) AS null_order_id,
       SUM(product_id IS NULL) AS null_product_id,
       SUM(add_to_cart_order IS NULL) AS null_cart_order,
       SUM(reordered IS NULL) AS null_reordered
FROM order_products__train;

SELECT COUNT(*) AS total_rows,
       SUM(order_id IS NULL) AS null_order_id,
       SUM(product_id IS NULL) AS null_product_id,
       SUM(add_to_cart_order IS NULL) AS null_cart_order,
       SUM(reordered IS NULL) AS null_reordered
FROM order_products__prior;

-- ------------------------------------------------------------
-- 5. Cart-position sequence validation
-- Verified result: 0 invalid orders in both transaction tables.
-- ------------------------------------------------------------
SELECT order_id,
       COUNT(*) AS number_of_products,
       MIN(add_to_cart_order) AS first_position,
       MAX(add_to_cart_order) AS last_position,
       COUNT(DISTINCT add_to_cart_order) AS unique_positions
FROM order_products__train
GROUP BY order_id
HAVING MIN(add_to_cart_order) <> 1
    OR MAX(add_to_cart_order) <> COUNT(*)
    OR COUNT(DISTINCT add_to_cart_order) <> COUNT(*);

SELECT order_id,
       COUNT(*) AS number_of_products,
       MIN(add_to_cart_order) AS first_position,
       MAX(add_to_cart_order) AS last_position,
       COUNT(DISTINCT add_to_cart_order) AS unique_positions
FROM order_products__prior
GROUP BY order_id
HAVING MIN(add_to_cart_order) <> 1
    OR MAX(add_to_cart_order) <> COUNT(*)
    OR COUNT(DISTINCT add_to_cart_order) <> COUNT(*);

-- ------------------------------------------------------------
-- 6. Detect invalid product category references BEFORE cleaning
-- Verified results:
-- invalid aisle IDs       = 3,062
-- invalid department IDs  = 2,889
-- aisle_id = 0            = 3,035
-- department_id = 0       = 1,133
-- aisle_id > 134          = 27
-- department_id > 21      = 1,756
-- ------------------------------------------------------------
SELECT
    SUM(aisle_id NOT BETWEEN 1 AND 134) AS invalid_aisle_ids,
    SUM(department_id NOT BETWEEN 1 AND 21) AS invalid_department_ids,
    SUM(aisle_id = 0) AS zero_aisle_ids,
    SUM(department_id = 0) AS zero_department_ids,
    SUM(aisle_id > 134) AS aisle_ids_above_134,
    SUM(department_id > 21) AS department_ids_above_21
FROM products;

-- ------------------------------------------------------------
-- 7. Quantify affected product classifications BEFORE cleaning
-- Verified results:
-- total affected       = 3,203
-- aisle-only problem   = 314
-- department-only      = 141
-- both problems        = 2,748
-- ------------------------------------------------------------
SELECT
    SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) AS total_affected_products,
    SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id BETWEEN 1 AND 21)) AS aisle_only_problem,
    SUM((department_id NOT BETWEEN 1 AND 21) AND (aisle_id BETWEEN 1 AND 134)) AS department_only_problem,
    SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id NOT BETWEEN 1 AND 21)) AS both_problem
FROM products;
