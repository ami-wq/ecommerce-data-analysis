WITH users_segments AS (
	SELECT user_id,
		   total_orders,
		   total_order_costs,
		   CASE 
		   	   WHEN total_orders = 1
		   	   	   THEN '1 order'
		   	   WHEN total_orders BETWEEN 2 AND 5
		   	   	   THEN '2—5 orders'
		   	   WHEN total_orders BETWEEN 6 AND 10
		   	   	   THEN '6–10 orders'
		   	   ELSE '11 and more orders'
		   END AS segment
	FROM ds_ecom.product_user_features
)

SELECT segment,
	   COUNT(user_id) AS num_users,
	   ROUND(AVG(total_orders), 2) AS avg_orders,
	   ROUND(SUM(total_order_costs)::numeric / SUM(total_orders), 2) AS avg_costs
FROM users_segments
GROUP BY segment
ORDER BY MIN(total_orders);

/* Segmentation analysis revealed the following patterns:
 * 1. The vast majority of customers placed only one order.
 * 2. As the frequency of purchases increases, the size of the segment decreases. There is virtually no loyal customer base.
 * 3. Customers with a single order tend to purchase more expensive items, while the few loyal customers tend to switch to smaller, less expensive purchases.
*/

SELECT user_id,
	   total_orders, 
       avg_order_cost
FROM  ds_ecom.product_user_features
WHERE total_orders >= 3
ORDER BY avg_order_cost DESC
LIMIT 15;

/* The vast majority of users in the ranking (13 out of 15) fall at the very lower end of the filter (3 orders).
 * This top list confirms the conclusion that buyers are focused on infrequent and expensive purchases rather than everyday and regular ones.
*/

SELECT region,
	   COUNT(user_id) AS total_users,
	   SUM(total_orders) AS total_orders,
	   ROUND(SUM(total_order_costs)::numeric / SUM(total_orders), 2) AS avg_order_cost,
	   ROUND(SUM(num_installment_orders)::numeric / SUM(total_orders), 2) AS installment_orders_ratio,
	   ROUND(SUM(num_orders_with_promo)::numeric / SUM(total_orders), 2) AS orders_with_promo_ratio,
	   ROUND(AVG(used_cancel), 2) AS used_cancel_ratio
FROM ds_ecom.product_user_features
GROUP BY region
ORDER BY region;

/* An analysis by region revealed the following trends:
 * 1. Moscow leads in terms of the number of users. However, it also has the lowest average transaction value.
 * 2. Customers from St. Petersburg and the Novosibirsk Region are significantly more likely to make purchases on an installment plan.
 * 3. The percentage of promo code usage and the share of users with cancellations are consistently low across all regions.
*/

SELECT DATE_TRUNC('month', first_order_ts)::date AS month,
	   COUNT(user_id) AS total_users,
	   SUM(total_orders) AS total_orders,
	   ROUND(SUM(total_order_costs)::numeric / SUM(total_orders), 2) AS avg_order_cost,
	   ROUND(AVG(avg_order_rating), 2) AS avg_order_rating,
	   ROUND(AVG(used_money_transfer), 2) AS used_money_transfer_ratio,
	   EXTRACT(DAY FROM AVG(lifetime)) AS avg_lifetime_days
FROM ds_ecom.product_user_features
WHERE EXTRACT(YEAR FROM first_order_ts) = 2023
GROUP BY DATE_TRUNC('month', first_order_ts)::date
ORDER BY month;

/* There is a peak in new user growth in November.
 * Regardless of the month of registration, the proportion of users who use money transfers for their first payment is low.
 * As expected, the average time spent active decreases from older customers to newer ones.
 */