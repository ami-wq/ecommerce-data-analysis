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

| segment | num_users | avg_orders | avg_costs |
|---|---|---|---|
| 1 order | 60468 | 1.00 | 3305.66 |
| 2—5 orders |	1934 |	2.09 |	3058.39 |
| 6–10 orders |	5 |	7.00 |	2769.57 |
| 11 and more orders |	1 |	15.00 |	1244.80 |

**2. Top spenders ranking**
Customers with 3+ orders, ranked by average order value — top 15.

| user_id | total_orders | avg_order_cost |
|---|---|---|
| 1da09dd64e235e7c2f29a4faff33535c | 3 | 14716.67 |
| 297ec5afd18366f5ba27520cc4954151 | 3 | 12478.33 |
| cef29e793e232d30250331804cdb7000 | 3 | 11518.33 |
| 397b44d5bb99eabf54ea9c2b41ebb905 | 4 | 10928.25 |
| d132b863416f85f2abb1a988ca05dd12 | 3 | 9704.67 |
| d387ea85dc301a91740e31360d355686 | 3 | 9141.67 |
| 4e1cce07cd5937c69dacac3c8b13d965 | 3 | 8603.33 |
| 9832ae2f7d3e5fa4c7a1a06e9551bc61 | 3 | 7971.67 |
| fe81bb32c243a86b2f86fbf053fe6140 | 5 | 7596.60 |
| 8961b4ca2c5aceb7a78ea72c6e0c840a | 3 | 6351.67 |
| b2e9a05d23ea17713b5d7799f2004f8e | 3 | 6046.67 |
| 6419a1be8feac26ec793667b71cbaeb4 | 3 | 6040.00 |
| ab243cd9e788d689cc822380f59616e1 | 3 | 5908.33 |
| e30b83af13d6ff0b0f427b2a67c43b39 | 3 | 5558.33 |
| 3de0c9303f39b7ccfe69ca11aee19cc6 | 3 | 5526.67 |

**3. Regional breakdown**
Per region: customer & order counts, avg order cost, installment share, promo share, cancellation share.

| region | total_users | total_orders | avg_order_cost | installment_orders_ratio | orders_with_promo_ratio | used_cancel_ratio |
|---|---|---|---|---|---|---|
| Мoscow | 39386 | 40747 | 3140.14 | 0.48 |	0.04 | 0.01 |
| Novosibirsk Oblast | 11044 |	11401 |	3491.79 |	0.54 |	0.04 |	0.00 |
| Saint Petersburg |	11978 |	12414 |	3593.46 |	0.55 |	0.04 |	0.01 |

**4. 2023 monthly cohorts by first-order month**
Per cohort: customer & order counts, avg order cost, avg rating, money-transfer share, avg customer lifetime.

| month | total_users | total_orders | avg_order_cost | avg_order_rating | used_money_transfer_ratio | avg_lifetime_days |
|---|---|---|---|---|---|---|
| 2023-01-01 |	465  |	499  |	2865.79 |	4.18 |	0.21 |	12 |
| 2023-02-01 |	1063 |	1115 |	2556.01 |	4.17 |	0.22 |	7 |
| 2023-03-01 |	1663 |	1762 |	2764.68 |	4.19 |	0.21 |	8 |
| 2023-04-01 |	1435 |	1511 |	3144.97 |	4.14 |	0.19 |	7 |
| 2023-05-01 |	2197 |	2322 |	2775.32 |	4.22 |	0.20 |	7 |
| 2023-06-01 |	1985 |	2107 |	2916.85 |	4.19 |	0.20 |	7 |
| 2023-07-01 |	2463 |	2604 |	2767.91 |	4.22 |	0.21 |	6 |
| 2023-08-01 |	2595 |	2742 |	2822.22 |	4.32 |	0.20 |	5 |
| 2023-09-01 |	2591 |	2737 |	3263.46 |	4.27 |	0.21 |	5 |
| 2023-10-01 |	2832 |	2954 |	3228.78 |	4.20 |	0.21 |	3 |
| 2023-11-01 |	4703 |	4892 |	3168.63 |	4.00 |	0.19 |	2 |
| 2023-12-01 |	3589 |	3696 |	3164.07 |	4.08 |	0.20 |	2 |

## Tech Stack
PostgreSQL — CTEs, conditional aggregation
