SELECT * FROM `vibrant-mind-479310-f7.partial_project.delivery`;

-- Total cost of all successfully delivered parcels
SELECT delivery_status, 
SUM (delivery_cost) AS total_cost
FROM `vibrant-mind-479310-f7.partial_project.delivery`
WHERE delivery_status LIKE 'Delivered'
group by 1;

-- Average delivery distance by vehicle type
select vehicle_type, 
round(avg(distance_km)) as avg_distance
from `vibrant-mind-479310-f7.partial_project.delivery`
group by 1;

-- Monthly distribution of delivered orders
SELECT
FORMAT_DATE('%b', delivery_time) AS month_name,
count (delivery_id) as delivered_per_month
FROM `vibrant-mind-479310-f7.partial_project.delivery`
group by 1
order by 2 desc;

-- Distribution of delivery statuses among late deliveries
WITH late_deliveries AS (
  SELECT
    delivery_status,
    delivered_on_time
  FROM `vibrant-mind-479310-f7.partial_project.delivery`
  WHERE delivered_on_time = 0
)
SELECT
  delivery_status,
  COUNT(*) AS late_delivery_count
FROM late_deliveries
GROUP BY delivery_status
ORDER BY late_delivery_count DESC;

-- Regions with the highest number of late deliveries
select region, 
count (delivered_on_time) as untimely
from `vibrant-mind-479310-f7.partial_project.delivery`
where delivered_on_time = 0
group by 1
order by 2 desc;

-- Top 5 most expensive successful deliveries
select delivery_id, courier_id, delivery_time, delivery_cost, region
from `vibrant-mind-479310-f7.partial_project.delivery`
where delivery_status like 'Delivered'
order by delivery_cost desc
limit 5;

-- Vehicle types with the highest number of late deliveries
select vehicle_type, 
count (*) as untimely
from `vibrant-mind-479310-f7.partial_project.delivery`
where delivered_on_time = 0
group by 1
order by 2 desc;

-- Weather conditions associated with the highest number of late deliveries
select weather_conditions, 
count (*) as untimely
from `vibrant-mind-479310-f7.partial_project.delivery`
where delivered_on_time = 0
group by 1
order by 2 desc;

-- Regions with the highest number of cancelled deliveries
SELECT region, 
COUNT(*) AS cancelled_deliveries_count
FROM `vibrant-mind-479310-f7`.`partial_project`.`delivery`
WHERE delivery_status LIKE 'Cancelled'
GROUP BY 1
ORDER BY 2 DESC;

-- Weather conditions with the highest number of successful deliveries
SELECT weather_conditions,
count (*) as successful_delivery
FROM `vibrant-mind-479310-f7.partial_project.delivery`
where delivery_status like 'Delivered'
group by 1
order by 2 desc;

-- Total delivery cost by region
SELECT region, 
sum (delivery_cost) as total_cost
FROM `vibrant-mind-479310-f7`.`partial_project`.`delivery`
GROUP BY 1
ORDER BY 2 DESC;

-- Average delivery cost by region
SELECT region, 
round(avg (delivery_cost)) as average_cost_by_region
FROM `vibrant-mind-479310-f7`.`partial_project`.`delivery`
GROUP BY 1
ORDER BY 2 DESC;

-- Average delivery cost by vehicle type
SELECT vehicle_type, 
round(avg (delivery_cost)) as average_cost_by_vehicle
FROM `vibrant-mind-479310-f7`.`partial_project`.`delivery`
GROUP BY 1
ORDER BY 2 DESC;

-- Average delivery cost by weather conditions
SELECT weather_conditions, 
round(avg (delivery_cost)) as average_cost_by_weather
FROM `vibrant-mind-479310-f7`.`partial_project`.`delivery`
GROUP BY 1
ORDER BY 2 DESC;

-- Delivery cost per kilometer by weather conditions
SELECT weather_conditions, 
avg((delivery_cost/distance_km)) as cost_per_km
FROM `vibrant-mind-479310-f7`.`partial_project`.`delivery`
GROUP BY 1
ORDER BY 2 DESC;

-- Monthly distribution of cancelled deliveries
SELECT extract(month from delivery_time) as month_number, 
count (delivery_status) as canceled
FROM `vibrant-mind-479310-f7`.`partial_project`.`delivery`
GROUP BY 1
ORDER BY 2 DESC;

-- Comparison of average cost: cancelled vs successful deliveries
WITH cost_stats AS (
SELECT
ROUND (AVG(CASE WHEN delivery_status = 'Delivered' THEN delivery_cost END), 2) AS avg_success_cost,
ROUND( AVG(CASE WHEN delivery_status = 'Cancelled' THEN delivery_cost END), 2) AS avg_cancelled_cost
FROM `vibrant-mind-479310-f7.partial_project.delivery`
)
SELECT
avg_success_cost,
avg_cancelled_cost,
ROUND ((avg_cancelled_cost / avg_success_cost), 2) AS cancelled_to_success_pct
FROM cost_stats;

-- Average delivery speed by vehicle type (on-time vs late deliveries)
with delivery_duration as (
  select vehicle_type, distance_km, delivery_status, delivered_on_time,
  date_diff (delivery_time, pickup_time, day)* 24 as delivery_hours
  from `vibrant-mind-479310-f7.partial_project.delivery`)
select 
  vehicle_type,
  round(avg(case when delivered_on_time = 1 or delivery_status like 'Delivered' then distance_km/delivery_hours end), 3) as speed_kmh_on_time,
  round(avg(case when delivered_on_time = 0 or delivery_status in ('Failed','Cancelled') then distance_km/delivery_hours end), 3) as speed_kmh_not_on_time
from delivery_duration
group by vehicle_type;

-- Late delivery rate: weekday vs weekend comparison
WITH weekday_nums AS (
  SELECT
  delivered_on_time,
  EXTRACT(DAYOFWEEK FROM order_date)+1 AS weekday_num
  FROM `vibrant-mind-479310-f7.partial_project.delivery`
),
categorized AS (
  SELECT
    CASE WHEN weekday_num IN (1, 2, 3, 4, 5) THEN 'Weekday' ELSE 'Weekend' END AS day_type,
    delivered_on_time
  FROM weekday_nums
)
SELECT
  day_type,
  COUNTIF(delivered_on_time = 0) AS late_deliveries,
  COUNT(*) AS total_deliveries,
  ROUND(COUNTIF(delivered_on_time = 0) / COUNT(*), 3) AS late_part
FROM categorized
GROUP BY 1
ORDER BY 2 DESC;

-- Average delivery distance by month
SELECT
  EXTRACT (month FROM order_date) AS month_number,
  ROUND(AVG(distance_km), 2) AS avg_distance,
  COUNT(*) AS total_orders
FROM `vibrant-mind-479310-f7.partial_project.delivery`
GROUP BY 1
ORDER BY 1;

-- Delivery status distribution by weather conditions
SELECT
  weather_conditions,
  ROUND(COUNTIF(delivery_status = 'Failed') / COUNT(*), 2) AS failed_percent,
  ROUND(COUNTIF(delivery_status = 'Cancelled') / COUNT(*), 2) AS cancelled_percent,
  ROUND(COUNTIF(delivery_status = 'Delayed') / COUNT(*), 2) AS delayed_percent,
  ROUND(COUNTIF(delivery_status = 'Delivered') / COUNT(*), 2) AS delivered_percent
FROM `vibrant-mind-479310-f7.partial_project.delivery`
GROUP BY 1;
