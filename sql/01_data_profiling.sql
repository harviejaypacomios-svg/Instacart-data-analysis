/* Instacart — Data Profiling */
USE instacart_db;

-- 4.1 Core row counts
SELECT 'departments' AS table_name, COUNT(*) AS total_rows FROM departments
UNION ALL SELECT 'aisles', COUNT(*) FROM aisles
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_products__train', COUNT(*) FROM order_products__train
UNION ALL SELECT 'order_products__prior', COUNT(*) FROM order_products__prior;

-- 4.2 Unique identifiers
SELECT COUNT(*) total_rows, COUNT(DISTINCT department_id) unique_ids,
       COUNT(*)-COUNT(DISTINCT department_id) duplicate_ids FROM departments;
SELECT COUNT(*) total_rows, COUNT(DISTINCT aisle_id) unique_ids,
       COUNT(*)-COUNT(DISTINCT aisle_id) duplicate_ids FROM aisles;
SELECT COUNT(*) total_rows, COUNT(DISTINCT product_id) unique_ids,
       COUNT(*)-COUNT(DISTINCT product_id) duplicate_ids FROM products;
SELECT COUNT(*) total_rows, COUNT(DISTINCT order_id) unique_ids,
       COUNT(*)-COUNT(DISTINCT order_id) duplicate_ids FROM orders;

-- 4.7 Logical ranges in orders
SELECT MIN(order_number) min_order_number, MAX(order_number) max_order_number,
       MIN(order_dow) min_order_dow, MAX(order_dow) max_order_dow,
       MIN(order_hour_of_day) min_order_hour, MAX(order_hour_of_day) max_order_hour,
       MIN(days_since_prior_order) min_days_since_prior,
       MAX(days_since_prior_order) max_days_since_prior
FROM orders;

-- 4.8 Evaluation-set distribution
SELECT eval_set, COUNT(*) total_orders,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM orders),2) percentage_of_orders
FROM orders GROUP BY eval_set;

-- 4.15 Train transaction profiling
SELECT COUNT(*) total_rows, COUNT(DISTINCT order_id) unique_orders,
       COUNT(DISTINCT product_id) unique_products,
       MIN(add_to_cart_order) min_cart_position, MAX(add_to_cart_order) max_cart_position,
       MIN(reordered) min_reordered, MAX(reordered) max_reordered
FROM order_products__train;

-- 4.19 Train reorder distribution
SELECT reordered, COUNT(*) row_count,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM order_products__train),2) percentage
FROM order_products__train GROUP BY reordered ORDER BY reordered;

-- 4.24 Prior transaction profiling
SELECT COUNT(*) total_rows, COUNT(DISTINCT order_id) unique_orders,
       COUNT(DISTINCT product_id) unique_products,
       MIN(add_to_cart_order) min_cart_position, MAX(add_to_cart_order) max_cart_position,
       MIN(reordered) min_reordered, MAX(reordered) max_reordered
FROM order_products__prior;
