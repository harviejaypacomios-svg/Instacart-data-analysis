# Instacart Online Grocery Basket Analysis

## Data Preparation, Cleaning, Profiling & Validation

This repository documents the SQL data-quality workflow used to prepare the Instacart Online Grocery Basket Analysis dataset for business analysis in MySQL.

The project emphasizes **data reliability before analysis**: understanding table grain, profiling large transaction tables, detecting data-quality issues, preserving source data, validating a controlled product dimension, and proving end-to-end referential integrity.

## Project Scale

- **3,421,083** orders
- **32,434,489** prior order-product rows
- **1,384,617** train order-product rows
- **33,819,106** transaction rows validated end to end
- **49,688** products retained after cleaning
- **134** aisles
- **21** departments
- **0** broken product / aisle / department references after validation

## Main Data-Quality Case Study

Profiling identified a product-classification integrity issue in the imported `products` table:

- 3,203 affected products
- 3,062 invalid aisle IDs
- 2,889 invalid department IDs
- 2,748 products with both classifications invalid

The original product data was preserved in `products_backup`, while `products_clean` was used as the controlled analytical product dimension. Final reconciliation confirmed that all **49,688 products were retained** and that the cleaned table had **zero invalid product-category references**.

> Reproducibility note: the saved project report retained the before/after checks and validation SQL, but not the exact historical `UPDATE`/mapping statement used to correct `products_clean`. The repository therefore does not invent that missing transformation. If recovered from MySQL Workbench SQL History or a saved script, it should be added to `03_data_cleaning.sql`.

## Repository Structure

```text
instacart-data-analysis/
├── README.md
└── sql/
    ├── 01_data_profiling.sql
    ├── 02_data_quality_checks.sql
    ├── 03_data_cleaning.sql
    └── 04_data_validation.sql
```

## SQL Workflow

### 01 — Data Profiling
Establishes row-count baselines, identifier uniqueness, logical ranges, evaluation-set distribution, transaction-table scale, and reorder distribution.

### 02 — Data Quality Checks
Checks duplicate order-product pairs, missing values, expected NULL patterns, cart-position sequences, and the original product-classification issue.

### 03 — Data Cleaning
Documents source preservation, the cleaning baseline, row reconciliation, and post-cleaning quality checks for `products_clean`.

### 04 — Data Validation
Validates transaction-to-order and transaction-to-product relationships, aisle and department reference tables, the product hierarchy, and the full analytical path:

`Orders → Order Products → Products → Aisles / Departments`

## Key Validation Results

| Validation metric | Result |
|---|---:|
| Duplicate master/reference IDs | 0 |
| Duplicate order-product pairs | 0 |
| Invalid cart-position sequences | 0 |
| Unmatched train order IDs | 0 |
| Unmatched train product IDs | 0 |
| Unmatched prior order IDs | 0 |
| Unmatched prior product IDs | 0 |
| Invalid product aisle references after cleaning | 0 |
| Invalid product department references after cleaning | 0 |
| Missing product references in final hierarchy | 0 |
| Missing aisle references in final hierarchy | 0 |
| Missing department references in final hierarchy | 0 |

## Important Analytical Finding

`days_since_prior_order` contains **206,209 NULL values**, but these are not treated as data-quality errors. Validation showed that all of them correspond to each customer's first order (`order_number = 1`), where no prior order exists. This is an example of distinguishing **meaningful missingness** from defective data.

## Tools

- MySQL 8.0
- MySQL Workbench
- SQL
- CSV
- GitHub

## Portfolio Value

This project demonstrates more than query writing. It shows an analyst workflow built around:

- table-grain awareness
- controlled source preservation
- data profiling
- completeness and uniqueness testing
- domain and sequence validation
- referential-integrity testing
- reconciliation before and after cleaning
- end-to-end data-quality assurance

The validated dataset is ready for the next stage: customer behavior, basket analysis, product demand, reorder behavior, aisle performance, and department-level business analysis.
