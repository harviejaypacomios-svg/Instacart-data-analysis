-- ============================================================
-- INSTACART ONLINE GROCERY BASKET ANALYSIS
-- 03 - DATA CLEANING / CONTROLLED PRODUCT TABLE
-- Database: instacart_db
-- Purpose: Preserve the raw product table, use a controlled
--          analytical product table, and document cleaning evidence.
-- ============================================================

USE instacart_db;

-- IMPORTANT REPRODUCIBILITY NOTE
-- ------------------------------------------------------------
-- The saved project report preserved the backup command, the
-- before/after quality checks, and the validation results, but it did
-- NOT preserve the exact UPDATE/mapping statement used to repair the
-- 3,203 affected product classifications in products_clean.
--
-- To avoid inventing historical code, this file contains only the
-- cleaning-related SQL that is documented and verified in the project.
-- The exact correction statement should be added here only if recovered
-- from the original MySQL Workbench history or saved SQL script.
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 1. Preserve original product data before cleaning
-- Verified result: 49,688 rows in products and products_backup.
-- Run once only on a fresh copy of the project database.
-- ------------------------------------------------------------
CREATE TABLE products_backup AS
SELECT * FROM products;

SELECT (SELECT COUNT(*) FROM products) AS original_rows,
       (SELECT COUNT(*) FROM products_backup) AS backup_rows;

-- ------------------------------------------------------------
-- 2. Pre-cleaning issue scope (documented baseline)
-- Verified result: 3,203 affected products.
-- ------------------------------------------------------------
SELECT
    SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) AS total_affected_products,
    SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id BETWEEN 1 AND 21)) AS aisle_only_problem,
    SUM((department_id NOT BETWEEN 1 AND 21) AND (aisle_id BETWEEN 1 AND 134)) AS department_only_problem,
    SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id NOT BETWEEN 1 AND 21)) AS both_problem
FROM products;

-- ------------------------------------------------------------
-- 3. CORRECTION STEP
-- ------------------------------------------------------------
-- products_clean was the controlled analytical product table used in
-- the completed project. The exact historical SQL that corrected its
-- aisle_id and department_id values was not retained in the saved report.
--
-- DO NOT fabricate or guess this transformation in a portfolio.
-- Recover it from MySQL Workbench SQL History / saved scripts if possible,
-- then place it in this section with comments explaining the mapping logic.

-- ------------------------------------------------------------
-- 4. Row-preservation check after cleaning
-- Verified results:
-- products_backup = 49,688
-- products_clean  = 49,688
-- row difference  = 0
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_rows
FROM products_clean;

SELECT
    (SELECT COUNT(*) FROM products_backup) AS backup_rows,
    (SELECT COUNT(*) FROM products_clean) AS clean_rows,
    (SELECT COUNT(*) FROM products_backup) - (SELECT COUNT(*) FROM products_clean) AS row_difference;

-- ------------------------------------------------------------
-- 5. Validate cleaned category ID domains
-- Verified result: 0 invalid aisle IDs, 0 invalid department IDs,
-- and 0 affected products.
-- ------------------------------------------------------------
SELECT COUNT(*) AS total_products,
       SUM(aisle_id NOT BETWEEN 1 AND 134) AS invalid_aisle_ids,
       SUM(department_id NOT BETWEEN 1 AND 21) AS invalid_department_ids,
       SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) AS total_affected_products
FROM products_clean;

-- ------------------------------------------------------------
-- 6. Validate uniqueness, NULLs, and blank product names
-- Verified result: all checks passed.
-- ------------------------------------------------------------
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
