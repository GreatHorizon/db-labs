/*1.Добавить внешние ключи.*/
ALTER TABLE booking
    ADD FOREIGN KEY (id_client) REFERENCES client (id_client);

ALTER TABLE room
    ADD FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel);

ALTER TABLE room
    ADD FOREIGN KEY (id_room_category) REFERENCES room_category (id_room_category);

ALTER TABLE room_in_booking
    ADD FOREIGN KEY (id_booking) REFERENCES booking (id_booking);

ALTER TABLE room_in_booking
    ADD FOREIGN KEY (id_room) REFERENCES room (id_room);

/*2. Выдать информцию о клиентах гостиниы "Космос", проживающих в номерах категории "Люкс" на 1 апреля 2019г.*/
SELECT client.name, client.phone FROM
room_in_booking
INNER JOIN room ON room_in_booking.id_room = room.id_room
INNER JOIN hotel ON room.id_hotel = hotel.id_hotel
INNER JOIN room_category ON room_category.id_room_category = room.id_room_category
INNER JOIN booking ON room_in_booking.id_booking = booking.id_booking
INNER JOIN client ON booking.id_client = client.id_client
WHERE
      checkout_date >= '2019-04-01' AND
      checkin_date <= '2019-04-01' AND
      hotel.name = 'Космос' AND
      room_category.name = 'Люкс';

/*3. Дать список свободных номеров всех гостиниц на 22 апреля.*/
SELECT id_hotel, id_room_category, number, price FROM room
LEFT JOIN
    (
        SELECT id_room FROM
        room_in_booking WHERE
        checkin_date <= '2019-04-22' AND
        checkout_date >= '2019-04-22'
    ) AS booked_rooms
ON booked_rooms.id_room = room.id_room
WHERE booked_rooms.id_room IS NULL;

/*4. Дать количество проживающих в гостинице “Космос” на 23 марта по каждой категории номеров*/
SELECT count(room.id_room), room_category.name FROM room_in_booking
INNER JOIN room ON room.id_room = room_in_booking.id_room
INNER JOIN hotel ON room.id_hotel = hotel.id_hotel
INNER JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE checkout_date >= '2019-03-23' AND
      checkin_date <= '2019-03-23' AND
      hotel.name = 'Космос'
GROUP BY room_category.id_room_category;

/*5. Дать список последних проживавших клиентов по всем комнатам гостиницы
“Космос”, выехавшим в апреле с указанием даты выезда*/

SELECT client.name, room_in_booking.checkout_date, room_in_booking.id_room
FROM (
    SELECT room.id_room, MAX(checkout_date) as checkout_date FROM room_in_booking
    LEFT JOIN room ON room_in_booking.id_room = room.id_room
    LEFT JOIN hotel ON room.id_hotel = hotel.id_hotel
    WHERE checkout_date <= '2019-04-30' AND
         checkout_date >= '2019-04-01' AND
         hotel.name = 'Космос'
    GROUP BY room.id_room
) as t
INNER JOIN room_in_booking ON
    room_in_booking.id_room = t.id_room AND
    room_in_booking.checkout_date = t.checkout_date
INNER JOIN booking on room_in_booking.id_booking = booking.id_booking
INNER JOIN client on booking.id_client = client.id_client;

/*6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам
комнат категории “Бизнес”, которые заселились 10 мая*/
begin;
UPDATE room_in_booking
SET checkout_date = checkout_date + interval '2 day'
WHERE room_in_booking.id_room_in_booking IN
(
    SELECT id_booking FROM room_in_booking
    INNER JOIN room ON room.id_room = room_in_booking.id_room
    INNER JOIN hotel ON room.id_hotel = hotel.id_hotel
    INNER JOIN room_category ON room.id_room_category = room_category.id_room_category
    WHERE room_in_booking.checkin_date = '2019-05-10' AND
          hotel.name = 'Космос' AND
          room_category.name = 'Бизнес'
);
rollback;
/* 7. Найти все "пересекающиеся" варианты проживания.
Правильное состояние:не может быть забронирован один номер на одну
дату несколько раз, т.к. нельзя заселиться нескольким клиентам в один номер.
Записи в таблице room_in_booking с id_room_in_booking = 5 и 2154 являются примером неправильного с остояния,
которые необходимо найти. Результирующий кортеж выборки должен содержать информацию о двух конфликтующих номерах. */
SELECT B1.id_room_in_booking as rib1, B1.id_room as room2,
       B1.checkin_date as in1, B1.checkout_date as out1,
       B2.id_room_in_booking as rib1, B2.id_room as room2,
       B2.checkin_date as in2, B2.checkout_date as out2
FROM room_in_booking B1, room_in_booking B2
WHERE B1.checkin_date < B2.checkin_date AND
      B1.checkout_date > B2.checkin_date AND B1.id_room = B2.id_room;

/* 8. Создать бронирование в транзакции */
BEGIN;

INSERT INTO booking (id_booking, id_client, booking_date) VALUES (
5000, (SELECT client.id_client FROM client WHERE name = 'Якурин Владислав Эрнстович'),
date('2020-08-20'));

INSERT INTO room_in_booking
(id_booking, id_room_in_booking, id_room, checkin_date, checkout_date) VALUES
(5000, 5000, 10, date('2020-03-25'), date('2020-04-25'));
ROLLBACK;

/* 9.Добавить необходимые индексы для всех таблиц.*/

CREATE INDEX "IX_room_in_booking_id-room_checkout_date"
ON room_in_booking(id_room, checkout_date);

CREATE INDEX "IX_room_in_booking_id-room_id-booking"
ON room_in_booking(id_room);

CREATE INDEX "IX_room_in_booking_ckeckin-date_checkout-date"
ON room_in_booking(checkin_date, checkout_date)
INCLUDE (id_room_in_booking);

CREATE INDEX "IX_booking_id-client"
ON booking("id_client");

CREATE INDEX "IX_room_id-hotel_id-room-categoty"
ON room(id_hotel, id_room_category);

CREATE INDEX "IX_hotel_name"
ON hotel(name);

CREATE INDEX "IX_room_category_name"
ON room_category(name);

CREATE INDEX "IX_client_name"
ON client(name);
