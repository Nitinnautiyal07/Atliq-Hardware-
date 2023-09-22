with cte1 as(
SELECT *,row_number() over(partition by category order by amount desc ) as rn,
         rank() over(partition by category order by amount desc ) as rnk,
		 dense_rank() over(partition by category order by amount desc ) as drnk FROM random_tables.expenses
order by category
)
select * from cte1 where drnk<=2