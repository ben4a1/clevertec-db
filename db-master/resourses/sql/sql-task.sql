-- Вывести к каждому самолету класс
-- обслуживания и количество мест этого класса
SELECT ad.model,
       seats.aircraft_code,
       seats.fare_conditions,
       (count(fare_conditions))
FROM seats
         JOIN aircrafts_data ad on ad.aircraft_code = seats.aircraft_code
group by ad.model, seats.fare_conditions, seats.aircraft_code
ORDER BY aircraft_code;

--Найти 3 самых вместительных самолета (модель + кол-во мест)

SELECT