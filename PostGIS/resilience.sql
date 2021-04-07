/* Mapping access to medical services in Dar-es-Salaam */

/* 1 we need to isolate clinics */
create table medical_osm_polygon as
select osm_id, building, amenity, name, way
from planet_osm_polygon
where amenity = 'hospital' OR amenity = 'doctors' or amenity = 'clinic'

create table medical_osm_point as
select osm_id, building, amenity, name, way
from planet_osm_point
where amenity = 'hospital' OR amenity = 'doctors' or amenity = 'clinic'
-- needed to change from "where amenity = 'hospital', 'doctors', 'clinic'" cause of syntax error

------------------------------------------------------------

/* 2 isolate residential areas */
create table res_osm_polygon as
select osm_id, building, way
from planet_osm_polygon
where amenity is null and building is not null
-- filtering out amenities

alter table res_osm_polygon
add column res int
-- create table for residential

update res_osm_polygon
set res = 1
where building = 'yes' or building = 'residential'
-- filter out other weird buildings that shouldnt be there

delete from res_osm_polygon
where res is null
-- get rid of the ones that have stuck behind

create table res_osm_point as
select osm_id, building, way
from planet_osm_point
where amenity is null and building is not null

alter table res_osm_point
add column res int

update res_osm_point
set res = 1
where building = 'yes' or building = 'residential'

delete from res_osm_point
where res is null
-- repeat for points

---------------------------------------------------------------
-- IGNORE THIS!!!!!!!
/* 3 check for duplicates and get rid of em */
SELECT osm_id, COUNT( osm_id )
FROM res_osm_polygon
GROUP BY osm_id
HAVING COUNT( osm_id )> 1
ORDER BY osm_id;
-- a few

SELECT osm_id, COUNT( osm_id )
FROM res_osm_point
GROUP BY osm_id
HAVING COUNT( osm_id )> 1
ORDER BY osm_id;
-- none

SELECT osm_id, COUNT( osm_id )
FROM medical_osm_polygon
GROUP BY osm_id
HAVING COUNT( osm_id )> 1
ORDER BY osm_id;
-- none

SELECT osm_id, COUNT( osm_id )
FROM medical_osm_point
GROUP BY osm_id
HAVING COUNT( osm_id )> 1
ORDER BY osm_id;
-- none!!!!!

/* now its time to get rid of em */
alter table res_osm_polygon
add column cntpolygon int,
add column duplicate int

update res_osm_polygon
set cntpolygon as COUNT(osm_id)
from res_osm_polygon
group by osm_id
/* actually, we'll pretend those dont exist */

--------------------------------------------------------------------------------

/* 5 Consolidate polygons and points
/* Get rid of residential points that were also counted as residential polygons */
/* Create column*/
ALTER TABLE res_osm_point
ADD COLUMN duplicate int;

/* check for duplicates */
UPDATE res_osm_point
SET duplicate = 1
FROM res_osm_polygon
WHERE ST_INTERSECTS(res_osm_point.way, res_osm_polygon.way)

/* Delete the points that overlap the polygons */
DELETE FROM res_osm_point
WHERE duplicate = 1

/* now do the same for clinics */
alter table medical_osm_point
add COLUMN duplicate int;

update medical_osm_point
set duplicate = 1
from medical_osm_polygon
WHERE ST_INTERSECTS(medical_osm_point.way, medical_osm_polygon.way);

delete from medical_osm_point
where duplicate = 1;

-----------------------------------------------------------------------------------------------------------

/* 6 convert polygons to centroids */
/* Convert medical polygons to centroids and union with medical points */
CREATE TABLE med_union AS
SELECT osm_id, building, amenity, name, ST_CENTROID(way) AS geom
FROM medical_osm_polygon
UNION
SELECT osm_id, building, amenity, name, way as geom
FROM medical_osm_point

/* same with residential points */
CREATE TABLE res_union AS
SELECT osm_id, building,ST_CENTROID(way) AS geom
FROM res_osm_polygon
UNION
SELECT osm_id, building, way as geom
FROM res_osm_point

















/*   */
