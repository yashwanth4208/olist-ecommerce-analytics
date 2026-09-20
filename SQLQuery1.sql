USE olist_analytics;

SELECT COUNT(DISTINCT customer_unique_id)
FROM customers;

SELECT COUNT(*)
FROM order_items;

SELECT TOP 10 *
FROM customers;

SELECT TOP 10 *
FROM orders;

SELECT TOP 10 *
FROM order_items;

USE olist_analytics;

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM order_payments

UNION ALL

SELECT 'order_reviews', COUNT(*)
FROM order_reviews

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers;

SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;

SELECT
    SUM(price) AS product_revenue
FROM order_items;

SELECT
    SUM(freight_value) AS total_freight
FROM order_items;

SELECT
    SUM(price + freight_value) AS total_value
FROM order_items;

SELECT
    DATEFROMPARTS(
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp),
        1
    ) AS month,
    COUNT(DISTINCT order_id) AS orders
FROM orders
GROUP BY
    DATEFROMPARTS(
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp),
        1
    )
ORDER BY month;

SELECT
    SUM(oi.price) /
    COUNT(DISTINCT o.order_id) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';



SELECT
    t.product_category_name_english AS category,
    SUM(oi.price) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY t.product_category_name_english
ORDER BY revenue DESC;

SELECT TOP 10
    p.product_id,
    SUM(oi.price) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY revenue DESC;

SELECT
    c.customer_state,
    SUM(oi.price) AS revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN order_count > 1 THEN 'Repeat'
        ELSE 'One-time'
    END AS customer_type,
    COUNT(*) AS customers
FROM customer_orders
GROUP BY
    CASE
        WHEN order_count > 1 THEN 'Repeat'
        ELSE 'One-time'
    END
ORDER BY customers DESC;


WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    AVG(revenue) AS avg_customer_spend
FROM customer_revenue;

SELECT
    AVG(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        )
    ) AS avg_delivery_time_days
FROM orders
WHERE order_status = 'delivered';

SELECT
    100.0 *
    SUM(
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    )
    /
    COUNT(*) AS late_delivery_percentage
FROM orders
WHERE order_status = 'delivered';

SELECT
    AVG(review_score) AS average_review_score
FROM order_reviews;

SELECT
    review_score,
    COUNT(*) AS reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    AVG(CAST(r.review_score AS DECIMAL(10,2))) AS avg_review_score,
    COUNT(*) AS reviews
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END;