select * from wfbuildings;
-- pkid, osmid, name, wkgeom
-- wkgeom is the geometry column 

select * from wfpoints;
-- wfid, osmid,fclass,name,wkpoints
-- wkpoints is the geometry column here 

select * from wfroads;
-- wkid, osmid, name, wrgeom
-- wrgeom is the geometry of column here in this table. 

-- QUERY 1
-- How may points are in each of the polylines in the wfroads table
SELECT wkid, name, ST_NPoints(wrgeom) as NumPoints, ST_Length(ST_Transform(wrgeom,32630)) as RoadSegLength from wfroads order by RoadSegLength desc;

-- QUERY 2 (with non null name)
-- How may points are in each of the polylines in the wfroads table
SELECT wkid, name, ST_NPoints(wrgeom) as NumPoints, 
ST_Length(ST_Transform(wrgeom,32630)) as RoadSegLength from wfroads 
WHERE (name is not null)
order by RoadSegLength desc;

-- QUERY 3  -- LAB EXAM 3 QUESTION
-- Use a self join to indicate the distances between ALL
-- points in the WFPoints table. 
SELECT A.wfid,A.name,A.osmid,B.Wfid,B.Name,B.osmid, 
ST_Transform(A.wkpoints,32630) <-> ST_Transform(B.wkpoints,32630) as DISTANCE
FROM WFPoints as A, WFPoints as B
WHERE (B.wfid < A.wfid) and (A.wfid != B.wfid)
ORDER BY DISTANCE ASC;


-- QUERY 4 
-- Use a self join to indicate the distances between ALL
-- points in the WFPoints table.
-- remove any rows where the name is null 
SELECT A.wfid,A.name,A.osmid,B.Wfid,B.Name,B.osmid, 
ST_Transform(A.wkpoints,32630) <-> ST_Transform(B.wkpoints,32630) as DISTANCE
FROM WFPoints as A, WFPoints as B
WHERE (B.wfid < A.wfid) and (A.wfid != B.wfid) 
AND (A.name is not null) and (B.name is not null)
ORDER BY DISTANCE ASC;


-- QUERY 5 
-- Use a self join to indicate the distances between ALL
-- buildings in the WFbuildings table.
-- do not include any rows where the name is null 
SELECT A.pkid,A.name,A.osmid,B.pkid,B.Name,B.osmid, 
ST_Transform(A.wkgeom,32630) <-> ST_Transform(B.wkgeom,32630) as DISTANCE
FROM WFBuildings as A, WFBuildings as B
WHERE (B.pkid < A.pkid) and (A.pkid != B.pkid) 
AND (A.name is not null) and (B.name is not null)
ORDER BY DISTANCE ASC;

-- QUERY 6 
-- Use a self join to indicate the distances between ALL
-- buildings in the WFbuildings table.
-- ALLOW rows where the name is null 
SELECT A.pkid,A.name,A.osmid,B.pkid,B.Name,B.osmid, 
ST_Transform(A.wkgeom,32630) <-> ST_Transform(B.wkgeom,32630) as DISTANCE
FROM WFBuildings as A, WFBuildings as B
WHERE (B.pkid < A.pkid) and (A.pkid != B.pkid) 
ORDER BY DISTANCE ASC;

-- QUERY 7 
-- Use a self join to indicate the distances between ALL
-- ROADS in the WFRoads table.
-- ALLOW rows where the name is null - use additional 
-- order clauses if required 
SELECT A.wkid,A.name,A.osmid,B.wkid,B.Name,B.osmid, 
ST_Transform(A.wrgeom,32630) <-> ST_Transform(B.wrgeom,32630) as DISTANCE
FROM WFRoads as A, WFRoads as B
WHERE (B.wkid < A.wkid) and (A.wkid != B.wkid) 
ORDER BY DISTANCE ASC, A.osmid asc ;

-- QUERY 8 

SELECT A.pkid as BuildingPK,A.name,A.osmid,B.wfid as PointPK,B.Name,B.osmid, 
ST_Transform(A.wkgeom,32630) <-> ST_Transform(B.wkpoints,32630) as DISTANCE
FROM WFBuildings as A, WFPoints as B
ORDER BY DISTANCE desc;

-- query 9

SELECT A.pkid,A.name,A.osmid,B.pkid,B.Name,B.osmid, 
ST_Transform(A.wkgeom,32630) <-> ST_Transform(B.wkgeom,32630) as DISTANCE
FROM WFBuildings as A, WFBuildings as B
WHERE (B.pkid < A.pkid) and (A.pkid != B.pkid) and (A.wkgeom && B.wkgeom)
ORDER BY DISTANCE ASC;
Select *
FROM WFBuildings as A, WFBuildings as B
where (A.wkgeom && B.wkgeom) 

-- QUERY 10
-- CREATING A TABLE FROM QUERY OUTPUT
-- In case we need to run this query many times 
DROP TABLE IF EXISTS Week7Query10Output;

CREATE TABLE Week7Query10Output AS

SELECT A.pkid,A.name,A.osmid,ST_Envelope(A.wkgeom) 
FROM WFBuildings as A;

SELECT * from Week7Query10Output;
















