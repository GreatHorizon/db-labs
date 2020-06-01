/*1.Добавить внешние ключи.*/
ALTER TABLE dealer
    ADD FOREIGN KEY (id_company) REFERENCES company (id_company);

ALTER TABLE "order"
   ADD FOREIGN KEY (id_production) REFERENCES production (id_production);

ALTER TABLE "order"
    ADD FOREIGN KEY (id_dealer) REFERENCES dealer (id_dealer);

ALTER TABLE "order"
    ADD FOREIGN KEY (id_pharmacy) REFERENCES pharmacy (id_pharmacy);

ALTER TABLE production
    ADD FOREIGN KEY (id_company) REFERENCES company (id_company);

ALTER TABLE production
    ADD FOREIGN KEY (id_medicine) REFERENCES medicine (id_medicine);


/*2.Выдать информацию по всем заказам лекарства “Кордеон”
  компании “Аргус” c указанием названий аптек, дат, объема заказов.*/

SELECT "order".date, pharmacy.name, "order".quantity FROM "order"
INNER JOIN dealer ON "order".id_dealer = dealer.id_dealer
INNER JOIN company ON dealer.id_company = company.id_company
INNER JOIN production ON "order".id_production = production.id_production
INNER JOIN medicine ON production.id_medicine = medicine.id_medicine
INNER JOIN pharmacy ON "order".id_pharmacy = pharmacy.id_pharmacy
WHERE
      company.name = 'Аргус' AND
      medicine.name = 'Кордеон';

/*3. Дать список лекарств компании “Фарма”,
на которые не были сделаны заказы до 25 января.*/
SELECT medicine.name FROM medicine
WHERE  medicine.name NOT IN
(
      SELECT medicine.name
      FROM "order"
               INNER JOIN production ON "order".id_production = production.id_production
               INNER JOIN company ON production.id_company = company.id_company
               INNER JOIN medicine ON production.id_medicine = medicine.id_medicine
      WHERE company.name = 'Фарма'
        AND "order".date < '2019-01-25'
);

/*4. Дать минимальный и максимальный баллы лекарств каждой фирмы,
  которая оформила не менее 120 заказов.*/

SELECT company.name, MAX(production.rating) AS max_rating,
       MIN(production.rating) AS min_rating FROM "order"
INNER JOIN production ON "order".id_production = production.id_production
INNER JOIN company ON production.id_company = company.id_company
GROUP BY company.id_company
HAVING count(company.id_company) > 120;


/*5.Дать списки сделавших заказы аптек по всем дилерам
    компании “AstraZeneca”.
    Если у дилера нет заказов, в названии аптеки проставить NULL.*/

SELECT dealer.id_dealer, pharmacy.name FROM dealer
LEFT JOIN "order" ON "order".id_dealer = dealer.id_dealer
LEFT JOIN pharmacy ON "order".id_pharmacy = pharmacy.id_pharmacy
INNER JOIN  company ON dealer.id_company = company.id_company
WHERE company.name = 'AstraZeneca';

/*6.Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а
длительность лечения не более 7 дней*/

UPDATE production
SET price = price - (price * 0.2)
WHERE id_production IN (
    SELECT id_production FROM production
    INNER JOIN medicine ON production.id_medicine = medicine.id_medicine
    WHERE production.price > '3000'
      AND medicine.course_duration <= 7
);

/*7. Добавить
необходимые индексы*/
CREATE INDEX IX_medicine_name ON medicine(name);

CREATE INDEX IX_company_name ON company(name);

CREATE INDEX IX_order_id_dealer ON "order"(id_dealer);

CREATE INDEX IX_order_id_pharmacy ON "order"(id_pharmacy);

CREATE INDEX IX_order_id_production ON "order"(id_production);

CREATE INDEX IX_order_date ON "order"(date);

CREATE INDEX IX_production_id_company ON production(id_company);

CREATE INDEX IX_production_id_medicine ON production(id_medicine);
