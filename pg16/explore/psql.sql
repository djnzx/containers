SELECT version();
SELECT current_date;
SELECT 2 + 2;
\h
\q
-- https://www.postgresql.org/docs/16/tutorial-sql-intro.html
\i basics.sql
-- https://www.postgresql.org/docs/16/app-psql.html
CREATE TABLE weather (
  city    varchar(80),
  temp_lo int,
  temp_hi int,
  prcp    real,
  date    date
);
-- standard SQL types
    -- int, smallint,
    -- real, double precision,
    -- char(N), varchar(N),
    -- date, time, timestamp,
    -- interval
CREATE TABLE cities (
  name     varchar(80),
  location point  -- tuple of double
);
DROP TABLE cities;
-- postgres specific type
    -- point
INSERT INTO weather VALUES ('San Francisco', 46, 50, 0.25, '1994-11-27');
INSERT INTO cities VALUES ('San Francisco', '(-194.0, 53.0)');
INSERT INTO weather (city, temp_lo, temp_hi, prcp, date)
  VALUES ('San Francisco', 43, 57, 0.0, '1994-11-29');
INSERT INTO weather (date, city, temp_hi, temp_lo)
  VALUES ('1994-11-29', 'Hayward', 54, 37);
-- https://www.postgresql.org/docs/16/sql-copy.html
COPY weather FROM '/home/user/weather.txt';
SELECT * FROM weather;
SELECT city, temp_lo, temp_hi, prcp, date FROM weather;
SELECT city, (temp_hi+temp_lo)/2 AS temp_avg, date FROM weather;
SELECT * FROM weather WHERE city = 'San Francisco' AND prcp > 0.0;
SELECT * FROM weather ORDER BY city;
SELECT DISTINCT city FROM weather;
SELECT DISTINCT city FROM weather ORDER BY city;
SELECT * FROM weather JOIN cities ON city = name;
SELECT weather.city, weather.temp_lo, weather.temp_hi,
       weather.prcp, weather.date, cities.location
    FROM weather JOIN cities ON weather.city = cities.name;
SELECT *
    FROM weather, cities
    WHERE city = name;
SELECT w1.city, w1.temp_lo AS low, w1.temp_hi AS high,
       w2.city, w2.temp_lo AS low, w2.temp_hi AS high
    FROM weather w1
        JOIN weather w2 ON w1.temp_lo < w2.temp_lo AND w1.temp_hi > w2.temp_hi;
SELECT *
    FROM weather w JOIN cities c ON w.city = c.name;
-- https://www.postgresql.org/docs/16/tutorial-agg.html
SELECT max(temp_lo) FROM weather;
SELECT city FROM weather
    WHERE temp_lo = (SELECT max(temp_lo) FROM weather);
SELECT city, count(*), max(temp_lo)
    FROM weather
    GROUP BY city;
SELECT city, count(*) FILTER (WHERE temp_lo < 45), max(temp_lo)
    FROM weather
    GROUP BY city;
-- FILTER is much like WHERE,
-- except that it removes rows only from the input of the particular aggregate function
-- that it is attached to.
-- Here, the count aggregate counts only rows with temp_lo below 45;
-- but the max aggregate is still applied to all rows, so it still finds the reading of 46.
UPDATE weather
    SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2
    WHERE date > '1994-11-28';
DELETE FROM weather WHERE city = 'Hayward';
--------------------------------------------------------------------------------------------
-- 3. https://www.postgresql.org/docs/16/tutorial-advanced.html
--------------------------------------------------------------------------------------------
CREATE VIEW myview AS
SELECT name, temp_lo, temp_hi, prcp, date, location
FROM weather, cities
WHERE city = name;

SELECT * FROM myview;

CREATE TABLE cities (
  name     varchar(80) primary key,
  location point
);

CREATE TABLE weather (
  city      varchar(80) references cities(name),
  temp_lo   int,
  temp_hi   int,
  prcp      real,
  date      date
);

BEGIN;
  UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
  UPDATE branches SET balance = balance - 100.00
    WHERE name = (SELECT branch_name FROM accounts WHERE name = 'Alice');
  UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
  UPDATE branches SET balance = balance + 100.00
    WHERE name = (SELECT branch_name FROM accounts WHERE name = 'Bob');
COMMIT;
-- or ROLLBACK
SAVEPOINT x;
ROLLBACK TO x;
BEGIN;
  UPDATE accounts SET balance = balance - 100.00
  WHERE name = 'Alice';
  SAVEPOINT point1;

  UPDATE accounts SET balance = balance + 100.00
  WHERE name = 'Bob';
  ROLLBACK TO point1;

  UPDATE accounts SET balance = balance + 100.00
  WHERE name = 'Wally';
COMMIT;
-- window
SELECT
    depname, empno, salary,
    avg(salary) OVER (PARTITION BY depname) -- average within grouping by depname
  FROM empsalary;

SELECT
    depname, empno, salary,
    rank() OVER (PARTITION BY depname ORDER BY salary DESC)
  FROM empsalary;

SELECT sum(salary) OVER w, avg(salary) OVER w
  FROM empsalary
  WINDOW w AS (PARTITION BY depname ORDER BY salary DESC);

CREATE TABLE cities (
  name       text,
  population real,
  elevation  int
);
-- inherits columns and DATA!!!
CREATE TABLE capitals (
  state      char(2) UNIQUE NOT NULL
) INHERITS (cities);

INSERT INTO cities   (name, population, elevation) VALUES ('Odessa', 1000000, 20);
INSERT INTO capitals (name, population, elevation, state) VALUES ('Kyiv', 3500000, 250, 'UA');

select * from capitals;    -- Kyiv only
select * from cities;      -- Kyiv + Odessa
select * from ONLY cities; -- Odessa ONLY
-- SELECT, UPDATE, DELETE — support `ONLY`
-- it has not been integrated with unique constraints or foreign keys

--------------------------------------------------------------------------------------------
-- 4. https://www.postgresql.org/docs/16/sql-syntax.html
--------------------------------------------------------------------------------------------
-- The system uses no more than NAMEDATALEN-1 bytes of an identifier;
-- longer names can be written in commands, but they will be truncated.
-- By default, NAMEDATALEN is 64 so the maximum identifier length is 63 bytes.
-- If this limit is problematic, it can be raised by changing the NAMEDATALEN constant
-- in src/include/pg_config_manual.h.
select U&"\0441\043B\043E\043D"; -- data
select U&"d\0061t\+000061"; -- слон
SELECT 'foo'
'bar'; -- 'foobar'

type 'string'
'string'::type
CAST ( 'string' AS type )
typename ( 'string' )
-- https://www.postgresql.org/docs/16/sql-syntax-lexical.html#SQL-PRECEDENCE
SELECT 3 OPERATOR(pg_catalog.+) 4;
create table dept(
  id   serial,
  name text
);
CREATE FUNCTION dept(int) RETURNS dept
  AS $$ SELECT * FROM dept WHERE id = $1 $$
    LANGUAGE SQL;
