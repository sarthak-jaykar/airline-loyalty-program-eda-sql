-- 03_views/02_member.sql
-- Grain: one row per loyalty member.
-- Reference month for active members = 2018-12-01 (the last month in the data).
-- observed_2017_2018: member is observable in the flight window (not cancelled before 2017).
CREATE OR REPLACE VIEW analytics.v_member AS
WITH base AS (
    SELECT
        lh.*,
        MAKE_DATE(lh.enrollment_year::int, lh.enrollment_month::int, 1) AS enroll_date,
        CASE WHEN lh.cancellation_year IS NOT NULL
             THEN MAKE_DATE(lh.cancellation_year::int, lh.cancellation_month::int, 1) END AS cancel_date
    FROM raw.loyalty_history lh
)
SELECT
    b.loyalty_number,
    b.country,
    b.province,
    b.city,
    b.gender,
    b.education,
    b.marital_status,
    b.loyalty_card,
    b.enrollment_type,
    b.enrollment_year,
    b.enroll_date,
    b.cancel_date,
    (b.cancel_date IS NOT NULL)                                  AS is_churned,
    CASE WHEN b.salary IS NULL THEN 'Missing'
         WHEN b.salary < 0 THEN 'Invalid (negative)'
         WHEN b.salary < 50000 THEN 'Under 50k'
         WHEN b.salary < 75000 THEN '50k to 75k'
         WHEN b.salary < 100000 THEN '75k to 100k'
         ELSE '100k and over' END                                AS salary_band,
    CASE WHEN b.salary < 0 THEN NULL ELSE b.salary END           AS salary_valid,
    b.clv,
    GREATEST(1,
        (DATE_PART('year', COALESCE(b.cancel_date, DATE '2018-12-01'))::int * 12
         + DATE_PART('month', COALESCE(b.cancel_date, DATE '2018-12-01'))::int)
        - (DATE_PART('year', b.enroll_date)::int * 12 + DATE_PART('month', b.enroll_date)::int)
    )                                                            AS tenure_months,
    (b.cancel_date IS NULL OR b.cancel_date >= DATE '2017-01-01') AS observed_2017_2018
FROM base b;
