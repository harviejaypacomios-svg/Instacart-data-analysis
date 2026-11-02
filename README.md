# Instacart Online Grocery Basket Analysis — SQL Portfolio

A MySQL portfolio project covering data profiling, data-quality validation, customer/order behavior, basket analysis, product demand, category performance, and reorder behavior using the Instacart Online Grocery Basket Analysis dataset.

## Project objective

Build an analysis-ready relational dataset, validate its integrity, and answer business-oriented questions about how customers order, what they buy, how often they reorder, and which products/categories drive repeat purchasing.

## Tools

- MySQL 8.0
- MySQL Workbench
- SQL
- CSV source files

## Validated analytical data model

| Table | Grain | Validated rows |
|---|---|---:|
| `orders` | One row per order | 3,421,083 |
| `order_products__prior` | One product within a prior order | 32,434,489 |
| `order_products__train` | One product within a train order | 1,384,617 |
| `products_clean` | One row per product | 49,688 |
| `aisles` | One row per aisle | 134 |
| `departments` | One row per department | 21 |

Core relationship chain:

`orders -> order_products -> products_clean -> aisles / departments`

`products_clean` is the controlled analytical product dimension used in business analysis. The raw `products` table is retained for source-level/pre-cleaning investigation.

## Repository structure

```text
instacart-github-final/
├── README.md
├── sql/
│   ├── 00_master_data_preparation_29_activities.sql
│   ├── 01_data_profiling.sql
│   ├── 02_data_quality_checks.sql
│   ├── 03_data_cleaning.sql
│   ├── 04_data_validation.sql
│   ├── 05_order_customer_analysis.sql
│   ├── 06_basket_reorder_analysis.sql
│   ├── 07_product_category_analysis.sql
│   └── 08_business_analysis_all_20.sql
└── docs/
    ├── AUDIT_NOTES.md
    └── RESULTS_SUMMARY.md
```

## Data preparation and QA

The preparation workflow contains 29 documented SQL activities covering row counts, uniqueness, NULL patterns, logical ranges, duplicate order-product pairs, cart-position sequence checks, reference-table validation, product hierarchy validation, referential integrity, and end-to-end reconciliation.

Key QA outcomes:

- 33,819,106 combined prior + train order-product rows validated.
- 0 missing product, aisle, or department references in final hierarchy tests.
- 49,688 product rows preserved in `products_clean`.
- 3,203 products were identified as having invalid raw category references before cleaning.
- The exact historical SQL used to repair those product classifications was not preserved in the source report, so this repository does **not** fabricate that transformation. The validation queries documenting the before/after state are retained.

## 20 business-analysis activities

1. Orders by Day of Week
2. Order Number Distribution
3. Order Hour Distribution
4. Average Days Between Orders
5. Reorder Interval Distribution
6. Customer Frequency Segmentation
7. Orders per Customer Summary
8. Basket Size Summary
9. Basket Size Segmentation
10. Overall Product Reorder Rate
11. Reorder Rate by Basket Segment
12. Top Products by Purchase Volume
13. Top Products by Reordered Purchase Volume
14. Highest Reorder Rate Products (minimum 1,000 purchases)
15. Department Performance Analysis
16. Aisle Performance Analysis
17. Aisle Reorder Rate
18. Department Reorder Rate
19. Add-to-Cart Position and Reorder Behavior
20. Customer Reorder Segmentation

## Selected findings

- Overall prior-product reorder rate: **58.97%**.
- Average prior basket size: **10.09 products**.
- Peak order hour: **10 AM**.
- Average interval between orders: **11.11 days**; the dataset's 30-day value should be interpreted cautiously because it is capped at 30.
- Banana is the highest-volume product and also leads reordered-purchase volume.
- Produce dominates purchase volume, while Dairy & Eggs has the highest department reorder rate in the corrected category analysis.
- Earlier add-to-cart positions are associated with higher reorder rates; this is descriptive association, not causal evidence.

## SQL conventions used

- `COUNT(*)` = transaction/product-line count at order-product grain.
- `COUNT(DISTINCT order_id)` = order count.
- `products_clean` = product metadata/category joins in final business analysis.
- Percentages are rounded to two decimal places.
- Segmentation thresholds are explicitly documented because they are analyst-defined.
- Major category analyses reconcile back to the 32,434,489 prior order-product baseline when no intentional filter is applied.

## Reproducibility note

The SQL assumes the Instacart CSV files have already been imported into a MySQL schema named `instacart_db` and that the validated `products_clean` table from the documented cleaning workflow exists. The original source `products` table should remain preserved.
