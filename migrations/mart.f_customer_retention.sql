-----Очищаем вместе со статистикой
truncate table mart.f_customer_retention;
----Добавление для тех, которых нет
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
COUNT(distinct X.pre_new_customers_count) as new_customers_count, ---— кол-во новых клиентов (тех, которые сделали только один заказ за рассматриваемый промежуток времени).
COUNT(distinct X.pre_returning_customers_count) as returning_customers_count, --- кол-во вернувшихся клиентов (тех, которые сделали только несколько заказов за рассматриваемый промежуток времени).
COUNT(distinct X.pre_refunded_customer_count) as refunded_customer_count, --- refunded_customer_count — кол-во клиентов, оформивших возврат за рассматриваемый промежуток времени.
'weekly' as period_name, --- weekly. Рассматриваемый период
X.period_id, --- идентификатор периода (номер недели или номер месяца).
X.item_id,
SUM(case when X.pre_new_customers_count is not null then payment_amount else 0 end) as new_customers_revenue, --- — доход с новых клиентов.
SUM(case when X.pre_returning_customers_count is not null then payment_amount else 0 end) as returning_customers_revenue, --- returning_customers_revenue — доход с вернувшихся клиентов.
SUM(case when X.pre_refunded_customer_count is not null then payment_amount else 0 end) as customers_refunded --- customers_refunded — количество возвратов клиентов.
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
where week_of_year = date_part('week', DATE '{{ds}}')  --- обновляем за выбранную неделю отчётной даты
) X
left join mart.f_customer_retention Y 
on X.period_id = Y.period_id 
and X.item_id = Y.item_id
where Y.period_id is null
group by X.period_id, X.item_id;


----Обновление для тех, которые есть (сначала затупил и подумал, что это подразумевалось за инкремент)
/*
UPDATE mart.f_customer_retention N
set 
(new_customers_count, ---— кол-во новых клиентов (тех, которые сделали только один заказ за рассматриваемый промежуток времени).
returning_customers_count, ---— кол-во вернувшихся клиентов (тех, которые сделали только несколько заказов за рассматриваемый промежуток времени).
refunded_customer_count, --- refunded_customer_count — кол-во клиентов, оформивших возврат за рассматриваемый промежуток времени.
period_name, --- — weekly. Рассматриваемый период
period_id, --- period_id — идентификатор периода (номер недели или номер месяца).
item_id, --- — идентификатор категории товара.
new_customers_revenue, --- — доход с новых клиентов.
returning_customers_revenue, --- returning_customers_revenue — доход с вернувшихся клиентов.
customers_refunded --- customers_refunded — количество возвратов клиентов.
) = (select * from (
select 
COUNT(distinct X.pre_new_customers_count) as new_customers_count, ---— кол-во новых клиентов (тех, которые сделали только один заказ за рассматриваемый промежуток времени).
COUNT(distinct X.pre_returning_customers_count) as returning_customers_count, --- кол-во вернувшихся клиентов (тех, которые сделали только несколько заказов за рассматриваемый промежуток времени).
COUNT(distinct X.pre_refunded_customer_count) as refunded_customer_count, --- refunded_customer_count — кол-во клиентов, оформивших возврат за рассматриваемый промежуток времени.
'weekly' as period_name, --- weekly. Рассматриваемый период
X.period_id, --- идентификатор периода (номер недели или номер месяца).
X.item_id,
SUM(case when X.pre_new_customers_count is not null then payment_amount else 0 end) as new_customers_revenue, --- — доход с новых клиентов.
SUM(case when X.pre_returning_customers_count is not null then payment_amount else 0 end) as returning_customers_revenue, --- returning_customers_revenue — доход с вернувшихся клиентов.
SUM(case when X.pre_refunded_customer_count is not null then payment_amount else 0 end) as customers_refunded --- customers_refunded — количество возвратов клиентов.
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
where week_of_year >= date_part('week', current_date) - 1 --- обновляем с прошлой недели
) X
left join mart.f_customer_retention Y 
on X.period_id = Y.period_id 
and X.item_id = Y.item_id
where Y.period_id is not null
group by X.period_id, X.item_id) Z
WHERE Z.period_id = N.period_id 
and Z.item_id = N.item_id
);
*/