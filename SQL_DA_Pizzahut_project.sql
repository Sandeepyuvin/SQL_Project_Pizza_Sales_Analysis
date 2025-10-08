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
select count(order_id) as Total_orders
from orders;

-- 2. Calculate the total revenue generated from pizza sales.
select round(sum(od.quantity*p.price),2) as Total_revenue
from pizzas as p
join order_details as od on p.pizza_id = od.pizza_id;

-- 3. Identify the highest-priced pizza.

select pt.name, p.price as Highest_priced
from pizzas as p
join pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
-- group by pt.name,p.price
order by Highest_priced desc
limit 1;

-- 4. Identify the most common pizza size ordered.
select p.size,count(od.order_details_id) as common_pizza_size
from pizzas as p
join order_details as od on p.pizza_id = od.pizza_id
group by p.size
order by common_pizza_size desc
limit 1;

-- 5. List the top 5 most ordered pizza types along with their quantities.

select pt.name,pt.pizza_type_id,sum(od.quantity) as quantities
from pizza_types as pt
join pizzas as p on pt.pizza_type_id = p.pizza_type_id
join order_details as od on p.pizza_id = od.pizza_id
group by pt.name,pt.pizza_type_id
order by sum(od.quantity) desc
limit 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category,sum(od.quantity) as Total_quantity
from pizza_types as pt
join pizzas as p on pt.pizza_type_id= p.pizza_type_id
join order_details as od on p.pizza_id = od.pizza_id
group by pt.category 
order by sum(od.quantity) desc;


-- 7. Determine the distribution of orders by hour of the day.

select hour(order_time) as hour,count(order_id) as order_count
from orders
group by hour(order_time);
 
-- 8.Join relevant tables to find the category-wise distribution of pizzas
select category as category_wise ,count(name) as count_of_pizza
from pizza_types
group by category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quatities),2) from
(select o.order_date,sum(od.quantity) as quatities
from order_details as od
join orders as o on od.order_id = o.order_id
group by o.order_date ) as order_quantity;


-- 10. Determine the top 3 most ordered pizza types based on revenue.

select pt.name, sum(od.quantity*p.price) as Revenue
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by  pt.name
order by sum(od.quantity*p.price) desc
limit 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

select pt.category,round((sum(od.quantity*p.price)/(select round(sum(od.quantity*p.price),2) as Total_revenue
from pizzas as p
join order_details as od on p.pizza_id = od.pizza_id))*100,2) as Revenue 
from order_details as od
join pizzas as p on od.pizza_id = p.pizza_id
join pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
group by  pt.category
order by sum(od.quantity*p.price) desc;

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



































