# Customer Data Mart & Ad Hoc Analysis for an E-Commerce Marketplace

## Overview
An SQL project analyzing customer ordering behavior for an e-commerce marketplace: a data mart aggregating each customer's order history, plus four ad hoc business questions answered on top of it.

## Business Context
Two rules set the scope before the mart was built:
- Only orders with status **Delivered** or **Canceled** are included.
- The mart is limited to the **3 regions with the highest order volume**.

Each row represents a unique **(customer, region)** pair — a customer active in more than one top-3 region appears once per region.

## Data Mart: `product_user_features`

| Column | Description |
|---|---|
| `user_id` | Unique customer identifier |
| `region` | Region the order was placed from |
| `first_order_ts` | Timestamp of the customer's first order |
| `last_order_ts` | Timestamp of the customer's last order |
| `lifetime` | Days between first and last order |
| `total_orders` | Total number of orders |
| `avg_order_rating` | Average rating the customer gave their orders |
| `num_orders_with_rating` | Number of rated orders |
| `num_canceled_orders` | Number of canceled orders |
| `canceled_orders_ratio` | Share of canceled orders |
| `total_order_costs` | Total value of delivered orders |
| `avg_order_cost` | Average order value |
| `num_installment_orders` | Orders paid in installments |
| `num_orders_with_promo` | Orders paid using a promo code |
| `used_money_transfer` | Ever used money transfer as first payment method (binary) |
| `used_installments` | Ever paid in installments (binary) |
| `used_cancel` | Ever canceled an order (binary) |

## Ad Hoc Analysis

**1. Order-count segmentation**
Customers grouped into `1 order` / `2–5 orders` / `6–10 orders` / `11+ orders`, with user count, avg orders, and avg order cost per segment.

**2. Top spenders ranking**
Customers with 3+ orders, ranked by average order value — top 15.

**3. Regional breakdown**
Per region: customer & order counts, avg order cost, installment share, promo share, cancellation share.

**4. 2023 monthly cohorts by first-order month**
Per cohort: customer & order counts, avg order cost, avg rating, money-transfer share, avg customer lifetime.

## Tech Stack
PostgreSQL — CTEs, window functions, conditional aggregation
