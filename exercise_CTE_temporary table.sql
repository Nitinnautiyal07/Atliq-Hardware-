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