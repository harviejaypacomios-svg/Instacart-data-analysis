/* Instacart Business Analysis — Activities 12–18 */
USE instacart_db;

/* ACTIVITY 12 — Top Products by Purchase Volume */
SELECT p.product_id,
       p.product_name,
       COUNT(*) AS total_purchases,
       COUNT(DISTINCT op.order_id) AS total_orders
FROM order_products__prior op
JOIN products_clean p ON op.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_purchases DESC
LIMIT 10;

-- Product-match validation: expected 32,434,489 / 32,434,489 / 0
SELECT COUNT(*) AS total_prior_rows,
       COUNT(p.product_id) AS matched_product_rows,
       COUNT(*) - COUNT(p.product_id) AS unmatched_product_rows
FROM order_products__prior op
LEFT JOIN products_clean p ON op.product_id = p.product_id;

/* ACTIVITY 13 — Top Products by Reordered Purchase Volume */
SELECT p.product_id,
       p.product_name,
       COUNT(*) AS total_purchases,
       SUM(op.reordered) AS reordered_purchases,
       ROUND(SUM(op.reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_pct
FROM order_products__prior op
JOIN products_clean p ON op.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY reordered_purchases DESC
LIMIT 10;

/* ACTIVITY 14 — Highest Reorder Rate Products */
-- Minimum 1,000 purchases reduces instability from tiny-volume products.
SELECT p.product_id,
       p.product_name,
       COUNT(*) AS total_purchases,
       SUM(op.reordered) AS reordered_purchases,
       ROUND(SUM(op.reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_pct
FROM order_products__prior op
JOIN products_clean p ON op.product_id = p.product_id
GROUP BY p.product_id, p.product_name
HAVING COUNT(*) >= 1000
ORDER BY reorder_rate_pct DESC, total_purchases DESC
LIMIT 10;

/* ACTIVITY 15 — Department Performance Analysis */
SELECT d.department_id,
       d.department,
       COUNT(*) AS total_purchases,
       COUNT(DISTINCT op.order_id) AS total_orders,
       COUNT(DISTINCT p.product_id) AS unique_products
FROM order_products__prior op
JOIN products_clean p ON op.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department_id, d.department
ORDER BY total_purchases DESC;

/* ACTIVITY 16 — Aisle Performance Analysis */
SELECT a.aisle_id,
       a.aisle,
       COUNT(*) AS total_purchases,
       COUNT(DISTINCT op.order_id) AS total_orders,
       COUNT(DISTINCT p.product_id) AS unique_products
FROM order_products__prior op
JOIN products_clean p ON op.product_id = p.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
GROUP BY a.aisle_id, a.aisle
ORDER BY total_purchases DESC;

/* ACTIVITY 17 — Aisle Reorder Rate */
SELECT a.aisle_id,
       a.aisle,
       COUNT(*) AS total_purchases,
       SUM(op.reordered) AS reordered_purchases,
       ROUND(SUM(op.reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_pct
FROM order_products__prior op
JOIN products_clean p ON op.product_id = p.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
GROUP BY a.aisle_id, a.aisle
ORDER BY reorder_rate_pct DESC;

-- Reconciliation: expected 32,434,489
SELECT SUM(aisle_total) AS reconciled_total_purchases
FROM (
    SELECT p.aisle_id, COUNT(*) AS aisle_total
    FROM order_products__prior op
    JOIN products_clean p ON op.product_id = p.product_id
    GROUP BY p.aisle_id
) x;

/* ACTIVITY 18 — Department Reorder Rate */
SELECT d.department_id,
       d.department,
       COUNT(*) AS total_purchases,
       SUM(op.reordered) AS reordered_purchases,
       ROUND(SUM(op.reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_pct
FROM order_products__prior op
JOIN products_clean p ON op.product_id = p.product_id
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department_id, d.department
ORDER BY reorder_rate_pct DESC;

-- Reconciliation: expected 32,434,489
SELECT SUM(department_total) AS reconciled_total_purchases
FROM (
    SELECT p.department_id, COUNT(*) AS department_total
    FROM order_products__prior op
    JOIN products_clean p ON op.product_id = p.product_id
    GROUP BY p.department_id
) x;
