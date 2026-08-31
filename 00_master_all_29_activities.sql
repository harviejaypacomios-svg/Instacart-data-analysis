-- ============================================================
-- INSTACART ONLINE GROCERY BASKET ANALYSIS
-- 00 - MASTER SQL: ALL 29 DOCUMENTED ACTIVITIES
-- Database: instacart_db
-- Purpose: One chronological script containing every SQL activity
--          documented in the saved preparation/cleaning/validation report.
-- ============================================================

USE instacart_db;

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

-- ACTIVITY 4.3 - Duplicate Order-Product Pair Checks
-- Verified result: 0 duplicate order_id + product_id pairs in train and prior.
-- ============================================================
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id, product_id) AS unique_order_product_pairs,
       COUNT(*) - COUNT(DISTINCT order_id, product_id) AS duplicate_pairs
FROM order_products__train;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id, product_id) AS unique_order_product_pairs,
       COUNT(*) - COUNT(DISTINCT order_id, product_id) AS duplicate_pairs
FROM order_products__prior;

-- ============================================================

-- ACTIVITY 4.4 - Missing Values in Reference and Product Tables
-- Verified result: 0 NULLs in required fields.
-- ============================================================
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

-- ============================================================

-- ACTIVITY 4.5 - Missing Values in Orders
-- Verified result: only days_since_prior_order has NULLs (206,209).
-- ============================================================
SELECT COUNT(*) AS total_rows,
       SUM(order_id IS NULL) AS null_order_id,
       SUM(user_id IS NULL) AS null_user_id,
       SUM(eval_set IS NULL) AS null_eval_set,
       SUM(order_number IS NULL) AS null_order_number,
       SUM(order_dow IS NULL) AS null_order_dow,
       SUM(order_hour_of_day IS NULL) AS null_order_hour,
       SUM(days_since_prior_order IS NULL) AS null_days_since_prior
FROM orders;

-- ============================================================

-- ACTIVITY 4.6 - Confirmation of Expected NULL Pattern for First Orders
-- Verified result:
-- 206,209 first orders; all 206,209 have NULL days_since_prior_order.
-- ============================================================
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

-- ACTIVITY 4.9 - Product Backup Validation
-- Run CREATE TABLE only once on a fresh project copy.
-- Verified result: products = 49,688 rows; products_backup = 49,688 rows.
-- ============================================================
CREATE TABLE products_backup AS
SELECT * FROM products;

SELECT (SELECT COUNT(*) FROM products) AS original_rows,
       (SELECT COUNT(*) FROM products_backup) AS backup_rows;

-- ============================================================

-- ACTIVITY 4.10 - Detection of Invalid Product Category References Before Cleaning
-- Repeated here because it is the direct pre-cleaning diagnostic.
-- ============================================================
SELECT
    SUM(aisle_id NOT BETWEEN 1 AND 134) AS invalid_aisle_ids,
    SUM(department_id NOT BETWEEN 1 AND 21) AS invalid_department_ids,
    SUM(aisle_id = 0) AS zero_aisle_ids,
    SUM(department_id = 0) AS zero_department_ids,
    SUM(aisle_id > 134) AS aisle_ids_above_134,
    SUM(department_id > 21) AS department_ids_above_21
FROM products;

-- ============================================================

-- ACTIVITY 4.11 - Affected Product Classification Before Cleaning
-- Verified result: 3,203 affected products.
-- ============================================================
SELECT
    SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) AS total_affected_products,
    SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id BETWEEN 1 AND 21)) AS aisle_only_problem,
    SUM((department_id NOT BETWEEN 1 AND 21) AND (aisle_id BETWEEN 1 AND 134)) AS department_only_problem,
    SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id NOT BETWEEN 1 AND 21)) AS both_problem
FROM products;

-- ============================================================
-- HISTORICAL CORRECTION STEP - NOT PRESERVED IN THE SAVED REPORT
-- ============================================================
-- The report confirms that products_clean became the controlled analytical
-- product table and that invalid category references were reduced to zero,
-- but it does not contain the exact CREATE/UPDATE/mapping statement used.
-- Do not add guessed code here.

-- ============================================================

-- ACTIVITY 4.12 - Clean Product Table Row Preservation
-- Verified results:
-- products_clean total rows = 49,688
-- backup rows = 49,688
-- clean rows = 49,688
-- row difference = 0
-- ============================================================
SELECT COUNT(*) AS total_rows
FROM products_clean;

SELECT
    (SELECT COUNT(*) FROM products_backup) AS backup_rows,
    (SELECT COUNT(*) FROM products_clean) AS clean_rows,
    (SELECT COUNT(*) FROM products_backup) - (SELECT COUNT(*) FROM products_clean) AS row_difference;

-- ============================================================

-- ACTIVITY 4.13 - Validation of Clean Product Category IDs
-- Verified result: 0 invalid aisle IDs, 0 invalid department IDs, 0 affected products.
-- ============================================================
SELECT COUNT(*) AS total_products,
       SUM(aisle_id NOT BETWEEN 1 AND 134) AS invalid_aisle_ids,
       SUM(department_id NOT BETWEEN 1 AND 21) AS invalid_department_ids,
       SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) AS total_affected_products
FROM products_clean;

-- ============================================================

-- ACTIVITY 4.14 - Duplicate, NULL, and Blank Checks in products_clean
-- Verified result: 0 duplicate product IDs, 0 NULLs, 0 blank product names.
-- ============================================================
SELECT product_id,
       COUNT(*) AS occurrences
FROM products_clean
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT SUM(product_id IS NULL) AS null_product_id,
       SUM(product_name IS NULL) AS null_product_name,
       SUM(aisle_id IS NULL) AS null_aisle_id,
       SUM(department_id IS NULL) AS null_department_id
FROM products_clean;

SELECT COUNT(*) AS blank_product_names
FROM products_clean
WHERE TRIM(product_name) = '';

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

-- ACTIVITY 4.16 - Missing Values: order_products__train
-- Verified result: 0 NULLs in all four essential fields.
-- ============================================================
SELECT COUNT(*) AS total_rows,
       SUM(order_id IS NULL) AS null_order_id,
       SUM(product_id IS NULL) AS null_product_id,
       SUM(add_to_cart_order IS NULL) AS null_cart_order,
       SUM(reordered IS NULL) AS null_reordered
FROM order_products__train;

-- ============================================================

-- ACTIVITY 4.17 - Cart-Position Sequence Validation: order_products__train
-- Verified result: 0 invalid orders.
-- ============================================================
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

-- ============================================================

-- ACTIVITY 4.18 - Referential Integrity: Train to Orders and Products
-- Verified result: 0 unmatched train order IDs; 0 unmatched train product IDs.
-- ============================================================
SELECT COUNT(DISTINCT op.order_id) AS unmatched_order_ids
FROM order_products__train op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(DISTINCT op.product_id) AS unmatched_product_ids
FROM order_products__train op
LEFT JOIN products_clean p
    ON op.product_id = p.product_id
WHERE p.product_id IS NULL;

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

-- ACTIVITY 4.20 - Train Evaluation-Set Consistency and Coverage
-- Verified result: train only; 131,209 distinct train orders; 0 train orders without products.
-- ============================================================
SELECT o.eval_set,
       COUNT(DISTINCT op.order_id) AS number_of_orders
FROM order_products__train op
JOIN orders o
    ON op.order_id = o.order_id
GROUP BY o.eval_set;

SELECT COUNT(*) AS train_orders_without_products
FROM orders o
LEFT JOIN (
    SELECT DISTINCT order_id
    FROM order_products__train
) op ON o.order_id = op.order_id
WHERE o.eval_set = 'train'
  AND op.order_id IS NULL;

-- ============================================================

-- ACTIVITY 4.21 - Aisle Reference Table Validation
-- Verified result: 134 rows / 134 unique IDs; 0 NULLs/blanks;
-- 0 unmatched product aisle IDs; 0 unused aisles.
-- ============================================================
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT aisle_id) AS unique_aisle_ids,
       SUM(aisle_id IS NULL) AS null_aisle_id,
       SUM(aisle IS NULL) AS null_aisle
FROM aisles;

SELECT COUNT(*) AS blank_aisle_names
FROM aisles
WHERE TRIM(aisle) = '';

SELECT COUNT(DISTINCT p.aisle_id) AS unmatched_aisle_ids
FROM products_clean p
LEFT JOIN aisles a
    ON p.aisle_id = a.aisle_id
WHERE a.aisle_id IS NULL;

SELECT COUNT(*) AS unused_aisles
FROM aisles a
LEFT JOIN products_clean p
    ON a.aisle_id = p.aisle_id
WHERE p.product_id IS NULL;

-- ============================================================

-- ACTIVITY 4.22 - Department Reference Table Validation
-- Verified result: 21 rows / 21 unique IDs; 0 NULLs/blanks;
-- 0 unmatched product department IDs; 0 unused departments.
-- ============================================================
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT department_id) AS unique_department_ids,
       SUM(department_id IS NULL) AS null_department_id,
       SUM(department IS NULL) AS null_department
FROM departments;

SELECT COUNT(*) AS blank_department_names
FROM departments
WHERE TRIM(department) = '';

SELECT COUNT(DISTINCT p.department_id) AS unmatched_department_ids
FROM products_clean p
LEFT JOIN departments d
    ON p.department_id = d.department_id
WHERE d.department_id IS NULL;

SELECT COUNT(*) AS unused_departments
FROM departments d
LEFT JOIN products_clean p
    ON d.department_id = p.department_id
WHERE p.product_id IS NULL;

-- ============================================================

-- ACTIVITY 4.23 - Product Hierarchy Validation
-- Verified result:
-- total products = 49,688
-- valid aisle mappings = 49,688
-- valid department mappings = 49,688
-- aisles associated with >1 department = 0 rows.
-- ============================================================
SELECT COUNT(*) AS total_products,
       COUNT(a.aisle_id) AS products_with_valid_aisle,
       COUNT(d.department_id) AS products_with_valid_department
FROM products_clean p
LEFT JOIN aisles a
    ON p.aisle_id = a.aisle_id
LEFT JOIN departments d
    ON p.department_id = d.department_id;

SELECT aisle_id,
       COUNT(DISTINCT department_id) AS department_count
FROM products_clean
GROUP BY aisle_id
HAVING COUNT(DISTINCT department_id) > 1;

-- Portfolio-facing direct unmatched-product check.
-- Verified result: 0 unmatched products.
SELECT COUNT(*) AS unmatched_products
FROM products_clean p
LEFT JOIN aisles a
    ON p.aisle_id = a.aisle_id
LEFT JOIN departments d
    ON p.department_id = d.department_id
WHERE a.aisle_id IS NULL
   OR d.department_id IS NULL;

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

-- ACTIVITY 4.24 (missing-value portion) - Prior Transaction Missing-Value Validation
-- Verified result: 0 NULLs in all four essential fields.
-- Note: the profiling portion of Activity 4.24 is in 01_data_profiling.sql.
-- ============================================================
SELECT COUNT(*) AS total_rows,
       SUM(order_id IS NULL) AS null_order_id,
       SUM(product_id IS NULL) AS null_product_id,
       SUM(add_to_cart_order IS NULL) AS null_cart_order,
       SUM(reordered IS NULL) AS null_reordered
FROM order_products__prior;

-- ============================================================

-- ACTIVITY 4.25 - Prior Transaction Duplicate and Cart-Sequence Validation
-- IMPORTANT: This exact grouped duplicate query was missing from the first GitHub package.
-- It is restored here from the saved SQL report.
-- Verified result: 0 duplicate rows returned; 0 invalid cart sequences.
-- ============================================================
SELECT order_id,
       product_id,
       COUNT(*) AS occurrences
FROM order_products__prior
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

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

-- ACTIVITY 4.26 - Prior Referential Integrity: Orders and Products
-- Verified result: 0 unmatched prior order IDs; 0 unmatched prior product IDs.
-- ============================================================
SELECT COUNT(DISTINCT op.order_id) AS unmatched_order_ids
FROM order_products__prior op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(DISTINCT op.product_id) AS unmatched_product_ids
FROM order_products__prior op
LEFT JOIN products_clean p
    ON op.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ============================================================

-- ACTIVITY 4.27 - End-to-End Product Hierarchy: Prior Transactions
-- Verified result: 32,434,489 rows; 0 missing product / aisle / department references.
-- ============================================================
SELECT COUNT(*) AS total_order_product_rows,
       SUM(p.product_id IS NULL) AS missing_product,
       SUM(a.aisle_id IS NULL) AS missing_aisle,
       SUM(d.department_id IS NULL) AS missing_department
FROM order_products__prior op
LEFT JOIN products_clean p
    ON op.product_id = p.product_id
LEFT JOIN aisles a
    ON p.aisle_id = a.aisle_id
LEFT JOIN departments d
    ON p.department_id = d.department_id;

-- ============================================================

-- ACTIVITY 4.28 - End-to-End Product Hierarchy: Train Transactions
-- Verified result: 1,384,617 rows; 0 missing product / aisle / department references.
-- ============================================================
SELECT COUNT(*) AS total_order_product_rows,
       SUM(p.product_id IS NULL) AS missing_product,
       SUM(a.aisle_id IS NULL) AS missing_aisle,
       SUM(d.department_id IS NULL) AS missing_department
FROM order_products__train op
LEFT JOIN products_clean p
    ON op.product_id = p.product_id
LEFT JOIN aisles a
    ON p.aisle_id = a.aisle_id
LEFT JOIN departments d
    ON p.department_id = d.department_id;

-- ============================================================

-- ACTIVITY 4.29 - Consolidated Validation Outcome
-- Verified result: 33,819,106 combined transaction rows validated.
-- Final hierarchy tests: 0 missing products, aisles, departments.
-- ============================================================
SELECT
    (SELECT COUNT(*) FROM order_products__prior) AS prior_rows,
    (SELECT COUNT(*) FROM order_products__train) AS train_rows,
    (SELECT COUNT(*) FROM order_products__prior) +
    (SELECT COUNT(*) FROM order_products__train) AS combined_transaction_rows;
