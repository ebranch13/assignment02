/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel 
with its closest bus stop. The final result should give the parcel address, bus stop name,
 and distance apart in meters, rounded to two decimals. Order by distance (largest on top).

*/

SELECT
    parcel.address,
    stop.stop_name,
    ROUND(ST_Distance(parcel.geog, stop.geog)::numeric, 2) AS distance_m
FROM pwd.stormwater_billing_parcels AS parcel
JOIN LATERAL (
    SELECT stop_name, geog
    FROM septa.bus_stops
    ORDER BY parcel.geog <-> geog
    LIMIT 1
) AS stop ON true
ORDER BY distance_m DESC;