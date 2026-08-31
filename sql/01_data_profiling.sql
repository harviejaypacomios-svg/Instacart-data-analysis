-- ============================================================
-- INSTACART ONLINE GROCERY BASKET ANALYSIS
-- 01 - DATA PROFILING
-- Database: instacart_db
-- Purpose: Establish table size, grain, key uniqueness,
--          logical ranges, and baseline distributions.
-- ============================================================

USE instacart_db;

-- ------------------------------------------------------------
-- 1. Initial row counts across core tables
-- Verified results:
-- departments              21
-- aisles                  134
-- products             49,688
-- orders            3,421,083
-- order_products__train 1,384,617
-- order_products__prior 32,434,489
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 2. Unique identifier checks at expected table grain
-- Verified result: 0 duplicate IDs in all four tables.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 3. Order evaluation-set distribution
-- Verified results:
-- prior = 3,214,874 (93.97%)
-- train =   131,209 (3.84%)
-- test  =    75,000 (2.19%)
-- ------------------------------------------------------------
SELECT eval_set,
       COUNT(*) AS total_orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_orders
FROM orders
GROUP BY eval_set;

-- ------------------------------------------------------------
-- 4. Logical range validation for orders
-- Verified ranges:
-- order_number: 1-100
-- order_dow: 0-6
-- order_hour_of_day: 0-23
-- days_since_prior_order: 0.0-30.0
-- ------------------------------------------------------------
SELECT MIN(order_number) AS min_order_number,
       MAX(order_number) AS max_order_number,
       MIN(order_dow) AS min_order_dow,
       MAX(order_dow) AS max_order_dow,
       MIN(order_hour_of_day) AS min_order_hour,
       MAX(order_hour_of_day) AS max_order_hour,
       MIN(days_since_prior_order) AS min_days_since_prior,
       MAX(days_since_prior_order) AS max_days_since_prior
FROM orders;

-- ------------------------------------------------------------
-- 5. Profile order_products__train
-- Verified results:
-- rows 1,384,617 | orders 131,209 | products 39,123
-- cart position 1-80 | reordered 0-1
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_orders,
       COUNT(DISTINCT product_id) AS unique_products,
       MIN(add_to_cart_order) AS min_cart_position,
       MAX(add_to_cart_order) AS max_cart_position,
       MIN(reordered) AS min_reordered,
       MAX(reordered) AS max_reordered
FROM order_products__train;

-- ------------------------------------------------------------
-- 6. Profile order_products__prior
-- Verified results:
-- rows 32,434,489 | orders 3,214,874 | products 49,677
-- cart position 1-145 | reordered 0-1
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_orders,
       COUNT(DISTINCT product_id) AS unique_products,
       MIN(add_to_cart_order) AS min_cart_position,
       MAX(add_to_cart_order) AS max_cart_position,
       MIN(reordered) AS min_reordered,
       MAX(reordered) AS max_reordered
FROM order_products__prior;

-- ------------------------------------------------------------
-- 7. Reorder distribution in training transactions
-- Verified results:
-- 0 = 555,793 (40.14%)
-- 1 = 828,824 (59.86%)
-- ------------------------------------------------------------
SELECT reordered,
       COUNT(*) AS row_count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_products__train), 2) AS percentage
FROM order_products__train
GROUP BY reordered
ORDER BY reordered;
