-- Q3. Which members and segments have the highest CLV, and how does it relate to education, salary and tier?
-- CLV is lifetime invoice value, so it depends on how long a member has been enrolled.
-- clv_per_tenure_month normalises for tenure and is the fairer comparison.
-- Part A: by education. Part B: by salary band. Part C: by loyalty card tier.
SELECT education AS segment, COUNT(*) AS members,
       ROUND(AVG(clv), 2) AS avg_clv,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY clv)::numeric, 2) AS median_clv,
       ROUND(AVG(clv / tenure_months), 2) AS avg_clv_per_tenure_month
FROM analytics.v_member GROUP BY education ORDER BY avg_clv DESC;

SELECT salary_band AS segment, COUNT(*) AS members,
       ROUND(AVG(clv), 2) AS avg_clv,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY clv)::numeric, 2) AS median_clv,
       ROUND(AVG(clv / tenure_months), 2) AS avg_clv_per_tenure_month
FROM analytics.v_member GROUP BY salary_band ORDER BY avg_clv DESC;

SELECT loyalty_card AS segment, COUNT(*) AS members,
       ROUND(AVG(clv), 2) AS avg_clv,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY clv)::numeric, 2) AS median_clv,
       ROUND(AVG(clv / tenure_months), 2) AS avg_clv_per_tenure_month
FROM analytics.v_member GROUP BY loyalty_card ORDER BY avg_clv DESC;
