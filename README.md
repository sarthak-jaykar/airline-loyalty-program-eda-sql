# Airline Loyalty Programme: Member Value, Churn and Points

Which loyalty members are most valuable, why members leave, and whether the points scheme is commercially sound. Built in PostgreSQL, with a documented data-quality investigation of duplicate and out-of-membership flight records.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![pgAdmin](https://img.shields.io/badge/pgAdmin-4-336791)
![SQL](https://img.shields.io/badge/SQL-Views%20%7C%20CTEs-informational)
![Domain](https://img.shields.io/badge/Domain-Business%20Analysis-success)
![Data Model](https://img.shields.io/badge/Data%20Model-Relational-blue)

---

## Project Overview

An airline runs a tiered loyalty programme (Star, Nova, Aurora). Members earn points on flights and redeem them for travel. The loyalty team needs to know who is most valuable, why members leave, and whether the points scheme makes commercial sense.

The analysis answers these business questions:

1. How do flight activity and points differ by loyalty tier?
2. Where is churn concentrated?
3. What drives member value (CLV)?
4. How do points earned and redeemed compare?
5. Does flight activity change before a member cancels?
6. Do 2018 promotion members behave differently from standard members?
7. How concentrated is member value?

Scope covers flight activity for 2017 and 2018, membership and cancellation dates, points, redemption value and CLV. Fare revenue, cost per flight, service complaints and causes of cancellation are out of scope.

## Dataset

**Dataset:** Airline Loyalty Program, three linked tables: 16,737 members, 392,936 monthly flight records (2017 to 2018) and a 2,557-row calendar. Currency is CAD.

**Dataset note:** Secondary dataset obtained from publicly available online educational material and used for learning and portfolio analysis. The three source CSV files are included in `data/`.

## Key Metrics (members, 2017 to 2018 flight window)

| KPI | Result |
| --- | --- |
| Members | **16,737** (12.35% have cancelled, 2,067 members) |
| Flights per member-month (in membership) | **1.64** (Aurora 1.64, Nova 1.65, Star 1.63) |
| Points accumulated / redeemed | **769 million** / **11.8 million** (1.5%) |
| Value per redeemed point | **$0.18 CAD** |
| Top 10% of members' share of total CLV | **30.7%** |

## Key Findings

These findings describe the data. They show associations, not causes. Only flight months inside each member's membership dates are used, unless stated.

1. **Flight frequency is the same across tiers.** Aurora 1.64, Nova 1.65 and Star 1.63 flights per member-month. Tier does not currently appear to drive travel.
2. **Points are earned far faster than they are redeemed.** About 769 million points have been accumulated, and 1.5% have been redeemed. The unredeemed balance is a potential financial liability that this analysis does not value.
3. **Member value follows tier, not salary.** Average CLV is $10,673 for Aurora, $8,046 for Nova and $6,742 for Star. Salary bands show little difference.
4. **Churn is similar across tiers.** It is 11.8% for Star, 12.6% for Nova and 13.1% for Aurora. The highest rates sit in small groups: Prince Edward Island at 16.7% (66 members) and Manitoba at 15.2% (658 members).
5. **Members who cancel fly more in the months before, not less (unexpected).** They average 2.22 flights per member-month in the 4 to 6 months before cancelling, against 1.64 for members who stay. Possible explanations include heavy travellers who then cancel, or the 2017 to 2018 window cutting off earlier months.
6. **2018 promotion members fly more but have much shorter histories.** They average 4.66 flights per member-month against 1.54, and their CLV per tenure month is higher ($965 against $712). Their average tenure is 8.8 months against 37.1.
7. **Value is concentrated, but not extremely.** The top 10% of members by CLV hold 30.7% of total CLV.

## Recommended Actions

These are proposed management targets, not proven results.

| Priority | Area | Action | Proposed target |
| --- | --- | --- | --- |
| **P1** | Points liability | Ask Finance to size the unredeemed points balance and review redemption options members want. | Redemption ratio and liability value, monthly |
| **P1** | Early-warning signal | Do not use an activity drop as a retention trigger. Investigate the pre-cancellation pattern with a longer history first. | A validated signal, tested on a holdout period |
| **P2** | Tier engagement | Test bonus points for flights among Star members against a control group. | Flights per member-month by tier, quarterly |
| **P2** | Value targeting | Use tier, not income, for value-based targeting. Recheck once more data is available. | CLV per tenure month by tier |
| **P3** | Promotion | Compare promotion and standard members who enrolled in the same months, before repeating the promotion. | Flights and churn for matched cohorts, 12 months after enrolment |
| **P3** | Top members | Create a named-account review for the top 10% of members. | Top-decile retention rate, quarterly |

## Tools and Methodology

- **PostgreSQL and pgAdmin:** schemas, raw tables, views and seven analysis queries.
- **SQL techniques:** joins, CTEs, window functions (`NTILE`, `PERCENTILE_CONT`), conditional aggregation and reusable views.
- **Independent check:** a pandas calculation of the same definitions (`script/02_validation/`).
- **Execution guide:** [SQL script order and purpose](script/README.md).

**Data model:** loyalty history (one row per member) relates to flight activity (one row per member per month). Two views build the analysis tables:
- `v_flight_activity_clean` removes exact duplicates, quarantines conflicting rows and flags whether each month is inside the member's membership.
- `v_member` adds churn, tenure, salary band and CLV per tenure month.

**Definitions**
- Churn: a cancellation date is present.
- Tenure: months from enrolment to cancellation, or to December 2018 for active members (minimum 1).
- CLV per tenure month: lifetime CLV divided by tenure months.
- Redemption ratio: points redeemed divided by points accumulated.

**Data-quality rules**
- 1,922 exact duplicate flight rows are removed.
- 1,949 conflicting duplicate rows (about 1.5% of flights) are quarantined, not guessed.
- 52,938 rows before enrolment and 35,144 rows on or after cancellation are kept, flagged and excluded from membership analyses.

**Validation**
- Thirteen result files match the independent Python calculation, with differences only from rounding.
- The Q5 baseline query had a filter bug, which was found in review and fixed. The corrected baseline (288,990 member-months, 1.64 flights) is in `results/q5_baseline.csv`.

## Repository Structure

```text
airline-loyalty-program-eda-sql/
├── README.md
├── data/                              Three source CSV files used by the analysis
├── documentation/
│   ├── 01_business_brief.md           Context, stakeholders, decisions, questions
│   ├── 02_data_and_quality.md         Source, tables, quality decisions, checks
│   ├── 03_findings_and_recommendations.md  KPI definitions, findings, actions
│   └── how_to_run.txt                 Step-by-step pgAdmin guide (Windows)
├── results/                           Query outputs exported from PostgreSQL
├── screenshots/                       pgAdmin screenshots of the database and each question
└── script/
    ├── README.md                      Script execution order and file guide
    ├── 00_setup/                      Schemas and raw tables
    ├── 01_load/                       Load the three CSV files
    ├── 02_validation/                 Duplicates, keys, orphans, business rules, and a Python cross-check
    ├── 03_views/                      Clean flight view (with membership flag) and member view
    └── 04_analysis/                   One file per business question (Q1 to Q7)
```

## Analysis

| Business question | SQL file | Result files |
| --- | --- | --- |
| Q1. Flight activity and points by tier | [SQL](script/04_analysis/q1_flight_activity_by_tier.sql) | [Result](results/q1_flight_by_tier.csv) |
| Q2. Churn by tier, enrolment, cohort and province | [SQL](script/04_analysis/q2_churn_rates.sql) | [Card](results/q2_churn_card.csv) · [Cohort](results/q2_churn_cohort.csv) · [Enrolment](results/q2_churn_enrollment.csv) · [Province](results/q2_churn_province.csv) |
| Q3. Drivers of CLV | [SQL](script/04_analysis/q3_clv_drivers.sql) | [Card](results/q3_clv_card.csv) · [Education](results/q3_clv_education.csv) · [Salary](results/q3_clv_salary.csv) |
| Q4. Points earned and redeemed | [SQL](script/04_analysis/q4_points_redemption.sql) | [Result](results/q4_points.csv) |
| Q5. Activity before cancellation | [SQL](script/04_analysis/q5_activity_before_cancellation.sql) | [Pre-cancellation](results/q5_pre_cancel.csv) · [Baseline](results/q5_baseline.csv) |
| Q6. 2018 promotion vs standard | [SQL](script/04_analysis/q6_promotion_vs_standard.sql) | [Promotion A](results/q6_promotion_a.csv) · [Promotion B](results/q6_promotion_b.csv) |
| Q7. Value concentration | [SQL](script/04_analysis/q7_value_concentration.sql) | [Result](results/q7_concentration.csv) |

## Documentation

- [Business Brief](documentation/01_business_brief.md): stakeholders, decisions and questions
- [Data and Quality](documentation/02_data_and_quality.md): source, tables, quality decisions and checks
- [Findings and Recommendations](documentation/03_findings_and_recommendations.md): KPI definitions, findings and actions
- [How to Run](documentation/how_to_run.txt): step-by-step pgAdmin guide, including the Q5 re-run

## How to Reproduce

1. Create a PostgreSQL database named `airline_loyalty` in pgAdmin.
2. Place the three CSV files, renamed as shown in [documentation/how_to_run.txt](documentation/how_to_run.txt), in `C:\airline_loyalty_raw`.
3. Run the scripts in `script/` in folder order, following [documentation/how_to_run.txt](documentation/how_to_run.txt).
4. Confirm the Q5 baseline (step 10 of the guide).

## Limitations

- Flight data covers 2017 and 2018 only, so members who cancelled earlier have no activity to analyse.
- 2018 promotion members have short histories, so the promotion comparison is a hypothesis.
- Several flight records fall outside membership dates. They are flagged and excluded, and the source owner should confirm whether dates or activity records are wrong.
- The 2012 enrolment cohort shows zero churn, which is unexplained.

## Author

[Sarthak Jaykar](https://www.linkedin.com/in/sarthak-jaykar/) · [GitHub](https://github.com/sarthak-jaykar)
