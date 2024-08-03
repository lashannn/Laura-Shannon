# this sql project shows the use of data cleaning, data filtering, aggregate functions, joins, group by and order by functions.

SELECT * 
FROM sales_data.accounts;

# data cleaning, just updated spelling of technology - not seeing anything else to update at this time
update accounts
set sector = 'technology'
where sector = 'technolgy';

SELECT * 
FROM sales_data.sales_pipeline;

# what is the blank account? most of them look like they are engaging/prospecting 
# not sure how these have sales if they don't have accounts yet?  filter out prospecting and engaging since im not sure why these have 
# sales prices.

# generating data for the product that has the highest number of items sold (best selling item)
SELECT product, count(product)
FROM sales_pipeline
where deal_stage != 'engaging'
and deal_stage != 'prospecting'
group by product
order by count(product) desc;


SELECT product, count(product)
FROM sales_data.sales_pipeline
group by product
order by count(product) desc;

# data for the product that has the best sales (brings in the most money)
select sales_pipeline.product, sum(sales_price)
from sales_pipeline
join products
on sales_pipeline.product = products.product
group by sales_pipeline.product
order by sum(sales_price) desc;

# determining the account that spends the most money 
select account, sum(sales_price)
from sales_pipeline
join products
on sales_pipeline.product = products.product
group by account
order by sum(sales_price) desc;

select *
from sales_pipeline
join products
on sales_pipeline.product = products.product;

# generating data for the product that has the best sales (brings in the most money), filter out engaging/prospecting
select sales_pipeline.product, sum(sales_price)
from sales_pipeline
join products
on sales_pipeline.product = products.product
where deal_stage != 'engaging'
and deal_stage != 'prospecting'
group by sales_pipeline.product
order by sum(sales_price) desc;

# determining the agent that has the highest sales, filter out engaging/prospecting
select sales_agent, sum(sales_price)
from sales_pipeline
join products
on sales_pipeline.product = products.product
where deal_stage != 'engaging'
and deal_stage != 'prospecting'
group by sales_agent
order by sum(sales_price) desc;

# determining the agent that has won most accounts, excluding prospecting/engaging
select sales_agent, deal_stage, count(deal_stage)
from sales_pipeline
join products
on sales_pipeline.product = products.product
where deal_stage!= 'engaging'
and deal_stage != 'prospecting'
and deal_stage = 'won'
group by sales_agent, deal_stage
order by count(deal_stage) desc;


# data for the agent that has lost most accounts, excluding prospecting/engaging
select sales_agent, deal_stage, count(deal_stage)
from sales_pipeline
join products
on sales_pipeline.product = products.product
where deal_stage!= 'engaging'
and deal_stage != 'prospecting'
and deal_stage = 'lost'
group by sales_agent, deal_stage
order by count(deal_stage) desc;

select *
from sales_pipeline
join products
on sales_pipeline.product = products.product
where deal_stage!= 'engaging'
and deal_stage != 'prospecting';


# which company had the most purchase sales, top ten companies
select account, sum(sales_price)
from sales_pipeline
join products
on sales_pipeline.product = products.product
where deal_stage!= 'engaging'
and deal_stage != 'prospecting'
group by account
order by sum(sales_price) desc
Limit 10;

# which company had the most purchase sales and looking to see what they are buying
select account, sales_pipeline.product, sum(sales_price) as total_sales
from sales_pipeline
join products
on sales_pipeline.product = products.product
where deal_stage!= 'engaging'
and deal_stage != 'prospecting'
group by account, sales_pipeline.product
order by sum(sales_price) desc;


# which geographic locations have the most sales
SELECT office_location as location, sum(sales_price) as total_sales
FROM sales_pipeline
join accounts
	on sales_pipeline.account = accounts.account
join products
	on sales_pipeline.product = products.product
group by office_location
order by total_sales desc;