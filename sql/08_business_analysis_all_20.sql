/*
Instacart Online Grocery Basket Analysis
FINAL CANONICAL BUSINESS ANALYSIS — ACTIVITIES 1–20
Schema: instacart_db

This master file combines the final standardized business-analysis queries.
For easier review, the same queries are also split across 05–07.
*/
USE instacart_db;

-- ============================================================
-- ACTIVITY 1 — Orders by Day of Week
-- ============================================================
SELECT order_dow, COUNT(*) total_orders,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM orders),2) pct_of_total_orders
FROM orders GROUP BY order_dow ORDER BY order_dow;

-- ACTIVITY 2 — Order Number Distribution
SELECT order_number, COUNT(*) total_orders,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM orders),2) pct_of_total_orders
FROM orders GROUP BY order_number ORDER BY order_number;

-- ACTIVITY 3 — Order Hour Distribution
SELECT order_hour_of_day, COUNT(*) total_orders,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM orders),2) pct_of_total_orders
FROM orders GROUP BY order_hour_of_day ORDER BY total_orders DESC;

-- ACTIVITY 4 — Average Days Between Orders
SELECT ROUND(AVG(days_since_prior_order),2) avg_days_between_orders,
       MIN(days_since_prior_order) min_days_between_orders,
       MAX(days_since_prior_order) max_days_between_orders
FROM orders;

-- ACTIVITY 5 — Reorder Interval Distribution
SELECT days_since_prior_order, COUNT(*) total_orders,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM orders WHERE days_since_prior_order IS NOT NULL),2) pct_of_repeat_orders
FROM orders WHERE days_since_prior_order IS NOT NULL
GROUP BY days_since_prior_order ORDER BY days_since_prior_order;

-- ACTIVITY 6 — Customer Frequency Segmentation
WITH customer_orders AS (
    SELECT user_id, COUNT(*) total_orders FROM orders GROUP BY user_id
), s AS (
    SELECT *, CASE WHEN total_orders BETWEEN 1 AND 5 THEN 'Low Frequency (1-5)'
                   WHEN total_orders BETWEEN 6 AND 20 THEN 'Medium Frequency (6-20)'
                   WHEN total_orders BETWEEN 21 AND 50 THEN 'High Frequency (21-50)'
                   ELSE 'Very High Frequency (51+)' END frequency_segment
    FROM customer_orders
)
SELECT frequency_segment, COUNT(*) total_customers,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM s),2) customer_share_pct,
       ROUND(AVG(total_orders),2) avg_orders, SUM(total_orders) total_orders,
       ROUND(SUM(total_orders)*100.0/(SELECT SUM(total_orders) FROM s),2) order_share_pct
FROM s GROUP BY frequency_segment ORDER BY MIN(total_orders);

-- ACTIVITY 7 — Orders per Customer Summary
WITH c AS (SELECT user_id, COUNT(*) total_orders FROM orders GROUP BY user_id)
SELECT COUNT(*) total_customers, ROUND(AVG(total_orders),2) avg_orders_per_customer,
       MIN(total_orders) min_orders_per_customer, MAX(total_orders) max_orders_per_customer
FROM c;

-- ACTIVITY 8 — Basket Size Summary
WITH b AS (SELECT order_id, COUNT(*) basket_size FROM order_products__prior GROUP BY order_id)
SELECT COUNT(*) total_orders_analyzed, ROUND(AVG(basket_size),2) avg_basket_size,
       MIN(basket_size) min_basket_size, MAX(basket_size) max_basket_size FROM b;

-- ACTIVITY 9 — Basket Size Segmentation
WITH b AS (SELECT order_id, COUNT(*) basket_size FROM order_products__prior GROUP BY order_id),
s AS (SELECT *, CASE WHEN basket_size BETWEEN 1 AND 5 THEN 'Small (1-5)'
                     WHEN basket_size BETWEEN 6 AND 10 THEN 'Medium (6-10)'
                     WHEN basket_size BETWEEN 11 AND 20 THEN 'Large (11-20)'
                     ELSE 'Very Large (21+)' END basket_segment FROM b)
SELECT basket_segment, COUNT(*) total_orders,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM s),2) pct_of_orders,
       ROUND(AVG(basket_size),2) avg_basket_size
FROM s GROUP BY basket_segment ORDER BY MIN(basket_size);

-- ACTIVITY 10 — Overall Product Reorder Rate
SELECT COUNT(*) total_product_purchases, SUM(reordered) reordered_purchases,
       COUNT(*)-SUM(reordered) first_time_purchases,
       ROUND(SUM(reordered)*100.0/COUNT(*),2) reorder_rate_pct
FROM order_products__prior;

-- ACTIVITY 11 — Reorder Rate by Basket Segment
WITH b AS (SELECT order_id, COUNT(*) basket_size FROM order_products__prior GROUP BY order_id),
s AS (SELECT order_id, CASE WHEN basket_size BETWEEN 1 AND 5 THEN 'Small (1-5)'
                            WHEN basket_size BETWEEN 6 AND 10 THEN 'Medium (6-10)'
                            WHEN basket_size BETWEEN 11 AND 20 THEN 'Large (11-20)'
                            ELSE 'Very Large (21+)' END basket_segment FROM b)
SELECT s.basket_segment, COUNT(*) total_purchases, SUM(op.reordered) reordered_purchases,
       ROUND(SUM(op.reordered)*100.0/COUNT(*),2) reorder_rate_pct
FROM order_products__prior op JOIN s ON op.order_id=s.order_id
GROUP BY s.basket_segment ORDER BY reorder_rate_pct DESC;

-- ACTIVITY 12 — Top Products by Purchase Volume
SELECT p.product_id,p.product_name,COUNT(*) total_purchases,COUNT(DISTINCT op.order_id) total_orders
FROM order_products__prior op JOIN products_clean p ON op.product_id=p.product_id
GROUP BY p.product_id,p.product_name ORDER BY total_purchases DESC LIMIT 10;

-- ACTIVITY 13 — Top Products by Reordered Purchase Volume
SELECT p.product_id,p.product_name,COUNT(*) total_purchases,SUM(op.reordered) reordered_purchases,
       ROUND(SUM(op.reordered)*100.0/COUNT(*),2) reorder_rate_pct
FROM order_products__prior op JOIN products_clean p ON op.product_id=p.product_id
GROUP BY p.product_id,p.product_name ORDER BY reordered_purchases DESC LIMIT 10;

-- ACTIVITY 14 — Highest Reorder Rate Products (>= 1,000 purchases)
SELECT p.product_id,p.product_name,COUNT(*) total_purchases,SUM(op.reordered) reordered_purchases,
       ROUND(SUM(op.reordered)*100.0/COUNT(*),2) reorder_rate_pct
FROM order_products__prior op JOIN products_clean p ON op.product_id=p.product_id
GROUP BY p.product_id,p.product_name HAVING COUNT(*)>=1000
ORDER BY reorder_rate_pct DESC,total_purchases DESC LIMIT 10;

-- ACTIVITY 15 — Department Performance
SELECT d.department_id,d.department,COUNT(*) total_purchases,
       COUNT(DISTINCT op.order_id) total_orders,COUNT(DISTINCT p.product_id) unique_products
FROM order_products__prior op JOIN products_clean p ON op.product_id=p.product_id
JOIN departments d ON p.department_id=d.department_id
GROUP BY d.department_id,d.department ORDER BY total_purchases DESC;

-- ACTIVITY 16 — Aisle Performance
SELECT a.aisle_id,a.aisle,COUNT(*) total_purchases,
       COUNT(DISTINCT op.order_id) total_orders,COUNT(DISTINCT p.product_id) unique_products
FROM order_products__prior op JOIN products_clean p ON op.product_id=p.product_id
JOIN aisles a ON p.aisle_id=a.aisle_id
GROUP BY a.aisle_id,a.aisle ORDER BY total_purchases DESC;

-- ACTIVITY 17 — Aisle Reorder Rate
SELECT a.aisle_id,a.aisle,COUNT(*) total_purchases,SUM(op.reordered) reordered_purchases,
       ROUND(SUM(op.reordered)*100.0/COUNT(*),2) reorder_rate_pct
FROM order_products__prior op JOIN products_clean p ON op.product_id=p.product_id
JOIN aisles a ON p.aisle_id=a.aisle_id
GROUP BY a.aisle_id,a.aisle ORDER BY reorder_rate_pct DESC;

-- ACTIVITY 18 — Department Reorder Rate
SELECT d.department_id,d.department,COUNT(*) total_purchases,SUM(op.reordered) reordered_purchases,
       ROUND(SUM(op.reordered)*100.0/COUNT(*),2) reorder_rate_pct
FROM order_products__prior op JOIN products_clean p ON op.product_id=p.product_id
JOIN departments d ON p.department_id=d.department_id
GROUP BY d.department_id,d.department ORDER BY reorder_rate_pct DESC;

-- ACTIVITY 19 — Add-to-Cart Position and Reorder Behavior
SELECT CASE WHEN add_to_cart_order BETWEEN 1 AND 5 THEN '1-5 Early'
            WHEN add_to_cart_order BETWEEN 6 AND 10 THEN '6-10'
            WHEN add_to_cart_order BETWEEN 11 AND 20 THEN '11-20'
            ELSE '21+ Late' END cart_position_segment,
       COUNT(*) total_purchases,SUM(reordered) reordered_purchases,
       ROUND(SUM(reordered)*100.0/COUNT(*),2) reorder_rate_pct
FROM order_products__prior GROUP BY cart_position_segment ORDER BY MIN(add_to_cart_order);

-- ACTIVITY 20 — Customer Reorder Segmentation
WITH c AS (
    SELECT o.user_id,COUNT(*) total_purchases,SUM(op.reordered) reordered_purchases,
           SUM(op.reordered)*100.0/COUNT(*) reorder_rate_pct
    FROM order_products__prior op JOIN orders o ON op.order_id=o.order_id
    GROUP BY o.user_id
), s AS (
    SELECT *,CASE WHEN reorder_rate_pct>=75 THEN 'Very High (75%+)'
                  WHEN reorder_rate_pct>=50 THEN 'High (50-74.99%)'
                  WHEN reorder_rate_pct>=25 THEN 'Moderate (25-49.99%)'
                  ELSE 'Low (<25%)' END reorder_segment
    FROM c
)
SELECT reorder_segment,COUNT(*) total_customers,SUM(total_purchases) total_purchases,
       SUM(reordered_purchases) reordered_purchases,ROUND(AVG(reorder_rate_pct),2) avg_customer_reorder_rate_pct
FROM s GROUP BY reorder_segment ORDER BY MIN(reorder_rate_pct) DESC;
