--questions
--Basic:
--Retrieve the total number of orders placed.
--Calculate the total revenue generated from pizza sales.
--Identify the highest-priced pizza.
--Identify the most common pizza size ordered.
--List the top 5 most ordered pizza types along with their quantities.


--Intermediate:
--Join the necessary tables to find the total quantity of each pizza category ordered.
--Determine the distribution of orders by hour of the day.
--Join relevant tables to find the category-wise distribution of pizzas.
--Group the orders by date and calculate the average number of pizzas ordered per day.
--Determine the top 3 most ordered pizza types based on revenue.

--Advanced:
--Calculate the percentage contribution of each pizza type to total revenue.
--Analyze the cumulative revenue generated over time.
--Determine the top 3 most ordered pizza types based on revenue for each pizza category.



--basics


select count(order_id) as total_orders
from PizzaStore..orders



select  round(sum(pizzas.price*order_details.quantity),2) as total_Sales
from PizzaStore..order_details
Inner Join PizzaStore..pizzas
	on order_details.pizza_id=pizzas.pizza_id


select  name,price 
from PizzaStore..pizza_types
Inner Join PizzaStore..pizzas
	on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by price desc 



select  pizzas.size,count(order_details.order_details_id) as most_common_size
from PizzaStore..order_details
Inner Join PizzaStore..pizzas
	on order_details.pizza_id=pizzas.pizza_id
group by pizzas.size
order by most_common_size desc



select pizza_types.name,pizzas.pizza_type_id, sum(order_details.quantity) total_ordered
from PizzaStore..order_details
Inner Join PizzaStore..pizzas
	on order_details.pizza_id=pizzas.pizza_id
Inner Join PizzaStore..pizza_types
	ON pizzas.pizza_type_id=pizza_types.pizza_type_id
group by pizza_types.name,pizzas.pizza_type_id
order by total_ordered desc



--intermediate

select *
from PizzaStore..pizzas

select pizza_types.category, sum(order_details.quantity) total_ordered
from PizzaStore..order_details
Inner Join PizzaStore..pizzas
	on order_details.pizza_id=pizzas.pizza_id
Inner Join PizzaStore..pizza_types
	ON pizzas.pizza_type_id=pizza_types.pizza_type_id
group by pizza_types.category
order by total_ordered desc



select datepart(hour,time) as hour , count(order_id) hourlyorder
from PizzaStore..orders
group by datepart(hour,time)
order by hour


select category,count(pizza_type_id) as types
from PizzaStore..pizza_types
group by category

select round(AVG(orders_per_day),0)
from
(
select orders.date, sum(order_details.quantity) orders_per_day
from PizzaStore..orders
Inner Join PizzaStore..order_details
	on order_details.order_id=orders.order_id
group by orders.date
--order by orders.date
) as avg_quantity


select pizza_types.name,pizzas.pizza_type_id,sum(order_details.quantity*pizzas.price) revenue_per_type
from PizzaStore..order_details
Inner Join PizzaStore..pizzas
	on order_details.pizza_id=pizzas.pizza_id
Inner Join PizzaStore..pizza_types
	on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizzas.pizza_type_id, pizza_types.name
order by revenue_per_type desc


--advanced


select pizza_types.name,pizzas.pizza_type_id,
round(sum(order_details.quantity*pizzas.price)/
(	select sum(pizzas.price*order_details.quantity) as total_Sales
	from PizzaStore..order_details
		Inner Join PizzaStore..pizzas
		on order_details.pizza_id=pizzas.pizza_id
),4)*100 as revenue_percentage
from PizzaStore..order_details
Inner Join PizzaStore..pizzas
	on order_details.pizza_id=pizzas.pizza_id
Inner Join PizzaStore..pizza_types
	on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizzas.pizza_type_id, pizza_types.name
order by revenue_percentage desc




select pizza_types.category, 
round(sum(order_details.quantity*pizzas.price)/
(	select sum(pizzas.price*order_details.quantity) as total_Sales
	from PizzaStore..order_details
		Inner Join PizzaStore..pizzas
		on order_details.pizza_id=pizzas.pizza_id
),4)*100 as revenue_percentage_cat
from PizzaStore..order_details
Inner Join PizzaStore..pizzas
	on order_details.pizza_id=pizzas.pizza_id
Inner Join PizzaStore..pizza_types
	ON pizzas.pizza_type_id=pizza_types.pizza_type_id
group by pizza_types.category
order by revenue_percentage_cat desc




select datepart(MM,orders.date) month, round(sum(order_details.quantity*pizzas.price),2) sales_per_day,
round(sum(sum(order_details.quantity*pizzas.price)) over( order by datepart(MM,orders.date)),2)  cumulative
from PizzaStore..orders
Inner Join PizzaStore..order_details
	on order_details.order_id=orders.order_id
Inner Join PizzaStore..pizzas
	on order_details.pizza_id=pizzas.pizza_id
group by datepart(MM,orders.date)
order by month



with top3 as (
select pizza_types.name,pizza_types.category,sum(order_details.quantity*pizzas.price) revenue_of_type,
ROW_NUMBER() over (partition by pizza_types.category order by sum(order_details.quantity*pizzas.price) desc ) as cat_rank
from PizzaStore..order_details
Inner Join PizzaStore..pizzas
	on order_details.pizza_id=pizzas.pizza_id
Inner Join PizzaStore..pizza_types
	on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizza_types.category, pizza_types.name
--order by pizza_types.category asc,revenue_per_type desc
)
select *
from top3
where cat_rank<=3




with top3size as (
select pizza_types.name,pizza_types.category,pizzas.size,sum(order_details.quantity) total_quantity,
row_number() over (partition by pizzas.size,pizza_types.category order by  sum(order_details.quantity) desc ) row_num
from PizzaStore..order_details
	Inner Join PizzaStore..pizzas
	on order_details.pizza_id=pizzas.pizza_id
	Inner Join PizzaStore..pizza_types
	ON pizzas.pizza_type_id=pizza_types.pizza_type_id
	Inner Join PizzaStore..orders
	ON order_details.order_id=orders.order_id
Group by pizza_types.name,pizza_types.category,pizzas.size
--
)
select name,category,size, total_quantity
from top3size
where row_num<=3
order by category asc, size desc

