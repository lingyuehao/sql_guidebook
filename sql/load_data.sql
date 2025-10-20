
-- sqlite3 guidebook.db
-- .mode csv
-- .separator ","
-- .headers on
-- .import --csv airlines.txt     airlines
-- .import --csv airports.txt     airports
-- .import --csv planes.txt       planes
-- .import --csv routes_2014.txt  routes
-- .quit

ALTER TABLE routes ADD COLUMN route_id INTEGER;
UPDATE routes SET route_id = rowid;   
CREATE UNIQUE INDEX IF NOT EXISTS idx_routes_route_id ON routes(route_id);

SELECT 
    (SELECT COUNT(*) FROM airlines)  AS airlines_count,
    (SELECT COUNT(*) FROM airports)  AS airports_count,
    (SELECT COUNT(*) FROM planes)    AS planes_count,
    (SELECT COUNT(*) FROM routes)    AS routes_count;