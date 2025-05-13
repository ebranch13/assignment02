SELECT
  bs.stop_name,
  SUM(p.total) AS estimated_pop_800m,
  bs.geog
FROM (
  SELECT
    stop_id,
    stop_name,
    stop_lat,
    stop_lon,
    ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography AS geog
  FROM septa.bus_stops
) bs
JOIN census.blockgroups_2020 bg
  ON ST_Intersects(
    ST_Buffer(bs.geog, 800),
    bg.geog
  )
JOIN census.population_2020 p
  ON bg.geoid = p.geoid
WHERE bg.geoid LIKE '42101%'  -- Philadelphia County
GROUP BY bs.stop_name, bs.geog
HAVING SUM(p.total) > 500
ORDER BY estimated_pop_800m ASC
LIMIT 8;