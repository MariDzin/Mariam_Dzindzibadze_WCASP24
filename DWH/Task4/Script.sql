create schema if not exists transportation_sales



CREATE TABLE IF NOT EXISTS transportation_sales.DIM_DATES (
  DATE_ID BIGINT PRIMARY KEY, -- this will be primary key in the form of YYYYMMDD
  DAY_ID INTEGER NOT NULL,
  MONTH_ID INTEGER NOT NULL,
  YEAR_ID INTEGER NOT NULL,
  QRT_ID INTEGER NOT NULL,
  WEEK_ID INTEGER NOT NULL -- Week of the year
);


-- creating function given date, where all day, month, week,  year will be extracted, surr key will start from one and increase by one for 
--each date
-- Function will populate the DIM_DATES table
CREATE OR REPLACE FUNCTION populate_dim_dates(start_date DATE, end_date DATE) RETURNS VOID AS $$
DECLARE
  dt DATE := start_date;
BEGIN
  WHILE dt <= end_date LOOP
    INSERT INTO transportation_sales.DIM_DATES (
      DATE_ID,
      DAY_ID,
      MONTH_ID,
      YEAR_ID,
      QRT_ID,
      WEEK_ID
    )
    VALUES (
      TO_CHAR(dt, 'YYYYMMDD')::BIGINT,
      EXTRACT(DAY FROM dt)::INTEGER,
      EXTRACT(MONTH FROM dt)::INTEGER,
      EXTRACT(YEAR FROM dt)::INTEGER,
      EXTRACT(QUARTER FROM dt)::INTEGER,
      EXTRACT(WEEK FROM dt)::INTEGER
    );

    dt := dt + INTERVAL '1 day';
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Populate the DIM_DATES table for the range from 2022-01-01 to 2024-12-31
SELECT populate_dim_dates('2022-01-01', '2024-12-31');
