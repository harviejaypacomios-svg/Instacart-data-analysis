/* Instacart Business Analysis — Activities 8–11 and 19–20 */
USE instacart_db;

/* ACTIVITY 8 — Basket Size Summary */
WITH basket_sizes AS (
    SELECT order_id, COUNT(*) AS basket_size
    FROM order_products__prior
    GROUP BY order_id
)
SELECT COUNT(*) AS total_orders_analyzed,
       ROUND(AVG(basket_size), 2) AS avg_basket_size,
       MIN(basket_size) AS min_basket_size,
       MAX(basket_size) AS max_basket_size
FROM basket_sizes;

/* ACTIVITY 9 — Basket Size Segmentation */
WITH basket_sizes AS (
    SELECT order_id, COUNT(*) AS basket_size
    FROM order_products__prior
    GROUP BY order_id
), segmented AS (
    SELECT order_id,
           basket_size,
           CASE
               WHEN basket_size BETWEEN 1 AND 5 THEN 'Small (1-5)'
               WHEN basket_size BETWEEN 6 AND 10 THEN 'Medium (6-10)'
               WHEN basket_size BETWEEN 11 AND 20 THEN 'Large (11-20)'
               ELSE 'Very Large (21+)'
           END AS basket_segment
    FROM basket_sizes
)
SELECT basket_segment,
       COUNT(*) AS total_orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM segmented), 2) AS pct_of_orders,
       ROUND(AVG(basket_size), 2) AS avg_basket_size
FROM segmented
GROUP BY basket_segment
ORDER BY MIN(basket_size);

/* ACTIVITY 10 — Overall Product Reorder Rate */
SELECT COUNT(*) AS total_product_purchases,
       SUM(reordered) AS reordered_purchases,
       COUNT(*) - SUM(reordered) AS first_time_purchases,
       ROUND(SUM(reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_pct
FROM order_products__prior;

/* ACTIVITY 11 — Reorder Rate by Basket Segment */
WITH basket_sizes AS (
    SELECT order_id, COUNT(*) AS basket_size
    FROM order_products__prior
    GROUP BY order_id
), basket_segments AS (
    SELECT order_id,
           CASE
               WHEN basket_size BETWEEN 1 AND 5 THEN 'Small (1-5)'
               WHEN basket_size BETWEEN 6 AND 10 THEN 'Medium (6-10)'
               WHEN basket_size BETWEEN 11 AND 20 THEN 'Large (11-20)'
               ELSE 'Very Large (21+)'
           END AS basket_segment
    FROM basket_sizes
)
SELECT bs.basket_segment,
       COUNT(*) AS total_purchases,
       SUM(op.reordered) AS reordered_purchases,
       ROUND(SUM(op.reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_pct
FROM order_products__prior op
JOIN basket_segments bs ON op.order_id = bs.order_id
GROUP BY bs.basket_segment
ORDER BY reorder_rate_pct DESC;

/* ACTIVITY 19 — Add-to-Cart Position and Reorder Behavior */
SELECT CASE
           WHEN add_to_cart_order BETWEEN 1 AND 5 THEN '1-5 Early'
           WHEN add_to_cart_order BETWEEN 6 AND 10 THEN '6-10'
           WHEN add_to_cart_order BETWEEN 11 AND 20 THEN '11-20'
           ELSE '21+ Late'
       END AS cart_position_segment,
       COUNT(*) AS total_purchases,
       SUM(reordered) AS reordered_purchases,
       ROUND(SUM(reordered) * 100.0 / COUNT(*), 2) AS reorder_rate_pct
FROM order_products__prior
GROUP BY cart_position_segment
ORDER BY MIN(add_to_cart_order);

-- Reconciliation: expected 32,434,489
SELECT COUNT(*) AS total_prior_product_rows FROM order_products__prior;

/* ACTIVITY 20 — Customer Reorder Segmentation */
WITH customer_reorders AS (
    SELECT o.user_id,
           COUNT(*) AS total_purchases,
           SUM(op.reordered) AS reordered_purchases,
           SUM(op.reordered) * 100.0 / COUNT(*) AS reorder_rate_pct
    FROM order_products__prior op
    JOIN orders o ON op.order_id = o.order_id
    GROUP BY o.user_id
), segmented AS (
    SELECT user_id,
           total_purchases,
           reordered_purchases,
           reorder_rate_pct,
           CASE
               WHEN reorder_rate_pct >= 75 THEN 'Very High (75%+)'
               WHEN reorder_rate_pct >= 50 THEN 'High (50-74.99%)'
               WHEN reorder_rate_pct >= 25 THEN 'Moderate (25-49.99%)'
               ELSE 'Low (<25%)'
           END AS reorder_segment
    FROM customer_reorders
)
SELECT reorder_segment,
       COUNT(*) AS total_customers,
       SUM(total_purchases) AS total_purchases,
       SUM(reordered_purchases) AS reordered_purchases,
       ROUND(AVG(reorder_rate_pct), 2) AS avg_customer_reorder_rate_pct
FROM segmented
GROUP BY reorder_segment
ORDER BY MIN(reorder_rate_pct) DESC;

-- Reconciliation
SELECT COUNT(DISTINCT o.user_id) AS customers_in_prior,
       COUNT(*) AS total_purchases,
       SUM(op.reordered) AS reordered_purchases
FROM order_products__prior op
JOIN orders o ON op.order_id = o.order_id;
