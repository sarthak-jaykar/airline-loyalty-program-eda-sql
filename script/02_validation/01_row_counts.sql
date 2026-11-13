-- 02_validation/01_row_counts.sql
WITH expected (tbl, n) AS (
    VALUES ('loyalty_history', 16737), ('flight_activity', 392936), ('calendar', 2557)
),
actual AS (
    SELECT 'loyalty_history' AS tbl, COUNT(*) AS n FROM raw.loyalty_history UNION ALL
    SELECT 'flight_activity', COUNT(*) FROM raw.flight_activity UNION ALL
    SELECT 'calendar', COUNT(*) FROM raw.calendar
)
SELECT e.tbl, e.n AS expected_rows, a.n AS loaded_rows,
       CASE WHEN e.n = a.n THEN 'PASS' ELSE 'FAIL' END AS status
FROM expected e JOIN actual a USING (tbl)
ORDER BY e.tbl;
