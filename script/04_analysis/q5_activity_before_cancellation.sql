-- Q5. Do members' flight activity drop in the months before they cancel?
-- Population: members who cancelled between Jan 2017 and Dec 2018 (the only cancellations we can observe activity for).
-- months_before = 1 means the month immediately before the cancellation month. The cancellation month itself is excluded.
-- Part A: average flights per member-month by months before cancellation.
-- Part B: baseline for members who did not cancel in the window.
-- Fixed in review: active members have a NULL cancel_date, which the earlier filter wrongly excluded. (same years, all observable months).
WITH churners AS (
    SELECT loyalty_number, cancel_date
    FROM analytics.v_member
    WHERE cancel_date BETWEEN DATE '2017-01-01' AND DATE '2018-12-01'
),
pre AS (
    SELECT
        c.loyalty_number,
        (DATE_PART('year', c.cancel_date)::int * 12 + DATE_PART('month', c.cancel_date)::int)
        - (f.activity_year::int * 12 + f.activity_month::int) AS months_before,
        f.total_flights
    FROM churners c
    JOIN analytics.v_flight_activity_clean f USING (loyalty_number)
    WHERE f.in_membership
)
SELECT
    CASE WHEN months_before BETWEEN 1 AND 3 THEN '01 to 03 months before'
         WHEN months_before BETWEEN 4 AND 6 THEN '04 to 06 months before'
         WHEN months_before BETWEEN 7 AND 12 THEN '07 to 12 months before'
         WHEN months_before BETWEEN 13 AND 24 THEN '13 to 24 months before' END AS window_before_cancel,
    COUNT(*)                          AS member_months,
    ROUND(AVG(total_flights), 2)      AS avg_flights_per_member_month
FROM pre
WHERE months_before BETWEEN 1 AND 24
GROUP BY 1
ORDER BY 1;

-- Part B: baseline for members who did not cancel in the window.
-- Fixed in review: active members have a NULL cancel_date, which the earlier filter wrongly excluded.
SELECT
    'Members not cancelled in window (baseline)' AS group_name,
    COUNT(*) AS member_months,
    ROUND(AVG(f.total_flights), 2) AS avg_flights_per_member_month
FROM analytics.v_flight_activity_clean f
JOIN analytics.v_member m USING (loyalty_number)
WHERE f.in_membership
  AND (m.cancel_date IS NULL OR m.cancel_date NOT BETWEEN DATE '2017-01-01' AND DATE '2018-12-01');
