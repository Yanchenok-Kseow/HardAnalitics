--SELECT * FROM users
--SELECT DISTINCT category FROM products 
--SELECT city, COUNT (city) FROM users GROUP BY city 
--ORDER BY COUNT (city) DESC
--SELECT COUNT (DISTINCT city) FROM users

--ЧАСТЬ 1
--Задача 1
SELECT city, --выбираем город
    CASE --делаем проверку на возраст, делим на категории 
        WHEN age BETWEEN 0 AND 20 THEN 'young'
        WHEN age BETWEEN 21 AND 49 THEN 'adult'
        WHEN age >= 50 THEN 'old'
    END AS age_cat, --добавляем в колонку возрастной категории
    COUNT(*) AS user_count --считаем записи
FROM users 
WHERE age IS NOT NULL -- убираем исключение из проверки
GROUP BY city, age_cat --группируем по городу и возрасту
ORDER BY user_count DESC, city --выводим по убыванию кол-ва юзеров, и по алфавиту остальные города

--Задача 2
SELECT category, 
	   ROUND(CAST (AVG(price) as NUMERIC) ,2) AS avg_price  --выбираем категорию, среднюю цену, округляя до 2 знаков
FROM products
WHERE lower(category) LIKE '%home%' OR 
    lower(category) LIKE '%hair%' --где в значениях есть home и hair, убираем чувствительность к регистру
GROUP BY category -- группируем по категориям

--ЧАСТЬ 2
--Задание 1
--SELECT * FROM sellers WHERE seller_id = 7
SELECT seller_id, -- выбираем id селлера
       COUNT(category) AS total_categ, -- считаем категории
       ROUND(AVG(rating), 2) AS avg_rating, -- считаем средний рейтинг
       SUM(revenue) AS total_revenue, -- считаем суммарную выручку
       CASE -- добавляем условие присвоения типа селлера
           WHEN COUNT(category) > 1 AND SUM(revenue) > 50000 THEN 'rich' 
           WHEN COUNT(category) > 1 AND SUM(revenue) <= 50000 THEN 'poor' 
           ELSE 'no category' -- добавлено условие для случаев, не соответствующих логике
       END AS seller_type -- выводим отдельной колонкой
FROM sellers
WHERE category <> 'Bedding' -- исключаем категорию Bedding
GROUP BY seller_id -- группируем по селлеру
HAVING COUNT(category) > 1 -- исключаем тех, у кого 1 категория
ORDER BY seller_id; -- сортируем по id селлера

 
--Задание 2
--вариант 1
SELECT 
    seller_id,
    MIN (date_reg),
    EXTRACT(YEAR FROM age(MIN(TO_DATE(date_reg, 'DD/MM/YYYY')))) * 12 + 
    EXTRACT(MONTH FROM age(MIN(TO_DATE(date_reg, 'DD/MM/YYYY')))) AS month_from_registration, --выбираем кол-во мес из года и месяца
    (SELECT MAX(delivery_days) - MIN(delivery_days)
     FROM (SELECT delivery_days
           FROM sellers
           WHERE category <> 'Bedding'
           GROUP BY seller_id, delivery_days
           HAVING COUNT(category) > 1
           AND SUM(revenue) <= 50000) 
    ) AS max_delivery_difference --берем разницу по доставке из подзапроса
FROM (
    SELECT 
        seller_id,
        delivery_days,
        date_reg,  
        category,
        revenue
    FROM sellers
    WHERE category <> 'Bedding')  -- берем необходимые столбцы из табл. sellers, сразу исключаем категорию Bedding
GROUP BY seller_id  -- группируем только по seller_id
HAVING COUNT(category) > 1  -- оставляем только селлеров с более чем одной категорией, чтобы получить poor
AND SUM(revenue) <= 50000  -- оставляем только тех, кто не превышает 50000? чтобы получить poor
ORDER BY seller_id; --выводим результат в порядке убывания seller_id

--вариант2, более подходящий под задание
SELECT 
    seller_id,
    MIN(TO_DATE(date_reg, 'DD/MM/YYYY')) AS date_reg,
   (CURRENT_DATE - MIN(TO_DATE(date_reg, 'DD/MM/YYYY')))/30 AS month_from_registration, --считаем разницу в днях, переводим в месяцы
    (SELECT MAX(delivery_days) - MIN(delivery_days)
        FROM (
            SELECT delivery_days
            FROM sellers
            WHERE category <> 'Bedding'
            GROUP BY seller_id, delivery_days
            HAVING COUNT(category) > 1 AND SUM(revenue) <= 50000
        ) AS delivery_data
    ) AS max_delivery_difference
FROM (
    SELECT 
        seller_id,
        delivery_days,
        date_reg,  
        category,
        revenue
    FROM sellers
    WHERE category <> 'Bedding'
) AS seller_data
GROUP BY seller_id
HAVING COUNT(category) > 1 AND SUM(revenue) <= 50000
ORDER BY seller_id;

--Задание 3
--SELECT 
--    seller_id,
--    date_reg,
--   	revenue,
--    category
--FROM 
--    sellers
--WHERE 
--   date_reg like '%2022%'
--ORDER BY 
--    seller_id

SELECT seller_id,--выбираем селлера
    MIN(date_reg) AS date_reg, --выбираем дату
    SUM(revenue) AS total_revenue, --считаем общий доход
    STRING_AGG(DISTINCT category, ' - ' ORDER BY category) AS category_pair --объединяем категории в строку по алф порядку
FROM sellers 
WHERE date_reg LIKE '%2022%' --проигрался только этот вариант написания, остальные с датой не выдавали результат
GROUP BY seller_id --группируем по селлеру
HAVING 
    COUNT(DISTINCT category) = 2 --выполняемые условия отбора: 2 категории и общий доход больше 75 тыс
    AND SUM(revenue) > 75000
ORDER BY total_revenue DESC; --необязательное условие, но так красивее