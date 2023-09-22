    
   select *,(1 - pre_invoice_discount_pct) * gross_price_total  as net_invoice_sales,
   (po.discounts_pct+po.other_deductions_pct) as post_invocie_discount_pct
   from sales_preinv_discount s
   join fact_post_invoice_deductions po
   on 
       s.date=po.date and
       s.product_code=po.product_code and 
	   s.customer_code=po.customer_code
       
