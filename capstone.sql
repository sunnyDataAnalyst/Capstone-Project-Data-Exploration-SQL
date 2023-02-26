--Q.1) How many customers do we have in the data?
SELECT count(*) AS number_of_customers
FROM customers;

-- Q.2) What was the city with the most profit for the company in 2015?
SELECT o.shipping_city, sum(od.order_profits) AS total
FROM orders AS o
INNER JOIN order_details AS od
ON o.order_id = od.order_id
WHERE DATE_PART('year', order_date) = 2015
GROUP BY 1
ORDER BY total DESC
LIMIT 5;

-- WITH t1 AS (
-- SELECT /*(SELECT MAX(order_profits)
-- FROM order_details) AS MAX_profits,*/ shipping_city 
-- FROM orders 
-- WHERE extract(year from order_date) = '2015' AND order_Profis = (SELECT MAX(order_profits) FROM order_details)                                         /* order_profits = (SELECT MAX(order_profits) FROM order_details ) */
-- LIMIT 5;

-- SELECT MAX(order_profits)
-- FROM order_details
-- WITH t1 AS (
-- SELECT SUM(order_profits), o.shipping_city
-- FROM orders AS o
-- INNER JOIN order_details AS od
-- ON o.order_id = od.order_id
-- WHERE extract(year from o.order_date) = '2015'
-- GROUP BY 2
-- LIMIT 5)
-- SELECT shipping_city
-- FROM t1;
-- select o.shipping_city, MAX(od.order_profits) AS total_profit
-- FROM orders AS o
-- INNER JOIN order_details AS od
-- ON o.order_id = od.order_id
-- WHERE extract(year from o.order_date) = '2015'
-- GROUP BY o.shipping_city
-- ORDER BY total_profit DESC


-- Q.3)In 2015, what was the most profitable city's profit?
SELECT o.shipping_city, sum(od.order_profits) AS total
FROM orders AS o
INNER JOIN order_details AS od
ON o.order_id = od.order_id
WHERE DATE_PART('year', order_date) = 2015
GROUP BY 1
ORDER BY total DESC
LIMIT 5;
-- Q.4) How many different cities do we have in the data?
SELECT  count(DISTINCT shipping_city)
FROM orders;

-- Q.5) Show the total spent by customers from low to high.
SELECT customer_name, order_sales
FROM customers AS c
INNER JOIN orders AS o
USING(customer_id)
INNER JOIN order_details AS od
USING(order_id)
ORDER BY order_sales DESC;

-- Q.6) What is the most profitable city in the State of Tennessee?
SELECT o.shipping_city, SUM(od.order_profits) AS total_profit 
FROM orders AS o
INNER JOIN order_details AS od
ON o.order_id = od.order_id
WHERE shipping_state = 'Tennessee'
GROUP BY 1
ORDER BY total_profit DESC;

-- Q.7) What’s the average annual profit for that city across all years?
SELECT AVG(od.order_profits) AS annual_profits, o.shipping_city
FROM order_details AS od
INNER JOIN orders AS o
USING (order_id) 
WHERE  o.shipping_city  = 'Lebanon'
GROUP BY o.shipping_city
ORDER BY annual_profits DESC;

-- Q.8) What is the distribution of customer types in the data?
SELECT customer_segment, COUNT(*) 
FROM customers
GROUP BY 1;

-- Q.9) What’s the most profitable product category on average in Iowa across all years?
SELECT p.product_category, AVG(order_profits)
FROM product AS P
INNER JOIN order_details AS Od
USING (product_id)
INNER JOIN orders AS o
USING (order_id)
WHERE shipping_state = 'Iowa' 
GROUP BY p.product_category;

-- Q.10) What is the most popular product in that category across all states in 2016?
SELECT p.product_name, SUM(od.quantity) AS popular_product
FROM product AS P
INNER JOIN order_details AS Od
USING (product_id)
INNER JOIN orders AS o
USING (order_id)
WHERE EXTRACT(year from o.order_date) = 2016 AND product_category = 'Furniture'
GROUP BY p.product_name
ORDER BY popular_product DESC;

-- Q.11) Which customer got the most discount in the data? (in total amount)
WITH t1 AS (
    SELECT order_sales /(1-order_discount) AS original_price , order_id
    FROM order_details)
    
SELECT c.customer_id, t.original_price - od.order_sales AS discount_amount
FROM order_details AS od
INNER JOIN orders AS o
USING (order_id)
INNER JOIN customers AS c
USING (customer_id)
INNER JOIN t1 AS t
USING (order_id)
ORDER BY discount_amount DESC;

/*original_price - order_sales
order_sales / (1 - order_discount)
Hint 1: Select the customer id
Hint 2: The table has the "order_discount" in percentages and the final price after the discount, "order_sales."
So, first, you should get the original price using this formula: original_price = order_sales / (1 - order_discount)
Then, subtract from the original_price the "order_sales." discount_amount = original_price - order_sales*/


-- Q.12) How widely did monthly profits vary in 2018?
SELECT to_char(o.order_date, 'YYYY-MM') AS month, SUM(od.order_profits) AS profits, 
       (SUM(od.order_profits) - Lag(SUM(od.order_profits),1,0) OVER (ORDER BY to_char(o.order_date, 'YYYY-MM')) ) AS DIFF
FROM order_details AS od
INNER JOIN orders AS o
USING (order_id)
WHERE extract(year from order_date) = 2018
GROUP BY month
ORDER BY month;

-- Q.13) Which order was the highest in 2015?
SELECT MAX(od.order_id)
FROM order_details AS od
INNER JOIN orders AS o
USING (order_id)
WHERE date_part('year', order_date) = 2015
GROUP BY od.order_sales
ORDER BY od.order_sales DESC;

-- Q.14) What was the rank of each city in the East region in 2015?
SELECT RANK() OVER(ORDER BY SUM(od.quantity) DESC ) AS RANK, o.shipping_city, SUM(od.quantity) AS Number_of_order
FROM order_details AS od
INNER JOIN orders AS o
USING (order_id)
WHERE date_part('year', o.order_date) = 2015 AND o.shipping_region = 'East'
GROUP BY 2 
ORDER BY 3 DESC;

-- Q.15) Display customer names for customers who are in the segment ‘Consumer’ or ‘Corporate.’ How many customers are there in total? 
-- Hint 1: Select customer_id with the right filtering
-- Hint 2: Count only the customers within Consumer or Corporate segment
SELECT count(distinct customer_name)FROM customers WHERE  customer_segment IN ('Consumer', 'Corporate');

-- Q.16) Calculate the difference between the largest and smallest order quantities for product id ‘100.’
SELECT MAX(quantity) - MIN(quantity) AS DIFF 
FROM order_details
WHERE product_id = 100

-- Q.17) Calculate the percent of products that are within the category ‘Furniture.’ 
SELECT COUNT(*) * 100 * 1.0 / (SELECT COUNT(*) FROM product)::numeric AS percentage
FROM product
WHERE product_category = 'Furniture'

-- Q.18) Display the number of duplicate products based on their product manufacturer.           
-- Example: A product with an identical product manufacturer can be considered a duplicate.
SELECT product_manufacturer, COUNT(*)
FROM product
GROUP BY 1;

-- Q.19) Show the product_subcategory and the total number of products in the subcategory.
-- Show the order from most to least products and then by product_subcategory name ascending.
SELECT product_subcategory, COUNT(*) AS total_number
FROM product
GROUP BY 1
ORDER BY  total_number DESC, 1 ASC ;

-- Q.20) Show the product_id(s), the sum of quantities, where the total sum of its product quantities is greater than or equal to 100.
SELECT product_id, SUM (quantity) AS total
FROM order_details
GROUP BY 1
HAVING SUM(quantity) >= 100;
