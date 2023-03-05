-- Вывести к каждому самолету класс
-- обслуживания и количество мест этого класса
SELECT ad.model,
       seats.aircraft_code,
       seats.fare_conditions,
       (count(fare_conditions))
FROM seats
         JOIN aircrafts_data ad on ad.aircraft_code = seats.aircraft_code
GROUP BY ad.model, seats.fare_conditions, seats.aircraft_code
ORDER BY aircraft_code;

SELECT ad.model,
       (SELECT count(*)
        FROM seats s
        WHERE s.aircraft_code = ad.aircraft_code
          AND s.fare_conditions = 'Business') AS business,
       (SELECT count(*)
        FROM seats s
        WHERE s.aircraft_code = ad.aircraft_code
          AND s.fare_conditions = 'Comfort')  AS comfort,
       (SELECT count(*)
        FROM seats s
        WHERE s.aircraft_code = ad.aircraft_code
          AND s.fare_conditions = 'Economy')  AS economy
FROM aircrafts_data ad
ORDER BY business, comfort, economy;

--Найти 3 самых вместительных самолета (модель + кол-во мест)

SELECT ad.model,
       (count(fare_conditions))
FROM seats
         JOIN aircrafts_data ad on ad.aircraft_code = seats.aircraft_code
GROUP BY ad.model
ORDER BY count(fare_conditions) DESC
LIMIT 3;


-- Вывести код,модель самолета и места не эконом класса
-- для самолета 'Аэробус A321-200' с сортировкой по местам

SELECT ad.aircraft_code,
       ad.model,
       s.fare_conditions,
       s."seat_no"
FROM seats s
         JOIN aircrafts_data ad on ad.aircraft_code = s.aircraft_code
WHERE NOT s.fare_conditions = 'Economy'
  AND model ->> 'ru' LIKE '%Аэробус A321-200'
ORDER BY s.seat_no;

--Вывести города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город)

SELECT DISTINCT ad.airport_code,
                ad.airport_name,
                ad.city
FROM (SELECT city, count(*)
      FROM airports_data
      group by city
      HAVING count(*) > 1)
         AS a
         JOIN airports_data ad ON a.city = ad.city
ORDER BY ad.city, ad.airport_name;

SELECT city, count(*)
FROM airports
GROUP BY city
HAVING count(*) > 1;

-- Найти ближайший вылетающий рейс из Екатеринбурга в Москву,
-- на который еще не завершилась регистрация

SELECT fl.*
FROM flights fl
WHERE fl.departure_airport IN (SELECT airport_code
                               FROM airports_data
                               WHERE city ->> 'ru' LIKE '%Екатеринбург%')
  AND fl.arrival_airport IN (SELECT airport_code
                             FROM airports_data
                             WHERE city ->> 'ru' LIKE '%Москва%')
  AND (status = 'On Time' OR status = 'Delayed')
  AND fl.scheduled_departure > bookings.now()
ORDER BY fl.scheduled_departure
LIMIT 1;

--Вывести самый дешевый и дорогой билет и стоимость ( в одном результирующем ответе)

SELECT t.*, min(tf.amount), max(tf.amount)
FROM tickets t
         JOIN ticket_flights tf on t.ticket_no = tf.ticket_no
WHERE t.ticket_no = (SELECT tf.ticket_no
                     FROM ticket_flights tf
                     WHERE amount = (SELECT MIN(amount)
                                     FROM ticket_flights)
                     LIMIT 1)
   OR t.ticket_no = (SELECT tf.ticket_no
                     FROM ticket_flights tf
                     WHERE amount = (SELECT MAX(amount)
                                     FROM ticket_flights)
                     LIMIT 1)
group by t.ticket_no, book_ref, passenger_id, passenger_name, contact_data;

-- Написать DDL таблицы Customers , должны быть поля id ,
-- firstName, LastName, email , phone. Добавить ограничения на поля ( constraints).

CREATE TABLE IF NOT EXISTS customers
(
    customer_id SERIAL,
    first_name  varchar(128)                                         NOT NULL,
    last_name   varchar(128)                                         NOT NULL,
    email       varchar(128) UNIQUE                                  NOT NULL,
    phone       BIGINT CHECK ( phone > 999999 AND phone < 100000000) NOT NULL,
    PRIMARY KEY (customer_id)
);

-- Написать DDL таблицы Orders , должен быть id, customerId,
-- quantity. Должен быть внешний ключ на таблицу customers + ограничения

CREATE TABLE IF NOT EXISTS orders
(
    order_id       SERIAL,
    customer_id_fk INT NOT NULL,
    quantity       INT NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id_fk) REFERENCES customers
);

-- Написать 5 insert в эти таблицы

INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Alex', 'Alekseev', 'ni4esi@gmail.by', 12332155),
       ('Karina', 'P-V', 'thedoorsoff@gmail.gb', 98765311),
       ('Andrey', 'Kolomiets', 'kvnygenetot@planetakvn.rf', 79994645),
       ('Andrey', 'Ponomarev', 'harleyoneal@naba.com', 59994645),
       ('Luke', 'Neodnonogii', 'enakin@10000.napodhode', 1000000);

INSERT INTO orders(customer_id_fk, quantity)
VALUES (1, 15),
       (2, 20),
       (3, 25),
       (4, 30),
       (5, 333);

-- удалить таблицы

DROP TABLE IF EXISTS orders;

DROP TABLE IF EXISTS customers;

-- Написать свой кастомный запрос ( rus + sql)

/*
    Необходимо проследить за наполняемостью бортов,
    ибо есть предположение, что из Магадана в Сыктывкар летают мало пассажиров
 */
SELECT ts.flight_id,
       ts.flight_no,
       ts.departure_airport,
       ts.arrival_airport,
       a.model,
       ts.fact_passengers,
       ts.total_seats,
       round(ts.fact_passengers::numeric /
             ts.total_seats::numeric, 2) AS fraction
FROM (SELECT f.flight_id,
             f.flight_no,
             f.scheduled_departure,
             f.departure_airport,
             f.arrival_airport,
             f.aircraft_code,
             count(tf.ticket_no)                       AS fact_passengers,
             (SELECT count(s.seat_no)
              FROM seats s
              WHERE s.aircraft_code = f.aircraft_code) AS total_seats
      FROM flights f
               JOIN ticket_flights tf
                    ON f.flight_id = tf.flight_id
      WHERE f.status = 'Arrived'
      GROUP BY 1, 2, 3, 4, 5, 6) AS ts
         JOIN aircrafts AS a
              ON ts.aircraft_code = a.aircraft_code
ORDER BY fraction;





