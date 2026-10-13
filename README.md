# E-Commerce Customer Data Mart & Analytics

**TL;DR:** This project builds a centralized SQL data mart (`product_user_features`) for an expanding marketplace to lay the groundwork for future ML models. Each row of the resulting data mart represents a unique **(customer, region)** pair. **Key takeaway:** While Moscow drives the highest user volume, regional customers (St. Petersburg, Novosibirsk) demonstrate higher Average Order Values (AOV) and a 14% higher likelihood to use installment payments.

## 🎯 The Challenge
As the "VseTut" marketplace scaled, raw transactional data outgrew simple analytical queries. The business needed a consolidated, 360-degree view of its most active customers to launch personalized marketing and predict churn. 
My goal was to design and populate a user-feature data mart using SQL, and perform ad-hoc analysis to uncover immediate behavioral insights about our core audience.

## 🗂️ The Data
The original data consists of a relational database with 5 main tables: `orders`, `order_items`, `order_payments`, `order_reviews`, and `users`. 
* **Volume:** 99,441 orders covering 32,951 unique products.
* **Period:** September 2022 – October 2024 (Full data available for Jan 2023 – Aug 2024).
* **Constraints & Privacy:** This is an educational dataset provided as part of the course. No sensitive PII (Personally Identifiable Information) is exposed. The raw datasets are intentionally excluded to maintain data privacy.

```mermaid
erDiagram
    users ||--o{ orders : "имеет"
    orders ||--o{ order_items : "включает"
    orders ||--o{ order_payments : "оплачивается"
    orders ||--o{ order_reviews : "получает отзывы"

    users {
        varchar buyer_id PK
        varchar user_id
        varchar zip_code_prefix
        varchar region
    }

    orders {
        varchar order_id PK
        varchar buyer_id FK
        varchar order_status
        timestamp order_purchase_ts
        timestamp order_approved_at
        timestamp order_delivered_carrier_ts
        timestamp order_delivered_ts
        timestamp order_estimated_delivery_dt
    }

    order_items {
        varchar order_id PK FK
        int order_item_id PK
        varchar product_id
        varchar seller_id
        timestamp shipping_limit_date
        numeric price
        numeric delivery_cost
    }

    order_payments {
        varchar order_id PK FK
        int payment_sequential PK
        varchar payment_type
        int payment_installments
    }

    order_reviews {
        varchar review_id PK
        varchar order_id PK FK
        int review_score
        timestamp review_creation_date
        timestamp review_answer_timestamp
    }
```

## 🛠️ Methodology & Data Processing
I applied several critical business filters and transformations:
* **Region Filtering:** The dataset spans 27 regions, but the data is heavily skewed. I filtered the mart to only include the Top-3 most active regions (Moscow, St. Petersburg, Novosibirsk), which account for ~66% of the total customer base.
* **Status Filtering:** Excluded orders in transit or processing. Only `Delivered` and `Canceled` orders were included.
* **Aggregation:** Transformed transactional rows into a user-centric view, calculating metrics like `lifetime`, `canceled_orders_ratio`, and `avg_order_cost` per user-region pair.

## 💡 Key Findings

1. **One-Time Buyers Drive High AOV:** 
   The customer base is heavily skewed towards one-time purchases (60,468 users). Surprisingly, as order frequency increases, the AOV drops. Single-order customers have an AOV of **3,305 RUB**, while highly active users (11+ orders) average only **1,244 RUB**.

2. **Top Spenders Cluster at the 3-Order Mark:**
   When ranking users with 3+ orders by AOV, 13 out of the top 15 highest-spending customers placed exactly 3 orders (with AOVs reaching up to 14,716 RUB). High check amounts do not correlate with high purchase frequency.

3. **Regional Purchasing Habits Differ:**
   * **Moscow** has the largest customer base (39,386) but the lowest AOV (3,140 RUB).
   * **St. Petersburg** leads in AOV (3,593 RUB) and installment usage (55% vs Moscow's 48%).

4. **Acquisition Spikes in November:**
   Monthly cohort analysis (based on the first order in 2023) revealed a massive spike in user acquisition in **November 2023** (4,703 new customers). Meanwhile, payment preferences remain stable: ~20% of users consistently choose money transfers as their first payment method across all cohorts.

## 💻 Stack

**SQL (PostgreSQL)**
