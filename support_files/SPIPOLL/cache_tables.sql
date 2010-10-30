DROP TABLE spipoll_collections_cache;
CREATE TABLE spipoll_collections_cache (
    collection_id integer NOT NULL,
    datedebut date,
    datefin date,
    nom character varying(200),
    habitat_ids text,
    username text,
    flower_id integer NOT NULL,
    flower_type_id integer,
    flower_taxon_ids text,
    taxons_fleur_precise text,
    sky_ids text,
    shade_ids text,
    temp_ids text,
    wind_ids text, 
    insect_taxon_ids text,
    taxons_insecte_precise text,
    image_de_environment character varying(200),
    image_de_la_fleur character varying(200)
) ;

SELECT AddGeometryColumn ('spipoll_collections_cache', 'geom', 900913, 'GEOMETRY', 2);

DROP TABLE spipoll_insects_cache;

CREATE TABLE spipoll_insects_cache (
    insect_id integer NOT NULL,
    collection_id integer NOT NULL,
    datedebut date, 
    datefin date,
    updated date,
    nom character varying(200),
    protocol text,
    srefX text,
    srefY text,
    habitat_ids text,
    habitat text,
    nearest_hive integer,
    username text,
    userid text,
    email text,
    flower_type_id integer,
    flower_type text,
    flower_taxon_ids text,
    status_fleur text,
    flower_taxon text,
    taxons_fleur_precise text,
    date_de_session text,
    starttime text,
    endtime text,
    sky_ids text,
    ciel text,
    shade_ids text,
    fleur_a_lombre text,
    temp_ids text,
    temperature text,
    wind_ids text, 
    vent text, 
    insect_taxon_ids text,
    status_insecte text,
    insect_taxon text,
    taxons_insecte_precise text,
    insect_historical_taxon text,
    notonaflower text,
    number_insect text,
    image_de_environment character varying(200),
    image_de_la_fleur character varying(200),
    image_d_insecte character varying(200)
) ;

SELECT AddGeometryColumn ('spipoll_insects_cache', 'geom', 900913, 'GEOMETRY', 2);
