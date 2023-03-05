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
       model -> 'ru' as model,
       s.fare_conditions,
       s."seat_no"
FROM seats s
         JOIN aircrafts_data ad on ad.aircraft_code = s.aircraft_code
WHERE NOT s.fare_conditions = 'Economy'
  AND model = 'Аэробус A321-200'
ORDER BY s.seat_no;

SELECT model -> 'ru' as model
FROM aircrafts_data;

