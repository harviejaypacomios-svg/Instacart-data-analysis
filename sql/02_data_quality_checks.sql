/* Instacart — Data Quality Checks */
USE instacart_db;

-- 4.3 Duplicate order-product pair checks
SELECT COUNT(*) total_rows, COUNT(DISTINCT order_id,product_id) unique_pairs,
       COUNT(*)-COUNT(DISTINCT order_id,product_id) duplicate_pairs
FROM order_products__train;
SELECT COUNT(*) total_rows, COUNT(DISTINCT order_id,product_id) unique_pairs,
       COUNT(*)-COUNT(DISTINCT order_id,product_id) duplicate_pairs
FROM order_products__prior;

-- 4.4 Missing reference/product values
SELECT SUM(department_id IS NULL) null_department_id, SUM(department IS NULL) null_department_name FROM departments;
SELECT SUM(aisle_id IS NULL) null_aisle_id, SUM(aisle IS NULL) null_aisle_name FROM aisles;
SELECT SUM(product_id IS NULL) null_product_id, SUM(product_name IS NULL) null_product_name,
       SUM(aisle_id IS NULL) null_aisle_id, SUM(department_id IS NULL) null_department_id
FROM products_clean;

-- 4.5 Missing values in orders
SELECT COUNT(*) total_rows, SUM(order_id IS NULL) null_order_id,
       SUM(user_id IS NULL) null_user_id, SUM(eval_set IS NULL) null_eval_set,
       SUM(order_number IS NULL) null_order_number, SUM(order_dow IS NULL) null_order_dow,
       SUM(order_hour_of_day IS NULL) null_order_hour,
       SUM(days_since_prior_order IS NULL) null_days_since_prior
FROM orders;

-- 4.6 Expected first-order NULL pattern
SELECT order_number, COUNT(*) null_records FROM orders
WHERE days_since_prior_order IS NULL GROUP BY order_number ORDER BY order_number;
SELECT COUNT(*) first_orders, SUM(days_since_prior_order IS NULL) null_days_first_orders,
       SUM(days_since_prior_order IS NOT NULL) nonnull_days_first_orders
FROM orders WHERE order_number=1;

-- 4.10/4.11 Pre-cleaning product category diagnostics
SELECT SUM(aisle_id NOT BETWEEN 1 AND 134) invalid_aisle_ids,
       SUM(department_id NOT BETWEEN 1 AND 21) invalid_department_ids,
       SUM(aisle_id=0) zero_aisle_ids, SUM(department_id=0) zero_department_ids,
       SUM(aisle_id>134) aisle_ids_above_134, SUM(department_id>21) department_ids_above_21
FROM products;
SELECT SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) total_affected_products,
       SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id BETWEEN 1 AND 21)) aisle_only_problem,
       SUM((department_id NOT BETWEEN 1 AND 21) AND (aisle_id BETWEEN 1 AND 134)) department_only_problem,
       SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id NOT BETWEEN 1 AND 21)) both_problem
FROM products;

-- 4.16 Train NULL check
SELECT COUNT(*) total_rows, SUM(order_id IS NULL) null_order_id,
       SUM(product_id IS NULL) null_product_id, SUM(add_to_cart_order IS NULL) null_cart_order,
       SUM(reordered IS NULL) null_reordered FROM order_products__train;

-- 4.17 Train cart sequence
SELECT order_id, COUNT(*) number_of_products, MIN(add_to_cart_order) first_position,
       MAX(add_to_cart_order) last_position, COUNT(DISTINCT add_to_cart_order) unique_positions
FROM order_products__train GROUP BY order_id
HAVING MIN(add_to_cart_order)<>1 OR MAX(add_to_cart_order)<>COUNT(*)
    OR COUNT(DISTINCT add_to_cart_order)<>COUNT(*);

-- 4.24 Prior NULL check
SELECT COUNT(*) total_rows, SUM(order_id IS NULL) null_order_id,
       SUM(product_id IS NULL) null_product_id, SUM(add_to_cart_order IS NULL) null_cart_order,
       SUM(reordered IS NULL) null_reordered FROM order_products__prior;

-- 4.25 Prior duplicate detail + cart sequence
SELECT order_id, product_id, COUNT(*) occurrences
FROM order_products__prior GROUP BY order_id,product_id HAVING COUNT(*)>1;
SELECT order_id, COUNT(*) number_of_products, MIN(add_to_cart_order) first_position,
       MAX(add_to_cart_order) last_position, COUNT(DISTINCT add_to_cart_order) unique_positions
FROM order_products__prior GROUP BY order_id
HAVING MIN(add_to_cart_order)<>1 OR MAX(add_to_cart_order)<>COUNT(*)
    OR COUNT(DISTINCT add_to_cart_order)<>COUNT(*);
