# Document structure for the default Indicia Elasticsearch samples configuration.

If the standard instructions for configuring Elasticsearch and Indicia are followed, then
the samples index will contain documents structured as described below. Note:

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
**Warehouse field**|Derived from `samples.id`
**Description**|Elasticsearch index unique ID. This is the Indicia warehouse ID, with a prefix that denotes the
warehouse the record was sourced from, ensuring that \_id is always unique. The prefix will also include an indication
that this is a sample document to ensure a unique ID if mixed with occurrence data. E.g. BRCSMP&#124;123456. Where a
sample contains records that are sensitive or private, the index stores 2 copies of the record with a default blurred
view and a full precision view - in the latter case ! is appended to the \_id value, e.g. BRC1&#124;123456!.

`id`||
-----|-----
**Data type**|number
**Warehouse field**|`sample.id`
**Description**|The ID assigned to the sample record on the warehouse. May not be unique across the index if multiple
warehouses are indexed.

`warehouse`||
-----|-----
**Data type**|string
**Warehouse field**|N/A
**Description**|Indicia warehouse identifier. Useful if a single Elasticsearch index contains data from multiple
Indicia warehouses.

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
**Description**|Centroid point of the occurrence’s sample. Provided for mapping tools which do not make use of the
`location.geom` geo_shape field (e.g. Kibana).

`location.verbatim_locality`||
-----|-----
**Data type**|string
**Warehouse field**|`samples.location_name` or `locations.name`
**Description**|Location name associated with the record, either the name of the explicitly linked location or the
verbatim location description.

`metadata.confidential`||
-----|-----
**Data type**|boolean
**Warehouse field**|`samples.confidential`
**Description**|If the sample contains any occurrence records flagged as confidential then set to true. Default index
aliases should filter out documents where `metadata.confidential` = true.

`metadata.created_by_id`||
-----|-----
**Data type**|number
**Warehouse field**|`samples.created_by_id`
**Description**|ID of the user who input the sample.

`metadata.created_on`||
-----|-----
**Data type**|date
**Warehouse field**|`samples.created_on`
**Description**|Date and time the sample was input.

`metadata.group.id`||
-----|-----
**Data type**|number
**Warehouse field**|`groups.id`
**Description**|If the sample is associated with a recording group (activity or project etc), then the ID of the group.

`metadata.group.title`||
-----|-----
**Data type**|string
**Warehouse field**|`groups.title`
**Description**|If the sample is associated with a recording group (activity or project etc), then the title of the group.

`metadata.input_form`||
-----|-----
**Data type**|string
**Warehouse field**|`sample.input_form`
**Description**|Path to the form used to edit this sample.

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
**Description**|True if the sample is flagged as private.

`metadata.private`||
-----|-----
**Data type**|boolean
**Warehouse field**|derived from `samples.privacy_precision`
**Description**|For samples that are private, indicates the size of the grid square to blur to.

`metadata.sensitive`||
-----|-----
**Data type**|boolean
**Warehouse field**|derived from `occurrences.sensitivity_precision`
**Description**|True if the sample contains any records flagged as sensitive.

`metadata.sensitivity_blur`||
-----|-----
**Data type**|string
**Warehouse field**|derived from `occurrences.sensitivity_precision`
**Description**|Where the index contains 2 copies of sensitive or private records, identifies which copy of the sample
this document relates to. F = full precision, B = blurred. Default index aliases should filter out documents where
sensitivity\_blur = F.

`metadata.sensitivity_precision`||
-----|-----
**Data type**|number
**Warehouse field**|`occurrences.sensitivity_precision`
**Description**|For samples which contain records that are sensitive, indicates the size of the grid square to blur to.

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
**Warehouse field**|`cache_samples_functional.tracking`
**Description**|Unique sequential identifier for the last update event which affected the cached entry of this sample.

`metadata.trial`||
-----|-----
**Data type**|boolean
**Warehouse field**|`samples.training`
**Description**|True if this is a trial record (so should be excluded unless analysing trial data).

`metadata.updated_by_id`||
-----|-----
**Data type**|number
**Warehouse field**|`samples.updated_by_id`
**Description**|ID of the user who last updated the sample.

`metadata.updated_on`||
-----|-----
**Data type**|date
**Warehouse field**|`samples.updated_on`
**Description**|Date and time the sample was last updated.

`metadata.verification_status`||
-----|-----
**Data type**|string
**Warehouse field**|`sample.record_status`
**Description**|Verification status of the sample. Possible values are:<br>V = accepted<br/>C = not reviewed<br>R = not accepted.

`metadata.verified_on`||
-----|-----
**Data type**|date
**Warehouse field**|`samples.verified_on`
**Description**|If reviewed by a verifier, date of review.

`metadata.verifier.id`||
-----|-----
**Data type**|number
**Warehouse field**|`samples.verified_by_id`
**Description**|If reviewed by a verifier, ID of verifier from the users table.

`metadata.samples.name`||
-----|-----
**Data type**|string
**Warehouse field**|`people.first_name`, `people.surname`
**Description**|If reviewed by a verifier, name of verifier.

`metadata.website.id`||
-----|-----
**Data type**|number
**Warehouse field**|`websites.id`
**Description**|ID of the Indicia website registration on the warehouse.

`metadata.website.title`||
-----|-----
**Data type**|string
**Warehouse field**|`websites.title`
**Description**|Title of the Indicia website registration on the warehouse.

`stats.count_occurrences`||
-----|-----
**Data type**|string
**Warehouse field**|count of `occurrences.id`
**Description**|Count of occurrences in this sample. Includes occurrences in child samples (e.g. section occurrences
in a transect walk sample).

`stats.count_taxa`||
-----|-----
**Data type**|string
**Warehouse table**|count of `taxa_taxon_lists.taxon_meaning_id`
**Description**|Count of distinct taxa in this sample. Includes occurrences in child samples (e.g. section occurrences
in a transect walk sample).

`stats.count_taxon_groups`||
-----|-----
**Data type**|string
**Warehouse table**|count of `taxa_taxon_lists.taxon_group_id`
**Description**|Count of distinct taxon groups in this sample. Includes occurrences in child samples (e.g. section
occurrences in a transect walk sample).

`stats.sum_individual_count`||
-----|-----
**Data type**|string
**Warehouse table**|derived from `occurrence_attribute_values.int_value`
**Description**|Sum of individuals counted for this sample (if count data are in numeric format). Includes occurrences
in child samples (e.g. section occurrences in a transect walk sample).
