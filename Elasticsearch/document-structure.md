# Document structure for the default Indicia Elasticsearch configuration.

If the standard instructions for configuring Elasticsearch and Indicia are followed, then the index will contain
documents structured as described below.

## Document fields

**Field**|**Data type**|**Description**|**Indicia field info**
-----|-----|-----|-----
`_id`|string|Elasticsearch index unique ID. This is the Indicia warehouse ID, with a prefix that denotes the warehouse the record was sourced from, ensuring that \_id is always unique. E.g. BRC1&#124;123456. Where a record is sensitive, the index stores 2 copies of the record with a default blurred view and a full precision view - in the latter case ! is appended to the \_id value, e.g. BRC1&#124;123456!.|Derived from `occurrences.id`
`id`|number|The ID assigned to the occurrence record on the warehouse. May not be unique|`occurrences.id`
`warehouse`|string|Indicia warehouse identifier. Useful if a single Elasticsearch index contains data from multiple Indicia warehouses.|
`@timestamp`|date|Timestamp that this occurrence was indexed in Elasticsearch.|
`event.date_end`|date|End of the date range that covers the field record. For a record on an exact date this will be the same as `event.start_date`.|`samples.date_end`
`event.date_start`|date|Start of the date range that covers the field record.|`samples.date_start`
`event.day_of_year`|number|Day within the year, 1-366. Null if not an exact date.|derived from `samples.date_start`
`event.event_id`|number|ID of the Indicia sample on the warehouse.|`samples.id`
`event.event_remarks`|string|Comments for the sample.|`samples.comment`
`event.habitat`|string|Habitat/biotope for the sample.|Sample custom attribute
`event.month`|number|Month within the year, 1-12. Omitted if the date range does not fall inside a single month.|derived from `samples.date_start`
`event.parent_event_id`|number|ID of the sample’s parent if set (e.g. points to the parent sample for transects).|`samples.parent_id`
`event.recorded_by`|string|Name of the recorder(s).|Depends on configuration
`event.sampling_protocol`|string|Method used for the sample.|Sample custom attribute
`event.ukbms_week`|number|Week number according to the UKBS protocol, where week 1 starts on 1st April.|derived from `samples.date_start`
`event.week`|number|Week number within the year, week 1 starts on 1st Jan. Omitted if the date range does not fall inside a single week.|derived from `samples.date_start`
`event.year`|number|Year of the sample. Null if the date range does not fall inside a single year. Omitted if the date range does not fall inside a single week.|derived from `samples.date_start`
`identification.auto_checks.enabled`|boolean|True if from a dataset that has automated rule checking enabled (warehouse Data Cleaner module). |`websites.verification_checks_enabled`
`identification.auto_checks.output`|object[]|List of objects describing automated rule check violations. Each object contains a value for message and rule type.|
`identification.auto_checks.result`|boolean|True if passes automated rule checks, false if fails, omitted if not checked.|
`identification.identification_verification_status`|string|Verification status of the record. Possible values are:<br>V = accepted<br>V1 = accepted as correct<br>V2 = accepted as considered correct<br>C = not reviewed, pending verification<br>C3 = not reviewed, plausible<br>R = not accepted<br>R4 = not accepted as unable to verify<br>R5 = not accepted as incorrect"|`occurrences.record_status`, `occurrences.record_substatus`
`identification.identified_by`|string|Name of the identifier of the record.|Sample custom attribute
`identification.query`|string|Query status of the record. Q = queried, A = answered.|Calculated from `occurrence_comments`.
`identification.recorder_certainty`|string|Certainty assigned to the identification given by the recorder at the time of data entry. Possible values are Certain, Likely or Maybe.|Occurrence custom attribute
`identification.verified_on`|date|If reviewed by a verifier, date of review.|`occurrences.verified_on`
`identification.verifier.id`|number|If reviewed by a verifier, ID of verifier from the users table.|`occurrences.verified_by_id`
`identification.verifier.name`|string|If reviewed by a verifier, name of verifier.|`people.first_name`, `people.surname`
`location.coordinate_uncertainty_in_meters`|number|If a measure of imprecision of the sample’s map reference known, then number of metres. [sic - matches Darwin Core!]|Sample custom attribute
`location.geom`|geo\_shape|Boundary of the occurrence’s sample.|`samples.geom`
`location.higher_geography`|object[]|List of objects that represent locations this sample has been identified as falling inside. Each object contains an ID (`locations.id`), name (`locations.name`), optional code (`locations.code)`, type (term derived from `locations.location_type_id`).|locations table
`location.location_id`|number|ID of the location if the recorder adding the record explicitly linked the record to a location in the locations table.|`locations.id`
`location.name`|string|Name of the location if the recorder adding the record explicitly linked the record to a location in the locations table.|`locations.name`
`location.output_sref`|string|Spatial reference in preferred local system format (e.g. an Ordnance Survey British National Grid Reference). If the record is sensitive, then blurred to the appropriate precision unless this is the full precision version of the occurrence document in the index (`metadata.sensitivity_blur` = F which should be filtered out from default index aliases). For the full precision version of a sensitive record, shows the original full precision reference.|`cache_samples_functional.output_sref`, derived from `samples.entered_sref`
`location.output_sref_system`|string|Spatial reference system code, e.g. OSGB or an EPSG projection ID.|`cache_samples_functional.output_sref_system`, derived from `samples.entered_sref_system`
`location.parent.location_id`|number|If there is a parent sample (e.g. for a transect) which has an explicitly linked location record, then gives the ID of this location.|`locations.id`
`location.parent.name`|string|If there is a parent sample (e.g. for a transect) which has an explicitly linked location record, then gives the name of this location.|`locations.name`
`location.point`|geo\_point|Centroid point of the occurrence’s sample. Provided for mapping tools which do not make use of the `location.geom` geo_shape field (e.g. Kibana).|`samples.geom`
`location.verbatim_locality`|string|Location name associated with the record, either the name of the explicitly linked location or the verbatim location description.|`samples.location_name` or `locations.name`
`metadata.confidential`|boolean|If the record is flagged as confidential then set to true. Default index aliases should filter out documents where `metadata.confidential` = true.|`occurrences.confidential`
`metadata.created_by_id`|number|ID of the user who input the record.|`occurrences.created_by_id`
`metadata.created_on`|date|Date and time the record was input.|`occurrences.created_on`
`metadata.group.id`|number|If the record is associated with a recording group (activity or project etc), then the ID of the group.|`groups.id`
`metadata.group.title`|string|If the record is associated with a recording group (activity or project etc), then the title of the group.|`groups.title`
`metadata.licence_code`|string|If the record has a licence explicitly associated with it, then gives the licence code (e.g. CC0).|`licences.code`
`metadata.release_status`|string|For records that are not ready for release into public reporting systems, gives the status. Values are R = released, U = unreleased, P = pending review. Values U and P should be filtered out in default index aliases.|`occurrences.release_status`
`metadata.sensitive`|boolean|True if the record is flagged as sensitive.|derived from `occurrences.sensitivity_precision`
`metadata.sensitivity_blur`|string|Where the index contains 2 copies of sensitive records, identifies which copy of the record this document relates to. F = full precision, B = blurred. Default index aliases should filter out documents where sensitivity\_blur = F.|derived from `occurrences.sensitivity_precision`
`metadata.sensitivity_precision`|number|For records that are sensitive, indicates the size of the grid square to blur to.|`occurrences.sensitivity_precision`
`metadata.survey.id`|number|ID of the Indicia survey dataset on the warehouse.|`surveys.id`
`metadata.survey.title`|string|Title of the Indicia survey dataset on the warehouse.|`surveys.title`
`metadata.updated_by_id`|number|ID of the user who last updated the record.|`occurrences.updated_by_id`
`metadata.updated_on`|date|Date and time the record was last updated.|`occurrences.updated_on`
`metadata.website.id`|number|ID of the Indicia website registration on the warehouse.|`websites.id`
`metadata.website.title`|string|Title of the Indicia website registration on the warehouse.|`websites.title`
`occurrence.associated_media`|string[]|List of media files associated with the occurrence. Prefix the file name with the path to the warehouse upload folder to locate the file.|`occurrence_media.path`
`occurrence.individual_count`|number|If a count of individuals is available in numeric form for the record, then the value is indicated here.|Occurrence custom attribute
`occurrence.life_stage`|string|Life stage of the recorded organism.|Occurrence custom attribute
`occurrence.occurrence_remarks`|string|Comment given when the record was input.|`occurrences.comment`
`occurrence.organism_quantity`|string|Abundance information (text or numeric).|Occurrence custom attribute
`occurrence.sex`|string|Label indicating the sex of the recorded organism.|Occurrence custom attribute
`taxon.accepted_name`|string|Accepted name of the organism’s taxon (normally a scientific name).|`taxa.taxon`
`taxon.accepted_name_authorship`|string|Author and date associated with the accepted name.|`taxa.authority`
`taxon.accepted_taxon_id`|string|Key given for the taxon accepted name (e.g. a taxon version key).|`taxa.external_key`
`taxon.class`|string|Class of the taxon.|`taxa.taxon`
`taxon.family`|string|Family of the taxon.|`taxa.taxon`
`taxon.genus`|string|Genus of the taxon.|`taxa.taxon`
`taxon.group`|string|Output group label for the taxon (e.g. terrestrial mammal).|`taxon_group.title`
`taxon.higher_taxon_ids`|string[]|List of taxon external keys associated with the higher taxa.|`taxa.external_key`
`taxon.kingdom`|string|Kingdom of the taxon.|`taxa.taxon`
`taxon.marine`|boolean|True if the taxon is associated with marine environments.|`taxa.marine_flag`
`taxon.order`|string|Order of the taxon.|`taxa.taxon`
`taxon.phylum`|string|Phylum of the taxon.|`taxa.taxon`
`taxon.species`|string|Species of the taxon. Allows sub-species to be aggregated to a single species name when counting species in a list and also allows higher taxa to be excluded from such counts.|`taxa.taxon`
`taxon.species_taxon_id`|string|External key of the taxon given in the `taxon.species` field (allows disambiguation of name clashes).|`taxa.external_key`
`taxon.subfamily`|string|Subfamily of the taxon.|`taxa.taxon`
`taxon.taxon_id`|string|Key of the given taxon (e.g. a taxon version key).|`taxa.search_code`
`taxon.taxon_name`|string|Name given for the recorded organism by the recorder.|`taxa.taxon`
`taxon.taxon_name_authorship`|string|Author and date associated with the taxon name.|`taxa.authority`
`taxon.taxon_rank`|string|Rank label for the taxon (e.g. Species).|`taxon_ranks.rank`
`taxon.taxon_rank_sort_order`|number|Sort order of the taxon’s rank in order of higher to lower taxa.|`taxon_ranks.sort_order`
`taxon.vernacular_name`|string|Preferred common name associated with this taxon.|`taxa.taxon`