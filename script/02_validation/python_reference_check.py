"""
Independent Python reference check for the Airline Loyalty Program SQL project.

Recomputes the validation counts and Q1 to Q7 outputs with pandas, using the same
definitions as the SQL views, so pgAdmin results can be compared with them.

Usage (from the project root):
    python validation/python_reference_check.py

Reads data/customer_loyalty_history.csv, customer_flight_activity.csv
(renamed to snake_case as described in documentation/how_to_run.txt.md).
Prints each validation result to the console. Requires: pandas.
"""
from pathlib import Path
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data"
def _show(obj):
    """Print a validation result to the console instead of saving it as a CSV."""
    print(obj.to_string() if hasattr(obj, "to_string") else obj)
    print()
    return obj
KEYS = ["loyalty_number", "activity_year", "activity_month"]
REF = pd.Timestamp("2018-12-01")
WINDOW_START = pd.Timestamp("2017-01-01")

lh = pd.read_csv(RAW / "customer_loyalty_history.csv")
fa_raw = pd.read_csv(RAW / "customer_flight_activity.csv")
fa_raw.columns = ["loyalty_number", "activity_year", "activity_month", "total_flights",
                  "distance", "points_accumulated", "points_redeemed", "dollar_cost_points_redeemed"]
lh.columns = ["loyalty_number", "country", "province", "city", "postal_code", "gender", "education",
              "salary", "marital_status", "loyalty_card", "clv", "enrollment_type", "enrollment_year",
              "enrollment_month", "cancellation_year", "cancellation_month"]

# ---- Validation counts ---------------------------------------------------
exact_dups = int(len(fa_raw) - len(fa_raw.drop_duplicates()))
d = fa_raw.drop_duplicates()
conflict_mask = d.duplicated(KEYS, keep=False)
conflict_rows = int(conflict_mask.sum())
conflict_keys = int(d[conflict_mask].groupby(KEYS).ngroups)
clean = d[~conflict_mask].copy()

validation = pd.DataFrame([
    ("loyalty_history rows", len(lh), 16737),
    ("flight_activity rows", len(fa_raw), 392936),
    ("exact duplicate rows", exact_dups, 1922),
    ("conflicting rows (total)", conflict_rows, 3892),
    ("conflicting member-months (distinct keys)", conflict_keys, 1943),
    ("conflicting extra rows (rows minus keys)", conflict_rows - conflict_keys, 1949),
    ("loyalty_history duplicate ids", int(lh["loyalty_number"].duplicated().sum()), 0),
    ("flight rows outside membership (informational)", None, None),
    ("orphan flight rows (no member)", int((~fa_raw["loyalty_number"].isin(lh["loyalty_number"])).sum()), 0),
    ("negative salary (informational)", int((lh["salary"] < 0).sum()), None),
    ("missing salary (informational)", int(lh["salary"].isna().sum()), None),
], columns=["check", "python_result", "profiled_result"])
validation.pipe(_show)

# ---- Member view (same logic as analytics.v_member) ----------------------
m = lh.copy()
m["enroll_date"] = pd.to_datetime(dict(year=m.enrollment_year, month=m.enrollment_month, day=1))
m["cancel_date"] = pd.to_datetime(dict(year=m.cancellation_year.fillna(2000),
                                       month=m.cancellation_month.fillna(1), day=1))
m.loc[m["cancellation_year"].isna(), "cancel_date"] = pd.NaT
m["is_churned"] = m["cancel_date"].notna()
end = m["cancel_date"].fillna(REF)
m["tenure_months"] = np.maximum(1, (end.dt.year * 12 + end.dt.month) - (m.enroll_date.dt.year * 12 + m.enroll_date.dt.month))
m["observed"] = m["cancel_date"].isna() | (m["cancel_date"] >= WINDOW_START)
m["salary_band"] = np.select(
    [m["salary"].isna(), m["salary"] < 0, m["salary"] < 50000, m["salary"] < 75000, m["salary"] < 100000],
    ["Missing", "Invalid (negative)", "Under 50k", "50k to 75k", "75k to 100k"],
    default="100k and over")
m["clv_per_tenure"] = m["clv"] / m["tenure_months"]

fa = clean.merge(m[["loyalty_number", "loyalty_card", "enrollment_type", "observed", "province",
                    "enroll_date", "cancel_date"]], on="loyalty_number")
act_month = pd.to_datetime(dict(year=fa.activity_year, month=fa.activity_month, day=1))
fa["in_membership"] = (fa["enroll_date"] <= act_month) & (fa["cancel_date"].isna() | (act_month < fa["cancel_date"]))
fa_members = fa[fa["in_membership"]]  # membership-based analyses use this subset

def seg_table(df, col):
    g = df.groupby(col)
    return pd.DataFrame({
        "members": g.size(),
        "churned": g["is_churned"].sum(),
        "churn_rate_pct": (100 * g["is_churned"].mean()).round(2),
    }).reset_index().rename(columns={col: "segment"})

# ---- Q1 ------------------------------------------------------------------
o = fa_members
q1 = o.groupby("loyalty_card").agg(
    members=("loyalty_number", "nunique"), member_months=("loyalty_number", "size"),
    flights=("total_flights", "sum"), avg_flights_per_member_month=("total_flights", "mean"),
    avg_distance_km_per_member_month=("distance", "mean"),
    avg_points_per_member_month=("points_accumulated", "mean"),
    pct_member_months_with_flights=("total_flights", lambda s: 100 * (s > 0).mean())).round(2).reset_index()
q1.pipe(_show)

# ---- Q2 ------------------------------------------------------------------
pd.concat([seg_table(m, "loyalty_card").assign(cut="card"),
           seg_table(m, "enrollment_type").assign(cut="enrollment_type"),
           seg_table(m.assign(segment_col=m.enrollment_year.astype(str)), "segment_col").assign(cut="enrollment_year"),
           seg_table(m, "province").assign(cut="province")]).pipe(_show)

# ---- Q3 ------------------------------------------------------------------
def clv_table(col):
    g = m.groupby(col)
    return pd.DataFrame({"members": g.size(), "avg_clv": g["clv"].mean().round(2),
                         "median_clv": g["clv"].median().round(2),
                         "avg_clv_per_tenure_month": g["clv_per_tenure"].mean().round(2)}).reset_index()
pd.concat([clv_table("education").assign(cut="education"),
           clv_table("salary_band").assign(cut="salary_band"),
           clv_table("loyalty_card").assign(cut="card")]).pipe(_show)

# ---- Q4 ------------------------------------------------------------------
q4 = fa_members.groupby("loyalty_card").agg(
    points_accumulated=("points_accumulated", "sum"), points_redeemed=("points_redeemed", "sum"),
    redemption_value_cad=("dollar_cost_points_redeemed", "sum")).reset_index()
q4["redemption_ratio_pct"] = (100 * q4["points_redeemed"] / q4["points_accumulated"]).round(2)
q4["cad_per_redeemed_point"] = (q4["redemption_value_cad"] / q4["points_redeemed"]).round(4)
q4.pipe(_show)

# ---- Q5 ------------------------------------------------------------------
churn_in_window = m[m["cancel_date"].between(WINDOW_START, REF)][["loyalty_number", "cancel_date"]]
pre = churn_in_window.merge(fa_members.drop(columns=["cancel_date"]), on="loyalty_number")
pre["months_before"] = (pre.cancel_date.dt.year * 12 + pre.cancel_date.dt.month) - (pre.activity_year * 12 + pre.activity_month)
pre = pre[pre["months_before"].between(1, 24)].copy()
pre["window"] = pd.cut(pre["months_before"], [0, 3, 6, 12, 24], labels=["01 to 03 months before", "04 to 06 months before",
                                                                       "07 to 12 months before", "13 to 24 months before"])
q5 = pre.groupby("window", observed=True)["total_flights"].agg(["size", "mean"]).round(2).reset_index()
q5.columns = ["window_before_cancel", "member_months", "avg_flights_per_member_month"]
baseline_members = m[m["observed"] & ~m["cancel_date"].between(WINDOW_START, REF)]["loyalty_number"]
base = fa_members[fa_members["loyalty_number"].isin(baseline_members)]["total_flights"]
q5 = pd.concat([q5, pd.DataFrame([{"window_before_cancel": "Members not cancelled in window (baseline)",
                                   "member_months": len(base), "avg_flights_per_member_month": round(base.mean(), 2)}])])
q5.pipe(_show)

# ---- Q6 ------------------------------------------------------------------
q6a = m.groupby("enrollment_type").agg(members=("loyalty_number", "size"), churn_rate_pct=("is_churned", lambda s: round(100 * s.mean(), 2)),
                                       avg_clv=("clv", "mean"), avg_clv_per_tenure_month=("clv_per_tenure", "mean"),
                                       avg_tenure_months=("tenure_months", "mean")).round(2).reset_index()
q6b = fa_members.groupby("enrollment_type").agg(members=("loyalty_number", "nunique"),
                                                        avg_flights_per_member_month=("total_flights", "mean"),
                                                        avg_points_per_member_month=("points_accumulated", "mean")).round(2).reset_index()
pd.concat([q6a.assign(part="A"), q6b.assign(part="B")]).pipe(_show)

# ---- Q7 ------------------------------------------------------------------
r = m.sort_values("clv", ascending=False).reset_index(drop=True)
n = len(r)
r["decile"] = (np.arange(n) * 10 // n) + 1
total = r["clv"].sum()
top = r.loc[r["decile"] == 1, "clv"].sum()
q7a = pd.DataFrame([{"segment": "All members", "members": n, "total_clv": round(total, 2),
                     "top10pct_clv": round(top, 2), "top10pct_share_pct": round(100 * top / total, 2)}])
q7b = r.groupby("province").agg(members=("loyalty_number", "size"), total_clv=("clv", "sum")).reset_index()
q7b["top10pct_clv"] = q7b["province"].map(r[r.decile == 1].groupby("province")["clv"].sum()).fillna(0)
q7b["top10pct_share_pct"] = (100 * q7b["top10pct_clv"] / q7b["total_clv"]).round(2)
q7b = q7b.sort_values("total_clv", ascending=False).round(2)
pd.concat([q7a, q7b.rename(columns={"province": "segment"})]).pipe(_show)

print(validation.to_string(index=False))
print("\nQ1\n", q1.to_string(index=False))
print("\nQ5\n", q5.to_string(index=False))
print("\nQ7 overall\n", q7a.to_string(index=False))
