-- Q6. Do members enrolled through the 2018 promotion behave differently from standard enrolments?
-- Part A: member-level outcomes (churn, CLV, tenure). Part B: flight behaviour for observable members.
SELECT
    enrollment_type,
    COUNT(*)                                       AS members,
    ROUND(100.0 * AVG(is_churned::int), 2)         AS churn_rate_pct,
    ROUND(AVG(clv), 2)                             AS avg_clv,
    ROUND(AVG(clv / tenure_months), 2)             AS avg_clv_per_tenure_month,
    ROUND(AVG(tenure_months), 1)                   AS avg_tenure_months
FROM analytics.v_member
GROUP BY enrollment_type
ORDER BY enrollment_type;

WITH obs AS (
    SELECT m.enrollment_type, f.*
    FROM analytics.v_flight_activity_clean f
    JOIN analytics.v_member m USING (loyalty_number)
    WHERE f.in_membership
)
SELECT
    enrollment_type,
    COUNT(DISTINCT loyalty_number)                 AS members,
    ROUND(AVG(total_flights), 2)                   AS avg_flights_per_member_month,
    ROUND(AVG(points_accumulated), 0)              AS avg_points_per_member_month
FROM obs
GROUP BY enrollment_type
ORDER BY enrollment_type;
