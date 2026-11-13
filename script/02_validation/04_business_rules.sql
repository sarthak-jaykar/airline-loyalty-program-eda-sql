-- 02_validation/04_business_rules.sql
-- Business-rule checks. Each value is a count of violating rows.
SELECT 'cancellation year without month (expect 0)' AS rule,
       COUNT(*) AS violating_rows
FROM raw.loyalty_history WHERE (cancellation_year IS NULL) <> (cancellation_month IS NULL)
UNION ALL
SELECT 'cancellation before enrollment (expect 0)',
       COUNT(*) FROM raw.loyalty_history
WHERE cancellation_year IS NOT NULL
  AND (cancellation_year * 100 + cancellation_month) < (enrollment_year * 100 + enrollment_month)
UNION ALL
SELECT 'enrollment type not in expected list (expect 0)',
       COUNT(*) FROM raw.loyalty_history WHERE enrollment_type NOT IN ('Standard', '2018 Promotion')
UNION ALL
SELECT 'loyalty card not in expected list (expect 0)',
       COUNT(*) FROM raw.loyalty_history WHERE loyalty_card NOT IN ('Star', 'Nova', 'Aurora')
UNION ALL
SELECT 'negative salary (INFORMATIONAL: treated as invalid in analysis)',
       COUNT(*) FROM raw.loyalty_history WHERE salary < 0
UNION ALL
SELECT 'missing salary (INFORMATIONAL: shown as Missing band)',
       COUNT(*) FROM raw.loyalty_history WHERE salary IS NULL;

-- Date and value ranges (for the data quality log)
SELECT 'enrollment (yyyymm)' AS field, MIN(enrollment_year * 100 + enrollment_month)::text AS first_value,
       MAX(enrollment_year * 100 + enrollment_month)::text AS last_value FROM raw.loyalty_history
UNION ALL
SELECT 'cancellation (yyyymm)', MIN(cancellation_year * 100 + cancellation_month)::text,
       MAX(cancellation_year * 100 + cancellation_month)::text FROM raw.loyalty_history
UNION ALL
SELECT 'calendar (date)', MIN(date_value)::text, MAX(date_value)::text FROM raw.calendar;
