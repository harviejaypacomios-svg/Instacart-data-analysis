# Final SQL Audit Notes

## Preparation-stage audit

The documented preparation report contains 29 numbered SQL activities (4.1–4.29). All 29 are represented in the final package.

The exact historical product-classification correction SQL was not preserved in the source documentation. It is therefore intentionally not reconstructed. Instead, this repository preserves the documented before-cleaning diagnostics, row-preservation checks, cleaned-category validation, and end-to-end referential-integrity checks.

## Business-analysis audit

The 20 analytical activities were standardized for the final package.

Important corrections/standards applied:

- Product/category analysis uses `products_clean` rather than raw `products`.
- Activities 17 and 18 were corrected to prevent transaction loss caused by invalid raw category references.
- Activity 14 explicitly uses `HAVING COUNT(*) >= 1000` to prevent tiny-volume products from dominating a reorder-rate ranking.
- Activities 1, 2, and 7 were re-established and independently reconciled against the validated `orders` baseline.
- Activity 12 product coverage was validated: 32,434,489 prior rows matched `products_clean`, with 0 unmatched product rows.
- Category analyses are checked against the full prior transaction baseline whenever they are intended to be exhaustive.

## Validated baselines

- Orders: 3,421,083
- Customers: 206,209
- Prior orders: 3,214,874
- Prior order-product rows: 32,434,489
- Train order-product rows: 1,384,617
- Combined transaction rows: 33,819,106
- Products: 49,688
- Aisles: 134
- Departments: 21

## Analytical caveats

- `days_since_prior_order` has a maximum of 30; interpret 30 as a capped value rather than necessarily exactly 30 days.
- Reorder rate measures historical repeat-purchase behavior and should not be described as causal loyalty.
- Cart-position findings are associations, not proof that adding an item earlier causes a customer to reorder it.
- Customer and basket segment thresholds are analyst-defined business groupings.
