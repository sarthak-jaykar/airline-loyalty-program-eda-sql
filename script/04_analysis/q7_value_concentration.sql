-- Q7. Which provinces hold the most value, and how concentrated is it among top members?
-- Top 10% = members in the top decile of CLV across all members (NTILE(10), decile 1 = highest CLV).
-- Part A: overall concentration. Part B: by province.
WITH ranked AS (
    SELECT loyalty_number, province, clv, NTILE(10) OVER (ORDER BY clv DESC) AS decile
    FROM analytics.v_member
)
SELECT
    'All members' AS segment,
    COUNT(*)                                                              AS members,
    ROUND(SUM(clv), 2)                                                    AS total_clv,
    ROUND(SUM(clv) FILTER (WHERE decile = 1), 2)                          AS top10pct_clv,
    ROUND(100.0 * SUM(clv) FILTER (WHERE decile = 1) / SUM(clv), 2)       AS top10pct_share_pct
FROM ranked
UNION ALL
SELECT * FROM (
    SELECT
        province,
        COUNT(*),
        ROUND(SUM(clv), 2),
        ROUND(SUM(clv) FILTER (WHERE decile = 1), 2),
        ROUND(100.0 * SUM(clv) FILTER (WHERE decile = 1) / NULLIF(SUM(clv), 0), 2)
    FROM ranked
    GROUP BY province
    ORDER BY SUM(clv) DESC
) by_province;
