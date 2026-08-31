-- ============================================================
-- INSTACART ONLINE GROCERY BASKET ANALYSIS
-- 03 - DATA CLEANING / CONTROLLED PRODUCT TABLE
-- Database: instacart_db
-- Source basis: documented Activities 4.9-4.14 in the saved SQL report
-- Purpose: Preserve raw product data and document verified before/after cleaning evidence.
-- ============================================================

USE instacart_db;

-- ============================================================
-- REPRODUCIBILITY NOTE
-- The saved project report documents the backup, pre-cleaning issue,
-- post-cleaning row reconciliation, and post-cleaning validation.
-- It DOES NOT preserve the exact historical SQL statement that repaired
-- the 3,203 product classifications in products_clean.
--
-- This final package intentionally does not invent that missing transformation.
-- If the original statement is recovered from MySQL Workbench SQL History or
-- another saved script, insert it in the clearly marked section below.
-- ============================================================

-- ============================================================
-- ACTIVITY 4.9 - Product Backup Validation
-- Run CREATE TABLE only once on a fresh project copy.
-- Verified result: products = 49,688 rows; products_backup = 49,688 rows.
-- ============================================================
CREATE TABLE products_backup AS
SELECT * FROM products;

SELECT (SELECT COUNT(*) FROM products) AS original_rows,
       (SELECT COUNT(*) FROM products_backup) AS backup_rows;

-- ============================================================
-- ACTIVITY 4.10 - Detection of Invalid Product Category References Before Cleaning
-- Repeated here because it is the direct pre-cleaning diagnostic.
-- ============================================================
SELECT
    SUM(aisle_id NOT BETWEEN 1 AND 134) AS invalid_aisle_ids,
    SUM(department_id NOT BETWEEN 1 AND 21) AS invalid_department_ids,
    SUM(aisle_id = 0) AS zero_aisle_ids,
    SUM(department_id = 0) AS zero_department_ids,
    SUM(aisle_id > 134) AS aisle_ids_above_134,
    SUM(department_id > 21) AS department_ids_above_21
FROM products;

-- ============================================================
-- ACTIVITY 4.11 - Affected Product Classification Before Cleaning
-- Verified result: 3,203 affected products.
-- ============================================================
SELECT
    SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) AS total_affected_products,
    SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id BETWEEN 1 AND 21)) AS aisle_only_problem,
    SUM((department_id NOT BETWEEN 1 AND 21) AND (aisle_id BETWEEN 1 AND 134)) AS department_only_problem,
    SUM((aisle_id NOT BETWEEN 1 AND 134) AND (department_id NOT BETWEEN 1 AND 21)) AS both_problem
FROM products;

-- ============================================================
-- HISTORICAL CORRECTION STEP - NOT PRESERVED IN THE SAVED REPORT
-- ============================================================
-- The report confirms that products_clean became the controlled analytical
-- product table and that invalid category references were reduced to zero,
-- but it does not contain the exact CREATE/UPDATE/mapping statement used.
-- Do not add guessed code here.

-- ============================================================
-- ACTIVITY 4.12 - Clean Product Table Row Preservation
-- Verified results:
-- products_clean total rows = 49,688
-- backup rows = 49,688
-- clean rows = 49,688
-- row difference = 0
-- ============================================================
SELECT COUNT(*) AS total_rows
FROM products_clean;

SELECT
    (SELECT COUNT(*) FROM products_backup) AS backup_rows,
    (SELECT COUNT(*) FROM products_clean) AS clean_rows,
    (SELECT COUNT(*) FROM products_backup) - (SELECT COUNT(*) FROM products_clean) AS row_difference;

-- ============================================================
-- ACTIVITY 4.13 - Validation of Clean Product Category IDs
-- Verified result: 0 invalid aisle IDs, 0 invalid department IDs, 0 affected products.
-- ============================================================
SELECT COUNT(*) AS total_products,
       SUM(aisle_id NOT BETWEEN 1 AND 134) AS invalid_aisle_ids,
       SUM(department_id NOT BETWEEN 1 AND 21) AS invalid_department_ids,
       SUM(aisle_id NOT BETWEEN 1 AND 134 OR department_id NOT BETWEEN 1 AND 21) AS total_affected_products
FROM products_clean;

-- ============================================================
-- ACTIVITY 4.14 - Duplicate, NULL, and Blank Checks in products_clean
-- Verified result: 0 duplicate product IDs, 0 NULLs, 0 blank product names.
-- ============================================================
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
