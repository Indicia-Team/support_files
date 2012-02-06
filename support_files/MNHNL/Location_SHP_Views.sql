DROP VIEW POINT_LOCATIONS;
CREATE OR REPLACE VIEW POINT_LOCATIONS (id, location_type_id, name, code, geom) AS
select id, location_type_id, name, code, ST_CollectionExtract(boundary_geom, 1) from locations
WHERE GeometryType(boundary_geom) = 'GEOMETRYCOLLECTION'
AND NOT ST_IsEmpty(ST_CollectionExtract(boundary_geom, 1))
UNION
select id, location_type_id, name, code, boundary_geom from locations
WHERE GeometryType(boundary_geom) = 'MULTIPOINT'
UNION
select id, location_type_id, name, code, ST_MULTI(boundary_geom) from locations
WHERE GeometryType(boundary_geom) = 'POINT'
ORDER by id
;

DROP VIEW LINE_LOCATIONS;
CREATE OR REPLACE VIEW LINE_LOCATIONS (id, location_type_id, name, code, geom) AS
select id, location_type_id, name, code, ST_CollectionExtract(boundary_geom, 2) from locations
WHERE GeometryType(boundary_geom) = 'GEOMETRYCOLLECTION'
AND NOT ST_IsEmpty(ST_CollectionExtract(boundary_geom, 2))
UNION
select id, location_type_id, name, code, boundary_geom from locations
WHERE GeometryType(boundary_geom) = 'MULTILINE'
UNION
select id, location_type_id, name, code, ST_MULTI(boundary_geom) from locations
WHERE GeometryType(boundary_geom) = 'LINE'
ORDER by id
;

DROP VIEW POLYGON_LOCATIONS;
CREATE OR REPLACE VIEW POLYGON_LOCATIONS (id, location_type_id, name, code, geom) AS
select id, location_type_id, name, code, ST_CollectionExtract(boundary_geom, 3) from locations
WHERE GeometryType(boundary_geom) = 'GEOMETRYCOLLECTION'
AND NOT ST_IsEmpty(ST_CollectionExtract(boundary_geom, 3))
UNION
select id, location_type_id, name, code, boundary_geom from locations
WHERE GeometryType(boundary_geom) = 'MULTIPOLYGON'
UNION
select id, location_type_id, name, code, boundary_geom from locations
WHERE GeometryType(boundary_geom) = 'POLYGON'
ORDER by id
;