-- ============================================================
-- Data Mart: product_user_features
-- Builds an aggregated view of each customer's order behavior,
-- limited to the 3 highest-volume regions and to orders with
-- status Delivered or Canceled.
-- ============================================================

WITH top_3_regions AS (
	SELECT u.region 
	FROM ds_ecom.users AS u
	JOIN ds_ecom.orders AS o USING(buyer_id)
	GROUP BY u.region
	ORDER BY COUNT(order_id) DESC 
	LIMIT 3
),
general_orders_info AS (
	SELECT u.user_id,
		   u.region,
		   MIN(o.order_purchase_ts) AS first_order_ts,
		   MAX(o.order_purchase_ts) AS last_order_ts,
		   EXTRACT(DAY FROM (MAX(o.order_purchase_ts) - MIN(o.order_purchase_ts))) AS lifetime,
		   COUNT(DISTINCT o.order_id) AS total_orders,
		   ROUND(AVG(r.review_score), 2) AS avg_order_rating,
		   COUNT(DISTINCT r.order_id) AS num_orders_with_rating
	FROM ds_ecom.users AS u
	JOIN ds_ecom.orders AS o USING(buyer_id)
	LEFT JOIN ds_ecom.order_reviews AS r ON o.order_id = r.order_id
	WHERE o.order_status IN ('Delivered', 'Canceled') 
		AND u.region IN (
			SELECT region 
			FROM top_3_regions
		)
	GROUP BY u.user_id, u.region
),
canceled_orders AS (
	SELECT u.user_id,
		   u.region,
		   COUNT(o.order_id) AS num_canceled_orders
	FROM ds_ecom.users AS u
	JOIN ds_ecom.orders AS o USING(buyer_id)
	WHERE order_status = 'Canceled' 
		AND u.region IN (
			SELECT region 
			FROM top_3_regions
		)
	GROUP BY u.user_id, u.region
),
orders_costs AS (
	SELECT u.user_id,
		   u.region,
		   oi.order_id,
		   SUM(oi.price + oi.delivery_cost) AS full_order_cost
	FROM ds_ecom.users AS u
	JOIN ds_ecom.orders AS o USING(buyer_id)
	JOIN ds_ecom.order_items AS oi USING(order_id)
	WHERE order_status = 'Delivered'
		AND u.region IN (
			SELECT region 
			FROM top_3_regions
		)
	GROUP BY u.user_id, u.region, oi.order_id
),
total_costs AS (
	SELECT user_id,
		   region, 
		   SUM(full_order_cost) AS total_order_costs,
		   AVG(full_order_cost) AS avg_order_cost
	FROM orders_costs 
	GROUP BY user_id, region
),
users_payments AS (
	SELECT u.user_id,
		   u.region,
		   COUNT(
		   	   DISTINCT CASE 
		   	       WHEN op.payment_installments > 1
		   	       	   THEN o.order_id
		   	   END
		   ) AS num_installment_orders,
		   COUNT(
		   	   DISTINCT CASE 
		   	       WHEN op.payment_type = 'promo_code'
		   	       	   THEN o.order_id
		   	   END
		   ) AS num_orders_with_promo,
		   MAX(
		   	   CASE 
		   	   	   WHEN op.payment_sequential = 1 AND op.payment_type = 'money_transfer'
		   	   	       THEN 1
		   	   	   ELSE 0
		   	   END  
		   ) AS used_money_transfer
	FROM ds_ecom.users AS u 
	JOIN ds_ecom.orders AS o USING(buyer_id)
	LEFT JOIN ds_ecom.order_payments AS op USING(order_id)
	WHERE o.order_status IN ('Delivered', 'Canceled') 
		AND u.region IN (
			SELECT region 
			FROM top_3_regions
		)
	GROUP BY u.user_id, u.region
)

SELECT goi.user_id,
	   goi.region,
	   goi.first_order_ts,
	   goi.last_order_ts,
	   goi.lifetime,
	   goi.total_orders,
	   goi.avg_order_rating,
	   goi.num_orders_with_rating,
	   COALESCE(co.num_canceled_orders, 0) AS num_canceled_orders,
	   COALESCE(ROUND(co.num_canceled_orders::numeric / goi.total_orders , 2), 0) AS canceled_orders_ratio,
	   COALESCE(tc.total_order_costs, 0) AS total_order_costs,
	   COALESCE(tc.avg_order_cost, 0) AS avg_order_cost,
	   up.num_installment_orders,
	   up.num_orders_with_promo,
	   up.used_money_transfer,
	   CASE 
	   	   WHEN up.num_installment_orders > 0
	   	   	   THEN 1
	   	   ELSE 0
	   END AS used_installments,
	   CASE 
	   	   WHEN COALESCE(co.num_canceled_orders, 0) > 0
	   	   	   THEN 1
	   	   ELSE 0
	   END AS used_cancel
FROM general_orders_info AS goi
LEFT JOIN canceled_orders AS co USING(user_id, region)
LEFT JOIN total_costs AS tc USING(user_id, region)
JOIN users_payments AS up USING(user_id, region)
ORDER BY goi.user_id, goi.region;