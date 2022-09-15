ALTER TABLE staging.user_order_log ADD COLUMN status varchar(15) NOT NULL Default 'shipped'

ALTER TABLE mart.f_sales ADD COLUMN status varchar(15) NOT NULL Default 'shipped'

create table mart.f_customer_retention
(
new_customers_count int, ---— кол-во новых клиентов (тех, которые сделали только один заказ за рассматриваемый промежуток времени).
returning_customers_count int, ---— кол-во вернувшихся клиентов (тех, которые сделали только несколько заказов за рассматриваемый промежуток времени).
refunded_customer_count int, --- refunded_customer_count — кол-во клиентов, оформивших возврат за рассматриваемый промежуток времени.
period_name varchar(50), --- — weekly. Рассматриваемый период
period_id int, --- period_id — идентификатор периода (номер недели или номер месяца).
item_id int, --- — идентификатор категории товара.
new_customers_revenue numeric(12,4), --- — доход с новых клиентов.
returning_customers_revenue numeric(12,4), --- returning_customers_revenue — доход с вернувшихся клиентов.
customers_refunded int --- customers_refunded — количество возвратов клиентов.
)
