select * from Week4Switzerland

-- STEP 0 - Loading the data 
SELECT name,timestamp, ST_AsText(geom) 
from Week4Switzerland;

-- STEP 1 - consider some of the characteristics of 
-- the polygons in the table

select id, name, ST_Npoints(geom) as n, ST_SRID(geom)
from Week4Switzerland 
ORDER BY n desc;

--STEP 2 - Calculate the area and the PERIMETER of the polygons
-- we need to use ST_Transform - original data in EPSG:4326

Select id, name, ST_Area(ST_Transform(geom,21781))/1000000 as AreaKM2,
ST_Perimeter(ST_Transform(geom,21781))/1000 as LengthKM
from Week4Switzerland;

-- STEP 3 - finding the polygon containing a given POINT. 

select id, name FROM Week4Switzerland 
where 
ST_Distance(ST_Transform(geom,21781),
ST_Transform(St_GeomFromText('POINT(6.629004 46.516584)',4326),21781)) = 0;

-- STEP 4 - using ST_Contains
Select ID, name from Week4Switzerland
where 
ST_Contains(geom,St_GeomFromText('POINT(6.629004 46.516584)',4326));

-- STEP 5 - mixed geometries in ST_Contains
-- LEt's transform the geom column to EPSG:21781
-- Run the query to see the output. 
Select ID, name from Week4Switzerland
where 
ST_Contains(ST_Transform(geom,21781),
St_GeomFromText('POINT(6.629004 46.516584)',4326));

-- STEP 6 
-- Running step 6 again but with the geom column 
-- represented in EPSG:4326 and the WKT POINT Transformed
-- to a different CRS, namely 21781

select id, name FROM Week4Switzerland 
where 
ST_Distance(geom,
ST_Transform(St_GeomFromText('POINT(6.629004 46.516584)',4326),21781)) = 0;

-- STEP 7 Point in Polygon Query
-- We are using a spatial join (using ST_Contains)
-- For convenience and easy reading - we use a rename 
-- of both tables. This is a little trick to make it easier
-- to read our SQL in the queries. 
SELECT Polys.name,Pts.pkid
FROM Week4Switzerland as Polys, Week4SwitzerlandPoints as Pts 
WHERE ST_Contains(Polys.geom,Pts.thegeom)
Order by Polys.name;






