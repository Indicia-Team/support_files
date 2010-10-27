CREATE TABLE spipoll_collections_cache (
    collection_id integer NOT NULL,
    date_start date,
    date_end date,
    location_name character varying(200),
    habitat text,
    cms_username text,
    location_image_path character varying(200),
    flower_id integer NOT NULL,
    flower_type integer,
    flower_taxon text,
    flower_extra_info text,
    flower_image_path character varying(200),
    sky text,
    shade text,
    temp text,
    wind text, 
    insect_taxon text,
    insect_extra_info text
) ;

SELECT AddGeometryColumn ('spipoll_collections_cache', 'geom', 900913, 'GEOMETRY', 2);

CREATE TABLE spipoll_insects_cache (
    insect_id integer NOT NULL,
    collection_id integer NOT NULL,
    date_start date,
    date_end date,
    habitat text,
    cms_username text,
    flower_type integer,
    flower_taxon text,
    flower_extra_info text,
    sky text,
    shade text,
    temp text,
    wind text, 
    insect_taxon text,
    insect_extra_info text,
    insect_image_path character varying(200)
) ;

SELECT AddGeometryColumn ('spipoll_insects_cache', 'geom', 900913, 'GEOMETRY', 2);
