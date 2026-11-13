# Findings and Recommendations

## How to read this
Each finding follows: **finding → evidence → business implication → recommendation → measure**. Findings describe associations. Only flight months inside each member's membership are used, unless stated.

## KPI definitions

| KPI | Definition |
|---|---|
| Flights per member-month | Total flights ÷ member-months (in-membership, 2017 to 2018) |
| Churn rate | Members with a cancellation date ÷ members |
| CLV per tenure month | CLV ÷ tenure months (enrolment to cancellation, or to Dec 2018 if active) |
| Redemption ratio | Points redeemed ÷ points accumulated |
| Top-10% CLV share | CLV of the top 10% of members (by CLV) ÷ total CLV |

## Findings

**F1. Flight frequency is the same across loyalty tiers.**
Aurora 1.64, Nova 1.65 and Star 1.63 flights per member-month. The share of member-months with at least one flight is about 57.5% for each tier.
*Implication:* tier status does not currently appear to drive travel.
*Recommendation:* test whether bonus points for flights raise flying among Star members, against a control group. *Owner:* loyalty programme manager.
*Measure:* flights per member-month by tier, quarterly.

**F2. Points are earned far faster than they are redeemed.**
Members have accumulated about 769 million points and redeemed 11.8 million (1.5%). Each redeemed point is worth about $0.18 CAD, the same in every tier.
*Implication:* the unredeemed balance is a potential financial liability. This analysis does not measure its value.
*Recommendation:* ask Finance to size the liability, and review redemption options members actually want. *Owner:* loyalty programme manager with Finance.
*Measure:* redemption ratio and points liability, monthly.

**F3. Member value follows tier, not salary.**
Average CLV is $10,673 for Aurora, $8,046 for Nova and $6,742 for Star. Per month of tenure, the gap is larger: $935, $767 and $604. Salary bands show little difference ($7,500 to $8,450 average CLV).
*Implication:* tier is a better guide to value than income for this data.
*Recommendation:* use tier for value-based targeting. Recheck once more data is available. *Owner:* CRM lead.
*Measure:* CLV per tenure month by tier.

**F4. Churn is similar across tiers. The highest rates are in small groups.**
Churn is 11.8% for Star, 12.6% for Nova and 13.1% for Aurora. Prince Edward Island has the highest rate (16.7%), but only 66 members. Manitoba (15.2%, 658 members) is the next highest.
*Implication:* tier and province do not separate churners well. A better signal is needed.
*Recommendation:* treat small-province rates as hypotheses, and look for behavioural signals (see F5). *Owner:* CRM lead.
*Measure:* monthly churn rate by tier.

**F5. Flying rises before cancellation (unexpected).**
Members who cancel fly 2.22 times per member-month in the 4 to 6 months before cancelling, against 1.64 for members who stay. Activity is also higher in the 1 to 3 months before (1.96). It falls to 1.39 at 7 to 12 months before.
*Implication:* this is the opposite of the usual early-warning assumption. Possible explanations include heavy travellers who then cancel, or the 2017 to 2018 window cutting off earlier months.
*Recommendation:* do not use an activity drop as a retention trigger. Investigate with a longer history first. *Owner:* CRM lead with data team.
*Measure:* a validated pre-cancellation signal, tested on a holdout period.

**F6. 2018 promotion members fly more, but have much shorter histories.**
Promotion members average 4.66 flights per member-month against 1.54 for standard members. Their CLV per tenure month is higher ($965 against $712), but their average tenure is 8.8 months against 37.1.
*Implication:* the promotion may attract frequent flyers, but the short history and enrolment timing make its effect hard to separate.
*Recommendation:* treat the promotion as a hypothesis. Compare promotion and standard members who enrolled in the same months. *Owner:* marketing lead.
*Measure:* flights and churn for matched cohorts, 12 months after enrolment.

**F7. Value is concentrated, but not extremely.**
The top 10% of members by CLV hold 30.7% of total CLV. Ontario (29.8%) and British Columbia (30.3%) show similar concentration.
*Implication:* losing a few high-value members has a real but not extreme effect.
*Recommendation:* create a named-account review for the top decile. *Owner:* CRM lead.
*Measure:* retention rate of the top decile, quarterly.

## Caveats
- Flight data covers 2017 and 2018 only.
- Out-of-membership flights and conflicting duplicates are excluded and quantified (see the data and quality document).
- The 2012 cohort shows no churn, which is an open question for the data owner.
- CLV is lifetime invoice value. Compare it per tenure month.
