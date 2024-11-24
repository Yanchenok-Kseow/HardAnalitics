--ЧАСТЬ 3
--Задание 1
-- без оконок. высокая и низкая зп

--высокая зп
SELECT 
    first_name, 
    last_name, 
    salary, 
    industry, 
    CONCAT(first_name, ' ', last_name) AS name_highest_sal --соединим полное имя с помощью контакенации
FROM "Salary" s1
WHERE salary = (SELECT MAX(salary)
    FROM "Salary" s2
    WHERE s2.industry = s1.industry)
ORDER BY industry
--низкая зп
--выбираем необходимые столбцы
SELECT 
    first_name, 
    last_name, 
    salary, 
    industry, 
    CONCAT(first_name, ' ', last_name) AS name_lowest_sal --соединим полное имя с помощью контакенации
FROM "Salary" s1
WHERE salary = (SELECT MIN(salary) --выбираем в качестве фильтра мин зп
    FROM "Salary" s2
    WHERE s2.industry = s1.industry)
ORDER BY industry

-- вариант с оконнными функциями.низкая зп
SELECT 
    first_name, 
    last_name, 
    salary, 
    industry,
    --выбираем в качестве партиций industry, сотрируем по зп, выбираем последнее значение, т.е. самую низкую зп
    LAST_VALUE(CONCAT(first_name, ' ', last_name)) OVER (PARTITION BY industry ORDER BY salary ASC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS name_lowest_sal --среди всех строк в партиции
FROM "Salary"
WHERE (industry, salary) IN (
    SELECT industry, MIN(salary)
    FROM "Salary"
    GROUP BY industry
);

--высокая зп
SELECT 
    first_name, 
    last_name, 
    salary, 
    industry,
    --выбираем в качестве партиций industry, сотрируем по убыванию зп, выбираем первое значение, т.е. самую высокую зп
    FIRST_VALUE(CONCAT(first_name, ' ', last_name)) OVER (PARTITION BY industry ORDER BY salary ASC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS name_highest_sal
FROM "Salary"
WHERE (industry, salary) IN (
    SELECT industry, MAX(salary)
    FROM "Salary"
    GROUP BY industry
);

--ЧАСТЬ 2
--SELECT * FROM "GOODS"
--SELECT * FROM "SALES"
--SELECT * FROM "SHOPS"

--задание 1
-- выбираем единственную запись по магазину, тк оконка не убирает строки, а записывает их с тем же кол-вом
--выбираем все нужные строки из 3х таблиц
SELECT DISTINCT sales."SHOPNUMBER", 
shops."CITY", 
shops."ADDRESS", 
--суммируем продажи в партициях по магазину, гододу и адресу
SUM(sales."QTY") OVER (PARTITION BY sales."SHOPNUMBER", shops."CITY", shops."ADDRESS") AS "SUM_QTY",
-- суммируем продажи в рублях, умножая предыдущую строку на цену, по партициям, 
SUM(sales."QTY" * CAST(goods."PRICE" AS BIGINT)) OVER (PARTITION BY sales."SHOPNUMBER", shops."CITY", shops."ADDRESS") AS "SUM_QTY_PRICE"
FROM "SALES" sales
--джойним по id товара цену
JOIN "GOODS" goods ON sales."ID_GOOD" = goods."ID_GOOD"
--джойним по номеру магазина адрес и город
JOIN "SHOPS" shops ON sales."SHOPNUMBER" = shops."SHOPNUMBER"
--фильтр по дате
WHERE sales."DATE" = '2016-01-02'
-- сотрируем по магазину
ORDER BY sales."SHOPNUMBER"

 --задание 2
SELECT DISTINCT sales."DATE", 
shops."CITY",
-- суммируем продажи в рублях, умножая кол-во на цену, по партициям даты, города 
SUM(sales."QTY" * CAST(goods."PRICE" AS BIGINT)) OVER (PARTITION BY sales."DATE", shops."CITY") AS "SUM_SALES_REL"
FROM "SALES" sales
--джойним по id товара цену
JOIN "GOODS" goods ON sales."ID_GOOD" = goods."ID_GOOD"
--джойним по номеру магазина адрес и город
JOIN "SHOPS" shops ON sales."SHOPNUMBER" = shops."SHOPNUMBER"
--фильтр по категории
WHERE goods."CATEGORY" = 'ЧИСТОТА'


--задание 3
-- создаем подтаблицу, чтобы из нее выбирать 1-3 место 
WITH goods_rank as(SELECT "DATE", 
         "SHOPNUMBER", 
         "ID_GOOD",
	-- выбираем в партициях по дате и магазину, в порядке убывания кол-ва продаж
	ROW_NUMBER () OVER (PARTITION BY "DATE", "SHOPNUMBER" ORDER BY "QTY" DESC) as ranked
	FROM "SALES")
--выбираем из созданной выборки, нужные поля 
SELECT "DATE", 
"SHOPNUMBER", 
"ID_GOOD" from goods_rank
--с фильтром по ranked, 1-3 место
WHERE ranked <=3
GROUP BY "DATE", "SHOPNUMBER", "ID_GOOD"
--сотрировка по дате и магазину
ORDER BY "DATE", "SHOPNUMBER"


--задание 4
--SELECT shops."SHOPNUMBER", shops."CITY" FROM "SHOPS" shops WHERE "CITY" = 'СПБ'
--SELECT sales."DATE", sales."SHOPNUMBER", sales."ID_GOOD", sales."QTY" FROM "SALES" sales
--SELECT goods."ID_GOOD", goods."CATEGORY", goods."PRICE"  FROM "GOODS" goods

WITH sum_sales AS (
    SELECT sales."DATE",
        sales."SHOPNUMBER",
        goods."CATEGORY",
        sales."QTY",
        goods."PRICE",
        sales."QTY" * CAST(goods."PRICE" AS BIGINT) AS "SUM_SALES" -- считаем продажи
    FROM "SALES" sales
    JOIN "GOODS" goods ON sales."ID_GOOD" = goods."ID_GOOD" -- джойним товары
    JOIN "SHOPS" shops ON sales."SHOPNUMBER" = shops."SHOPNUMBER" -- джойним магазины
    WHERE shops."CITY" = 'СПб' -- выборка только по СПБ
    ORDER BY sales."SHOPNUMBER", sales."DATE"
),
prev_sales AS (
    SELECT "DATE",
        "SHOPNUMBER",
        "CATEGORY",
        SUM("SUM_SALES") AS TOTAL_SALES, -- сумма продаж за текущую дату
        LAG(SUM("SUM_SALES")) OVER (PARTITION BY "SHOPNUMBER", "CATEGORY" ORDER BY "DATE") AS PREV_SALES -- продажи на предыдущую дату
    FROM sum_sales
    GROUP BY "DATE", "SHOPNUMBER", "CATEGORY" -- группируем по дате, номеру магазина и категории
)
SELECT "DATE" AS DATE_,
    "SHOPNUMBER",
    "CATEGORY",
    COALESCE(PREV_SALES, 0) AS PREV_SALES -- Заполняем NULL значениями нулями
FROM prev_sales
WHERE PREV_SALES IS NOT NULL -- убираем те строки, где предыдущие продажи отсутствуют
ORDER BY "SHOPNUMBER", "DATE";


--ЧАСТЬ 3
--создаем таблицу
CREATE TABLE "query" (
    searchid SERIAL PRIMARY KEY,
    "year" INT,
    "month" INT,
    "day" INT,
    userid INT,
    ts BIGINT,
    devicetype TEXT,
    deviceid TEXT,
    "query" TEXT
);

--вносим данные в таблицу
INSERT INTO "query" ("year", "month", "day", userid, ts, devicetype, deviceid, "query") VALUES
(2024, 11, 22, 1, 1732284927, 'android', 'device_1', 'купить б'),
(2024, 11, 22, 1, 1732284987, 'android', 'device_1', 'купить брюки'),
(2024, 11, 22, 2, 1732284990, 'android', 'device_2', 'куртка зимняя'),
(2024, 11, 22, 3, 1732306602, 'android', 'device_3', 'зимняя шапка'),
(2024, 11, 23, 1, 1732360575, 'android', 'device_1', 'купить обувь'),
(2024, 11, 23, 1, 1732360635, 'pc', 'device_4', 'купить ботинки'),
(2024, 11, 23, 2, 1732360680, 'android', 'device_2', 'осенние куртки'),
(2024, 11, 23, 3, 1732373415, 'android', 'device_3', 'где купить'),
(2024, 11, 24, 1, 1732375620, 'android', 'device_1', 'тёплая куртка'),
(2024, 11, 24, 1, 1732375635, 'android', 'device_1', 'тёплая куртка мужская'),
(2024, 11, 24, 2, 1732456486, 'android', 'device_2', 'тёплая куртка черная'),
(2024, 11, 24, 3, 1732456580, 'android', 'device_3', 'лучшие куртки на зиму'),
(2024, 11, 24, 3, 1732456640, 'iphone', 'device_4', 'шарф и шапка'),
(2024, 11, 24, 2, 1732456640, 'android', 'device_2', 'тёплая куртка черная длинная'),
(2024, 11, 24, 3, 1732456700, 'android', 'device_3', 'лучшие куртки на зиму'),
(2024, 11, 24, 3, 1732456777, 'pc', 'device_5', 'резина зимняя'),
(2024, 11, 24, 3, 1732456780, 'android', 'device_3', 'перчатки'),
(2024, 11, 24, 1, 1732463900, 'android', 'device_1', 'ботинки'),
(2024, 11, 24, 1, 1732464000, 'android', 'device_3', 'ботинки зимние'),
(2024, 11, 24, 2, 1732463980, 'android', 'device_2', 'тёплая куртка черная длинная мужская'),
(2024, 11, 24, 3, 1732456900, 'android', 'device_3', 'перчатки кожаные'),
(2024, 11, 24, 3, 1732456980, 'ps', 'device_5', 'перчатки кожаные мужские');

--SELECT * FROM "query"

-- выборка для фильтра по дате и времени
WITH date_filter AS (
    SELECT
        q1.year,
        q1.month,
        q1.day,
        q1.userid,
        q1.ts,
        q1.devicetype,
        q1.deviceid,
        q1.query,
        -- используем LEAD для получения следующего запроса и временной метки в партициях по юзеру и девайсу
        LEAD(q1.query) OVER (PARTITION BY q1.userid, q1.deviceid ORDER BY q1.ts) AS next_query,
        LEAD(q1.ts) OVER (PARTITION BY q1.userid, q1.deviceid ORDER BY q1.ts) AS next_ts
    FROM query q1
    -- фильтруем данные только за 24 ноября 2024 года
    WHERE q1.year = 2024 AND q1.month = 11 AND q1.day = 24
),
query_filter AS (
    SELECT
        "year",
        "month",
        "day",
        userid,
        ts,
        devicetype,
        deviceid,
        "query",
        next_query,
        -- определяем, выполнения условий задачи
        CASE
            WHEN next_query IS NULL THEN 1  -- если следующего запроса нет
            WHEN (next_ts - ts) > 180 THEN 1 -- если разница по времени больше 3 минут
            WHEN LENGTH(next_query) < LENGTH("query") AND (next_ts - ts) > 60 THEN 2 -- если следующий запрос короче текущего и разница более 1 минуты
            ELSE 0 -- в остальных случаях
        END AS is_final
    FROM date_filter
)

-- итоговый запрос, который выбирает финальные запросы
SELECT  
    "year", 
    "month",
    "day", 
    userid, 
    ts, 
    devicetype, 
    deviceid, 
    "query", 
    next_query, 
    is_final
FROM query_filter
-- фильтруем по финальным запросам и только для android
WHERE is_final IN (1, 2) AND devicetype = 'android';