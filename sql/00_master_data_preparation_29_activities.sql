/*
Instacart SQL Portfolio
MASTER DATA PREPARATION / CLEANING / PROFILING / VALIDATION SCRIPT
Schema: instacart_db

This file preserves the 29 documented SQL activities (4.1–4.29).
IMPORTANT: the exact historical SQL that repaired invalid product classifications was
not preserved in the source report. It is NOT fabricated here. products_clean is
assumed to be the validated controlled product dimension produced by that workflow.
*/

USE instacart_db;

/* =========================================================
   ACTIVITY 4.1 — Initial Row Counts Across Core Tables
   ========================================================= */
SELECT 'departments' AS table_name, COUNT(*) AS total_rows FROM departments
UNION ALL SELECT 'aisles', COUNT(*) FROM aisles
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_products__train', COUNT(*) FROM order_products__train
UNION ALL SELECT 'order_products__prior', COUNT(*) FROM order_products__prior;

/* ACTIVITY 4.2 — Duplicate Identifier Checks */
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT department_id) AS unique_department_ids,
       COUNT(*) - COUNT(DISTINCT department_id) AS duplicate_ids
FROM departments;
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT aisle_id) AS unique_aisle_ids,
       COUNT(*) - COUNT(DISTINCT aisle_id) AS duplicate_ids
FROM aisles;
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT product_id) AS unique_product_ids,
       COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_ids
FROM products;
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS unique_order_ids,
       COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids
FROM orders;

/* ACTIVITY 4.3 — Duplicate Order-Product Pair Checks */
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id, product_id) AS unique_order_product_pairs,
       COUNT(*) - COUNT(DISTINCT order_id, product_id) AS duplicate_pairs
FROM order_products__train;
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id, product_id) AS unique_order_product_pairs,
       COUNT(*) - COUNT(DISTINCT order_id, product_id) AS duplicate_pairs
FROM order_products__prior;

/* ACTIVITY 4.4 — Missing Values in Reference and Product Tables */
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

/* ACTIVITY 4.5 — Missing Values in Orders */
SELECT COUNT(*) AS total_rows,
       SUM(order_id IS NULL) AS null_order_id,
       SUM(user_id IS NULL) AS null_user_id,
       SUM(eval_set IS NULL) AS null_eval_set,
       SUM(order_number IS NULL) AS null_order_number,
       SUM(order_dow IS NULL) AS null_order_dow,
       SUM(order_hour_of_day IS NULL) AS null_order_hour,
       SUM(days_since_prior_order IS NULL) AS null_days_since_prior
FROM orders;

/* ACTIVITY 4.6 — Expected NULL Pattern for First Orders */
SELECT order_number, COUNT(*) AS null_records
FROM orders
WHERE days_since_prior_order IS NULL
GROUP BY order_number
ORDER BY order_number;
SELECT COUNT(*) AS first_orders,
       SUM(days_since_prior_order IS NULL) AS null_days_first_orders,
       SUM(days_since_prior_order IS NOT NULL) AS nonnull_days_first_orders
FROM orders
WHERE order_number = 1;

/* ACTIVITY 4.7 — Logical Range Validation for Orders */
SELECT MIN(order_number) AS min_order_number, MAX(order_number) AS max_order_number,
       MIN(order_dow) AS min_order_dow, MAX(order_dow) AS max_order_dow,
       MIN(order_hour_of_day) AS min_order_hour, MAX(order_hour_of_day) AS max_order_hour,
       MIN(days_since_prior_order) AS min_days_since_prior,
       MAX(days_since_prior_order) AS max_days_since_prior
FROM orders;

/* ACTIVITY 4.8 — Evaluation-Set Distribution */
SELECT eval_set, COUNT(*) AS total_orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_orders
FROM orders
GROUP BY eval_set;

/* ACTIVITY 4.9 — Product Backup Validation
   Run CREATE TABLE only once in a clean workflow. */
CREATE TABLE IF NOT EXISTS products_backup AS
SELECT * FROM products;
SELECT (SELECT COUNT(*) FROM products) AS original_rows,
       (SELECT COUNT(*) FROM products_backup) AS backup_rows;

/* ACTIVITY 4.10 — Invalid Product Category References Before Cleaning */
SELECT SUM(aisle_id NOT BETWEEN 1 AND 134) AS invalid_aisle_ids,
       SUM(department_id NOT BETWEEN 1 AND 21) AS invalid_department_ids,
       SUM(aisle_id = 0) AS zero_aisle_ids,
       SUM(department_id = 0) AS zero_department_ids,
       SUM(aisle_id > 134) AS aisle_ids_above_134,
       SUM(department_id > 21) AS department_ids_above_21
FROM products;

/* ACTIVITY 4.11 — Affected Product Classification Before Cleaning */
SELECT SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) AS total_affected_products,
       SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id BETWEEN 1 AND 21)) AS aisle_only_problem,
       SUM((department_id NOT BETWEEN 1 AND 21) AND (aisle_id BETWEEN 1 AND 134)) AS department_only_problem,
       SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id NOT BETWEEN 1 AND 21)) AS both_problem
FROM products;

/* -----------------------------------------------------------------
   HISTORICAL CORRECTION NOTE
   The exact SQL used to transform the affected raw product records into
   products_clean was not preserved in the source documentation. Do not
   invent or silently replace that transformation. The remaining activities
   validate the documented post-cleaning state.
   ----------------------------------------------------------------- */

/* ACTIVITY 4.12 — Clean Product Table Row Preservation */
SELECT COUNT(*) AS total_rows FROM products_clean;
SELECT (SELECT COUNT(*) FROM products_backup) AS backup_rows,
       (SELECT COUNT(*) FROM products_clean) AS clean_rows,
       (SELECT COUNT(*) FROM products_backup) - (SELECT COUNT(*) FROM products_clean) AS row_difference;

/* ACTIVITY 4.13 — Validation of Clean Product Category IDs */
SELECT COUNT(*) AS total_products,
       SUM(aisle_id NOT BETWEEN 1 AND 134) AS invalid_aisle_ids,
       SUM(department_id NOT BETWEEN 1 AND 21) AS invalid_department_ids,
       SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) AS total_affected_products
FROM products_clean;

/* ACTIVITY 4.14 — Duplicate, NULL, and Blank Checks in products_clean */
SELECT product_id, COUNT(*) AS occurrences
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

/* ACTIVITY 4.15 — Train Transaction Profiling */
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS unique_orders,
       COUNT(DISTINCT product_id) AS unique_products,
       MIN(add_to_cart_order) AS min_cart_position,
       MAX(add_to_cart_order) AS max_cart_position,
       MIN(reordered) AS min_reordered, MAX(reordered) AS max_reordered
FROM order_products__train;

/* ACTIVITY 4.16 — Train Transaction Missing Values */
SELECT COUNT(*) AS total_rows,
       SUM(order_id IS NULL) AS null_order_id,
       SUM(product_id IS NULL) AS null_product_id,
       SUM(add_to_cart_order IS NULL) AS null_cart_order,
       SUM(reordered IS NULL) AS null_reordered
FROM order_products__train;

/* ACTIVITY 4.17 — Train Cart-Position Sequence Validation */
SELECT order_id, COUNT(*) AS number_of_products,
       MIN(add_to_cart_order) AS first_position,
       MAX(add_to_cart_order) AS last_position,
       COUNT(DISTINCT add_to_cart_order) AS unique_positions
FROM order_products__train
GROUP BY order_id
HAVING MIN(add_to_cart_order) <> 1
    OR MAX(add_to_cart_order) <> COUNT(*)
    OR COUNT(DISTINCT add_to_cart_order) <> COUNT(*);

/* ACTIVITY 4.18 — Train Referential Integrity */
SELECT COUNT(DISTINCT op.order_id) AS unmatched_order_ids
FROM order_products__train op
LEFT JOIN orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;
SELECT COUNT(DISTINCT op.product_id) AS unmatched_product_ids
FROM order_products__train op
LEFT JOIN products_clean p ON op.product_id = p.product_id
WHERE p.product_id IS NULL;

/* ACTIVITY 4.19 — Train Reorder Distribution */
SELECT reordered, COUNT(*) AS row_count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_products__train), 2) AS percentage
FROM order_products__train
GROUP BY reordered
ORDER BY reordered;

/* ACTIVITY 4.20 — Train Evaluation-Set Consistency and Coverage */
SELECT o.eval_set, COUNT(DISTINCT op.order_id) AS number_of_orders
FROM order_products__train op
JOIN orders o ON op.order_id = o.order_id
GROUP BY o.eval_set;
SELECT COUNT(*) AS train_orders_without_products
FROM orders o
LEFT JOIN (SELECT DISTINCT order_id FROM order_products__train) op
  ON o.order_id = op.order_id
WHERE o.eval_set = 'train' AND op.order_id IS NULL;

/* ACTIVITY 4.21 — Aisle Reference Table Validation */
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT aisle_id) AS unique_aisle_ids,
       SUM(aisle_id IS NULL) AS null_aisle_id, SUM(aisle IS NULL) AS null_aisle
FROM aisles;
SELECT COUNT(*) AS blank_aisle_names FROM aisles WHERE TRIM(aisle) = '';
SELECT COUNT(DISTINCT p.aisle_id) AS unmatched_aisle_ids
FROM products_clean p LEFT JOIN aisles a ON p.aisle_id = a.aisle_id
WHERE a.aisle_id IS NULL;
SELECT COUNT(*) AS unused_aisles
FROM aisles a LEFT JOIN products_clean p ON a.aisle_id = p.aisle_id
WHERE p.product_id IS NULL;

/* ACTIVITY 4.22 — Department Reference Table Validation */
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT department_id) AS unique_department_ids,
       SUM(department_id IS NULL) AS null_department_id,
       SUM(department IS NULL) AS null_department
FROM departments;
SELECT COUNT(*) AS blank_department_names FROM departments WHERE TRIM(department) = '';
SELECT COUNT(DISTINCT p.department_id) AS unmatched_department_ids
FROM products_clean p LEFT JOIN departments d ON p.department_id = d.department_id
WHERE d.department_id IS NULL;
SELECT COUNT(*) AS unused_departments
FROM departments d LEFT JOIN products_clean p ON d.department_id = p.department_id
WHERE p.product_id IS NULL;

/* ACTIVITY 4.23 — Product Hierarchy Validation */
SELECT COUNT(*) AS total_products,
       COUNT(a.aisle_id) AS products_with_valid_aisle,
       COUNT(d.department_id) AS products_with_valid_department
FROM products_clean p
LEFT JOIN aisles a ON p.aisle_id = a.aisle_id
LEFT JOIN departments d ON p.department_id = d.department_id;
SELECT aisle_id, COUNT(DISTINCT department_id) AS department_count
FROM products_clean
GROUP BY aisle_id
HAVING COUNT(DISTINCT department_id) > 1;

/* ACTIVITY 4.24 — Prior Profiling + Missing Values */
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS unique_orders,
       COUNT(DISTINCT product_id) AS unique_products,
       MIN(add_to_cart_order) AS min_cart_position,
       MAX(add_to_cart_order) AS max_cart_position,
       MIN(reordered) AS min_reordered, MAX(reordered) AS max_reordered
FROM order_products__prior;
SELECT COUNT(*) AS total_rows,
       SUM(order_id IS NULL) AS null_order_id,
       SUM(product_id IS NULL) AS null_product_id,
       SUM(add_to_cart_order IS NULL) AS null_cart_order,
       SUM(reordered IS NULL) AS null_reordered
FROM order_products__prior;

/* ACTIVITY 4.25 — Prior Duplicate + Cart-Sequence Validation */
SELECT order_id, product_id, COUNT(*) AS occurrences
FROM order_products__prior
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;
SELECT order_id, COUNT(*) AS number_of_products,
       MIN(add_to_cart_order) AS first_position,
       MAX(add_to_cart_order) AS last_position,
       COUNT(DISTINCT add_to_cart_order) AS unique_positions
FROM order_products__prior
GROUP BY order_id
HAVING MIN(add_to_cart_order) <> 1
    OR MAX(add_to_cart_order) <> COUNT(*)
    OR COUNT(DISTINCT add_to_cart_order) <> COUNT(*);

/* ACTIVITY 4.26 — Prior Referential Integrity */
SELECT COUNT(DISTINCT op.order_id) AS unmatched_order_ids
FROM order_products__prior op
LEFT JOIN orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;
SELECT COUNT(DISTINCT op.product_id) AS unmatched_product_ids
FROM order_products__prior op
LEFT JOIN products_clean p ON op.product_id = p.product_id
WHERE p.product_id IS NULL;

/* ACTIVITY 4.27 — End-to-End Product Hierarchy: Prior */
SELECT COUNT(*) AS total_order_product_rows,
       SUM(p.product_id IS NULL) AS missing_product,
       SUM(a.aisle_id IS NULL) AS missing_aisle,
       SUM(d.department_id IS NULL) AS missing_department
FROM order_products__prior op
LEFT JOIN products_clean p ON op.product_id = p.product_id
LEFT JOIN aisles a ON p.aisle_id = a.aisle_id
LEFT JOIN departments d ON p.department_id = d.department_id;

/* ACTIVITY 4.28 — End-to-End Product Hierarchy: Train */
SELECT COUNT(*) AS total_order_product_rows,
       SUM(p.product_id IS NULL) AS missing_product,
       SUM(a.aisle_id IS NULL) AS missing_aisle,
       SUM(d.department_id IS NULL) AS missing_department
FROM order_products__train op
LEFT JOIN products_clean p ON op.product_id = p.product_id
LEFT JOIN aisles a ON p.aisle_id = a.aisle_id
LEFT JOIN departments d ON p.department_id = d.department_id;

/* ACTIVITY 4.29 — Consolidated Validation Outcome */
SELECT (SELECT COUNT(*) FROM order_products__prior) AS prior_rows,
       (SELECT COUNT(*) FROM order_products__train) AS train_rows,
       (SELECT COUNT(*) FROM order_products__prior) +
       (SELECT COUNT(*) FROM order_products__train) AS combined_transaction_rows;
