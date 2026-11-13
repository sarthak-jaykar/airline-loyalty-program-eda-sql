-- Q4. How do points accumulated compare with points redeemed, and what is the dollar value of redemptions?
-- Redemption ratio = points redeemed / points accumulated (in-membership member-months, 2017-2018).
-- Dollar value per point = dollar cost of redemptions / points redeemed.
SELECT
    m.loyalty_card,
    SUM(f.points_accumulated)                                          AS points_accumulated,
    SUM(f.points_redeemed)                                             AS points_redeemed,
    ROUND(100.0 * SUM(f.points_redeemed) / NULLIF(SUM(f.points_accumulated), 0), 2) AS redemption_ratio_pct,
    SUM(f.dollar_cost_points_redeemed)                                 AS redemption_value_cad,
    ROUND(SUM(f.dollar_cost_points_redeemed) / NULLIF(SUM(f.points_redeemed), 0), 4) AS cad_per_redeemed_point
FROM analytics.v_flight_activity_clean f
JOIN analytics.v_member m USING (loyalty_number)
WHERE f.in_membership
GROUP BY m.loyalty_card
ORDER BY CASE m.loyalty_card WHEN 'Aurora' THEN 1 WHEN 'Nova' THEN 2 WHEN 'Star' THEN 3 END;
