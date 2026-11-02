/* Instacart — Controlled Product Cleaning Audit */
USE instacart_db;

-- 4.9 Preserve raw product source.
CREATE TABLE IF NOT EXISTS products_backup AS SELECT * FROM products;
SELECT (SELECT COUNT(*) FROM products) original_rows,
       (SELECT COUNT(*) FROM products_backup) backup_rows;

-- 4.10/4.11 Document the pre-cleaning problem.
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

/*
REPRODUCIBILITY NOTE
The historical SQL that actually repaired the invalid product classifications was not
preserved in the source report. This package intentionally does not invent it.
The following queries validate the documented products_clean output.
*/

-- 4.12 Row preservation
SELECT COUNT(*) total_rows FROM products_clean;
SELECT (SELECT COUNT(*) FROM products_backup) backup_rows,
       (SELECT COUNT(*) FROM products_clean) clean_rows,
       (SELECT COUNT(*) FROM products_backup)-(SELECT COUNT(*) FROM products_clean) row_difference;

-- 4.13 Valid cleaned category IDs
SELECT COUNT(*) total_products,
       SUM(aisle_id NOT BETWEEN 1 AND 134) invalid_aisle_ids,
       SUM(department_id NOT BETWEEN 1 AND 21) invalid_department_ids,
       SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) total_affected_products
FROM products_clean;

-- 4.14 Uniqueness, NULLs, blanks
SELECT product_id, COUNT(*) occurrences FROM products_clean GROUP BY product_id HAVING COUNT(*)>1;
SELECT SUM(product_id IS NULL) null_product_id, SUM(product_name IS NULL) null_product_name,
       SUM(aisle_id IS NULL) null_aisle_id, SUM(department_id IS NULL) null_department_id
FROM products_clean;
SELECT COUNT(*) blank_product_names FROM products_clean WHERE TRIM(product_name)='';
