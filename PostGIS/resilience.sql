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

----------------------------------------------------------------------------------------------------

/* 7 count number of residences in each ward */
create table res_wards as
  select
  res_union.building as building,
  res_union.osm_id as osm_id,
  res_union.geom as point_geom,
  wards.fid as fid
  from res_union
  join wards
  on st_intersects(wards.geom, res_union.geom)
  -- creating a table that joins ward id to each residence points

 create table resward_cnt as
   select fid, count(osm_id)
   from res_wards
   group by fid
  -- creating a table that groups and counts residences in each ward

create table wards_w_res_cnt as
  select
  resward_cnt.count as count
  resward_cnt.fid as fid
  wards.ward_name as ward_name
  wards.geom as geom
  from resward_cnt
  inner join wards
  on resward_cnt.fid = wards.fid
-- joining resward_cnt w ward geometries to get a map of wards with counts of residences

--------------------------------------------------------------------------------
/* 8 count how many residences are within 1mi of a clinic */
-- WHY ISNT THIS WORKING

ALTER TABLE res_union ADD COLUMN res_access INTEGER;
-- add access to residential table

UPDATE res_union
SET res_access = 1
FROM med_union
WHERE ST_DWITHIN(res_union.geom, med_union.geom, 1609.34)
-- make access equal one when residence is within 1mi/1609.34m of a clinic



CREATE TABLE res_within_clinic AS
SELECT *
FROM res_union
WHERE res_access = 1
-- table with only residences within buffer

--------------------------------------------------------------------------------

/* 9 join residential points within buffer zone to wards with count, count total
number of residences within buffer, and calc percentage */

create table wards_w_access as
  select
  a.fid, count(b.res_access) as med_access
  from wards_w_res_cnt a
  join res_within_clinic b
  on st_intersects(a.geom, b.geom)
  group by a.fid
-- count residences with access in each ward

create table wards_final as
    select
    wards_w_res_cnt.fid as fid,
    wards_w_res_cnt.ward_name as name,
    wards_w_res_cnt.count as total_count,
    wards_w_access.med_access as access_count,
    wards.geom as geom
    from wards_w_res_cnt
    inner join wards_w_access
    on wards_w_res_cnt.fid = wards_w_access.fid
-- join the wards with number with access to the table with the names,
-- total count, and geom

ALTER TABLE wards_final
ADD COLUMN pct_access real;
UPDATE wards_final
SET pct_access = (access_count/total_count)*100
-- calculate percentage




------------------- scratch work (mostly from figuring out how to calculate residences within wards) ----------------------------------------------------------------
select osm_id, count(res_union.geom)
FROM
  (from
    select res_union.*, wards.fid as fid
    re_union inner join wards
    on st_within(res_union.geom, wards.geom)) as a

    CREATE TABLE wards_join AS
    SELECT
    wards.fid as fid, wards.ward_name as ward_name, wards.geom as geom1,
    COUNT(osm_id) as total_ct
    FROM wards
    JOIN res_union
    ON ST_Intersects(wards.geom, res_union.geom)
    GROUP BY wards.fid, wards.ward_name

    create table wards_join as
      select fid as fid, ward_name as ward_name, geom as geom 1
      from wards

    select *
    from wards_join
    full outer join res_union
    on ST_Intersects (wards.geom, res_union.geom)
    group by fid

    update res_union
      add column fid
















/*   */
