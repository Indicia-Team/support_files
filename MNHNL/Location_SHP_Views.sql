--- where there is no boundary geometry, assume point centroid
DROP VIEW POINT_LOCATIONS;
CREATE OR REPLACE VIEW POINT_LOCATIONS (geom, code, name, location_type, id, location_type_id, website_id) AS
select ST_CollectionExtract(l.boundary_geom, 1), l.code, l.name, ttl.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN detail_termlists_terms ttl on (l.location_type_id = ttl.id and ttl.preferred=true)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'GEOMETRYCOLLECTION'
 AND NOT ST_IsEmpty(ST_CollectionExtract(boundary_geom, 1))
UNION
select l.boundary_geom, l.code, l.name, ttl.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN detail_termlists_terms ttl on (l.location_type_id = ttl.id and ttl.preferred=true)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'MULTIPOINT'
UNION
select ST_MULTI(boundary_geom), l.code, l.name, ttl.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN detail_termlists_terms ttl on (l.location_type_id = ttl.id and ttl.preferred=true)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'POINT'
UNION
select ST_MULTI(centroid_geom), l.code, l.name, ttl.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN detail_termlists_terms ttl on (l.location_type_id = ttl.id and ttl.preferred=true)
 WHERE l.deleted = false
 AND GeometryType(centroid_geom) = 'POINT'
ORDER by name,id
;

DROP VIEW LINE_LOCATIONS;
CREATE OR REPLACE VIEW LINE_LOCATIONS (geom, code, name, location_type, id, location_type_id, website_id) AS
select ST_CollectionExtract(l.boundary_geom, 2), l.code, l.name, ttl.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN detail_termlists_terms ttl on (l.location_type_id = ttl.id and ttl.preferred=true)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'GEOMETRYCOLLECTION'
 AND NOT ST_IsEmpty(ST_CollectionExtract(boundary_geom, 2))
UNION
select l.boundary_geom, l.code, l.name, ttl.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN detail_termlists_terms ttl on (l.location_type_id = ttl.id and ttl.preferred=true)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'MULTILINE'
UNION
select ST_MULTI(boundary_geom), l.code, l.name, ttl.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN detail_termlists_terms ttl on (l.location_type_id = ttl.id and ttl.preferred=true)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'LINE'
ORDER by name,id
;

DROP VIEW POLYGON_LOCATIONS;
CREATE OR REPLACE VIEW POLYGON_LOCATIONS (geom, code, name, location_type, id, location_type_id, website_id) AS
select ST_CollectionExtract(l.boundary_geom, 1), l.code, l.name, ttl.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN detail_termlists_terms ttl on (l.location_type_id = ttl.id and ttl.preferred=true)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'GEOMETRYCOLLECTION'
 AND NOT ST_IsEmpty(ST_CollectionExtract(boundary_geom, 1))
UNION
select l.boundary_geom, l.code, l.name, ttl.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN detail_termlists_terms ttl on (l.location_type_id = ttl.id and ttl.preferred=true)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'MULTIPOLYGON'
UNION
select ST_MULTI(boundary_geom), l.code, l.name, ttl.term, l.id, l.location_type_id, lw.website_id from locations l
 JOIN locations_websites lw ON (l.id = lw.location_id and lw.deleted = false)
 JOIN detail_termlists_terms ttl on (l.location_type_id = ttl.id and ttl.preferred=true)
 WHERE l.deleted = false
 AND GeometryType(boundary_geom) = 'POLYGON'
ORDER by name,id
;