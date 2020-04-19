/*1. INSERT */
    /*1. Без указания списка полей*/
        INSERT INTO client VALUES (default, 'Maria', 'Garsia', '1989.11.30', '89042356789');
        INSERT INTO client VALUES (default, 'Jane', 'Clark', '2000.6.12', '39099990890');

    /*2. С указанием списка полей*/
        INSERT INTO client (first_name, last_name, date_of_birth, phone_number)
        VALUES ('Catherin', 'Johnson','1996.1.12', '89076435671');
        INSERT INTO client (first_name, last_name, date_of_birth)
        VALUES ('Johnson', 'Catherin','1996.2.12');

/*2. DELETE*/
	/*1. Всех записей*/
        DELETE FROM client;

	/*2. По условию*/
		DELETE FROM client WHERE id_client < 12;

    /*3. Очистить таблицу*/
		TRUNCATE client;

/*3.UPDATE*/
    /*1.Всех записей*/
        UPDATE client
        SET first_name = 'Carl', last_name = 'Johnson', phone_number = '+16196604476';

    /*2. По условию обновляя один атрибут*/
        UPDATE client
        SET first_name = 'Andrew' WHERE date_of_birth = '1989.11.30';

    /*3. По условию обновляя несколько атрибутов*/
        UPDATE client
        SET first_name = 'Catherin', last_name = 'Lowson' WHERE date_of_birth = '1996.01.12';

/*4. SELECT*/
	/*1. С определенным набором извлекаемых атрибутов (SELECT atr1, atr2 FROM...)*/
	    SELECT first_name, last_name FROM client;

    /*2. Со всеми атрибутами (SELECT * FROM...)*/
        SELECT * FROM client;

	/*3. С условием по атрибуту (SELECT * FROM ... WHERE atr1 = "")*/
	    SELECT * FROM client WHERE first_name = 'Jane';

/*5. SELECT ORDER BY + TOP (LIMIT)*/
    /*1. С сортировкой по возрастанию ASC + ограничение вывода количества записей*/
        SELECT * FROM client ORDER BY  first_name ASC;

    /*2. С сортировкой по убыванию DESC*/
        SELECT * FROM client ORDER BY  first_name DESC;

    /*3. С сортировкой по двум атрибутам + ограничение вывода количества записей*/
        SELECT * FROM client ORDER BY  last_name, first_name  DESC limit 6;

    /*4. С сортировкой по первому атрибуту, из списка извлекаемых*/
        SELECT first_name, last_name FROM client ORDER BY 1;

/*6. Работа с датами. Необходимо, чтобы одна из таблиц содержала атрибут с типом DATETIME.*/
    /*1. WHERE по дате*/
        SELECT first_name FROM client WHERE date_of_birth = '1989.11.30';

    /*2. Извлечь из таблицы не всю дату, а только год. Например, год рождения автора.*/
        SELECT extract(year from date_of_birth) from client;

/*7. SELECT GROUP BY с функциями агрегации*/
    /*1. MIN*/
        SELECT id_client, MIN(cost) FROM public.order GROUP BY id_client;

    /*2. MAX*/
        SELECT id_client, MAX(cost) FROM public.order GROUP BY id_client;

    /*3. AVG*/
        SELECT id_client, AVG(cost::numeric) FROM public.order GROUP BY id_client;

    /*4. SUM*/
        SELECT id_client, SUM(cost) FROM public.order GROUP BY id_client;

    /*5. COUNT*/
        SELECT id_client, COUNT(cost) FROM public.order GROUP BY id_client;
/*8. SELECT GROUP BY + HAVING*/
    /*1.*/
        SELECT  id_client, SUM(cost) FROM public.order GROUP BY id_client HAVING COUNT(cost) > 2;

    /*2.*/
        SELECT  id_client, MAX(cost) FROM public.order GROUP BY id_client HAVING MAX(cost::numeric) < 100000;

    /*3.*/
        SELECT  id_client, SUM(cost) FROM public.order GROUP BY id_client HAVING SUM(cost::numeric) > 100000;

/*9. SELECT JOIN*/
    /*1. LEFT JOIN двух таблиц и WHERE по одному из атрибутов*/
        SELECT * FROM "order" LEFT JOIN client on "order".id_client = client.id_client WHERE client.id_client > 43;

    /*2. RIGHT JOIN. Получить такую же выборку, как и в 5.1*/
        SELECT * FROM "order" RIGHT JOIN client on "order".id_client = client.id_client ORDER BY first_name ASC;

    /*3. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы*/
        SELECT * FROM client LEFT JOIN "order"  on client.id_client = "order".id_client
        LEFT JOIN rent on "order".id_rent = rent.id_rent
        WHERE rent.id_rent = 1 and "order".order_date = '1996-01-13' and client.id_client = 43;

    /*4. FULL OUTER JOIN двух таблиц*/
        SELECT * FROM "order" FULL OUTER JOIN client on "order".id_client = client.id_client;

/*10. Подзапросы*/
    /*1. Написать запрос с WHERE IN (подзапрос)*/
        SELECT id_client, cost, order_date FROM "order" WHERE order_date IN ('1996-01-12', '2015-01-12');

    /*2. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ...*/
        SELECT id_client, cost FROM "order" WHERE cost > (SELECT MIN(cost) FROM "order");