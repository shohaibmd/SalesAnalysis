
-- Data Cleaning --
update retails 
set sale_date = str_to_date(sale_date, '%Y-%m-%d');
alter table retails drop column sales_date ; 

-- Data Cleaning --
update retails
set sale_date=str_to_date(sale_date, "%Y-%m-%d");

-- Data Cleaning --
alter table retails
modify sale_date date;

-- Data Cleaning --
update retails set sale_time =str_to_date(sale_time, "%H:%i:%s");
alter table retails 
modify sale_time time;

-- Data Cleaning --
update retails 
set total_sale = null where total_sale = 'none' ;
select quantiy  from retails where quantiy = 'none' ;

-- Data Cleaning --
alter table retail;
rename column quantiy to quantity; 

select total_sale from retails where total_sale = 'none';

-- Data Cleaning --
select * from retails where transactions_id is null or sale_date is null or sale_time is null or customer_id is null or gender is null or age is null or category is null
and quantity is null or price_per_unit is null or cogs is null or
 total_sale is null ;

 -- Basic Data Browsing and Cleaning --
 select * from retails limit 10;
 select * from retails where quantity is null;
 delete  from retails where quantity is null;

 -- Data EXPLORE--

 -- how many customers we have till the date?
 select count(distinct customer_id) from retails; 

 -- number of male and female customers? -- 
 select count( gender) from retails group by gender; 
select case gender when 'Male' then 'M'
when 'Female' then 'F'
end as gender,
count(*) as c_gender
from retails
group by gender;

 -- Ratio of Male and female customers -- 
 select round( (select sum(count(gender)) from retails where gender = 'male') / (select sum(gender) from retails), 2) from retails; 
 select sum(gender) from retails; 
 
 select sum(gender = 'male') as male_count, 
 count(gender) as total, 
 round (100*
 sum(gender = 'male') / count(gender), 2) as male_percentage 
 from retails;
 
-- What is the avg time period of the sales -- 
 select case when hour(sale_time)< 6 then 'Night'
 when hour(sale_time) < 12 then 'Morning' 
 when hour(sale_time) < 18 then 'Afternoon' 
 else 'Evening' 
 end as time_slot,
 sum(quantity) as quantity, sum(total_sale) as total_sales from retails
 group by time_slot
 order by sum(total_sale) desc;
 select * from retails;
 
 -- What day customer prefers to buy more -- 

 select dayname(sale_date) as weekday,
 sum(quantity) as total_sales, category
 from retails
 group by category, weekday
 order by total_sales desc
 limit 5;

-- Which category is the most sold by quarter -- 
 sum(quantity) as quantity,
  rank () over ( partition by year(sale_date), quarter(sale_date) order by sum(quantity) desc) as category_rank
  from retails 
  group by year, quarter, category
  order by quantity desc;

-- which category is the most sold based on gender -- 
 select  
   category, gender,
 sum(quantity) as quantity
  from retails 
  group by category, gender
  order by quantity desc;

-- What is the avg quantity of product category our customers buy -- 
select count(distinct customer_id) from retails;
select sum(quantity), category from retails  group by category
order by sum(quantity) desc;

-- The profit from top 5 repeated customer -- 
select customer_id, count(*) as purchase_count
from retails group by customer_id having count(*) >1 order by purchase_count desc;

select  customer_id, round(sum(total_sale - cogs),  2) as profit from retails group by customer_id order by profit desc limit 5;

-- how much profit we had in each category -- 
select category, round( sum(price_per_unit - cogs), 2) as profit from retails 
group by category
order by profit desc;

-- possible to compare by each year as well || in 2022 the electronics category was the most sold. But in 2023 clothing ranked first. Beauty remains almost constant each year. 
select category, round(sum(price_per_unit - cogs) ,2) as profit from retails
where year(sale_date) = 2022
group by category
order by profit desc;

-- total sales and profit by each category -- 
select category, round(sum(price_per_unit - cogs),2) as profit, sum(quantity) as quantity
from retails 
group by category
order by profit desc ;

-- category sold by age and gender -- 
select year(sale_date) as year, 
   category, gender, avg(age),
 sum(quantity) as quantity, sum(total_sale) as amount
  from retails 
  group by category, year,  gender
  order by category, year;

-- Find out best selling month in each year
with monthly_sales as (
select  year(sale_date) as year, monthname(sale_date) as month_name, month(sale_date) as month_n, sum(total_sale) as total_sale,
row_number () over (partition by year(sale_date) 
order by sum(total_sale) desc ) as rn
from  retails 
group by year(sale_date), month(sale_date), monthname(sale_date) 
)
select year, month_name, total_sale from monthly_sales where rn = 1 order by year;

-- First and last visit by customer
select customer_id, min(sale_date) as first_date, max(sale_date) as last_date,
count(*) as total_visits
from retails group by customer_id having count(*) >1 order by total_visits desc limit 5;

-- average days between purchase by customer -- 
with customer_dates as ( 
select customer_id, sale_date, lag(sale_date) 
over ( partition by customer_id order by sale_date) as prev_sale_date from retails) 
,time_diffs as ( 
select customer_id, datediff(sale_date, prev_sale_date) as days_between from customer_dates where prev_sale_date is not null )
select customer_id, round(avg(days_between), 1) as avg_days_between_visits, count(*) +1 as total_purchase from
 time_diffs group by customer_id order by avg_days_between_visits limit 5
 ; 

 -- Some other exploration -- 
 -- write a sql query to retrive all columns for sales made on 2022-11-05
 select * from retails limit 1;
 select * from retails where sale_date = '2022-11-05'
 order by sale_time asc;
 -- Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
 select * from retails where category = 'clothing' and quantity >=4 and date_format(sale_date, '%Y-%m') = '2022-11'
 order by sale_date;
 -- Write a SQL query to calculate the total sales (total_sale) for each category
 select sum(total_sale) as total_sales, category, count(quantity) as quantity_sold from retails
 group by category
 order by total_sales desc;
 -- Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category
 select avg(age) as age from retails where category = 'Beauty' ;
 -- Write a SQL query to find all transactions where the total_sale is greater than 1000
 select * from retails where total_sale > '1000' order by sale_date asc;
 -- Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
select count(transactions_id), gender, category from retails
group by gender, category order by 1;
-- Write a SQL query to calculate the average sale for each month. 
select round(avg(total_sale), 2) as avg_total_sale, round(avg(quantity), 2) as avg_quantity_sold,  monthname(sale_date) as month_name from retails 
group by  monthname(sale_date), month(sale_date)
order by month(sale_date) asc
;
-- Write a SQL query to find the top 5 customers based on the highest total sales
select customer_id, sum(total_sale) as total_sale 
from retails 
group by customer_id 
order by total_sale desc  
limit 5 ;
-- Write a SQL query to find the number of unique customers who purchased items 
select category, count(distinct customer_id) from retails group by category;



