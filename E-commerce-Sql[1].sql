CREATE DATABASE olist_ecommerce;
USE olist_ecommerce;

show tables;


Select * from olist_order_payments_dataset;
Select * from olist_sellers_dataset;
Select * from product_category_name_translation;
Select * from olist_order_items_dataset;
Select * from olist_products_dataset;
Select * from olist_order_reviews_dataset;
SELECT * FROM olist_orders_dataset;
Select * from olist_customers_dataset;


-- COUNT OF DELIVERED ORDERS --
SELECT count(order_status), order_status
FROM olist_orders_dataset
WHERE order_status = 'delivered'
GROUP BY order_status;

##### SALES & REVENUE KPI's #####

-- TOTAL REVENUE -- 
SELECT concat(Round((sum(price)/1000000),2),"M") AS Total_Revenue 
FROM olist_order_items_dataset;

-- TOTAL ORDERS --
SELECT count(DISTINCT order_id) AS Total_Orders
FROM olist_orders_dataset;

-- AVERAGE ORDER VALUE -- 
SELECT concat('$',round((sum(p.payment_value)/count(DISTINCT o.order_id)),2)) AS Avg_Order_Value
FROM olist_order_payments_dataset p
JOIN olist_orders_dataset o
ON p.order_id = o.order_id;


## CUSTOMERS KPI's ##

-- TOTAL CUSTOMERS --
SELECT count(DISTINCT customer_unique_id) AS Total_Customers
FROM olist_customers_dataset;

-- REPEATED CUSTOMERS COUNT --
SELECT count(*)
FROM 
	(SELECT c.customer_unique_id
	FROM olist_orders_dataset o
	JOIN olist_customers_dataset c
		ON o.customer_id = c.customer_id
	GROUP BY customer_unique_id 
	HAVING count(DISTINCT o.order_id) > 1) AS T;
    
# Category Wise Revenue
SELECT 
    t.product_category_name_english AS category,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset pr 
    ON oi.product_id = pr.product_id
JOIN product_category_name_translation t
    ON pr.product_category_name = t.product_category_name
JOIN olist_order_payments_dataset p
    ON oi.order_id = p.order_id
GROUP BY category
ORDER BY revenue DESC;

#Top 10 Category Revenue
SELECT 
    t.product_category_name_english AS category,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset pr 
    ON oi.product_id = pr.product_id
JOIN product_category_name_translation t
    ON pr.product_category_name = t.product_category_name
JOIN olist_order_payments_dataset p
    ON oi.order_id = p.order_id
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

# Avg Rating
SELECT 
    ROUND(AVG(review_score), 2) AS avg_rating
FROM olist_order_reviews_dataset;

# Late delivered orders
SELECT 
    COUNT(*) AS late_deliveries
FROM olist_orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date > order_estimated_delivery_date;

#late delivery Rate
SELECT ROUND(SUM(
            CASE 
			WHEN order_delivered_customer_date > order_estimated_delivery_date 
			THEN 1 ELSE 0 
            END) * 100.0 / COUNT(*),2) AS late_delivery_rate
FROM olist_orders_dataset
WHERE order_status = 'delivered';


#Payment type distribution 
SELECT 
    payment_type,
    COUNT(*) AS total_payments,
    ROUND(SUM(payment_value), 2) AS total_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_value DESC;

#Monthly revenue
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(payment_value), 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;


    