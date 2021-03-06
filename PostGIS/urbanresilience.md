---
layout: page
title: Urban Resilience and Access to Medical Care in Dar-es-Salaam
---

## Background

Tanzania's [Resilience Academy](https://resilienceacademy.ac.tz/about-us/) is a partnership between a number of universities in Tanzania alongside Finland's University of Turku. This organization aims to build climate resilience in Tanzania's cities by increasing the amount of climate data available as well as leading community mapping initiatives. One of these initiatives, [Ramani Huria](https://ramanihuria.org/en/), aims to support flood resiliency efforts and urban planning by producing detailed local spatial data through community mapping using OpenStreet map.

## Purpose

The goal of this analysis is to utilize data provided by [the Resilience Academy](https://resilienceacademy.ac.tz/about-us/) and spatial data on [OpenStreetMap](https://www.openstreetmap.org/) provided through [Ramani Huria](https://ramanihuria.org/en/) to assess access to medical care within Dar-es-Salaam. Using database analysis through PostGIS and SQL with the data mentioned above, we are able to analyze Dar-es-Salaam's medical infrastructure on a large scale. As a [rapidly growing city](https://www.nationalgeographic.com/environment/article/tanzanian-city-may-soon-be-one-of-the-worlds-most-populous) in the developing world, it is essential to ensure that residents have sufficient access to medical care, and it is just as important to ensure that such access is equal and that significant gaps of access do not exist within the city.

## Accessing data

### Resilience Academy

Dar-es-Salaam's wards can be found on [the Resilience Academy's web feature service](https://geonode.resilienceacademy.ac.tz/). This can be accessed in QGIS by creating a new connection in WFS - found in the browser - and entering the url https://geonode.resilienceacademy.ac.tz/geoserver/ows when prompted.

Once a connection is estabished, the Resilience Academy's layers can be imported into projects in QGIS through the Database Manager tool.

### Open Street Map

Luckily, planet_osm_point and planet_osm_polygon, two layers containing all data currently available within OpenStreetMap were pre-loaded into class PostGIS schemas before class to query, but these [can also be publicly accessed](https://wiki.openstreetmap.org/wiki/Planet.osm) and queried using tools like osm2pgsql, as featured in [similar analyses](https://derrickburt.github.io/opengis/sql/DSlab/DSLAB.html).

## Analysis

The entire script for this analysis is available [here](resilience.sql).

This workflow was modeled in part by the work of Derrick Burt and his similar analysis of access to public transportation in Dar-es-Salaam, also using OpenStreetMap and Resilience Academy data. His analysis is linked [here](https://derrickburt.github.io/opengis/sql/DSlab/DSLAB.html)

<p align="center">
 <img height="600" src="wards_w_hosp.png">
  </p>

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

### 6) Count number of residences within 1mi of medical care
```sql
SELECT addgeometrycolumn('evan','res_union','utmgeom',32737,'POINT',2);
UPDATE res_union
SET utmgeom = ST_Transform(geom, 32737);
--prepare residences for analysis

SELECT addgeometrycolumn('evan','med_union','utmgeom',32737,'POINT',2);
UPDATE med_union
SET utmgeom = ST_Transform(geom, 32737);
-- prepare clinics for Analysis

SELECT addgeometrycolumn('evan','wards_w_res_cnt','utmgeom',32737,'POLYGON',2);
UPDATE wards_w_res_cnt
SET utmgeom = ST_Transform(geom, 32737);
-- prepare wards for analysis


ALTER TABLE res_union ADD COLUMN res_access INTEGER;
-- add access to residential table

UPDATE res_union
SET res_access = 1
FROM med_union
WHERE ST_DWITHIN(res_union.utmgeom, med_union.utmgeom, 1609.34);
-- make access equal one when residence is within 1mi/1609.34m of a clinic

select *
from res_union
where res_access is null
limit 1000;
-- lets check

CREATE TABLE res_within_clinic AS
SELECT *
FROM res_union
WHERE res_access = 1
-- create a table with only the residences within buffer for counting
```

### 7) Join the residences with access to medical care to the wards, count them, calculate percentage, and tidy it up!

```sql
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
    wards_w_res_cnt.geom as geom
    from wards_w_res_cnt
    full outer join wards_w_access
    on wards_w_res_cnt.fid = wards_w_access.fid
-- join the wards with number with access to the table with the names, total count, and geom

update wards_final
  set access_count = 0
  where access_count is null
-- make it 0 instead of null so that we can calculate cleanly

ALTER TABLE wards_final
ADD COLUMN pct_access float(8);
UPDATE wards_final
SET pct_access = access_count*1.0/total_count*1.0
-- calculate percentage

delete from med_union
where name = 'Hospitali ya Wilaya Muranga' or  name = 'KEREGE Dispensary' or  name = 'Kisarawe Hospital'
--get rid of hospitals that somehow ended up outside of DES so it looks pretty
```

<p align="center">
  <img height="600" src="resilience.png">
  </p>


## Discussion

Somewhat unsurprisingly, it's immediately apparent from the map produced by this analysis that clinics and other care points for medical care - here defined as what has been marked as a hospital, doctor, or clinic in OpenStreetMap - are heavily clustered in the central areas of Dar-es-Salaam. While medical care certainly exists outside this area, points of care are few and far between, limiting access in many areas of the city, with points of care being especially sparse in the East/Southeast of the city. Even in some areas closer to the city center, like the lighter areas directly to its southwest, access seems to be lacking. The northern ward, closest to the city center of these conspicuously light wards, contains the Port of Dar Es Salaam and few residences, somewhat accounting for the lack of medical care in this area; if there is little population, there is little imperative to provide medical care. The district directly south near an inlet in the river, however, seems to be largely residential, gauging from information available on OpenStreetMap and imaging from Google Map's satellite view, but comprised largely of informal settlements. With local conditions put into context, this analysis could provide valuable insight regarding gaps in medical care coverage, especially as public transit access remains low in many of the wards with little access to care, as demonstrated by [Derrick Burt](https://derrickburt.github.io/opengis/sql/DSlab/DSLAB.html).

It should be noted, however, that this near absence of care in the southeast, south, and northwest of the city could be a function of two important issues. First, important disparities exist in access to healthcare in Tanzania. While primarily an urban-rural divide, even within urbanized areas, stark differences in access occur, and "clustering" of healthcare - wherein resources are collected largely in certain areas while others lack such resources - is found across the country.

Secondly, a lack of sufficient data may be occurring, an issue noted by Derrick. While the work of Resilience Academy and their Ramani Huria project is admirable, the wholescale mapping of an entire metropolitan area by volunteers is a daunting task, and holes are certain to form. Due to the density of people and resources towards the center of the city, as naturally occurs in most metropolitan regions, these areas are much more likely to have been comprehensively mapped and had data gathered across them, and as such, areas towards the periphery are both less likely to have comprehensive data under projects like Ramani Huria, and also less likely to have resources like medical care available to them, an unfortunate correlation.


## Resources

[National Geographic article about Dar-es-Salaam's rapid growth](https://www.nationalgeographic.com/environment/article/tanzanian-city-may-soon-be-one-of-the-worlds-most-populous)
[Report on healthcare disparities in Tanzania](http://africainequalities.org/wp-content/uploads/2016/07/Health-inequality-and-Equity-in-Tanzania.pdf)
[Resilience Academy](https://resilienceacademy.ac.tz/about-us/)
[Resilience Academy's web feature service](https://geonode.resilienceacademy.ac.tz/)
[Ramani Huria project](https://ramanihuria.org/en/)
[Open Street Map](https://www.openstreetmap.org/)
[Derrick Burt's](https://derrickburt.github.io/opengis/sql/DSlab/DSLAB.html)analysis of public transportation access using some of the same sources and data, also including some guidance on querying OSM features in PostGIS/SQL
