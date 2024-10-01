-- Water Quality Visualisation -- 
-- Concatenating the 3 catchments into a single table —-

CREATE TABLE catchmentsTable AS
SELECT *
FROM wq_liffey10
WHERE parametername IN ('Nitrate (as N)', 'ortho-Phosphate (as P) - unspecified', 'Ammonia-Total (as N)', 'Dissolved Organic Carbon', 'Dissolved Oxygen', 'Total Oxidised Nitrogen (as N)', 'pH')
UNION
SELECT *
FROM wq_liffey20
WHERE parametername IN ('Nitrate (as N)', 'ortho-Phosphate (as P) - unspecified', 'Ammonia-Total (as N)', 'Dissolved Organic Carbon', 'Dissolved Oxygen', 'Total Oxidised Nitrogen (as N)', 'pH')
UNION
SELECT *
FROM wq_kings20
WHERE parametername IN ('Nitrate (as N)', 'ortho-Phosphate (as P) - unspecified', 'Ammonia-Total (as N)', 'Dissolved Organic Carbon', 'Dissolved Oxygen', 'Total Oxidised Nitrogen (as N)', 'pH')



-- Adding geolocation to chemistry data —-

alter table catchmentstable
add column wkb_geometry geometry
update catchmentstable
set wkb_geometry = monstations_sql.wkb_geometry
from monstations_sql
where monstations_sql.stationid = catchmentstable.monitoringstationcode


-- Adding Phosphate —-


alter table catchmentstable
add column phosphate DOUBLE PRECISION
UPDATE catchmentstable
SET phosphate = CASE
WHEN result = '' THEN NULL
ELSE CAST(result AS DOUBLE PRECISION) END::DOUBLE PRECISION;

update catchmentstable
set phosphate = null
where parametername != ('ortho-Phosphate (as P) - unspecified')


-- Adding Ammonia —-


alter table catchmentstable
add column ammonia DOUBLE PRECISION
UPDATE catchmentstable
SET ammonia = CASE
WHEN result = '' THEN NULL
ELSE CAST(result AS DOUBLE PRECISION) END::DOUBLE PRECISION;
update catchmentstable
set ammonia = null
where parametername != ('Ammonia-Total (as N)')
select * from monstations_sql select * from catchmentstable


-- Adding Total Oxidised Nitrogen —-


alter table catchmentstable
add column Ox_Nitrogen DOUBLE PRECISION
UPDATE catchmentstable
SET Ox_Nitrogen = CASE
WHEN result = '' THEN NULL
ELSE CAST(result AS DOUBLE PRECISION) END::DOUBLE PRECISION;
update catchmentstable
set Ox_Nitrogen = null
where parametername != ('Total Oxidised Nitrogen (as N)')


-- Creating averages between time periods --


select AVG(phosphate) as Average_phosphate, monitoringstationname, wkb_geometry from catchmentstable
where
(date_part ('month', date) > '09' and date_part ('month', date) <= '12')
and date_part('year', date) = '2020' and phosphate is not null and wkb_geometry is not null
group by monitoringstationname, monitoringstationname, wkb_geometry