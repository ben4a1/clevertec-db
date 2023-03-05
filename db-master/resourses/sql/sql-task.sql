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