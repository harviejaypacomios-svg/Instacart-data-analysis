-- ============================================================
-- INSTACART ONLINE GROCERY BASKET ANALYSIS
-- 04 - DATA VALIDATION
-- Database: instacart_db
-- Purpose: Prove referential integrity, reference-table quality,
--          hierarchy consistency, and end-to-end analytical readiness.
-- ============================================================

USE instacart_db;

-- ------------------------------------------------------------
-- 1. Train transactions -> orders / products_clean
-- Verified result: 0 unmatched order IDs and 0 unmatched product IDs.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 2. Train evaluation-set consistency and coverage
-- Verified result: train only, 131,209 distinct train orders,
-- 0 train orders without products.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 3. Aisle reference-table validation
-- Verified result: 134 unique aisles, no NULL/blank names,
-- 0 unmatched product aisle IDs, 0 unused aisles.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 4. Department reference-table validation
-- Verified result: 21 unique departments, no NULL/blank names,
-- 0 unmatched product department IDs, 0 unused departments.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 5. Product hierarchy validation
-- Verified result: all 49,688 products have valid aisle and
-- department mappings; no aisle spans multiple departments.
-- ------------------------------------------------------------
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

-- Direct validation used in the portfolio cleaning case study.
-- Verified result: 0 unmatched products.
SELECT COUNT(*) AS unmatched_products
FROM products_clean p
LEFT JOIN aisles a
       ON p.aisle_id = a.aisle_id
LEFT JOIN departments d
       ON p.department_id = d.department_id
WHERE a.aisle_id IS NULL
   OR d.department_id IS NULL;

-- ------------------------------------------------------------
-- 6. Prior transactions -> orders / products_clean
-- Verified result: 0 unmatched order IDs and product IDs.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 7. End-to-end hierarchy validation: prior transactions
-- Verified result:
-- total rows 32,434,489; missing product/aisle/department = 0.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 8. End-to-end hierarchy validation: train transactions
-- Verified result:
-- total rows 1,384,617; missing product/aisle/department = 0.
-- ------------------------------------------------------------
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

-- ------------------------------------------------------------
-- 9. Consolidated transaction count
-- Verified result: 33,819,106 rows validated in total.
-- ------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM order_products__prior) AS prior_rows,
    (SELECT COUNT(*) FROM order_products__train) AS train_rows,
    (SELECT COUNT(*) FROM order_products__prior) +
    (SELECT COUNT(*) FROM order_products__train) AS combined_transaction_rows;
