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
  dt DATE := start_date;
  date_surr_id BIGINT := 1;
BEGIN
  WHILE dt <= end_date LOOP
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
      dt,
      EXTRACT(DAY FROM dt)::INTEGER,
      EXTRACT(MONTH FROM dt)::INTEGER,
      EXTRACT(YEAR FROM dt)::INTEGER,
      EXTRACT(QUARTER FROM dt)::INTEGER,
      EXTRACT(WEEK FROM dt)::INTEGER
    );

    dt := dt + INTERVAL '1 day';
    date_surr_id := date_surr_id + 1;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT populate_dim_dates('2022-01-01', '2024-12-31');
