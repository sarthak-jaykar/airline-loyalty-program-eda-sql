-- 02_validation/03_keys_and_orphans.sql
-- Expect 0 unless marked informational.
SELECT 'flight_activity -> loyalty_history (orphan rows)' AS check_name, COUNT(*) AS value
FROM raw.flight_activity f
WHERE NOT EXISTS (SELECT 1 FROM raw.loyalty_history l WHERE l.loyalty_number = f.loyalty_number)
UNION ALL
SELECT 'loyalty members with no flight rows (informational)', COUNT(*)
FROM raw.loyalty_history l
WHERE NOT EXISTS (SELECT 1 FROM raw.flight_activity f WHERE f.loyalty_number = l.loyalty_number)
UNION ALL
SELECT 'activity rows outside 2017-2018 (expect 0)', COUNT(*)
FROM raw.flight_activity WHERE activity_year NOT IN (2017, 2018)
UNION ALL
SELECT 'activity month outside 1-12', COUNT(*)
FROM raw.flight_activity WHERE activity_month NOT BETWEEN 1 AND 12;
