# SQL scripts (run in this order)

| Step | File | Purpose |
|---|---|---|
| 1 | 00_setup/01_create_schemas.sql | Create schemas raw and analytics |
| 2 | 00_setup/02_create_raw_tables.sql | Create raw tables (flight_activity has no primary key) |
| 3 | 01_load/01_load_raw.sql | Load the three CSVs from C:/airline_loyalty_raw/ |
| 4 | 02_validation/01_row_counts.sql | Row counts (expect PASS) |
| 5 | 02_validation/02_keys_and_duplicates.sql | Key checks and flight duplicate investigation |
| 6 | 02_validation/03_keys_and_orphans.sql | Orphan checks |
| 7 | 02_validation/04_business_rules.sql | Business-rule checks and value ranges |
| 8 | 03_views/01_flight_activity_clean.sql | Duplicate and conflict handling, in_membership flag |
| 9 | 03_views/02_member.sql | One row per member, churn, tenure, salary band |
| 10 to 16 | 04_analysis/q1 to q7 | Business questions |

Python reference (not run in pgAdmin): 02_validation/python_reference_check.py. Run from the project root to recreate documentation/expected_results/.
