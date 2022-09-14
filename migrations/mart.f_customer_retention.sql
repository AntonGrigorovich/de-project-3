insert into mart.f_customer_retention 
(
new_customers_count, ---— кол-во новых клиентов (тех, которые сделали только один заказ за рассматриваемый промежуток времени).
returning_customers_count, ---— кол-во вернувшихся клиентов (тех, которые сделали только несколько заказов за рассматриваемый промежуток времени).
refunded_customer_count, --- refunded_customer_count — кол-во клиентов, оформивших возврат за рассматриваемый промежуток времени.
period_name, --- — weekly. Рассматриваемый период
period_id, --- period_id — идентификатор периода (номер недели или номер месяца).
item_id, --- — идентификатор категории товара.
new_customers_revenue, --- — доход с новых клиентов.
returning_customers_revenue, --- returning_customers_revenue — доход с вернувшихся клиентов.
customers_refunded --- customers_refunded — количество возвратов клиентов.
)
select 
COUNT(distinct pre_new_customers_count) as new_customers_count, ---— кол-во новых клиентов (тех, которые сделали только один заказ за рассматриваемый промежуток времени).
COUNT(distinct pre_returning_customers_count) as returning_customers_count, --- кол-во вернувшихся клиентов (тех, которые сделали только несколько заказов за рассматриваемый промежуток времени).
COUNT(distinct pre_refunded_customer_count) as refunded_customer_count, --- refunded_customer_count — кол-во клиентов, оформивших возврат за рассматриваемый промежуток времени.
'weekly' as period_name, --- weekly. Рассматриваемый период
period_id, --- идентификатор периода (номер недели или номер месяца).
item_id,
SUM(case when pre_new_customers_count is not null then payment_amount else 0 end) as new_customers_revenue, --- — доход с новых клиентов.
SUM(case when pre_returning_customers_count is not null then payment_amount else 0 end) as returning_customers_revenue, --- returning_customers_revenue — доход с вернувшихся клиентов.
SUM(case when pre_refunded_customer_count is not null then payment_amount else 0 end) as customers_refunded --- customers_refunded — количество возвратов клиентов.
FROM (

select
case when COUNT(customer_id) over(partition by customer_id order BY year_actual, week_of_year) = 1 then customer_id else null end pre_new_customers_count, ---— для кол-во новых клиентов (тех, которые сделали только один заказ за рассматриваемый промежуток времени).
case when COUNT(customer_id) over(partition by customer_id order BY year_actual, week_of_year) in (2, 3)then customer_id else null end pre_returning_customers_count, --- для кол-во вернувшихся клиентов (тех, которые сделали только несколько заказов за рассматриваемый промежуток времени).
case when payment_amount < 0 then customer_id else null end pre_refunded_customer_count, --- refunded_customer_count — кол-во клиентов, оформивших возврат за рассматриваемый промежуток времени.
week_of_year as period_id, --- идентификатор периода (номер недели или номер месяца).
item_id,
payment_amount
from mart.f_sales as f_sales
inner join mart.d_calendar as d_calendar
on f_sales.date_id = d_calendar.date_id
--where week_of_year = 37

) X
group by period_id, item_id;