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