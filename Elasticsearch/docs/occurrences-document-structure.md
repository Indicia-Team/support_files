# Document structure for the default Indicia Elasticsearch occurrences configuration.

If the standard instructions for configuring Elasticsearch and Indicia are followed, then
the occurrences index will contain documents structured as described below. Note:

* sensitive records are represented by 2 copies of the record, one which is full
  precision (metadata.sensitivity_blur=F) and one which is blurred accordingly
  (metadata.sensitivity_blur=B). Non-sensitive records have no value for
  metadata.sensitivity_precision.
* confidential records may be included (depending on the configuration of Logstash) but
  should be filtered out by your index alias. The confidential status is indicated by
  metadata.confidential.
* training records may be included (depending on the configuration of Logstash) but
  should be filtered out by your index alias. The training status is indicated by
  metadata.trial.

## Document fields

`_id`||
-----|-----
**Data type**|string
**Warehouse field**|Derived from `occurrences.id`
**Description**|Elasticsearch index unique ID. This is the Indicia warehouse ID, with a prefix that denotes the
warehouse the record was sourced from, ensuring that \_id is always unique. E.g. BRC1&#124;123456. Where a record is
sensitive or belongs to a sample flagged as private, the index stores 2 copies of the record with a default blurred
view and a full precision view - in the latter case ! is appended to the \_id value, e.g. BRCSMP&#124;123456!.

`id`||
-----|-----
**Data type**|number
**Warehouse field**|`occurrences.id`
**Description**|The ID assigned to the occurrence record on the warehouse. May not be unique across the index if multiple warehouses are indexed.

`warehouse`||
-----|-----
**Data type**|string
**Warehouse field**|N/A
**Description**|Indicia warehouse identifier. Useful if a single Elasticsearch index contains data from multiple Indicia warehouses.

`@timestamp`||
-----|-----
**Data type**|date
**Warehouse field**|N/A
**Description**|Timestamp of the moment that this occurrence was indexed in Elasticsearch.

`event.attributes`||
-----|-----
**Data type**|nested
**Warehouse field**|`sample_attribute_values.*`
**Description**|List of custom attribute values for the sampling event. Each item has an `id` and `value` and should be read in conjuction with the sample_attributes table.

`event.parent_attributes`||
-----|-----
**Data type**|nested
**Warehouse field**|`sample_attribute_values.*`
**Description**|List of custom attribute values for the parent event sampling event if it exists.
Each item has an `id` and `value` and should be read in conjuction with the sample_attributes
table.

`event.date_end`||
-----|-----
**Data type**|date
**Warehouse field**|`samples.date_end`
**Description**|End of the date range that covers the field record. For a record on an exact date this will be the same as `event.start_date`.

`event.date_start`||
-----|-----
**Data type**|date
**Warehouse field**|`samples.date_start`
**Description**|Start of the date range that covers the field record.

`event.day_of_year`||
-----|-----
**Data type**|number
**Warehouse field**|derived from `samples.date_start`
**Description**|Day within the year, 1-366. Null if not an exact date.

`event.event_id`||
-----|-----
**Data type**|number
**Warehouse field**|ID of the Indicia sample on the warehouse.
**Description**|`samples.id`

`event.event_remarks`||
-----|-----
**Data type**|string
**Warehouse field**|`samples.comment`
**Description**|Comments for the sample.

`event.habitat`||
-----|-----
**Data type**|string
**Warehouse field**|Habitat/biotope for the sample.
**Description**|`sample_attribute_values.*`

`event.media`||
-----|-----
**Data type**|nested
**Warehouse field**|`sample_media`
**Description**|List of media files associated with the event. Each item contains the file name, caption, type and licence. Prefix the file name with the path to the warehouse upload folder to locate the file.

`event.month`||
-----|-----
**Data type**|number
**Warehouse field**|derived from `samples.date_start`
**Description**|Month within the year, 1-12. Omitted if the date range does not fall inside a single month.

`event.parent_event_id`||
-----|-----
**Data type**|number
**Warehouse field**|`sample.parent_id`
**Description**|ID of the sample’s parent if set (e.g. points to the parent sample for transects).

`event.recorded_by`||
-----|-----
**Data type**|string
**Warehouse field**|Depends on configuration - `sample_attribute_values.*` or `samples.recorder_names`.
**Description**|Name of the recorder(s).

`event.sampling_protocol`||
-----|-----
**Data type**|string
**Warehouse field**|Method used for the sample.
**Description**|`sample_attribute_values.*`

`event.ukbms_week`||
-----|-----
**Data type**|number
**Warehouse field**|derived from `samples.date_start`
**Description**|Week number according to the UKBS protocol, where week 1 starts on 1st April.

`event.week`||
-----|-----
**Data type**|number
**Warehouse field**|derived from `samples.date_start`
**Description**|Week number within the year, week 1 starts on 1st Jan. Omitted if the date range does not fall inside a single week.

`event.year`||
-----|-----
**Data type**|number
**Warehouse field**|derived from `samples.date_start`
**Description**|Year of the sample. Null if the date range does not fall inside a single year. Omitted if the date range does not fall inside a single week.

`identification.auto_checks.enabled`||
-----|-----
**Data type**|boolean
**Warehouse field**|websites.verification_checks_enabled`
**Description**|True if from a dataset that has automated rule checking enabled (warehouse Data Cleaner module).

`identification.auto_checks.identification_difficulty`||
-----|-----
**Data type**|boolean
**Warehouse field**|occurrence_comments.sub_type`
**Description**|If the record is flagged by an identification difficulty rule, specifies the difficulty from 1 to 5.

`identification.auto_checks.output`||
-----|-----
**Data type**|nested
**Warehouse field**|`occurrence_comments.*`
**Description**|List of objects describing automated rule check violations. Each object contains a value for message and rule type.

`identification.auto_checks.result`||
-----|-----
**Data type**|boolean
**Warehouse field**|`occurrence_comments.*`
**Description**|True if passes automated rule checks, false if fails, omitted if not checked.

`identification.auto_checks.verification_rule_types_applied`||
-----|-----
**Data type**|string array
**Warehouse field**|`cache_occurrences_functional.applied_verification_rule_types`
**Description**|List of key verification rule types that have been applied to an occurrence, giving an indication of
rule coverage. E.g. ["period","period_within_year","without_polygon"].

`identification.custom_verification_rule_flags`||
-----|-----
**Data type**|nested
**Description**|Flags attached to the record by a verifier's custom verification rules. Contains the `custom_verification_ruleset_id` and `custom_verification_rule_id` that generated the flag, `created_by_id`, `result`, `icon`, `message`, `check_date_time`.

`identification.identified_by`||
-----|-----
**Data type**|string
**Warehouse field**|`sample_attribute_values.*`
**Description**|Name of the identifier of the record.

`identification.query`||
-----|-----
**Data type**|string
**Warehouse field**|derived from `occurrence_comments.*`
**Description**|Query status of the record. Q = queried, A = answered.

`identification.recorder_certainty`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrence_attribute_values.*`
**Description**|Certainty assigned to the identification given by the recorder at the time of data entry. Possible values are Certain, Likely or Maybe.

`identification.verification_decision_source`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrences.record_decision_source`
**Description**|For verified records:<br/>H = human decision<br/>M = machine decision.

`identification.verification_status`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrence.record_status`
**Description**|Verification status of the record. Possible values are:<br>V = accepted<br>C = not reviewed<br>R = not accepted.

`identification.verification_substatus`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrence.record_substatus`
**Description**|Detail for verification status of the record. Possible values are:<br>1 = accepted as correct<br>2 = accepted as considered correct<br>3 = not reviewed, plausible<br>4 = not accepted as unable to verify<br>5 = not accepted as incorrect"

`identification.verified_on`||
-----|-----
**Data type**|date
**Warehouse field**|`occurrences.verified_on`
**Description**|If reviewed by a verifier, date of review.

`identification.verifier.id`||
-----|-----
**Data type**|number
**Warehouse field**|`occurrence.verified_by_id`
**Description**|If reviewed by a verifier, ID of verifier from the users table.

`identification.verifier.name`||
-----|-----
**Data type**|string
**Warehouse field**|`people.first_name`, `people.surname`
**Description**|If reviewed by a verifier, name of verifier.

`location.code`||
-----|-----
**Data type**|string
**Warehouse field**|`locations.code`
**Description**|Code for the location if the recorder adding the record explicitly linked the record to a location in the locations table.

`location.coordinate_uncertainty_in_meters`||
-----|-----
**Data type**|number
**Warehouse field**|`sample_attribute_values.*`
**Description**|If a measure of imprecision of the sample’s map reference known, then number of metres. [sic - matches Darwin Core!]

`location.geom`||
-----|-----
**Data type**|geo\_shape
**Warehouse field**|`samples.geom`
**Description**|Boundary of the occurrence’s sample. Blurred if sensitive or private and not the full precision version of the record.

`location.higher_geography`||
-----|-----
**Data type**|object[]
**Warehouse field**|List of objects that represent locations this sample has been identified as falling inside. Each object contains an ID (`locations.id`), name (`locations.name`), optional code (`locations.code)`, type (term derived from `locations.location_type_id`).
**Description**|`locations.*`

`location.location_id`||
-----|-----
**Data type**|number
**Warehouse field**|`locations.id`
**Description**|ID of the location if the recorder adding the record explicitly linked the record to a location in the locations table.

`location.grid_square.srid`||
-----|-----
**Data type**|number
**Warehouse field**|Projection used to calculate `map_squares.geom`
**Description**|EPSG projection ID used for aligning the grid squares. Will be the preferred local projection.

`location.grid_square.1km.centre`||
-----|-----
**Data type**|keyword
**Warehouse field**|`map_squares.geom`
**Description**|Centre of 1km grid square for the record, in WGS84 (EPSG:4326) but using the preferred local projection
to align the square. Formatted as a string with a space between X and Y value (as easier for aggregation queries).
Client mapping code can use this and the location.grid_square.srid field to calculate the actual square to draw in the
mapped projection. Empty if sensitivity or privacy of the records means this precision should not be visible.

`location.grid_square.2km.centre`||
-----|-----
**Data type**|keyword
**Warehouse field**|`map_squares.geom`
**Description**|As `location.grid_square.1km.centre` for 2km grid squares.

`location.grid_square.10km.centre`||
-----|-----
**Data type**|keyword
**Warehouse field**|`map_squares.geom`
**Description**|As `location.grid_square.1km.centre` for 10km grid squares.

`location.input_sref`||
-----|-----
**Data type**|string
**Warehouse field**|`cache_samples_functional.public_entered_sref`, derived from `samples.entered_sref`
**Description**|Spatial reference in notation as input by the recorder. If the record is sensitive or private, then the
`location.output_sref` value is used, blurred to the appropriate precision unless this is the full precision version of
the occurrence document in the index (`metadata.sensitivity_blur` = F which should be filtered out from default index
aliases). For the full precision version of a sensitive or private record, shows the original full precision reference.

`location.input_sref_system`||
-----|-----
**Data type**|string
**Warehouse field**|`cache_samples_functional.entered_sref_system`, derived from `samples.entered_sref_system`
**Description**|Spatial reference system code, e.g. OSGB or an EPSG projection ID, for the value in `location.input_sref`.

`location.name`||
-----|-----
**Data type**|string
**Warehouse field**|`locations.name`
**Description**|Name of the location if the recorder adding the record explicitly linked the record to a location in the locations table.

`location.output_sref`||
-----|-----
**Data type**|string
**Warehouse field**|`cache_samples_functional.output_sref`, derived from `samples.entered_sref`
**Description**|Spatial reference in preferred local system format (e.g. an Ordnance Survey British National Grid
Reference). If the record is sensitive or private, then blurred to the appropriate precision unless this is the full
precision version of the occurrence document in the index (`metadata.sensitivity_blur` = F which should be filtered out
from default index aliases). For the full precision version of a sensitive or private record, shows the original full
precision reference.

`location.output_sref_system`||
-----|-----
**Data type**|string
**Warehouse field**|`cache_samples_functional.output_sref_system`, derived from `samples.entered_sref_system`
**Description**|Spatial reference system code, e.g. OSGB or an EPSG projection ID.

`location.parent.location_id`||
-----|-----
**Data type**|number
**Warehouse field**|`locations.id`
**Description**|If there is a parent sample (e.g. for a transect) which has an explicitly linked location record, then gives the ID of this location.

`location.parent.code`||
-----|-----
**Data type**|string
**Warehouse field**|`locations.code`
**Description**|If there is a parent sample (e.g. for a transect) which has an explicitly linked location record, then gives the code of this location.

`location.parent.name`||
-----|-----
**Data type**|string
**Warehouse field**|`locations.name`
**Description**|If there is a parent sample (e.g. for a transect) which has an explicitly linked location record, then gives the name of this location.

`location.point`||
-----|-----
**Data type**|geo\_point
**Warehouse field**|`samples.geom`
**Description**|Centroid point of the occurrence’s sample. Provided for mapping tools which do not make use of the `location.geom` geo_shape field (e.g. Kibana).

`location.verbatim_locality`||
-----|-----
**Data type**|string
**Warehouse field**|`samples.location_name` or `locations.name`
**Description**|Location name associated with the record, either the name of the explicitly linked location or the verbatim location description.

`metadata.confidential`||
-----|-----
**Data type**|boolean
**Warehouse field**|`occurrences.confidential`
**Description**|If the record is flagged as confidential then set to true. Default index aliases should filter out documents where `metadata.confidential` = true.

`metadata.created_by_id`||
-----|-----
**Data type**|number
**Warehouse field**|`occurrences.created_by_id`
**Description**|ID of the user who input the record.

`metadata.created_on`||
-----|-----
**Data type**|date
**Warehouse field**|`occurrences.created_on`
**Description**|Date and time the record was input.

`metadata.group.id`||
-----|-----
**Data type**|number
**Warehouse field**|`groups.id`
**Description**|If the record is associated with a recording group (activity or project etc), then the ID of the group.

`metadata.group.title`||
-----|-----
**Data type**|string
**Warehouse field**|`groups.title`
**Description**|If the record is associated with a recording group (activity or project etc), then the title of the group.

`metadata.import_guid`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrences.import_guid`
**Description**|If the record was created by an import, then the globally unique identifier that was assigned to the batch of records at the time of import.

`metadata.input_form`||
-----|-----
**Data type**|string
**Warehouse field**|`sample.input_form`
**Description**|Path to the form used to edit this record.

`metadata.licence_code`||
-----|-----
**Data type**|string
**Warehouse field**|`licences.code`
**Description**|If the record has a licence explicitly associated with it, then gives the licence code (e.g. CC0).

`metadata.release_status`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrences.release_status`
**Description**|For records that are not ready for release into public reporting systems, gives the status. Values are R = released, U = unreleased, P = pending review. Values U and P should be filtered out in default index aliases.

`metadata.privacy_precision`||
-----|-----
**Data type**|boolean
**Warehouse field**|`samples.privacy_precision`
**Description**|True if the sample containing the record is flagged as private.

`metadata.private`||
-----|-----
**Data type**|boolean
**Warehouse field**|derived from `samples.privacy_precision`
**Description**|For records that are private, indicates the size of the grid square to blur to.

`metadata.sensitive`||
-----|-----
**Data type**|boolean
**Warehouse field**|derived from `occurrences.sensitivity_precision`
**Description**|True if the record is flagged as sensitive.

`metadata.sensitivity_blur`||
-----|-----
**Data type**|string
**Warehouse field**|derived from `occurrences.sensitivity_precision`
**Description**|Where the index contains 2 copies of sensitive or private records, identifies which copy of the record
this document relates to. F = full precision, B = blurred. Default index aliases should filter out documents where
sensitivity\_blur = F.

`metadata.sensitivity_precision`||
-----|-----
**Data type**|number
**Warehouse field**|`occurrences.sensitivity_precision`
**Description**|For records that are sensitive, indicates the size of the grid square to blur to.

`metadata.survey.id`||
-----|-----
**Data type**|number
**Warehouse field**|`surveys.id`
**Description**|ID of the Indicia survey dataset on the warehouse.

`metadata.survey.title`||
-----|-----
**Data type**|string
**Warehouse field**|`surveys.title`
**Description**|Title of the Indicia survey dataset on the warehouse.

`metadata.tracking`||
-----|-----
**Data type**|number
**Warehouse field**|`cache_occurrences_functional.tracking`
**Description**|Unique sequential identifier for the last update event which affected the cached entry of this record.

`metadata.trial`||
-----|-----
**Data type**|boolean
**Warehouse field**|`occurrences.training`
**Description**|True if this is a trial record (so should be excluded unleess analysing trial data).

`metadata.updated_by_id`||
-----|-----
**Data type**|number
**Warehouse field**|`occurrences.updated_by_id`
**Description**|ID of the user who last updated the record.

`metadata.updated_on`||
-----|-----
**Data type**|date
**Warehouse field**|`occurrences.updated_on`
**Description**|Date and time the record was last updated.

`metadata.website.id`||
-----|-----
**Data type**|number
**Warehouse field**|`websites.id`
**Description**|ID of the Indicia website registration on the warehouse. Currently the special value 0 is used to imply a "dirty" record which requires an update in ES, so should not display in any filtered searches.

`metadata.website.title`||
-----|-----
**Data type**|string
**Warehouse field**|`websites.title`
**Description**|Title of the Indicia website registration on the warehouse.

`occurrence.behaviour`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrence_attribute_value.*`
**Description**|Behaviour shown by the subject (text).

`occurrence.media`||
-----|-----
**Data type**|nested
**Warehouse field**|`occurrence_media`
**Description**|List of media files associated with the occurrence. Each item contains the file name, caption, type and licence. Prefix the file name with the path to the warehouse upload folder to locate the file.

`occurrence.attributes`||
-----|-----
**Data type**|nested
**Warehouse field**|`occurrence_attribute_values`
**Description**|List of custom attribute values for the record. Each item has an `id` and `value` and should be read in conjuction with the occurrence_attributes table

`occurrence.individual_count`||
-----|-----
**Data type**|number
**Warehouse field**|`occurrence_attribute_values.*`
**Description**|If a count of individuals is available in numeric form for the record, then the value is indicated here.

`occurrence.life_stage`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrence_attribute_values.*`
**Description**|Life stage of the recorded organism.

`occurrence.occurrence_remarks`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrences.comment`
**Description**|Comment given when the record was input.

`occurrence.organism_quantity`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrence_attribute_value.*`
**Description**|Abundance information (text or numeric).

`occurrence.reproductive_condition`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrence_attribute_value.*`
**Description**|Reproductive condition of the biological individual (text).

`occurrence.source_system_key`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrence.external_key`
**Description**|Unique key given to record by the system the record was sourced from.

`occurrence.sex`||
-----|-----
**Data type**|string
**Warehouse field**|`occurrence_attribute_values.*`
**Description**|Label indicating the sex of the recorded organism.

`occurrence.zero_abundance`||
-----|-----
**Data type**|boolean
**Warehouse field**|`occurrence.zero_abundance*`
**Description**|Indicates if a record is of absence of a species.

`taxon.accepted_name`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Accepted name of the organism’s taxon (normally a scientific name).

`taxon.accepted_name_authorship`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.authority`
**Description**|Author and date associated with the accepted name.

`taxon.accepted_taxon_id`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.external_key`
**Description**|Key given for the taxon accepted name (e.g. a taxon version key).

`taxon.class`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Class of the taxon.

`taxon.family`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Family of the taxon.

`taxon.genus`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Genus of the taxon.

`taxon.group`||
-----|-----
**Data type**|string
**Warehouse field**|`taxon_group.title`
**Description**|Output group label for the taxon (e.g. terrestrial mammal, from the taxon as mapped to the mastter list).

`taxon.group_id`||
-----|-----
**Data type**|string
**Warehouse field**|`taxon_group.id`
**Description**|Output group ID for the taxon (from the taxon as mapped to the mastter list).

`taxon.input_group`||
-----|-----
**Data type**|string
**Warehouse field**|`taxon_group.title`
**Description**|Input group label for the taxon (label from the taxon list the record was input against).

`taxon.input_group_id`||
-----|-----
**Data type**|string
**Warehouse field**|`taxon_group.id`
**Description**|Input group ID for the taxon (ID from the taxon list the record was input against).

`taxon.higher_taxon_ids`||
-----|-----
**Data type**|string[]
**Warehouse field**|`taxa.external_key`
**Description**|List of taxon external keys associated with the higher taxa.

`taxon.kingdom`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Kingdom of the taxon.

`taxon.marine`||
-----|-----
**Data type**|boolean
**Warehouse field**|`taxa.marine_flag`
**Description**|True if the taxon is associated with marine environments.

`taxon.freshwater`||
-----|-----
**Data type**|boolean
**Warehouse field**|`taxa.freshwater_flag`
**Description**|True if the taxon is associated with freshwater environments.

`taxon.terrestrial`||
-----|-----
**Data type**|boolean
**Warehouse field**|`taxa.terrestrial_flag`
**Description**|True if the taxon is associated with terrestrial environments.

`taxon.non_native`||
-----|-----
**Data type**|boolean
**Warehouse field**|`taxa.non_native_flag`
**Description**|True if the taxon is associated with non-native environments.

`taxon.order`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Order of the taxon.

`taxon.phylum`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Phylum of the taxon.

`taxon.species`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Species of the taxon. Allows sub-species to be aggregated to a single species name when counting species in a list and also allows higher taxa to be excluded from such counts.

`taxon.species_authorship`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.authority`
**Description**|Author and date associated with the name given in `taxon.species`.

`taxon.species_taxon_id`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.external_key`
**Description**|External key of the taxon given in the `taxon.species` field (allows disambiguation of name clashes).

`taxon.species_vernacular`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Common name associated with this taxon at the species level.

`taxon.subfamily`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Subfamily of the taxon.

`taxon.taxa_taxon_list_id`||
-----|-----
**Data type**|number
**Warehouse field**|`taxa_taxon_lists.id`
**Description**|ID given to this taxon name in the taxa_taxon_lists table.

`taxon.taxon_id`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.search_code`
**Description**|Key of the given taxon (e.g. a taxon version key).

`taxon.taxon_meaning_id`||
-----|-----
**Data type**|number
**Warehouse field**|`taxon_meanings.id`
**Description**|ID given to this taxon concept in the taxon_meanings table.

`taxon.taxon_list.id`||
-----|-----
**Data type**|number
**Warehouse field**|`taxon_list.id`
**Description**|ID of the taxon list the record was input against.

`taxon.taxon_list.title`||
-----|-----
**Data type**|string
**Warehouse field**|`taxon_list.title`
**Description**|Title of the taxon list the record was input against.

`taxon.taxon_name`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Name given for the recorded organism by the recorder.

`taxon.taxon_name_authorship`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.authority`
**Description**|Author and date associated with the taxon name.

`taxon.taxon_rank`||
-----|-----
**Data type**|string
**Warehouse field**|`taxon_ranks.rank`
**Description**|Rank label for the taxon (e.g. Species).

`taxon.taxon_rank_sort_order`||
-----|-----
**Data type**|number
**Warehouse field**|`taxon_ranks.sort_order`
**Description**|Sort order of the taxon’s rank in order of higher to lower taxa.

`taxon.vernacular_name`||
-----|-----
**Data type**|string
**Warehouse field**|`taxa.taxon`
**Description**|Preferred common name associated with this taxon.