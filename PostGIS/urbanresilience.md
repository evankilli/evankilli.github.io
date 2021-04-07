---
layout: page
title: Urban Resilience: Access to Medical Care in Dar-es-Salaam
---
## A note: this page is currently incomplete, but will be updated in the near future

## Background

Tanzania's [Resilience Academy](https://resilienceacademy.ac.tz/about-us/) is a partnership between a number of universities in Tanzania alongside Finland's University of Turku. This organization aims to build climate resilience in Tanzania's cities by increasing the amount of climate data available as well as leading community mapping initiatives. One of these initiatives, [Ramani Huria](https://ramanihuria.org/en/), aims to support flood resiliency efforts and urban planning by producing detailed local spatial data through community mapping using OpenStreet map.

## Purpose

The goal of this analysis is to utilize data provided by [the Resilience Academy](https://resilienceacademy.ac.tz/about-us/) and spatial data on [OpenStreetMap](https://www.openstreetmap.org/) provided through [Ramani Huria](https://ramanihuria.org/en/) to assess access to medical care within Dar-es-Salaam. Using database analysis through PostGIS and SQL with the data mentioned above, we are able to analyze Dar-es-Salaam's medical infrastructure on a large scale. As a [rapidly growing city](https://www.nationalgeographic.com/environment/article/tanzanian-city-may-soon-be-one-of-the-worlds-most-populous) in the developing world, it is essential to ensure that residents have sufficient access to medical care, and it is just as important to ensure that such access is equal and that significant gaps of access do not exist within the city.

## Accessing data

### Resilience Academy

Dar-es-Salaam's wards can be found on [the Resilience Academy's web feature service](https://geonode.resilienceacademy.ac.tz/). This can be accessed in QGIS by creating a new connection in WFS - found in the browser - and entering the url https://geonode.resilienceacademy.ac.tz/geoserver/ows when prompted.

INSTRUCTIONS FOR HOW TO LOAD INTO POSTGIS DATABASE ARE INCOMPLETE: The wards can be loaded into a PostGIS database by adding a layer from your new WFS connection to the project, then loading them into

### Open Street Map

Luckily, planet_osm_point and planet_osm_polygon, two layers containing all data currently available within OpenStreetMap were pre-loaded into class PostGIS schemas before class to query, but these [can also be downloaded from OpenStreetMap for open use](https://wiki.openstreetmap.org/wiki/Planet.osm).

## Analysis

The entire script for this analysis is available [here](resilience.sql).

Unfortunately, some issues were encountered when attempting to count residences within a certain radius of clinics, so the analysis of the process used to conduct this project and discussion of results are incomplete.

INSERT MAP OF WARDS WITH CLINICS

### 1) Isolate clinics for analysis

```sql
create table medical_osm_polygon as
select osm_id, building, amenity, name, way
from planet_osm_polygon
where amenity = 'hospital' OR amenity = 'doctors' or amenity = 'clinic'

create table medical_osm_point as
select osm_id, building, amenity, name, way
from planet_osm_point
where amenity = 'hospital' OR amenity = 'doctors' or amenity = 'clinic'
```

### 2) Isolate residences for analysis

```sql
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
```

### 3) Check for where features might have been mapped twice

```sql
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
```

### 4) Consolidate residential and medical points and polygons, create one layer of features for each

```sql
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
```

### 5) Count number of residences in each wards

```sql
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
```

### Additional steps to come; needs editing to produce final analysis

## Discussion

Discussion to come once analysis is complete

## Resources

Resources to come once analysis is complete
