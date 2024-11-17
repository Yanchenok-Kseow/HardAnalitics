--ДЗ 2
--Часть 1
--Задание 1
--SELECT * FROM orders_new_3 WHERE customer_id = 63 OR customer_id = 94

--создаем временную таблицу, вытаскиваем из orders нормер покупателя и разницу дат заказа  и доставкой
WITH order_info AS ( 
    SELECT 
        customer_id, 
  --считаем разницу дат заказа и доставки
        (TO_TIMESTAMP(shipment_date, 'YYYY-MM-DD HH24:MI:SS') - TO_TIMESTAMP(order_date, 'YYYY-MM-DD HH24:MI:SS')) AS waiting,
  -- проверим в минутах разницу доставки с заказом
        ROUND(EXTRACT(EPOCH FROM (TO_TIMESTAMP(shipment_date, 'YYYY-MM-DD HH24:MI:SS') - TO_TIMESTAMP(order_date, 'YYYY-MM-DD HH24:MI:SS'))) / 60, 2) AS waiting_min
    FROM orders_new_3)
--выборка из временной таблицы orders_info + имя из customers
SELECT 
    ord.customer_id, 
    ord.waiting, 
    ord.waiting_min, 
    cust.name
FROM order_info ord
JOIN customers_new_3 cust ON ord.customer_id = cust.customer_id --джойним по id 2 таблицы 
WHERE ord.waiting = (SELECT MAX(waiting) FROM order_info)
ORDER BY ord.customer_id; --сортируем по id

--задача 2
SELECT ord.customer_id, --выбираем покупателя
	   cust.name AS customer_name,
       COUNT(ord.order_id) AS order_count, --считаем заказы
       --считаем среднее время доставки
       AVG((TO_TIMESTAMP(ord.shipment_date, 'YYYY-MM-DD HH24:MI:SS') - TO_TIMESTAMP(ord.order_date, 'YYYY-MM-DD HH24:MI:SS'))) AS avg_waiting,
       SUM(ord.order_ammount) AS total_order_ammount --считаем общую сумму заказов
FROM orders_new_3 ord
JOIN customers_new_3 cust ON ord.customer_id = cust.customer_id -- джойним по id 2 таблицы
GROUP BY ord.customer_id, cust.name --группируем по покупателю
ORDER BY total_order_ammount DESC; --сортируем по сумме заказов

--задача 3
--SELECT * from orders_new_3 WHERE customer_id = 10
SELECT ord.customer_id, --выбираем инфу о покупателях из двух таблиц
       cust.name AS customer_name,
       --считаем, у кого были задержки больше 5 дней 
       COUNT(CASE WHEN (TO_TIMESTAMP(ord.shipment_date, 'YYYY-MM-DD HH24:MI:SS') - TO_TIMESTAMP(ord.order_date, 'YYYY-MM-DD HH24:MI:SS')) > INTERVAL '5 days' THEN 1 END) AS late_shipment,
      --считаем отмененные заказы
      COUNT(CASE WHEN ord.order_status = 'Cancel' THEN 1 END) AS cancelled_orders,
       -- считаем сумму отмененных заказов 
       SUM(CASE WHEN ord.order_status = 'Cancel' THEN ord.order_ammount ELSE 0 END) AS cancelled_order_ammount
FROM customers_new_3 cust
LEFT JOIN orders_new_3 ord ON ord.customer_id = cust.customer_id -- джойним по id 2 таблицы
GROUP BY ord.customer_id, cust.name   --группируем по покупателю
ORDER BY cancelled_order_ammount DESC; --группируем по убыванию суммы по отказам

--ЧАСТЬ 2 
--SELECT * from products_3
--SELECT * from orders_2
--SELECT product_id, product_category FROM products_3
 
 --создаем выборку из заказов с суммой заказов по категориям, джойним по id товара товары
 WITH order_info AS (
    SELECT prod.product_category,
        SUM(ord.order_ammount) AS category_ammount
    FROM orders_2 ord
    JOIN products_3 prod ON prod.product_id = ord.product_id
    GROUP BY prod.product_category),
    --создаем выборку по продуктам, считаем суммы по продуктам, создаем партиции по категориям, снова джойним по id товары 
prod_info AS (
    SELECT prod.product_id,
    prod.product_name,
    prod.product_category,
    SUM(ord.order_ammount) AS product_ammount,
    RANK() OVER (PARTITION BY prod.product_category ORDER BY SUM(ord.order_ammount) DESC) AS product_rank
    FROM orders_2 ord
    JOIN products_3 prod ON prod.product_id = ord.product_id
    GROUP BY prod.product_id, prod.product_name, prod.product_category)
--создаем итоговую таблицу, где выводим все категории в порядке убывания, где видно на 1 месте категорию 
--с самой большой суммой заказов, сумму заказов, а дальше инфо по товарам (id, товар и сумму по товару, где больше продаж)
SELECT ordi.product_category,
    ordi.category_ammount,
    prdi.product_id,
    prdi.product_name AS best_product,
    prdi.product_ammount AS product_ammount
FROM order_info ordi
LEFT JOIN prod_info prdi ON ordi.product_category = prdi.product_category AND prdi.product_rank = 1
ORDER BY ordi.category_ammount DESC;

