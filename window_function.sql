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