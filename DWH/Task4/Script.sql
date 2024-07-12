create schema if not exists transportation_sales

CREATE TABLE if not exists transportation_sales.DIM_DATES (
  DATE_SURR_ID BIGINT PRIMARY KEY,
  DATE_ID DATE NOT NULL,
  DAY_ID integer NOT NULL,
  MONTH_ID integer NOT NULL,
  YEAR_ID integer NOT NULL,
  QRT_ID integer NOT NULL,
  WEEK_ID integer NOT NULL -- WEEK of THE YEAR
)

-- creating function given date, where allm day, month, week,  year will be extracted, surr key will start from one and increase by one for 
--each date
-- Function will populate the DIM_DATES table
CREATE OR REPLACE FUNCTION populate_dim_dates(start_date DATE, end_date DATE) RETURNS VOID AS $$
DECLARE
  current_date DATE := start_date;
  date_surr_id BIGINT := 1;
BEGIN
  WHILE current_date <= end_date LOOP
    INSERT INTO transportation_sales.DIM_DATES (
      DATE_SURR_ID,
      DATE_ID,
      DAY_ID,
      MONTH_ID,
      YEAR_ID,
      QRT_ID,
      WEEK_ID
    )
    VALUES (
      date_surr_id,
      current_date,
      EXTRACT(DAY FROM current_date)::INTEGER,
      EXTRACT(MONTH FROM current_date)::INTEGER,
      EXTRACT(YEAR FROM current_date)::INTEGER,
      EXTRACT(QUARTER FROM current_date)::INTEGER,
      EXTRACT(WEEK FROM current_date)::INTEGER
    );

    current_date := current_date + INTERVAL '1 day';
    date_surr_id := date_surr_id + 1;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- i dont know why but current date has syntax error here 

