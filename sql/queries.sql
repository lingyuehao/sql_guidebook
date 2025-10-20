-- Query1： Top 15 Countries by Number of Airports
SELECT country, COUNT(*) AS airport_count
FROM airports
GROUP BY country
ORDER BY airport_count DESC
LIMIT 15;

-- Query2： Most International Airports by Destination Countries （Top 20）
WITH dests AS (
  SELECT source_airport_id, dst.country AS dest_country
  FROM routes r
  JOIN airports dst ON r.destination_airport_id = dst.airport_id
)
SELECT ap.name AS airport_name, ap.city, ap.country,
       COUNT(DISTINCT dest_country) AS destination_countries
FROM dests
JOIN airports ap ON dests.source_airport_id = ap.airport_id
GROUP BY ap.airport_id
ORDER BY destination_countries DESC
LIMIT 20;

-- Query 3: Number of Airports Served by Each Airline (Top 15)
WITH all_airports AS (
  SELECT airline_id, source_airport_id AS airport_id FROM routes
  UNION
  SELECT airline_id, destination_airport_id FROM routes
)
SELECT a.name AS airline_name, COUNT(DISTINCT airport_id) AS airports_served
FROM all_airports aa
JOIN airlines a ON a.airline_id = aa.airline_id
GROUP BY a.name
ORDER BY airports_served DESC
LIMIT 15;

-- Query 4: China and United States – Top Departure Hubs with Hub Size Labels
WITH dep AS (
  SELECT
    r.source_airport_id AS airport_id,
    COUNT(*) AS dep_cnt
  FROM routes r
  GROUP BY r.source_airport_id
),
ranked AS (
  SELECT
    ap.country,
    ap.name AS airport_name,
    ap.city,
    dep.dep_cnt,
    ROW_NUMBER() OVER (
      PARTITION BY ap.country
      ORDER BY dep.dep_cnt DESC
    ) AS rn,
    CASE
      WHEN dep.dep_cnt >= 1500 THEN 'Mega hub'
      WHEN dep.dep_cnt >= 500  THEN 'Large'
      WHEN dep.dep_cnt >= 200  THEN 'Medium'
      ELSE 'Small'
    END AS hub_size
  FROM dep
  JOIN airports ap ON ap.airport_id = dep.airport_id
  WHERE ap.country IN ('China', 'United States')
)
SELECT country, rn, airport_name, city, dep_cnt, hub_size
FROM ranked
WHERE rn <= 10                     
ORDER BY country, dep_cnt DESC;


-- Query 5: Top 10 Airlines and Their Most Used Aircraft Models (Usage Trend Comparison)
WITH plane_usage AS (
  SELECT
      a.name AS airline_name,
      COALESCE(NULLIF(p.name, '\N'), '(Unknown Plane)') AS plane_name,
      COUNT(r.route_id) AS route_count
  FROM routes r
  JOIN airlines a ON r.airline_id = a.airline_id
  JOIN planes p ON TRIM(p.iata) = TRIM(SUBSTR(r.equipment, 1, 3))
  GROUP BY a.name, p.name
),
ranked AS (
  SELECT
      airline_name,
      plane_name,
      route_count,
      RANK() OVER (PARTITION BY airline_name ORDER BY route_count DESC) AS rank_within_airline,
      LAG(route_count) OVER (PARTITION BY airline_name ORDER BY route_count DESC) AS prev_usage,
      LEAD(route_count) OVER (PARTITION BY airline_name ORDER BY route_count DESC) AS next_usage
  FROM plane_usage
),
top_airlines AS (
  SELECT airline_name
  FROM plane_usage
  GROUP BY airline_name
  ORDER BY SUM(route_count) DESC
  LIMIT 10
)
SELECT
  r.airline_name,
  r.plane_name,
  r.route_count,
  COALESCE(r.prev_usage - r.route_count, 0) AS diff_from_prev,
  COALESCE(r.route_count - r.next_usage, 0) AS diff_from_next
FROM ranked r
JOIN top_airlines t ON r.airline_name = t.airline_name
WHERE r.rank_within_airline = 1
ORDER BY r.route_count DESC;

-- Query 6: Top 20 City Pair per Airline (with frequency)
WITH city_pairs AS (
  SELECT
    r.airline_id,
    COALESCE(NULLIF(TRIM(src.city), ''), '(unknown)') AS src_city,
    COALESCE(NULLIF(TRIM(dst.city), ''), '(unknown)') AS dst_city,
    COUNT(*) AS pair_cnt
  FROM routes r
  JOIN airports src ON r.source_airport_id      = src.airport_id    
  JOIN airports dst ON r.destination_airport_id = dst.airport_id    
  GROUP BY r.airline_id, src_city, dst_city
),

ranked AS (
  SELECT
    cp.airline_id,
    cp.src_city,
    cp.dst_city,
    cp.pair_cnt,
    ROW_NUMBER() OVER (
      PARTITION BY cp.airline_id
      ORDER BY cp.pair_cnt DESC, cp.src_city, cp.dst_city
    ) AS rn
  FROM city_pairs cp
)

SELECT
  COALESCE(NULLIF(a.name, '\N'), '(Unknown Airline)') AS airline_name,
  r.src_city,
  r.dst_city,
  r.pair_cnt AS flights_between_cities
FROM ranked r
JOIN airlines a ON a.airline_id = r.airline_id
WHERE r.rn = 1                    
ORDER BY flights_between_cities DESC
LIMIT 20;                         
