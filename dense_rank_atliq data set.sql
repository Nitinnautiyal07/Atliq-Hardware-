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