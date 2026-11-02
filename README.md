# Instacart Customer Behavior & Product Performance Analysis

**Data Analytics Portfolio Project | MySQL • Tableau • Data Quality • Business Insights**

## Project Overview

This project explores grocery shopping behavior using the Instacart Online Grocery Basket Analysis dataset. The goal is to turn large-scale transaction data into clear, actionable insights about customer purchasing patterns, product demand, repeat purchases, and category performance.

The workflow covers data preparation, quality checks, exploratory analysis, and business interpretation. Tableau is included in the visualization toolset; a project-specific dashboard link will be added when available.

## Business Questions

- When do customers place the most orders?
- How frequently do customers return, and how large are their baskets?
- Which products and categories drive demand and repeat purchases?
- How do reorder patterns vary across customers and product categories?

## Tools & Skills

| Tool / Skill | Application |
|---|---|
| **MySQL & SQL** | Data preparation, validation, joins, aggregations, segmentation, and analysis |
| **MySQL Workbench** | Query development and database exploration |
| **Tableau** | Data visualization and dashboard presentation (dashboard link to be added) |
| **Data Quality Assurance** | Integrity checks, reconciliation, and documented assumptions |
| **Business Analysis** | Translating analytical results into practical recommendations |

## Project at a Glance

| Metric | Result |
|---|---:|
| Orders analyzed in the source order table | 3,421,083 |
| Order-product records validated (prior + train) | 33,819,106 |
| Products in the validated analytical dimension | 49,688 |
| Product, aisle, and department reference gaps after validation | 0 |
| Documented business-analysis activities | 20 |

## Key Findings

- **58.97%** of prior-order product purchases were reorders, showing substantial repeat-purchase activity.
- The average prior-order basket contained **10.09 products**.
- **10 AM** was the busiest order hour in the dataset.
- **Bananas** were the most frequently purchased product.
- **Produce** led in purchase volume, while **Dairy & Eggs** had the highest department-level reorder rate (**67.00%**).
- Products added earlier to baskets showed higher reorder rates. This is an observed association, not proof of causation.

## Business Recommendations

- Prioritize availability and replenishment planning for frequently purchased staples and high-demand produce.
- Use repeat-purchase patterns to inform convenient **Buy Again** features and personalized product suggestions.
- Plan staffing and operational capacity around high-volume ordering hours.
- Monitor customer segments with lower reorder activity for retention opportunities.

These are analytical recommendations based on historical data, not measured outcomes from implemented changes.

## Data Preparation & Validation

Before analyzing shopping behavior, the dataset was profiled and checked for duplicates, missing values, product hierarchy issues, and broken references. The documented workflow includes **29 data-preparation and QA activities**.

A key quality issue involved **3,203 products** with invalid category references in the original product data. Final analysis uses the validated `products_clean` dimension, with zero missing product, aisle, or department references in the final checks.

**Reproducibility note:** The exact historical SQL that corrected those category classifications was not preserved. The repository documents the issue and final validation rather than presenting an invented repair procedure.

## Analysis & Visualization

The analysis covers order timing, customer frequency, basket size, product demand, reorder behavior, and aisle/department performance.

**Tableau dashboard:** *Link to be added after publication.*

## Repository Contents

- [`sql/`](sql/) — Data preparation, validation, and business-analysis queries
- [`docs/`](docs/) — Audit notes and summarized results

## Data & Methodology Notes

- The data is the public **Instacart Online Grocery Basket Analysis** dataset.
- Business findings primarily use the `order_products__prior` table (32,434,489 rows), while the combined validation count also includes `order_products__train`.
- Product/category analysis joins to `products_clean`, not the original raw product classification fields.
- The `days_since_prior_order` value is capped at 30 in the dataset, so long intervals should be interpreted carefully.
- The project demonstrates analysis and recommendations; it does not claim that recommendations were deployed or caused business improvements.

---

*Portfolio focus: reliable data, understandable insights, and decisions supported by evidence.*
