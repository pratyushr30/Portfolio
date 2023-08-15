CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INT,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(10),
  extras VARCHAR(10),
  order_time DATETIME
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name CHAR(30)
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INT,
  toppings VARCHAR(30)
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name CHAR(30)
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

select * from customer_orders;

# DATA CLEANING

CREATE TABLE customer_order_temp SELECT order_id,
    customer_id,
    pizza_id,
    CASE
        WHEN exclusions = 'null' OR exclusions = '' THEN NULL
        ELSE exclusions
    END AS exclusions,
    CASE
        WHEN extras = 'null' OR extras = '' THEN NULL
        ELSE extras
    END AS extras,
    order_time FROM
    customer_orders;

select * from runner_orders;

create table runner_orders_temp select order_id,runner_id,
cast(case WHEN pickup_time = 'null' then NULL else pickup_time end as datetime) as pickup_time,
cast(case WHEN distance = 'null' then NULL else trim('km' from distance) end as FLOAT) as distance,
cast(case WHEN duration = 'null' then NULL WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration) else duration end as FLOAT) as duration,
CASE WHEN cancellation in ('null', '') THEN NULL ELSE cancellation end as cancellation
from runner_orders;


# DATA ANALYSIS

# Number of pizzas ordered

SELECT 
    COUNT(pizza_id) AS 'Pizza ordered'
FROM
    customer_order_temp;

# Unique customer orders
SELECT 
    COUNT(DISTINCT order_id) as 'Unqiue customer order' 
FROM
    customer_order_temp;
    

# Number of Successful orders were delivered by each runner

SELECT 
    runner_id,COUNT(runner_id) as 'Successfull order delivered'
FROM
    runner_orders_temp
WHERE
    cancellation IS NULL
GROUP BY runner_id;

# How many of each type of pizza was delivered?

SELECT 
    c.pizza_id,
    p.pizza_name,
    COUNT(c.pizza_id) AS 'Pizza delivered'
FROM
    runner_orders_temp r
        JOIN
    customer_order_temp c ON r.order_id = c.order_id
        JOIN
    pizza_names p ON c.pizza_id = p.pizza_id
WHERE
    r.cancellation IS NULL
GROUP BY c.pizza_id;

# Vegetarian and Meatlovers were ordered by each customer

select * from customer_order_temp;

SELECT 
    c.customer_id,
    p.pizza_name,
    COUNT(c.pizza_id) AS 'Pizza ordered'
FROM
    customer_order_temp c
        JOIN
    pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id , p.pizza_name
ORDER BY c.customer_id;

# Maximum number of pizzas delivered in a single order

SELECT 
   MAX(items_in_each_order) AS max_items_ordered
FROM
    (SELECT 
        c.order_id, COUNT(c.order_id) AS items_in_each_order
    FROM
        customer_order_temp c
    JOIN pizza_names p ON c.pizza_id = p.pizza_id
    GROUP BY c.order_id
    ORDER BY c.order_id ASC) as item_ordered;
    


# For each customer, Number of delivered pizzas had at least 1 change and how many had no changes?

SELECT 
    c.customer_id,
    SUM(CASE
        WHEN
            c.exclusions IS NOT NULL
                OR c.extras IS NOT NULL
        THEN
            1
        ELSE 0
    END) AS 'Atleast 1 change',
    SUM(CASE
        WHEN c.exclusions IS NULL OR c.extras IS NULL THEN 1
        ELSE 0
    END) AS 'No change'
FROM
    customer_order_temp c
        JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    r.cancellation IS NULL
GROUP BY c.customer_id;

# Number of pizzas delivered that had both exclusions and extras

SELECT 
    c.pizza_id,
    SUM(CASE
        WHEN
            c.exclusions IS NOT NULL
                AND c.extras IS NOT NULL
        THEN
            1
        ELSE 0
    END) AS 'Both exlcusions and extras'
FROM
    customer_order_temp c
        JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    r.cancellation IS NULL
GROUP BY c.pizza_id;

# Total volume of pizzas ordered for each hour of the day

select * from customer_order_temp;

SELECT 
    HOUR(order_time) AS hr_of_day,
    COUNT(pizza_id) AS 'Total pizzas'
FROM
    customer_order_temp
GROUP BY hr_of_day
ORDER BY hr_of_day;

select * from customer_order_temp;

# excluding cancelled orders

SELECT 
    HOUR(order_time) AS hr_of_day,
    COUNT(pizza_id) AS 'Total pizzas'
FROM
    customer_order_temp c
        JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    r.cancellation IS NULL
GROUP BY hr_of_day
ORDER BY hr_of_day;



# Total volume of orders for each day of the week

# Including cancelled orders
SELECT 
    DAYNAME(order_time) AS day_of_week,
    COUNT(pizza_id) AS 'Total pizzas'
FROM
    customer_order_temp
GROUP BY day_of_week
ORDER BY day_of_week;

# Excluding cancelled orders

SELECT 
    DAYNAME(order_time) AS day_of_week,
    COUNT(pizza_id) AS 'Total pizzas'
FROM
    customer_order_temp c
        JOIN
    runner_orders_temp r ON c.order_id = r.order_id
WHERE
    r.cancellation IS NULL
GROUP BY day_of_week
ORDER BY day_of_week;

# Runners signed up for each 1 week period?

SELECT 
    EXTRACT(WEEK from registration_date) AS wk, COUNT(runner_id)
FROM
    runners
GROUP BY wk	;    

# Average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order.

SELECT 
    r.runner_id,round(avg(TIMESTAMPDIFF(minute,order_time,pickup_time))) AS 'Average Pickup time'
FROM
    runner_orders_temp r
        JOIN
    customer_order_temp c ON r.order_id = c.order_id
    group by r.runner_id
    order by runner_id;
    
# Is there any relationship between the number of pizzas and how long the order takes to prepare?
select * from customer_order_temp;
select * from runner_orders_temp;


# Average distance travelled for each customer?

SELECT 
    customer_id, ROUND(AVG(distance), 1)
FROM
    (SELECT distinct
        c.order_id, c.customer_id, r.distance
    FROM
        customer_order_temp c
    JOIN runner_orders_temp r ON c.order_id = r.order_id
    WHERE
        cancellation IS NULL) A
GROUP BY customer_id;
    
# Difference between the longest and shortest delivery times for all orders

SELECT 
    MAX(duration) - MIN(duration) as 'Difference bw L and S'
FROM
    runner_orders_temp;


# Average speed for each runner for each delivery and do you notice any trend for these values
SELECT 
    order_id,
    runner_id,
    distance as 'Distance (km)',
    round((duration / 60),2) AS 'Duration (Hour)',
    round(AVG(distance / (duration / 60)),2) AS 'Avg Speed (Kmph)'
FROM
    runner_orders_temp
GROUP BY order_id , runner_id
order by runner_id;

/*
Runner 1 has taken more orders than  runner 2  but runner 2 is slightly faster than runner 1 
Runner 3 has taken only one order but on an average he is still faster than runner 1 considering the same distance.
Runner 2 > 1 > 3
*/

# Successful delivery percentage for each runner

/*
In this case, total orders that a runner took will be the count of the order id corresponding to the
runner_id. 
Delivered orders will be the number of times a runner successfully picked the pizza from HQ.
*/

SELECT 
    runner_id,
    COUNT(pickup_time) AS 'Delivered',
    COUNT(order_id) AS 'Total orders',
    ROUND((COUNT(pickup_time) / COUNT(order_id)) * 100,
            2) AS 'Successfully Delivery Percentage'
FROM
    runner_orders_temp
GROUP BY runner_id;

    
