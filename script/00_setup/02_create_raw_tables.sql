-- 00_setup/02_create_raw_tables.sql
-- Raw tables mirror the CSV files. flight_activity has NO primary key on purpose:
-- the source contains duplicate member-months, which are investigated in 02_validation.
DROP TABLE IF EXISTS raw.flight_activity, raw.loyalty_history, raw.calendar CASCADE;

CREATE TABLE raw.loyalty_history (
    loyalty_number      INTEGER PRIMARY KEY,
    country             TEXT,
    province            TEXT,
    city                TEXT,
    postal_code         TEXT,
    gender              TEXT,
    education           TEXT,
    salary              NUMERIC(12,2),
    marital_status      TEXT,
    loyalty_card        TEXT,
    clv                 NUMERIC(12,2),
    enrollment_type     TEXT,
    enrollment_year     SMALLINT,
    enrollment_month    SMALLINT,
    cancellation_year   SMALLINT,
    cancellation_month  SMALLINT
);

CREATE TABLE raw.flight_activity (
    loyalty_number              INTEGER,
    activity_year               SMALLINT,
    activity_month              SMALLINT,
    total_flights               INTEGER,
    distance                    NUMERIC(12,2),
    points_accumulated          NUMERIC(12,2),
    points_redeemed             NUMERIC(12,2),
    dollar_cost_points_redeemed NUMERIC(12,2)
);

CREATE TABLE raw.calendar (
    date_value        DATE PRIMARY KEY,
    start_of_year     DATE,
    start_of_quarter  DATE,
    start_of_month    DATE
);
