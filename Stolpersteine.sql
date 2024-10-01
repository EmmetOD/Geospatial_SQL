-- TABLES USED -- 

select * from stolpersteine_972 -- Original Dataset which contained addresses and deportation info

select * from stones -- Geo-referenced table which contained only unique ID and geometry information

Select * from Step_Stones -- Joined historical geo-referenced TABLE

select * from berlin_places -- OSM download containing district polygons of Berlin




--- DATA Wrangling -- 


-- wkb geometry was presest after SQL Dump in un-georefernced table but didn't contain accurate locations 
-- Droped Geometry in original table too allow for Join
alter table  stolpersteine_972
drop wkb_geometry


-- Create new table of original plus geometry information
Drop table if exists Step_Stones

CREATE TABLE Step_Stones AS 
select stolpersteine_972.*, stones.wkb_geometry
from stolpersteine_972

Join stones ON stones.ogc_fid = stolpersteine_972.ogc_fid

-- Testing New Table *4953 Rows returned 
select *,  ST_SRID(wkb_geometry) from Step_Stones





--Aggregate Queries to establish density per house, neigherbourhood and query deportation locations -- 


-- Creating count of addresses and display in ascending order 
SELECT address, COUNT(*) as countaddress
FROM Step_Stones
GROUP BY address
HAVING COUNT(*) >= 1
order by countaddress desc 

--Querying Neighbourhood density
SELECT neighbourhood, COUNT(*) as countneighbourhood
FROM Step_Stones
GROUP BY neighbourhood
HAVING COUNT(*) >= 1
order by countneighbourhood desc 


-- Querying Deportation Destinations - 
-- Not displayed in Presentation but Auschwitz was highest (1655) with Theresienstadt 2nd (1199)
SELECT deportationarea, COUNT(*) as Number_of_people
FROM Step_Stones
GROUP BY deportationarea
HAVING COUNT(*) >= 1
order by Number_of_people desc 








-- TIMELINE Data Wrangling -- 

-- Establishing data left out due to missing records important 
select * from Step_Stones -- 829 Rows
where

datedeportation1 is null



-- Dates are saved as a stringt type so we'll need to convert the column to a date type 
ALTER TABLE Step_Stones
ADD COLUMN Date_Deport_New DATE 

-- Update the new column with the converted dates
UPDATE Step_Stones
SET Date_Deport_New = TO_DATE(datedeportation1, 'DD/MM/YYYY')

-- Checking if any dates are not in correct format
select datedeportation1, * from Step_Stones
where not
datedeportation1 ~ '^\d{2}/\d{2}/\d{4}$';








-- Additional TABLE of BERLIN from OSM incorporated 


----- Check out TABLE of Berlin Places from OSM 
select ogc_fid, fclass, name from berlin_places




--City entry of Berlin total is not required OGC_FID = 109 

delete from berlin_places 
where ogc_fid = 109 


--- Add new row to house information on amount of deportations per area 

ALTER TABLE berlin_places
ADD COLUMN DeportPerQuarter INT 


-- Show columns - deportperquarter will be null until update function is passed through 

select ogc_fid, fclass, DeportPerQuarter, name from berlin_places 
order by deportperquarter desc


-- Point in polygon function to find 
-- and then update amount of deportations per area into new column 

with deportQuery as 
	( 
		select B.ogc_fid, name, count(*) as DeportPerArea
		from berlin_places as B, Step_Stones as S 
		where ST_Contains(B.wkb_geometry, S.wkb_geometry)
		group by B.ogc_fid	

	)	
	
	update berlin_places 
	set DeportPerQuarter = deportQuery.DeportPerArea + COALESCE(DeportPerQuarter, 0) -- Coalesce is needed as column wont update across null values 
	from deportQuery 
	where deportQuery.ogc_fid = berlin_places.ogc_fid
	
	
	
	
	
--Final update to treat zero deportations per area with 0 instead of null 
Update berlin_places 
set DeportPerQuarter = 0 
where DeportPerQuarter is null 





