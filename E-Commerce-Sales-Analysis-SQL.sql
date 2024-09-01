select * from customers;
select * from geolocation;
select * from order_items;
select * from order_payments;
select * from order_reviews;
select * from orders;
select * from product_category_name_translation;
select * from products;
select * from sellers;

 
 # KPI-1) Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
 
  with kpi1 as
(
 select 
 case
   when weekday(order_purchase_timestamp) in (0,1,2,3,4) then "weekday"
   when weekday(order_purchase_timestamp) in (5,6) then "weekend"
 end as weekday_weekend, payment_value
 from orders as o
 join order_payments as op
 on o.order_id = op.order_id
 )
 select weekday_weekend, concat(round(sum(payment_value/1000000),2),"M") as payment_value,
 case 
   when weekday_weekend = "weekday" then
    concat(round(((select sum(payment_value) from kpi1 where weekday_weekend = "weekday") / (select sum(payment_value) from kpi1 ))*100,0),'%')
   when weekday_weekend = "weekend" then
    concat(round(((select sum(payment_value) from kpi1 where weekday_weekend = "weekend") / (select sum(payment_value) from kpi1 ))*100,0),'%')
  end as contribution
 from kpi1
 group by 1;
 
 
 #KPI-2) Number of Orders with review score 5 and payment type as credit card.

select 
   payment_type, review_score, concat(round(count(DISTINCT r.order_id)/1000,0),'K') as No_of_orders
from order_payments as op
join order_reviews as r
on op.order_id = r.order_id
where review_score = 5 and  payment_type = "credit_card";
 
 
#KPI-3) Average number of days taken for order_delivered_customer_date for pet_shop

select product_category_name, round(Avg(datediff( order_delivered_customer_date, order_purchase_timestamp )),0) as Avg_days_taken
from 
orders as o 
join order_items as oi
on o. order_id = oi.order_id
join products as p
on oi.product_id = p.product_id
where product_category_name = 'pet_shop';


#KPI-4) Average price and payment values from customers of sao paulo city

select round(avg(price),0) Average_price,  round(avg(payment_value),0) as Avg_payment_value
from customers as c
join orders as o 
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
join order_payments as op
on o.order_id = op.order_id
where city = 'sao paulo';

#KPI-5) Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

select review_score,
 round(Avg(datediff( order_delivered_customer_date, order_purchase_timestamp )),0) as Avg_shipping_days
from order_reviews as r
join orders as o 
on r.order_id = o.order_id
group by 1
order by review_score ;
