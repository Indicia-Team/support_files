--- where there is no boundary geometry, assume point centroid
--- These views are used to download shapefiles for the locations. 
--- Shape files have restrictions (ie only one type of object per file), so we need to split up points, polygons and lines.
--- Convert single points etc to multi versions, so multi and singles are output in same file.

DROP VIEW POINT_LOCATIONS;
CREATE OR REPLACE VIEW POINT_LOCATIONS (geom, code, name, location_type, id, location_type_id, website_id) AS
select ST_CollectionExtract(l.boundary_geom, 1), l.code, l.name, t.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN termlists_terms tlt ON (l.location_type_id = tlt.id and tlt.preferred=true AND tlt.deleted = false)
 JOIN terms t ON (t.id = tlt.term_id AND t.deleted = false)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'GEOMETRYCOLLECTION'
 AND NOT ST_IsEmpty(ST_CollectionExtract(boundary_geom, 1))
UNION
select l.boundary_geom, l.code, l.name, t.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN termlists_terms tlt ON (l.location_type_id = tlt.id and tlt.preferred=true AND tlt.deleted = false)
 JOIN terms t ON (t.id = tlt.term_id AND t.deleted = false)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'MULTIPOINT'
UNION
select ST_MULTI(boundary_geom), l.code, l.name, t.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN termlists_terms tlt ON (l.location_type_id = tlt.id and tlt.preferred=true AND tlt.deleted = false)
 JOIN terms t ON (t.id = tlt.term_id AND t.deleted = false)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'POINT'
UNION
select ST_MULTI(centroid_geom), l.code, l.name, t.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN termlists_terms tlt ON (l.location_type_id = tlt.id and tlt.preferred=true AND tlt.deleted = false)
 JOIN terms t ON (t.id = tlt.term_id AND t.deleted = false)
 WHERE l.deleted = false and l.boundary_geom is null
 AND GeometryType(centroid_geom) = 'POINT'
ORDER by name,id
;

DROP VIEW LINE_LOCATIONS;
CREATE OR REPLACE VIEW LINE_LOCATIONS (geom, code, name, location_type, id, location_type_id, website_id) AS
select ST_CollectionExtract(l.boundary_geom, 2), l.code, l.name, t.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN termlists_terms tlt ON (l.location_type_id = tlt.id and tlt.preferred=true AND tlt.deleted = false)
 JOIN terms t ON (t.id = tlt.term_id AND t.deleted = false)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'GEOMETRYCOLLECTION'
 AND NOT ST_IsEmpty(ST_CollectionExtract(boundary_geom, 2))
UNION
select l.boundary_geom, l.code, l.name, t.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN termlists_terms tlt ON (l.location_type_id = tlt.id and tlt.preferred=true AND tlt.deleted = false)
 JOIN terms t ON (t.id = tlt.term_id AND t.deleted = false)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'MULTILINESTRING'
UNION
select ST_MULTI(boundary_geom), l.code, l.name, t.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN termlists_terms tlt ON (l.location_type_id = tlt.id and tlt.preferred=true AND tlt.deleted = false)
 JOIN terms t ON (t.id = tlt.term_id AND t.deleted = false)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'LINESTRING'
ORDER by name,id
;

DROP VIEW POLYGON_LOCATIONS;
CREATE OR REPLACE VIEW POLYGON_LOCATIONS (geom, code, name, location_type, id, location_type_id, website_id) AS
select ST_CollectionExtract(l.boundary_geom, 1), l.code, l.name, t.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN termlists_terms tlt ON (l.location_type_id = tlt.id and tlt.preferred=true AND tlt.deleted = false)
 JOIN terms t ON (t.id = tlt.term_id AND t.deleted = false)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'GEOMETRYCOLLECTION'
 AND NOT ST_IsEmpty(ST_CollectionExtract(boundary_geom, 1))
UNION
select l.boundary_geom, l.code, l.name, t.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN termlists_terms tlt ON (l.location_type_id = tlt.id and tlt.preferred=true AND tlt.deleted = false)
 JOIN terms t ON (t.id = tlt.term_id AND t.deleted = false)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'MULTIPOLYGON'
UNION
select ST_MULTI(boundary_geom), l.code, l.name, t.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN termlists_terms tlt ON (l.location_type_id = tlt.id and tlt.preferred=true AND tlt.deleted = false)
 JOIN terms t ON (t.id = tlt.term_id AND t.deleted = false)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'POLYGON'
ORDER by name,id
;