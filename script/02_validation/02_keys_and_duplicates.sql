-- 02_validation/02_keys_and_duplicates.sql
-- Part A: primary keys (expect 0).
SELECT 'loyalty_history.loyalty_number' AS check_name, COUNT(*) - COUNT(DISTINCT loyalty_number) AS duplicate_keys FROM raw.loyalty_history
UNION ALL
SELECT 'calendar.date_value', COUNT(*) - COUNT(DISTINCT date_value) FROM raw.calendar;

-- Part B: flight_activity duplicates (expected from profiling: 1,922 exact; 1,949 conflicting extra rows).
WITH d AS (SELECT DISTINCT * FROM raw.flight_activity),
conflict_keys AS (
    SELECT loyalty_number, activity_year, activity_month
    FROM d GROUP BY loyalty_number, activity_year, activity_month HAVING COUNT(*) > 1
)
SELECT 'exact duplicate rows (extra copies)' AS check_name,
       (SELECT COUNT(*) FROM raw.flight_activity) - (SELECT COUNT(*) FROM d) AS value
UNION ALL
SELECT 'rows that share a member-month key with a different row (total)',
       (SELECT COUNT(*) FROM d JOIN conflict_keys k USING (loyalty_number, activity_year, activity_month))
UNION ALL
SELECT 'conflicting member-months (distinct keys)',
       (SELECT COUNT(*) FROM conflict_keys)
UNION ALL
SELECT 'conflicting extra rows (total rows minus keys)',
       (SELECT COUNT(*) FROM d JOIN conflict_keys k USING (loyalty_number, activity_year, activity_month))
       - (SELECT COUNT(*) FROM conflict_keys);
