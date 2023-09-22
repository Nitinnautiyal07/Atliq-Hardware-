##Select all Hollywood movies released after the year 2000 that made more than 500 million $ profit or more profit. 
#Note that all Hollywood movies have millions as a unit hence you don't need to do the unit conversion.
 #Also, you can write this query without CTE as well but you should try to write this using CTE only

with CTE as ( select title,industry,release_year,(revenue-budget) as profit
            from movies m
			join financials f
            on m.movie_id=f.movie_id
            where industry="Hollywood" and release_year>2000
)
select * from CTE where profit > 500;
       

