-- Q2. What is the cancellation (churn) rate by tier, enrollment type, enrollment cohort and province?
-- Churn = cancellation date present. Rates are cumulative to the end of the data (Dec 2018).
-- Part A: by loyalty card tier
SELECT loyalty_card AS segment, COUNT(*) AS members, SUM(is_churned::int) AS churned,
       ROUND(100.0 * AVG(is_churned::int), 2) AS churn_rate_pct
FROM analytics.v_member GROUP BY loyalty_card ORDER BY churn_rate_pct DESC;

-- Part B: by enrollment type
SELECT enrollment_type AS segment, COUNT(*) AS members, SUM(is_churned::int) AS churned,
       ROUND(100.0 * AVG(is_churned::int), 2) AS churn_rate_pct
FROM analytics.v_member GROUP BY enrollment_type ORDER BY churn_rate_pct DESC;

-- Part C: by enrollment year (cohort)
SELECT enrollment_year::text AS segment, COUNT(*) AS members, SUM(is_churned::int) AS churned,
       ROUND(100.0 * AVG(is_churned::int), 2) AS churn_rate_pct
FROM analytics.v_member GROUP BY enrollment_year ORDER BY enrollment_year;

-- Part D: by province
SELECT province AS segment, COUNT(*) AS members, SUM(is_churned::int) AS churned,
       ROUND(100.0 * AVG(is_churned::int), 2) AS churn_rate_pct
FROM analytics.v_member GROUP BY province ORDER BY churn_rate_pct DESC;
