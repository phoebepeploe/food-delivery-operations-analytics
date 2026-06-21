-- Creating a database to import the food_delivery_data from flat file
CREATE DATABASE FoodDeliveryDB;
USE FoodDeliveryDB;

-- Data Cleaning
-- Validating data to ensure import was successful (import validation)
SELECT COUNT (*) AS total_rows
FROM food_delivery_data;

-- Visual inspection of the newly uploaded data (datatype validation)
SELECT TOP 10 *
FROM food_delivery_data;

-- Checking for missing values in all the columns (NULL analysis)
SELECT
COUNT (*) AS total_rows,
COUNT(order_id) AS order_id,
COUNT(city_tier) AS city_tier,
COUNT(customer_age) AS customer_age,
COUNT(customer_loyalty_score) AS customer_loyalty_score,
COUNT(order_hour) AS order_hour,
COUNT(order_day_of_week) AS order_day_of_week,
COUNT(order_month) AS order_month,
COUNT(delivery_distance_km) AS delivery_distance_km,
COUNT(preparation_time_minutes) AS preparation_time_minutes,
COUNT(delivery_time_minutes) AS delivery_time_minutes,
COUNT(estimated_delivery_time) AS estimated_delivery_time,
COUNT(traffic_level_score) AS traffic_level_score,
COUNT(weather_severity_score) AS weather_severity_score,
COUNT(restaurant_rating) AS restaurant_rating,
COUNT(delivery_partner_rating) AS delivery_partner_rating,
COUNT(customer_rating) AS customer_rating,
COUNT(order_value) AS order_value,
COUNT(delivery_fee) AS delivery_fee,
COUNT(discount_amount) AS discount_amount,
COUNT(tip_amount) AS tip_amount,
COUNT(final_amount_paid) AS final_amount_paid,
COUNT(number_of_items) AS number_of_items,
COUNT(cancellation_flag) AS cancellation_flag,
COUNT(delayed_delivery_flag) AS delayed_delivery_flag,
COUNT(refund_flag) AS refund_flag,
COUNT(promo_code_used) AS promo_code_used,
COUNT(premium_customer_flag) AS premium_customer_flag,
COUNT(festival_or_weekend_flag) AS festival_or_weekend_flag,
COUNT(delivery_partner_experience_years) AS delivery_partner_experience_years,
COUNT(delivery_efficiency_score) AS delivery_efficiency_score
FROM food_delivery_data;

-- Checking to see if theres a why to the missing values (Missingness investigation)
SELECT TOP 20
customer_rating,
delivery_partner_rating,
tip_amount,
cancellation_flag,
delayed_delivery_flag
FROM food_delivery_data
WHERE
customer_rating IS NULL
OR delivery_partner_rating IS NULL
OR tip_amount IS NULL;

-- Checking to see if all mising values occur together
SELECT COUNT(*) AS matching_null_rows
FROM food_delivery_data
WHERE
customer_rating IS NULL
AND delivery_partner_rating IS NULL
AND tip_amount IS NULL;

-- Duplicate checks
SELECT
order_id,
COUNT(*) AS duplicate_count
FROM food_delivery_data
GROUP BY order_id
HAVING COUNT(*) >1;


-- Analytical EDA
-- Baseline KPI Analysis
SELECT
AVG(delivery_time_minutes) AS avg_delivery_time_minutes,
AVG(preparation_time_minutes) AS avg_preparation_time_minutes,
AVG(delivery_distance_km) AS avg_delivery_distance_km,
AVG(customer_rating) AS avg_customer_rating,
AVG(delivery_partner_rating) AS avg_delivery_partner_rating,
AVG(delivery_efficiency_score) AS avg_delivery_efficiency_score
FROM food_delivery_data;


-- Part 1: What factors most affect delivery times? (Operational Analysis)
-- Traffic
SELECT
CASE
WHEN traffic_level_score < 3 THEN 'Low Traffic'
WHEN traffic_level_score < 6 THEN 'Moderate Traffic'
WHEN traffic_level_score < 8 THEN 'High Traffic'
ELSE 'Severe Traffic'
END AS traffic_level,
AVG(delivery_time_minutes) AS avg_delivery_time
FROM food_delivery_data
GROUP BY
CASE
WHEN traffic_level_score < 3 THEN 'Low Traffic'
WHEN traffic_level_score < 6 THEN 'Moderate Traffic'
WHEN traffic_level_score < 8 THEN 'High Traffic'
ELSE 'Severe Traffic'
END
ORDER BY avg_delivery_time;

-- Distance
SELECT
CASE
WHEN delivery_distance_km < 5 THEN '0-5 km'
WHEN delivery_distance_km < 10 THEN '5-10 km'
WHEN delivery_distance_km < 20 THEN '10-20 km'
ELSE '20+ km'
END AS distance_band,
AVG(delivery_time_minutes) AS avg_delivery_time
FROM food_delivery_data
GROUP BY
CASE
WHEN delivery_distance_km < 5 THEN '0-5 km'
WHEN delivery_distance_km < 10 THEN '5-10 km'
WHEN delivery_distance_km < 20 THEN '10-20 km'
ELSE '20+ km'
END
ORDER BY avg_delivery_time;

-- Preparation Time
SELECT
CASE
WHEN preparation_time_minutes < 10 THEN '<10 mins'
WHEN preparation_time_minutes BETWEEN 10 AND 20 THEN '10-20 mins'
WHEN preparation_time_minutes BETWEEN 21 AND 30 THEN '21-30 mins'
WHEN preparation_time_minutes BETWEEN 31 AND 40 THEN '31-40 mins'
ELSE '40+ mins'
END AS Prep_Time_Group,
AVG(delivery_time_minutes) AS Avg_Delivery_Time
FROM food_delivery_data
GROUP BY
CASE
WHEN preparation_time_minutes < 10 THEN '<10 mins'
WHEN preparation_time_minutes BETWEEN 10 AND 20 THEN '10-20 mins'
WHEN preparation_time_minutes BETWEEN 21 AND 30 THEN '21-30 mins'
WHEN preparation_time_minutes BETWEEN 31 AND 40 THEN '31-40 mins'
ELSE '40+ mins'
END
ORDER BY Avg_Delivery_Time;

-- Weather Severity
SELECT
CASE
WHEN weather_severity_score < 2 THEN 'Very Low (0-2)'
WHEN weather_severity_score < 4 THEN 'Low (2-4)'
WHEN weather_severity_score < 6 THEN 'Moderate (4-6)'
WHEN weather_severity_score < 8 THEN 'High (6-8)'
ELSE 'Severe (8-10)'
END AS weather_severity_group,
AVG(delivery_time_minutes) AS avg_delivery_time
FROM food_delivery_data
GROUP BY
CASE
WHEN weather_severity_score < 2 THEN 'Very Low (0-2)'
WHEN weather_severity_score < 4 THEN 'Low (2-4)'
WHEN weather_severity_score < 6 THEN 'Moderate (4-6)'
WHEN weather_severity_score < 8 THEN 'High (6-8)'
ELSE 'Severe (8-10)'
END
ORDER BY avg_delivery_time DESC;

-- City Tier
SELECT city_tier,
AVG(delivery_time_minutes) AS avg_delivery_time
FROM food_delivery_data
GROUP BY city_tier
ORDER BY avg_delivery_time DESC;

-- Order Hour
SELECT order_hour,
AVG(delivery_time_minutes) AS Avg_Delivery_Time_Mins
FROM food_delivery_data
GROUP BY order_hour
ORDER BY order_hour;

-- Order Day
SELECT order_day_of_week,
AVG(delivery_time_minutes) AS Avg_Delivery_Time_Mins
FROM food_delivery_data
GROUP BY order_day_of_week
ORDER BY Avg_Delivery_Time_Mins DESC;


-- Part 2: What restaurant operational factors are causing longer prep times? (Performance analysis)
-- Preparation time drivers
-- No. of orders vs prep time
SELECT order_hour,
COUNT(*) AS Number_of_Orders,
AVG(preparation_time_minutes) AS Avg_Prep_Time
FROM food_delivery_data
GROUP BY order_hour
ORDER BY Number_of_Orders;

-- No. of items in order vs. prep time
SELECT number_of_items,
AVG(preparation_time_minutes) AS Avg_Prep_Time
FROM food_delivery_data
GROUP BY number_of_items
ORDER BY number_of_items;

-- What factors are associated with deliveries arriving later than estimated? (Delivery Performance Analysis)
SELECT
CASE
WHEN delivery_time_minutes > estimated_delivery_time THEN 'Late'
WHEN delivery_time_minutes < estimated_delivery_time THEN 'Early'
ELSE 'On Time'
END AS Delivery_Status,
COUNT(*) AS Number_Of_Orders,
AVG(preparation_time_minutes) AS Avg_Prep_Time,
AVG(delivery_distance_km) AS Avg_Distance,
AVG(traffic_level_score) AS Avg_Traffic
FROM food_delivery_data
GROUP BY
CASE
WHEN delivery_time_minutes > estimated_delivery_time THEN 'Late'
WHEN delivery_time_minutes < estimated_delivery_time THEN 'Early'
ELSE 'On Time'
END;


-- Delivery estimate accuracy/SLA performance
SELECT
CASE
WHEN delivery_time_minutes > estimated_delivery_time THEN 'Late'
WHEN delivery_time_minutes < estimated_delivery_time THEN 'Early'
ELSE 'On Time'
END AS Delivery_Status,
COUNT(*) AS Number_Of_Orders,
ROUND(COUNT(*) * 100.0 /
(SELECT COUNT(*) FROM food_delivery_data),2) AS Percentage_Of_Orders
FROM food_delivery_data
GROUP BY
CASE
WHEN delivery_time_minutes > estimated_delivery_time THEN 'Late'
WHEN delivery_time_minutes < estimated_delivery_time THEN 'Early'
ELSE 'On Time'
END;


-- Part 3 Customer Experience Analysis
-- Do longer delivery times lead to lower customer ratings?
-- 3A - Delivery time VS. delivery partner ratings
SELECT delivery_partner_rating,
AVG(delivery_time_minutes) AS Avg_Delivery_Time
FROM food_delivery_data
GROUP BY delivery_partner_rating
ORDER BY delivery_partner_rating DESC;

SELECT
CASE
WHEN delivery_partner_rating >= 4 THEN 'High Rating'
WHEN delivery_partner_rating >= 3 THEN 'Medium Rating'
ELSE 'Low Rating'
END AS Rating_Group,
AVG(delivery_time_minutes) AS Avg_Delivery_Time,
COUNT(*) AS Number_Of_Orders
FROM food_delivery_data
GROUP BY
CASE
WHEN delivery_partner_rating >= 4 THEN 'High Rating'
WHEN delivery_partner_rating >= 3 THEN 'Medium Rating'
ELSE 'Low Rating'
END;

-- 3B - Cancellation Rates VS SLA Performance
-- Are late deliveries associated with higher cancellation rates?
SELECT
CASE
WHEN delivery_time_minutes > estimated_delivery_time THEN 'Late'
ELSE 'On Time/Early'
END AS Delivery_Performance,
cancellation_flag,
COUNT(*) AS Number_Of_Orders
FROM food_delivery_data
GROUP BY
CASE
WHEN delivery_time_minutes > estimated_delivery_time THEN 'Late'
ELSE 'On Time/Early'
END, cancellation_flag
ORDER BY Delivery_Performance;

-- 3C - Discount Amount Vs Delivery Partner Ratings
SELECT
CASE
WHEN discount_amount < 10 THEN 'Low Discount'
WHEN discount_amount < 20 THEN 'Medium Discount'
ELSE 'High Discount'
END AS Discount_Group,
AVG(delivery_partner_rating) AS Avg_Delivery_Partner_Rating,
COUNT(*) AS Number_Of_Orders
FROM food_delivery_data
GROUP BY
CASE
WHEN discount_amount < 10 THEN 'Low Discount'
WHEN discount_amount < 20 THEN 'Medium Discount'
ELSE 'High Discount'
END;


-- Part 4 Demand Analysis
-- Order Hour
SELECT order_hour,
COUNT(*) AS Number_Of_Orders
FROM food_delivery_data
GROUP BY order_hour
ORDER BY Number_Of_Orders DESC;

-- Day of the Week
SELECT order_day_of_week,
COUNT(*) AS Number_Of_Orders
FROM food_delivery_data
GROUP BY order_day_of_week
ORDER BY Number_Of_Orders DESC;

-- Weekend/Festival Flag
SELECT festival_or_weekend_flag,
COUNT(*) AS Number_Of_Orders
FROM food_delivery_data
GROUP BY festival_or_weekend_flag;

SELECT @@SERVERNAME
