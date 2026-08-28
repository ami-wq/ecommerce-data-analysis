# Customer Data Mart & Ad Hoc Analysis for an E-Commerce Marketplace

SQL project focused on customer ordering behavior in an e-commerce marketplace.

The project combines **customer-level data mart development** with **ad hoc business analysis** covering customer segmentation, high-value purchases, regional differences, and monthly cohorts.

## Overview

The analysis was performed on a closed educational dataset provided as part of a data science course.

Two business rules define the scope of the analysis:

* Only orders with status **Delivered** or **Canceled** are included.
* The data mart is limited to the **3 regions with the highest order volume**.

Each row of the resulting data mart represents a unique **(customer, region)** pair. A customer active in multiple top-3 regions therefore appears once per region.

## Key Findings

* The vast majority of customers placed only **one order**, while repeat customers represent a very small share of the dataset.
* Among customers with 3+ orders, most of the customers with the highest average order values are concentrated near the minimum threshold of **3 orders**.
* **Moscow** has the largest customer base but the **lowest average order value** among the three analyzed regions.
* Customers from **Saint Petersburg** and **Novosibirsk Oblast** use installment payments more frequently than customers from Moscow.
* **November 2023** shows the strongest increase in the number of new customers.
* The share of customers using money transfers as their first payment method remains relatively stable across cohorts, at around **20%**.

## Data Mart

The project produces the `product_user_features` data mart.

| Column                   | Description                                                               |
| ------------------------ | ------------------------------------------------------------------------- |
| `user_id`                | Unique customer identifier                                                |
| `region`                 | Region the order was placed from                                          |
| `first_order_ts`         | Timestamp of the customer's first order                                   |
| `last_order_ts`          | Timestamp of the customer's last order                                    |
| `lifetime`               | Days between first and last order                                         |
| `total_orders`           | Total number of orders                                                    |
| `avg_order_rating`       | Average rating given by the customer                                      |
| `num_orders_with_rating` | Number of rated orders                                                    |
| `num_canceled_orders`    | Number of canceled orders                                                 |
| `canceled_orders_ratio`  | Share of canceled orders                                                  |
| `total_order_costs`      | Total value of delivered orders                                           |
| `avg_order_cost`         | Average order value                                                       |
| `num_installment_orders` | Number of orders paid in installments                                     |
| `num_orders_with_promo`  | Number of orders paid using a promo code                                  |
| `used_money_transfer`    | Whether the customer ever used money transfer as the first payment method |
| `used_installments`      | Whether the customer ever paid in installments                            |
| `used_cancel`            | Whether the customer ever canceled an order                               |

## Ad Hoc Analysis

### 1. Customer Segmentation by Order Frequency

Customers were divided into four groups:

* `1 order`
* `2–5 orders`
* `6–10 orders`
* `11+ orders`

| Segment     | Customers | Avg. Orders | Avg. Order Value |
| ----------- | --------: | ----------: | ---------------: |
| 1 order     |    60,468 |        1.00 |         3,305.66 |
| 2–5 orders  |     1,934 |        2.09 |         3,058.39 |
| 6–10 orders |         5 |        7.00 |         2,769.57 |
| 11+ orders  |         1 |       15.00 |         1,244.80 |

The dataset is strongly concentrated around one-time purchases. As order frequency increases, the customer segment becomes dramatically smaller.

At the same time, customers with fewer orders tend to have a higher average order value, while the small group of highly active customers tends to make less expensive purchases.

### 2. Customers with the Highest Average Order Value

Customers with at least 3 orders were ranked by `avg_order_cost`.

| User                               | Orders | Avg. Order Value |
| ---------------------------------- | -----: | ---------------: |
| `1da09dd64e235e7c2f29a4faff33535c` |      3 |        14,716.67 |
| `297ec5afd18366f5ba27520cc4954151` |      3 |        12,478.33 |
| `cef29e793e232d30250331804cdb7000` |      3 |        11,518.33 |
| `397b44d5bb99eabf54ea9c2b41ebb905` |      4 |        10,928.25 |
| `d132b863416f85f2abb1a988ca05dd12` |      3 |         9,704.67 |

The ranking is heavily concentrated near the lower bound of the filter: **13 of the top 15 customers placed exactly 3 orders**.

This suggests that high average order value is not necessarily associated with high purchase frequency in the analyzed dataset.

### 3. Regional Analysis

| Region             | Customers | Orders | Avg. Order Value | Installment Share | Promo Share | Cancellation Share |
| ------------------ | --------: | -----: | ---------------: | ----------------: | ----------: | -----------------: |
| Moscow             |    39,386 | 40,747 |         3,140.14 |               48% |          4% |                 1% |
| Novosibirsk Oblast |    11,044 | 11,401 |         3,491.79 |               54% |          4% |                 0% |
| Saint Petersburg   |    11,978 | 12,414 |         3,593.46 |               55% |          4% |                 1% |

Key observations:

* Moscow has the largest customer base but the lowest average order value.
* Installment usage is higher in Saint Petersburg and Novosibirsk Oblast.
* Promo-code usage remains consistently low across all three regions.
* Cancellation shares are also low and show little variation between regions.

### 4. Monthly Cohort Analysis

Customers were grouped by their **first-order month in 2023**.

| Cohort Month | Customers | Orders | Avg. Order Value | Avg. Rating | Money Transfer Share | Avg. Lifetime |
| ------------ | --------: | -----: | ---------------: | ----------: | -------------------: | ------------: |
| Jan          |       465 |    499 |         2,865.79 |        4.18 |                  21% |       12 days |
| Feb          |     1,063 |  1,115 |         2,556.01 |        4.17 |                  22% |        7 days |
| Mar          |     1,663 |  1,762 |         2,764.68 |        4.19 |                  21% |        8 days |
| Apr          |     1,435 |  1,511 |         3,144.97 |        4.14 |                  19% |        7 days |
| May          |     2,197 |  2,322 |         2,775.32 |        4.22 |                  20% |        7 days |
| Jun          |     1,985 |  2,107 |         2,916.85 |        4.19 |                  20% |        7 days |
| Jul          |     2,463 |  2,604 |         2,767.91 |        4.22 |                  21% |        6 days |
| Aug          |     2,595 |  2,742 |         2,822.22 |        4.32 |                  20% |        5 days |
| Sep          |     2,591 |  2,737 |         3,263.46 |        4.27 |                  21% |        5 days |
| Oct          |     2,832 |  2,954 |         3,228.78 |        4.20 |                  21% |        3 days |
| Nov          |     4,703 |  4,892 |         3,168.63 |        4.00 |                  19% |        2 days |
| Dec          |     3,589 |  3,696 |         3,164.07 |        4.08 |                  20% |        2 days |

November had the highest number of new customers in the analyzed period.

The share of users whose first payment was made via money transfer remained relatively stable across cohorts, while average lifetime naturally decreases for more recent cohorts because they have had less time to remain active.

## Tech Stack

**PostgreSQL** · **SQL** · **Data Analysis**

## Data & Reproducibility

The project uses a **closed educational dataset** provided as part of the course.

The source database cannot be published or redistributed, so the repository contains the SQL analysis and documentation, but not the original data.
