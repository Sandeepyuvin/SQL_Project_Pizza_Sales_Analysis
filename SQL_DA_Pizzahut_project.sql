create database Pizza;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id)
);

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id)
);
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Retrieve the total number of orders placed.
use pizza;
SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS Total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id;

-- 3. Identify the highest-priced pizza.

SELECT 
    pt.name, p.price AS Highest_priced
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY Highest_priced DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS common_pizza_size
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY common_pizza_size DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, pt.pizza_type_id, SUM(od.quantity) AS quantities
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.name , pt.pizza_type_id
ORDER BY SUM(od.quantity) DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS Total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY SUM(od.quantity) DESC;


-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);
 
-- 8.Join relevant tables to find the category-wise distribution of pizzas
SELECT 
    category AS category_wise, COUNT(name) AS count_of_pizza
FROM
    pizza_types
GROUP BY category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quatities), 2)
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quatities
    FROM
        order_details AS od
    JOIN orders AS o ON od.order_id = o.order_id
    GROUP BY o.order_date) AS order_quantity;


-- 10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(od.quantity * p.price) AS Revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY SUM(od.quantity * p.price) DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS Total_revenue
                FROM
                    pizzas AS p
                        JOIN
                    order_details AS od ON p.pizza_id = od.pizza_id)) * 100,
            2) AS Revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY SUM(od.quantity * p.price) DESC;

-- 12. Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over(order by order_date) as cummulative_revenue
from(
select o.order_date,sum(od.quantity*p.price) as revenue
from order_details as od
join pizzas as p on od.pizza_id = od.pizza_id
join orders as o on od.order_id = o.order_id
group by o.order_date) as sales;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, revenue
FROM (
    SELECT 
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS revenue,
        ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rn
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) ranked
WHERE rn <= 3
ORDER BY category, revenue DESC;



































