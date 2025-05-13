/*

Using the bus_shapes, bus_routes, 
and bus_trips tables from GTFS bus feed, 
find the two routes with the longest trips.
*/

WITH shape_geoms AS (
    SELECT 
        shape_id,
        ST_MakeLine(
            ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326)::geography 
            ORDER BY shape_pt_sequence
        ) AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),

trip_shapes AS (
    SELECT 
        bt.trip_id,
        bt.route_id,
        bt.trip_headsign,
        sg.shape_geog,
        ROUND(ST_Length(sg.shape_geog)) AS shape_length
    FROM septa.bus_trips bt
    JOIN shape_geoms sg ON bt.shape_id = sg.shape_id
),

trip_with_routes AS (
    SELECT 
        br.route_short_name,
        ts.trip_headsign,
        ts.shape_geog,
        ts.shape_length,
        ROW_NUMBER() OVER (ORDER BY ts.shape_length DESC) AS rn
    FROM trip_shapes ts
    JOIN septa.bus_routes br ON ts.route_id = br.route_id
)
SELECT 
    route_short_name,
    trip_headsign,
    shape_geog,
    shape_length
FROM trip_with_routes
WHERE rn <= 2;
