# Atliq-Hardware-
Supply Chain Analytics of Atliq Hardware


#--Month
#--Product name
#--Variant 
#--Sold Quantity##
#--Gross Price Per item
#--Gross Price total

select s.date,s.product_code,
       p.product,p.variant,s.sold_quantity,
       g.gross_price,g.fiscal_year,
       Round((g.gross_price*s.sold_quantity),1) as gross_price_total
from fact_sales_monthly s
join dim_product p
on p.product_code=s.product_code
join fact_gross_price g
on 
   g.product_code=s.product_code and 
   g.fiscal_year=get_fiscal_year(s.date)
where 
	  customer_code=90002002 and 
	  get_fiscal_year(date)=2021 and
      get_fiscal_quarter(date)="Q4"
order by date asc

// 

#Month
## total gross sales amount to coma india

select s.date,
       sum(g.gross_price*sold_quantity) as gross_price_total
 from fact_sales_monthly s
join fact_gross_price g
on g.product_code=s.product_code and 
   g.fiscal_year=get_fiscal_year(s.date)
 where customer_code=90002002
 group by s.date
 order by s.date asc;

 //

 #Exercise: Yearly Sales Report
#Generate a yearly report for Croma India where there are two columns
#1. Fiscal Year
#2. Total Gross Sales amount In that year from Croma

select get_fiscal_year(date) as fiscal_year,
       sum(round(s.sold_quantity*g.gross_price,2)) as yearly_sales
 from fact_sales_monthly s
join fact_gross_price g
on g.fiscal_year=get_fiscal_year(date) and
   g.product_code=s.product_code
       where customer_code=90002002
       group by fiscal_year
       order by fiscal_year;


       ///
Problem Solving and pre_invoice deduction

    
   select *,(1 - pre_invoice_discount_pct) * gross_price_total  as net_invoice_sales,
   (po.discounts_pct+po.other_deductions_pct) as post_invocie_discount_pct
   from sales_preinv_discount s
   join fact_post_invoice_deductions po
   on 
       s.date=po.date and
       s.product_code=po.product_code and 
	   s.customer_code=po.customer_code
       
///

Window function

SELECT * , 
       amount*100/sum(amount) over() as pct 
       FROM random_tables.expenses
          order by category;
          
SELECT * , 
       amount*100/sum(amount) over(partition by category ) as pct 
       FROM random_tables.expenses
          order by category;
          
          
          
SELECT * , 
       sum(amount) over(partition by category order by date ) as total_expense_till_date 
       FROM random_tables.expenses
          order by category,date;


          with cte1 as(
SELECT customer,Round(sum(net_sales)/1000000,2) as net_sales_mln
         FROM gdb041.net_sales n
         join dim_customer c
         on n.customer_code=c.customer_code
         where fiscal_year=2021 
         group by c.customer
         )
         select *,net_sales_mln*100/sum(net_sales_mln) over() as pct  from cte1
         order by net_sales_mln desc

with cte1 as (
          SELECT c.customer,c.region
                ,Round(sum(net_sales)/1000000,2) as net_sales_mln
         FROM gdb041.net_sales n
         join dim_customer c
         on n.customer_code=c.customer_code
         where fiscal_year=2021 
         group by c.customer,c.region )
         select *,net_sales_mln*100/sum(net_sales_mln) over(partition by region) as pct_share_regions from cte1
         order by region,net_sales_mln desc

////

Row and dense rank
        
         with cte1 as(
SELECT *,row_number() over(partition by category order by amount desc ) as rn,
         rank() over(partition by category order by amount desc ) as rnk,
		 dense_rank() over(partition by category order by amount desc ) as drnk FROM random_tables.expenses
order by category
)
select * from cte1 where drnk<=2


SELECT *,
         row_number() over(order by marks desc) as rn,
		 rank()       over(order by marks desc) as rnk,
         dense_rank() over(order by marks desc) as drnk FROM random_tables.student_marks;


         with cte1 as(
	   SELECT p.division,
       p.product,
       sum(sold_quantity)  as total_quantity 
       FROM fact_sales_monthly s
       join dim_product p
            on p.product_code=s.product_code
		where fiscal_year=2021
        group by p.product
        ),
   cte2 as( 
        select *,
        dense_rank () over(partition by division order by total_quantity desc) as drnk  from cte1
        )
select * from cte2 where drnk<=3;

with cte1 as (
       select c.market,
	   c.region,
       round(sum(gross_price_total)/1000000,2) as gross_sales_mln
		from  gross_sales s
        join dim_customer c
	     on c.customer_code=s.customer_code
         where fiscal_year=2021
         group by market
         order by gross_sales_mln desc
),
cte2 as (
         select *,
       dense_rank() over(partition by region order by gross_sales_mln desc) as drnk from cte1 
)
select * from cte2 where  drnk<=2

    ///

    Creating helper table

    create table fact_act_est
(
select
         s.date as date,
         s.fiscal_year as fiscal_year,
         s.product_code as product_code,
         s.customer_code as customer_code,
         s.sold_quantity as sold_quantity,
         f.forecast_quantity as forecast_quantity
from fact_sales_monthly s
left join fact_forecast_monthly f
using(date,customer_code,product_code)

Union

select
         f.date as date,
         f.fiscal_year as fiscal_year,
         f.product_code as product_code,
         f.customer_code as customer_code,
         s.sold_quantity as sold_quantity,
         f.forecast_quantity as forecast_quantity
from fact_forecast_monthly f
left join fact_sales_monthly s
using(date,customer_code,product_code)
);

create temporary table table_2021
with forecast_err_table as 
       (SELECT s.customer_code as customer_code,
       c.customer as customer_name,
       c.market as market,
       sum((s.forecast_quantity-s.sold_quantity)) as net_err,
      sum( (s.forecast_quantity-s.sold_quantity))*100/sum(s.forecast_quantity) as net_err_pct,
       sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_err,
       sum(abs(s.forecast_quantity-s.sold_quantity))*100/sum(s.forecast_quantity) as abs_err_pct
       FROM gdb041.fact_act_est s
       join dim_customer  c
       on s.customer_code=c.customer_code
       where s.fiscal_year=2021
       group by customer_code
)
       
select *,
	   if (abs_err_pct > 100,0,100-abs_err_pct) as forecast_accuracy 
       from forecast_err_table 
		order by forecast_accuracy  desc;
       
## table for 2022

create temporary table table_2020
with forecast_err_table as 
       (SELECT s.customer_code as customer_code,
       c.customer as customer_name,
       c.market as market,
       sum((s.forecast_quantity-s.sold_quantity)) as net_err,
      sum( (s.forecast_quantity-s.sold_quantity))*100/sum(s.forecast_quantity) as net_err_pct,
       sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_err,
       sum(abs(s.forecast_quantity-s.sold_quantity))*100/sum(s.forecast_quantity) as abs_err_pct
       FROM gdb041.fact_act_est s
          join dim_customer  c
       on s.customer_code=c.customer_code
       where s.fiscal_year=2020
       group by customer_code
)
       
select *,
	   if (abs_err_pct > 100,0,100-abs_err_pct) as forecast_accuracy 
       from forecast_err_table     
       order by forecast_accuracy  desc;

select f2.customer_code,f1.customer_name,f2.market,f2.forecast_accuracy as forecast_accuracy_2020,
       f1.forecast_accuracy as forecast_accuracy_2021
       from  table_2021 as f1
       join  table_2020 as f2
       on f1.customer_code=f2.customer_code
       where f1.forecast_accuracy < f2.forecast_accuracy
       order by f2.forecast_accuracy;

       
