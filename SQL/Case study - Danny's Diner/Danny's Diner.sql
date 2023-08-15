# Total amount spent by each customer

SELECT 
    s.customer_id,sum(m.price) as 'Total Amount'
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

# Number of days a customer visited the restaurant

SELECT 
    customer_id, COUNT(DISTINCT order_date) AS 'Days Visited'
FROM
    sales
GROUP BY customer_id;

# First item purchased by each customer in the restaurant

with cte as
(SELECT 
    s.customer_id,
    m.product_name,
    row_number() over (partition by customer_id order by order_date) as rank_num
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id)
    
select c.customer_id,c.product_name from cte c where c.rank_num=1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
# Item purchased by the customer maximum number of times 

with cte as
(SELECT 
  product_name, 
  COUNT(order_date) as orders 
FROM 
  sales as s
  JOIN menu as m on s.product_id = m.product_id
GROUP BY 
  product_name)

select c.product_name,max(c.orders) as orders from cte c;

# Most popular item among each customer

with cte as
(SELECT 
  s.customer_id,
  m.product_name, 
  COUNT(s.order_date) as orders,
  row_number() over(partition by s.customer_id order by count(order_date) desc) as rank_num
FROM 
  sales as s
  JOIN menu as m on s.product_id = m.product_id
  group by product_name, 
  customer_id)

select c.customer_id, c.product_name,c.orders  from cte c where rank_num=1;

# First item purchased by the Customer after they became the member(took the membership) 

with cte as
(SELECT 
    s.customer_id, s.order_date, Me.join_date, m.product_name,
    row_number() over (partition by s.customer_id order by order_date asc) as row_num
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
        JOIN
    members Me ON Me.customer_id = s.customer_id
WHERE
    s.order_date >= Me.join_date)
    
select c.customer_id, c.product_name from cte c where row_num=1;


# Item purchased by each customer just before they became a member

with cte as
(SELECT 
    s.customer_id, s.order_date, Me.join_date, m.product_name,
    row_number() over (partition by s.customer_id order by order_date asc) as row_num
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
        JOIN
    members Me ON Me.customer_id = s.customer_id
WHERE
    s.order_date < Me.join_date)
    
select c.customer_id, c.product_name from cte c where row_num=1;


# Total items consumed and total amount spend by each customer before they became a member.

with cte as
(SELECT 
    s.customer_id, s.order_date, Me.join_date,count(m.product_id) as items,sum(m.price) as amt,
    row_number() over (partition by s.customer_id order by order_date asc) as row_num
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
        JOIN
    members Me ON Me.customer_id = s.customer_id
WHERE
    s.order_date < Me.join_date
    group by s.customer_id)
    
    
select c.customer_id, c.items, c.amt from cte c where row_num=1;

# Introduction to the Point system 
# If each $1 spent equates to 10 points and sushi has a 2x points multiplier - Calculating points of each customer.

SELECT 
    s.customer_id,
    SUM(CASE
        WHEN m.product_name = 'Sushi' THEN m.price * 10 * 2
        ELSE price * 10
    END) AS Points
FROM
    sales s
        JOIN
    menu m ON s.product_id - m.product_id
GROUP BY s.customer_id; 

/*
 In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
 not just sushi - how many points do customer A and B have at the end of January?
*/


# checking the order which was not made in january.
SELECT
    *
FROM
    sales
where order_date>'2021-01-31';

SELECT 
    s.customer_id, sum(case when s.order_date between Me.join_date and DATE_ADD(Me.join_date, INTERVAL 6 DAY) then m.price*10*2 when m.product_name='Sushi' then m.price*10*2 else m.price*10 end) as points
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
        JOIN
    members Me ON Me.customer_id = s.customer_id
    where s.order_date <= '2021-01-31'
    group by s.customer_id;
    
# Introducing a new column whether a customer has become a part of loyalty program while ordering.

SELECT 
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN s.order_date >= Me.join_date THEN 'Y'
        ELSE 'N'
    END AS Members
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
        LEFT JOIN
    members Me ON Me.customer_id = s.customer_id;
 
# Introducing a new column 'Ranking' which determines the order in which a customer signs up for the Customer loyalty program.

with cte as
(SELECT 
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN s.order_date >= Me.join_date THEN 'Y'
        ELSE 'N'
    END AS Members
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
        LEFT JOIN
    members Me ON Me.customer_id = s.customer_id)

select *, case when c.Members ='Y' then row_number() over(partition by c.customer_id,c.members) else 'Null' end  as ranking from cte c;


