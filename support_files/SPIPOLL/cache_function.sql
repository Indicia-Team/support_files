
CREATE OR REPLACE FUNCTION build_spipoll_cache(arg_survey_id integer) RETURNS integer AS $$
DECLARE
	-- following should be updated to reflect values in Database
	protocol_attr_id	integer := 33;
	closed_attr_id		integer := 30;
	cms_userid_attr_id	integer := 18;
	cms_username_attr_id	integer := 19;
	flower_type_attr_id		integer := 16;
	habitat_attr_id		integer := 3;
	hive_attr_id		integer := 2;
	email_attr_id		integer := 8;
	start_time_attr_id		integer := 28;
	end_time_attr_id		integer := 29;
	sky_attr_id		integer := 34;
	shade_attr_id		integer := 35;
	temp_attr_id		integer := 36;
	wind_attr_id		integer := 37;
	--- END
	---
	collectionrow	samples%ROWTYPE;
	count	integer;
	old_id	integer;
	rowsampleattributevalue sample_attribute_values%ROWTYPE;
	curlocation refcursor;
	rowlocation locations%ROWTYPE;
	rowlocationattributevalue	location_attribute_values%ROWTYPE;
	curlocationimage refcursor;
	rowlocationimage location_images%ROWTYPE;
	curflower refcursor;
	rowflower occurrences%ROWTYPE;
	curdetermination refcursor;
	rowdetermination determinations%ROWTYPE;
	curflowerimage refcursor;
	rowflowerimage occurrence_images%ROWTYPE;
	rowoccurrenceattributevalue	occurrence_attribute_values%ROWTYPE;
	rowsession		samples%ROWTYPE;
	rowinsect	occurrences%ROWTYPE;
	curinsectdetermination refcursor;
	rowinsectdetermination determinations%ROWTYPE;
	curinsectimage refcursor;
	rowinsectimage occurrence_images%ROWTYPE;
	status				integer;
BEGIN
	count := 0;
	old_id := -1;
	-- This will be handled as a single transaction, so can delete everything here then rebuild it.
	DELETE FROM spipoll_collections_cache ;
	DELETE FROM spipoll_insects_cache ;
	
	FOR collectionrow IN SELECT * FROM samples
	WHERE parent_id IS NULL AND deleted = false AND survey_id = arg_survey_id ORDER by id
	LOOP
	  DECLARE
	  	cacherow	spipoll_collections_cache%ROWTYPE;
	  BEGIN
		status := 2; -- 0 is open, 1 is closed, 2 is don't know
		cacherow.collection_id := collectionrow.id;
		cacherow.date_start := collectionrow.date_start;
		cacherow.date_end := collectionrow.date_end;
		OPEN curlocation FOR SELECT * FROM locations WHERE id = collectionrow.location_id AND deleted = false ORDER BY id DESC;
		FETCH curlocation INTO rowlocation;
		IF FOUND THEN
			cacherow.location_name := rowlocation.name;
			cacherow.geom := rowlocation.centroid_geom;
			FOR rowlocationattributevalue IN SELECT * FROM location_attribute_values WHERE location_id = rowlocation.id AND deleted = false ORDER BY id desc
			LOOP
				CASE rowlocationattributevalue.location_attribute_id
					WHEN habitat_attr_id THEN --- multiple values separated by |
						IF cacherow.habitat IS NULL THEN
							cacherow.habitat := '|' || rowlocationattributevalue.int_value || '|';
						ELSE
							cacherow.habitat := cacherow.habitat || rowlocationattributevalue.int_value || '|';
						END IF;
					WHEN hive_attr_id THEN	--- ignore
					ELSE
						RAISE WARNING 'Unrecognised Location Attribute, Location ID --> %, LA ID --> % in LAV ID --> %: ignored', rowlocation.id, rowlocationattributevalue.location_attribute_id, rowlocationattributevalue.id ;
				END CASE;
			END LOOP;
			--- Before we check the location image etc, we need to retrieve the collection attribute: proceed only if closed.
			FOR rowsampleattributevalue IN SELECT * FROM sample_attribute_values WHERE sample_id = collectionrow.id AND deleted = false ORDER BY id desc
			LOOP
				CASE rowsampleattributevalue.sample_attribute_id
					WHEN closed_attr_id THEN
						IF status = 2 THEN
							status := rowsampleattributevalue.int_value;
						ELSE
							RAISE WARNING 'Multiple Closed Attributes for Collection ID --> %, ignored Attr ID --> %', collectionrow.id, rowsampleattributevalue.id ;
						END IF;
					WHEN cms_username_attr_id THEN
						IF cacherow.cms_username IS NULL THEN
							cacherow.cms_username = rowsampleattributevalue.text_value;
						ELSE
							RAISE WARNING 'Multiple Username Attributes for Collection ID --> %, ignored Attr ID --> %', collectionrow.id, rowsampleattributevalue.id ;
						END IF;
					WHEN protocol_attr_id, email_attr_id, cms_userid_attr_id THEN	--- ignore;
					ELSE
						RAISE WARNING 'Unrecognised Collection Attribute, Collection ID --> %, SA ID --> % in SAV ID --> %: ignored', collectionrow.id, rowsampleattributevalue.sample_attribute_id, rowsampleattributevalue.id ;
				END CASE;
			END LOOP;
			CASE status
				WHEN 1 THEN
					OPEN curlocationimage FOR SELECT * FROM location_images WHERE location_id = rowlocation.id AND deleted = false ORDER BY id DESC;
					FETCH curlocationimage INTO rowlocationimage;
					IF FOUND THEN
						cacherow.location_image_path = rowlocationimage.path;
						FETCH curlocationimage INTO rowlocationimage;
						IF FOUND THEN
							RAISE WARNING 'Multiple Locations Images on Location ID --> %, only most recent location used, ignoring ID --> %', rowlocation.id, rowlocationimage.id ;
						END IF;
						OPEN curflower FOR SELECT * FROM occurrences WHERE sample_id = collectionrow.id AND deleted = false ORDER BY id DESC;
						FETCH curflower INTO rowflower;
						IF FOUND THEN
							cacherow.flower_id = rowflower.id;
							FOR rowoccurrenceattributevalue IN SELECT * FROM occurrence_attribute_values WHERE occurrence_id = rowflower.id AND deleted = false ORDER BY id desc
							LOOP
								CASE rowoccurrenceattributevalue.occurrence_attribute_id
									WHEN flower_type_attr_id THEN
										cacherow.flower_type = rowoccurrenceattributevalue.int_value;
									ELSE
										RAISE WARNING 'Unrecognised Flower Attribute, Flower ID --> %, OA ID --> % in OAV ID --> %: ignored', rowflower.id, rowoccurrenceattributevalue.occurrence_attribute_id, rowoccurrenceattributevalue.id ;
								END CASE;
							END LOOP;
							OPEN curdetermination FOR SELECT * FROM determinations WHERE occurrence_id = rowflower.id AND deleted = false ORDER BY id desc;
							FETCH curdetermination INTO rowdetermination;
							IF FOUND THEN
								--- flower treated slightly differently to insect - there most always be only one flower and it must have an identification
								IF rowdetermination.taxa_taxon_list_id IS NOT NULL THEN
									cacherow.flower_taxon := '|'||rowdetermination.taxa_taxon_list_id||'|';
								ELSE
									cacherow.flower_taxon := ARRAY(select '|'||unnest(rowdetermination.taxa_taxon_list_id_list)::text||'|')::text;
								END IF;
								cacherow.flower_extra_info := rowdetermination.taxon_extra_info;
								OPEN curflowerimage FOR SELECT * FROM occurrence_images WHERE occurrence_id = rowflower.id AND deleted = false ORDER BY id DESC;
								FETCH curflowerimage INTO rowflowerimage;
								IF FOUND THEN
									cacherow.flower_image_path = rowflowerimage.path;
									FETCH curflowerimage INTO rowflowerimage;
									IF FOUND THEN
										RAISE WARNING 'Multiple Flower Images on Flower ID --> %, only most recent image used, ignoring ID --> %', rowflower.id, rowflowerimage.id ;
									END IF;
									FOR rowsession IN SELECT * FROM samples WHERE parent_id = collectionrow.id AND deleted = false
									LOOP
										--- multiple sessions mean multiple values in collection.
										FOR rowsampleattributevalue IN SELECT * FROM sample_attribute_values WHERE sample_id = rowsession.id AND deleted = false ORDER BY id desc
										LOOP
											CASE rowsampleattributevalue.sample_attribute_id
												WHEN sky_attr_id THEN
													IF cacherow.sky IS NULL THEN
														cacherow.sky := '|' || rowsampleattributevalue.int_value || '|';
													ELSE
														cacherow.sky := cacherow.sky || rowsampleattributevalue.int_value || '|';
													END IF;
												WHEN shade_attr_id THEN
													IF cacherow.shade IS NULL THEN
														cacherow.shade := '|' || rowsampleattributevalue.int_value || '|';
													ELSE
														cacherow.shade := cacherow.shade || rowsampleattributevalue.int_value || '|';
													END IF;
												WHEN temp_attr_id THEN
													IF cacherow.temp IS NULL THEN
														cacherow.temp := '|' || rowsampleattributevalue.int_value || '|';
													ELSE
														cacherow.temp := cacherow.temp || rowsampleattributevalue.int_value || '|';
													END IF;
												WHEN wind_attr_id THEN
													IF cacherow.wind IS NULL THEN
														cacherow.wind := '|' || rowsampleattributevalue.int_value || '|';
													ELSE
														cacherow.wind := cacherow.wind || rowsampleattributevalue.int_value || '|';
													END IF;
												WHEN start_time_attr_id, end_time_attr_id THEN	--- ignore;
												ELSE
													RAISE WARNING 'Unrecognised Session Attribute, Session ID --> %, SA ID --> % in SAV ID --> %: ignored', rowsession.id, rowsampleattributevalue.sample_attribute_id, rowsampleattributevalue.id ;
											END CASE;
										END LOOP;
										FOR rowinsect IN SELECT * FROM occurrences WHERE sample_id = rowsession.id AND deleted = false
										LOOP
										  DECLARE
											cacheinsectrow	spipoll_insects_cache%ROWTYPE;
										  BEGIN
											cacheinsectrow.insect_id := rowinsect.id;
											cacheinsectrow.collection_id := cacherow.collection_id;
											cacheinsectrow.date_start := cacherow.date_start;
											cacheinsectrow.date_end := cacherow.date_end;
											cacheinsectrow.habitat := cacherow.habitat;
											cacheinsectrow.cms_username := cacherow.cms_username;
											cacheinsectrow.flower_type := cacherow.flower_type;
											cacheinsectrow.flower_taxon := cacherow.flower_taxon;
											cacheinsectrow.flower_extra_info := cacherow.flower_extra_info;
											cacheinsectrow.sky := cacherow.sky;
											cacheinsectrow.shade := cacherow.shade;
											cacheinsectrow.temp := cacherow.temp;
											cacheinsectrow.wind := cacherow.wind;
											cacheinsectrow.geom := cacherow.geom;
											OPEN curinsectdetermination FOR SELECT * FROM determinations WHERE occurrence_id = rowinsect.id AND deleted = false ORDER BY id desc;
											FETCH curinsectdetermination INTO rowinsectdetermination;
											IF FOUND THEN
												IF rowinsectdetermination.taxa_taxon_list_id IS NOT NULL THEN
													cacheinsectrow.insect_taxon := '|'||rowinsectdetermination.taxa_taxon_list_id||'|';
												ELSE
													cacheinsectrow.insect_taxon := ARRAY(select '|'||unnest(rowinsectdetermination.taxa_taxon_list_id_list)::text||'|')::text;
												END IF;
												IF cacherow.insect_taxon IS NULL THEN
													cacherow.insect_taxon := cacheinsectrow.insect_taxon;
												ELSE
													cacherow.insect_taxon := cacherow.insect_taxon||cacheinsectrow.insect_taxon;
												END IF;
												cacheinsectrow.insect_extra_info := rowinsectdetermination.taxon_extra_info;
												IF cacherow.insect_extra_info IS NULL THEN
													cacherow.insect_extra_info := '|' || rowinsectdetermination.taxon_extra_info || '|';
												ELSE
													cacherow.insect_extra_info := cacherow.insect_extra_info || rowinsectdetermination.taxon_extra_info || '|';
												END IF;
												OPEN curinsectimage FOR SELECT * FROM occurrence_images WHERE occurrence_id = rowinsect.id AND deleted = false ORDER BY id DESC;
												FETCH curinsectimage INTO rowinsectimage;
												IF FOUND THEN
													cacheinsectrow.insect_image_path = rowinsectimage.path;
													FETCH curinsectimage INTO rowinsectimage;
													IF FOUND THEN
														RAISE WARNING 'Multiple Insect Images on Insect ID --> %, only most recent image used, ignoring ID --> %', rowinsect.id, rowinsectimage.id ;
													END IF;
													--- RAISE WARNING '%', cacheinsectrow;
													---------------------------------
													INSERT INTO spipoll_insects_cache SELECT cacheinsectrow.*;
													---------------------------------
												END IF;
												CLOSE curinsectimage;
											END IF; --- could be flagged to be identified later 
											CLOSE curinsectdetermination;
										  END;
										END LOOP;
									END LOOP;
									--- RAISE WARNING '%', cacherow;
									---------------------------------
									INSERT INTO spipoll_collections_cache SELECT cacherow.*;
									---------------------------------
									count := count + 1;
								ELSE
									RAISE WARNING 'Could not find Flower Image for Flower ID --> %, Collection % not cached', rowflower.id, collectionrow.id ;
								END IF;
								CLOSE curflowerimage;
							ELSE
								RAISE WARNING 'Could not find Determination for Flower ID --> %, Collection % not cached', rowflower.id, collectionrow.id ;
							END IF;
							CLOSE curdetermination;
							FETCH curflower INTO rowflower;
							IF FOUND THEN
								RAISE WARNING 'Multiple Flowers on Collection ID --> %, only most recent location used, ignoring ID --> %', collectionrow.id, rowflower.id ;
							END IF;
						ELSE
							RAISE WARNING 'Could not find Flower for Collection ID --> %, Collection not cached', collectionrow.id ;
						END IF;
						CLOSE curflower;
					ELSE
						RAISE WARNING 'Could not find Location Image for Location ID --> %, Collection % not cached', rowlocation.id, collectionrow.id ;
					END IF;
					CLOSE curlocationimage;
					FETCH curlocation INTO rowlocation;
					IF FOUND THEN
						RAISE WARNING 'Multiple Locations on Collection ID --> %, only most recent location used, ignoring ID --> %', collectionrow.id, rowlocation.id ;
					END IF;
				WHEN 0 THEN
					RAISE WARNING 'Collection not closed, ID --> %', collectionrow.id ;
				WHEN 2 THEN
					RAISE WARNING 'No closed attribute found for Collection ID --> %', collectionrow.id ;
			END CASE;
		ELSE
			RAISE WARNING 'Could not find Location for Collection ID --> %, Collection not cached', collectionrow.id ;
		END IF;
		CLOSE curlocation;
	  END;
    END LOOP;

	return count;
END;
$$ LANGUAGE plpgsql;

--- BEGIN;
select * from build_spipoll_cache(6);
--- COMMIT;