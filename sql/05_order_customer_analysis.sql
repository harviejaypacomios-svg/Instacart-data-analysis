/* Instacart Business Analysis — Activities 1–7 */
USE instacart_db;

/* ACTIVITY 1 — Orders by Day of Week */
SELECT order_dow,
       COUNT(*) AS total_orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct_of_total_orders
FROM orders
GROUP BY order_dow
ORDER BY order_dow;

-- Reconciliation: expected 3,421,083
SELECT COUNT(*) AS total_orders FROM orders;

/* ACTIVITY 2 — Order Number Distribution */
SELECT order_number,
       COUNT(*) AS total_orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct_of_total_orders
FROM orders
GROUP BY order_number
ORDER BY order_number;

-- Reconciliation: expected 3,421,083
SELECT SUM(total_orders) AS reconciled_total_orders
FROM (
    SELECT order_number, COUNT(*) AS total_orders
    FROM orders
    GROUP BY order_number
) x;

/* ACTIVITY 3 — Order Hour Distribution */
SELECT order_hour_of_day,
       COUNT(*) AS total_orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct_of_total_orders
FROM orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC;

/* ACTIVITY 4 — Average Days Between Orders */
-- AVG ignores the expected NULL values on first orders.
SELECT ROUND(AVG(days_since_prior_order), 2) AS avg_days_between_orders,
       MIN(days_since_prior_order) AS min_days_between_orders,
       MAX(days_since_prior_order) AS max_days_between_orders
FROM orders;

/* ACTIVITY 5 — Reorder Interval Distribution */
-- Caution: the dataset caps days_since_prior_order at 30.
SELECT days_since_prior_order,
       COUNT(*) AS total_orders,
       ROUND(
           COUNT(*) * 100.0 /
           (SELECT COUNT(*) FROM orders WHERE days_since_prior_order IS NOT NULL),
           2
       ) AS pct_of_repeat_orders
FROM orders
WHERE days_since_prior_order IS NOT NULL
GROUP BY days_since_prior_order
ORDER BY days_since_prior_order;

/* ACTIVITY 6 — Customer Frequency Segmentation */
WITH customer_orders AS (
    SELECT user_id, COUNT(*) AS total_orders
    FROM orders
    GROUP BY user_id
), segmented AS (
    SELECT user_id,
           total_orders,
           CASE
               WHEN total_orders BETWEEN 1 AND 5 THEN 'Low Frequency (1-5)'
               WHEN total_orders BETWEEN 6 AND 20 THEN 'Medium Frequency (6-20)'
               WHEN total_orders BETWEEN 21 AND 50 THEN 'High Frequency (21-50)'
               ELSE 'Very High Frequency (51+)'
           END AS frequency_segment
    FROM customer_orders
)
SELECT frequency_segment,
       COUNT(*) AS total_customers,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM segmented), 2) AS customer_share_pct,
       ROUND(AVG(total_orders), 2) AS avg_orders,
       SUM(total_orders) AS total_orders,
       ROUND(SUM(total_orders) * 100.0 / (SELECT SUM(total_orders) FROM segmented), 2) AS order_share_pct
FROM segmented
GROUP BY frequency_segment
ORDER BY MIN(total_orders);

/* ACTIVITY 7 — Orders per Customer Summary */
WITH customer_orders AS (
    SELECT user_id, COUNT(*) AS total_orders
    FROM orders
    GROUP BY user_id
)
SELECT COUNT(*) AS total_customers,
       ROUND(AVG(total_orders), 2) AS avg_orders_per_customer,
       MIN(total_orders) AS min_orders_per_customer,
       MAX(total_orders) AS max_orders_per_customer
FROM customer_orders;

-- Reconciliation: expected 206,209 customers / 3,421,083 orders
SELECT COUNT(DISTINCT user_id) AS total_customers,
       COUNT(*) AS total_orders
FROM orders;
