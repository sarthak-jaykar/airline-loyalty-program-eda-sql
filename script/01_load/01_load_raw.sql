-- 01_load/01_load_raw.sql
-- Loads the three CSV files from C:/airline_loyalty_raw/ (see documentation/how_to_run.txt).
-- Column order matches the CSV headers exactly, because COPY maps by position.
COPY raw.loyalty_history FROM 'C:/airline_loyalty_raw/customer_loyalty_history.csv' WITH (FORMAT csv, HEADER true);
COPY raw.flight_activity FROM 'C:/airline_loyalty_raw/customer_flight_activity.csv' WITH (FORMAT csv, HEADER true);
COPY raw.calendar FROM 'C:/airline_loyalty_raw/calendar.csv' WITH (FORMAT csv, HEADER true);
ANALYZE raw.loyalty_history;
ANALYZE raw.flight_activity;
ANALYZE raw.calendar;
