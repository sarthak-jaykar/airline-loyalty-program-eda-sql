# Data and Quality

## Source
| Field | Value |
|---|---|
| Dataset | Airline Loyalty Program (loyalty history, monthly flight activity, calendar) |
| Dataset context | Secondary dataset obtained from publicly available online educational material; used for educational and portfolio analysis. |
| Currency | CAD (per the data dictionary) |
| Period | Flights: 2017 to 2018. Enrolments: 2012 to 2018. Cancellations: 2013 to 2018. |

## Tables and row grain

| Table | Grain | Rows | Key |
|---|---|---|---|
| loyalty_history | one member | 16,737 | loyalty_number |
| flight_activity | one member per month | 392,936 | none (duplicates present; see below) |
| calendar | one day | 2,557 | date_value |

Relationship: loyalty_history → flight_activity, one to many. Every flight row matches a member.

## Data quality decisions

| # | Issue | Rows / members affected | Decision |
|---|---|---|---|
| 1 | Exact duplicate flight rows | 1,922 extra rows | Removed (one copy kept) |
| 2 | Same member-month with different values | 1,949 extra rows; 1,943 member-months; 135 members; 7,490 flights (1.5% of flights) | Quarantined and excluded. Not guessed, because the file alone cannot show which value is correct. |
| 3 | Flights recorded before the enrolment month | 52,938 rows; 5,014 members; 8,251 flights | Kept and flagged `in_membership = FALSE`. Excluded from membership analyses. |
| 4 | Flights recorded on or after the cancellation month | 35,144 rows; 2,067 members; 2,144 flights | Kept and flagged. Excluded from membership analyses. |
| 5 | Salary missing | 4,238 members | Shown as "Missing". Not imputed. |
| 6 | Salary negative (invalid) | 20 members | Shown as "Invalid". Excluded from salary bands. |
| 7 | Cancellation fields blank | 14,670 members | Treated as active (not cancelled). |
| 8 | 2012 enrolment cohort has zero churn | 1,686 members | Unexplained. Open question for the data owner. Not interpreted. |
| 9 | 2018 enrolment cohort has short tenure | 3,010 members | Churn by cohort reported but not compared directly (tenure too short). |

Items 3 and 4 suggest that enrolment or cancellation dates may be wrong, or that the activity table includes records from outside membership. The data owner should confirm which.

## Checks

| Check | Expected | Status |
|---|---|---|
| Row counts (three tables) | 16,737; 392,936; 2,557 | Passed (author run, `script/02_validation/01_row_counts.sql`) |
| Duplicate keys in loyalty_history | 0 | As above |
| Orphan flight rows | 0 | As above |
| Duplicate investigation counts | 1,922 exact; 1,949 conflicting | As above |

The Python reference values are printed to the console by `script/02_validation/python_reference_check.py`.
