-- ============================================================
-- INSTACART ONLINE GROCERY BASKET ANALYSIS
-- 01 - DATA PROFILING
-- Database: instacart_db
-- Source basis: documented Activities 4.1-4.29 in the saved SQL report
-- Purpose: Establish size, grain, uniqueness, ranges, and baseline distributions.
-- ============================================================

USE instacart_db;

-- ============================================================
-- ACTIVITY 4.1 - Initial Row Counts Across Core Tables
-- Verified results:
-- departments = 21
-- aisles = 134
-- products = 49,688
-- orders = 3,421,083
-- order_products__train = 1,384,617
-- order_products__prior = 32,434,489
-- ============================================================
SELECT 'departments' AS table_name, COUNT(*) AS total_rows FROM departments
UNION ALL
SELECT 'aisles', COUNT(*) FROM aisles
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_products__train', COUNT(*) FROM order_products__train
UNION ALL
SELECT 'order_products__prior', COUNT(*) FROM order_products__prior;

-- ============================================================
-- ACTIVITY 4.2 - Duplicate Identifier Checks for Reference and Master Tables
-- Verified result: 0 duplicate IDs in departments, aisles, products, and orders.
-- ============================================================
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT department_id) AS unique_department_ids,
       COUNT(*) - COUNT(DISTINCT department_id) AS duplicate_ids
FROM departments;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT aisle_id) AS unique_aisle_ids,
       COUNT(*) - COUNT(DISTINCT aisle_id) AS duplicate_ids
FROM aisles;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT product_id) AS unique_product_ids,
       COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_ids
FROM products;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_order_ids,
       COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids
FROM orders;

-- ============================================================
-- ACTIVITY 4.7 - Logical Range Validation for Orders
-- Verified ranges:
-- order_number = 1 to 100
-- order_dow = 0 to 6
-- order_hour_of_day = 0 to 23
-- days_since_prior_order = 0.0 to 30.0
-- ============================================================
SELECT MIN(order_number) AS min_order_number,
       MAX(order_number) AS max_order_number,
       MIN(order_dow) AS min_order_dow,
       MAX(order_dow) AS max_order_dow,
       MIN(order_hour_of_day) AS min_order_hour,
       MAX(order_hour_of_day) AS max_order_hour,
       MIN(days_since_prior_order) AS min_days_since_prior,
       MAX(days_since_prior_order) AS max_days_since_prior
FROM orders;

-- ============================================================
-- ACTIVITY 4.8 - Order Evaluation-Set Distribution
-- Verified results:
-- prior = 3,214,874 (93.97%)
-- train = 131,209 (3.84%)
-- test = 75,000 (2.19%)
-- ============================================================
SELECT eval_set,
       COUNT(*) AS total_orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_orders
FROM orders
GROUP BY eval_set;

-- ============================================================
-- ACTIVITY 4.15 - Transaction Table Profiling: order_products__train
-- Verified results:
-- total rows = 1,384,617
-- unique orders = 131,209
-- unique products = 39,123
-- cart position = 1 to 80
-- reordered = 0 to 1
-- ============================================================
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_orders,
       COUNT(DISTINCT product_id) AS unique_products,
       MIN(add_to_cart_order) AS min_cart_position,
       MAX(add_to_cart_order) AS max_cart_position,
       MIN(reordered) AS min_reordered,
       MAX(reordered) AS max_reordered
FROM order_products__train;

-- ============================================================
-- ACTIVITY 4.19 - Reorder Distribution: order_products__train
-- Verified results:
-- reordered = 0 -> 555,793 rows (40.14%)
-- reordered = 1 -> 828,824 rows (59.86%)
-- ============================================================
SELECT reordered,
       COUNT(*) AS row_count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_products__train), 2) AS percentage
FROM order_products__train
GROUP BY reordered
ORDER BY reordered;

-- ============================================================
-- ACTIVITY 4.24 (profiling portion) - Prior Transaction Table Profiling
-- Verified results:
-- total rows = 32,434,489
-- unique orders = 3,214,874
-- unique products = 49,677
-- cart position = 1 to 145
-- reordered = 0 to 1
-- Note: the missing-value portion of Activity 4.24 is in 02_data_quality_checks.sql.
-- ============================================================
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_orders,
       COUNT(DISTINCT product_id) AS unique_products,
       MIN(add_to_cart_order) AS min_cart_position,
       MAX(add_to_cart_order) AS max_cart_position,
       MIN(reordered) AS min_reordered,
       MAX(reordered) AS max_reordered
FROM order_products__prior;
