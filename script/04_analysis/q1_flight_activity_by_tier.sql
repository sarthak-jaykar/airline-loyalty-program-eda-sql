-- Q1. How do flight activity and points vary by loyalty card tier?
-- Population: flight months inside each member's membership (in_membership = TRUE). Conflicting rows already excluded in the view.
-- Grain of output: one row per loyalty card tier.
WITH obs AS (
    SELECT m.loyalty_card, f.*
    FROM analytics.v_flight_activity_clean f
    JOIN analytics.v_member m USING (loyalty_number)
    WHERE f.in_membership
)
SELECT
    loyalty_card,
    COUNT(DISTINCT loyalty_number)                          AS members,
    COUNT(*)                                                AS member_months,
    SUM(total_flights)                                      AS flights,
    ROUND(AVG(total_flights), 2)                            AS avg_flights_per_member_month,
    ROUND(AVG(distance), 0)                                 AS avg_distance_km_per_member_month,
    ROUND(AVG(points_accumulated), 0)                       AS avg_points_per_member_month,
    ROUND(100.0 * SUM((total_flights > 0)::int) / COUNT(*), 2) AS pct_member_months_with_flights
FROM obs
GROUP BY loyalty_card
ORDER BY CASE loyalty_card WHEN 'Aurora' THEN 1 WHEN 'Nova' THEN 2 WHEN 'Star' THEN 3 END;
