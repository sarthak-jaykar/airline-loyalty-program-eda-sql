-- 03_views/01_flight_activity_clean.sql
-- Grain: one row per member per month.
-- Rule 1: exact duplicate rows are removed (keep one copy).
-- Rule 2: member-months that still have CONFLICTING rows are QUARANTINED (excluded), not guessed.
-- Rule 3: in_membership flags whether the month falls inside the member's membership:
--         enrollment month <= activity month < cancellation month (or no cancellation).
--         Rows outside membership are KEPT but flagged. Membership analyses filter on in_membership = TRUE.
CREATE OR REPLACE VIEW analytics.v_flight_activity_clean AS
WITH d AS (
    SELECT DISTINCT * FROM raw.flight_activity
),
conflict_keys AS (
    SELECT loyalty_number, activity_year, activity_month
    FROM d
    GROUP BY loyalty_number, activity_year, activity_month
    HAVING COUNT(*) > 1
),
kept AS (
    SELECT d.*
    FROM d
    WHERE NOT EXISTS (
        SELECT 1 FROM conflict_keys k
        WHERE k.loyalty_number = d.loyalty_number
          AND k.activity_year = d.activity_year
          AND k.activity_month = d.activity_month
    )
)
SELECT
    k.*,
    (
        MAKE_DATE(l.enrollment_year::int, l.enrollment_month::int, 1) <= MAKE_DATE(k.activity_year::int, k.activity_month::int, 1)
        AND (l.cancellation_year IS NULL
             OR MAKE_DATE(k.activity_year::int, k.activity_month::int, 1)
                < MAKE_DATE(l.cancellation_year::int, l.cancellation_month::int, 1))
    ) AS in_membership
FROM kept k
JOIN raw.loyalty_history l ON l.loyalty_number = k.loyalty_number;
