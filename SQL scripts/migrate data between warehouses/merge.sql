set search_path=indicia, public;

-- Insert users first as referred to by other tables. We will insert a null or dummy value for Fks, then
-- update them in a second step to avoid violations on initial insert.
insert into users (id, home_entered_sref, home_entered_sref_system, interests, location_name, person_id, email_visible,
  view_common_names, core_role_id, created_on, created_by_id, updated_on, updated_by_id, username, password,
  forgotten_password_key, deleted, default_digest_mode, allow_share_for_reporting, allow_share_for_peer_review,
  allow_share_for_verification, allow_share_for_data_flow, allow_share_for_moderation, allow_share_for_editing)
select id, home_entered_sref, home_entered_sref_system, interests, location_name, 1, email_visible,
  view_common_names, core_role_id, created_on, 1, updated_on, 1, username, password,
  forgotten_password_key, deleted, default_digest_mode, allow_share_for_reporting, allow_share_for_peer_review,
  allow_share_for_verification, allow_share_for_data_flow, allow_share_for_moderation, allow_share_for_editing
from import.users i
where i.new=true;

-- People next so we can fix the FK person_id in users table.
insert into people(id, first_name, surname, initials, email_address, website_url, created_on, created_by_id, updated_on,
  updated_by_id, title_id, address, deleted, external_key)
select id, first_name, surname, initials, email_address, website_url, created_on, created_by_id, updated_on,
  updated_by_id, title_id, address, deleted, external_key
from import.people i
where i.new=true;

-- Fix up user foreign keys
update users u
set person_id=i.person_id, created_by_id=i.created_by_id, updated_by_id=i.updated_by_id
from import.users i
where i.new=true
and i.id=u.id;

-- Languages
insert into languages(id, iso, language, created_on, created_by_id, updated_on, updated_by_id, deleted)
select id, iso, language, created_on, created_by_id, updated_on, updated_by_id, deleted
from import.languages i
where i.new=true;

-- Websites
insert into websites(id, title, description, created_on, created_by_id, updated_on, updated_by_id, url,
  default_survey_id, password, deleted, verification_checks_enabled)
select id, title, description, created_on, created_by_id, updated_on, updated_by_id, url,
  default_survey_id, password, deleted, verification_checks_enabled
from import.websites i
where i.new=true;

-- Term lists. Parent_id set to null initially to avoid FK violation.
insert into termlists(id, title, description, website_id, parent_id, deleted, created_on, created_by_id,
  updated_on, updated_by_id, external_key)
select id, title, description, website_id, null, deleted, created_on, created_by_id,
  updated_on, updated_by_id, external_key
from import.termlists i
where i.new=true;

-- Fix up parent FK
update termlists s
set parent_id=i.parent_id
from import.termlists i
where i.new=true
and i.id=s.id
and i.parent_id is not null;

-- Terms
insert into terms(id, term, language_id, created_on, created_by_id, updated_on, updated_by_id, deleted)
select id, term, language_id, created_on, created_by_id, updated_on, updated_by_id, deleted
from import.terms i
where i.new=true;

-- Meanings
insert into meanings(id)
select id
from import.meanings i;

-- Termlist terms. Parent_id set to null initially to avoid FK violation.
insert into termlists_terms(id, termlist_id, term_id, created_on, created_by_id, updated_on, updated_by_id, parent_id,
  meaning_id, preferred, sort_order, deleted, source_id, image_path, allow_data_entry)
select id, termlist_id, term_id, created_on, created_by_id, updated_on, updated_by_id, null,
  meaning_id, preferred, sort_order, deleted, source_id, image_path, allow_data_entry
from import.termlists_terms i
where i.new=true;

-- Fix up parent FK
update termlists_terms s
set parent_id=i.parent_id
from import.termlists_terms i
where i.new=true
and i.id=s.id
and i.parent_id is not null;

-- Taxon lists. Parent_id set to null initially to avoid FK violation.
insert into taxon_lists(id, title, description, website_id, parent_id, created_on, created_by_id,
  updated_on, updated_by_id, deleted)
select id, title, description, website_id, null, created_on, created_by_id,
  updated_on, updated_by_id, deleted
from import.taxon_lists i
where i.new=true;

-- Fix up parent FK
update taxon_lists s
set parent_id=i.parent_id
from import.taxon_lists i
where i.new=true
and i.id=s.id
and i.parent_id is not null;

-- Taxon groups. Parent_id set to null initially to avoid FK violation.
insert into taxon_groups(id, title, created_on, created_by_id, updated_on, updated_by_id, deleted, external_key,
  parent_id, description)
select id, title, created_on, created_by_id, updated_on, updated_by_id, deleted, external_key,
  parent_id, description
from import.taxon_groups i
where i.new=true;

-- Fix up parent FK
update taxon_groups s
set parent_id=i.parent_id
from import.taxon_lists i
where i.new=true
and i.id=s.id
and i.parent_id is not null;

-- Taxon ranks.
insert into taxon_ranks(id, rank, short_name, italicise_taxon, sort_order, created_on, created_by_id,
  updated_on, updated_by_id, deleted)
select id, rank, short_name, italicise_taxon, sort_order, created_on, created_by_id,
  updated_on, updated_by_id, deleted
from import.taxon_ranks i
where i.new=true;

-- Taxa
insert into taxa(id, taxon, taxon_group_id, language_id, external_key, authority, search_code, scientific,
  created_on, created_by_id, updated_on, updated_by_id, deleted, description, taxon_rank_id, attribute, marine_flag)
select id, taxon, taxon_group_id, language_id, external_key, authority, search_code, scientific,
  created_on, created_by_id, updated_on, updated_by_id, deleted, description, taxon_rank_id, attribute, marine_flag
from import.taxa i
where i.new=true;

-- Taxon meanings
insert into taxon_meanings(id)
select id
from import.taxon_meanings;

-- Taxa taxon lists. Parent_id set to null initially to avoid FK violation.
insert into taxa_taxon_lists(id, taxon_list_id, taxon_id, created_on, created_by_id, parent_id, taxon_meaning_id,
  taxonomic_sort_order, preferred, updated_on, updated_by_id, deleted, description, common_taxon_id, allow_data_entry,
  verification_check_version)
select id, taxon_list_id, taxon_id, created_on, created_by_id, 1, taxon_meaning_id,
  taxonomic_sort_order, preferred, updated_on, updated_by_id, deleted, description, common_taxon_id, allow_data_entry,
  verification_check_version
from import.taxa_taxon_lists i
where i.new=true;

-- Fix up parent FK
update taxa_taxon_lists s
set parent_id=i.parent_id
from import.taxa_taxon_lists i
where i.new=true
and i.id=s.id
and i.parent_id is not null;

-- Locations. Parent_id set to null initially to avoid FK violation.
insert into locations(id, name, code, parent_id, centroid_sref, centroid_sref_system, created_on, created_by_id,
  updated_on, updated_by_id, comment, external_key, deleted, centroid_geom, boundary_geom, location_type_id, public)
select id, name, code, 1, centroid_sref, centroid_sref_system, created_on, created_by_id,
  updated_on, updated_by_id, comment, external_key, deleted, centroid_geom, boundary_geom, location_type_id, public
from import.locations i
where i.new=true;

-- Fix up parent FK
update locations s
set parent_id=i.parent_id
from import.locations i
where i.new=true
and i.id=s.id
and i.parent_id is not null;

-- Locations websites
insert into locations_websites(id, location_id, website_id, created_on, created_by_id, deleted, updated_on, updated_by_id)
select id, location_id, website_id, created_on, created_by_id, deleted, updated_on, updated_by_id
from import.locations_websites i
where i.new=true;

-- Surveys
insert into surveys(id, title, owner_id, description, website_id, created_on, created_by_id, updated_on, updated_by_id,
  deleted, parent_id, core_validation_rules)
select id, title, owner_id, description, website_id, created_on, created_by_id, updated_on, updated_by_id,
  deleted, null, core_validation_rules
from import.surveys i
where i.new=true;

-- Fix up parent FK
update surveys s
set parent_id=i.parent_id
from import.surveys i
where i.new=true
and i.id=s.id
and i.parent_id is not null;

-- Samples. Leave out parent_id, location_id and sample_method_id FKs to fix up later.
insert into samples(id, survey_id, location_id, date_start, date_end, date_type, entered_sref, entered_sref_system,
  location_name, created_on, created_by_id, updated_on, updated_by_id, comment, external_key, sample_method_id, deleted,
  geom, recorder_names, parent_id, input_form, group_id, privacy_precision, record_status, verified_by_id, verified_on,
  licence_id)
select id, survey_id, location_id, date_start, date_end, date_type, entered_sref, entered_sref_system,
  location_name, created_on, created_by_id, updated_on, updated_by_id, comment, external_key, sample_method_id, deleted,
  geom, recorder_names, 1, input_form, group_id, privacy_precision, record_status, verified_by_id, verified_on,
  licence_id
from import.samples i
where i.new=true;

-- Fix up parent FK
update samples s
set parent_id=i.parent_id
from import.samples i
where i.new=true
and i.id=s.id
and i.parent_id is not null;

-- Occurrences
insert into occurrences(id, sample_id, determiner_id, confidential, created_on, created_by_id, updated_on,
  updated_by_id, website_id, external_key, comment, taxa_taxon_list_id, deleted, record_status, verified_by_id,
  verified_on, downloaded_flag, downloaded_on, all_info_in_determinations, zero_abundance, last_verification_check_date,
  training, sensitivity_precision, release_status, record_substatus, record_decision_source, import_guid, metadata)
select id, sample_id, determiner_id, confidential, created_on, created_by_id, updated_on,
  updated_by_id, website_id, external_key, comment, taxa_taxon_list_id, deleted, record_status, verified_by_id,
  verified_on, downloaded_flag, downloaded_on, all_info_in_determinations, zero_abundance, last_verification_check_date,
  training, sensitivity_precision, release_status, record_substatus, record_decision_source, import_guid, metadata::json
from import.occurrences i
where i.new=true;

-- Determinations
insert into determinations(id, occurrence_id, email_address, person_name, cms_ref, taxa_taxon_list_id, comment,
  taxon_extra_info, deleted, created_by_id, created_on, updated_by_id, updated_on, determination_type, taxon_details,
  taxa_taxon_list_id_list)
select id, occurrence_id, email_address, person_name, cms_ref, taxa_taxon_list_id, comment,
  taxon_extra_info, deleted, created_by_id, created_on, updated_by_id, updated_on, determination_type, taxon_details,
  taxa_taxon_list_id_list
from import.determinations i
where i.new=true;

-- Form structure blocks. Leave out parent_id, location_id and sample_method_id FKs to fix up later.
insert into form_structure_blocks(id, name, parent_id, survey_id, type, weight)
select id, name, parent_id, survey_id, type, weight
from import.form_structure_blocks i
where i.new=true;

-- Fix up parent FK
update form_structure_blocks s
set parent_id=i.parent_id
from import.form_structure_blocks i
where i.new=true
and i.id=s.id
and i.parent_id is not null;

-- Survey attributes
insert into survey_attributes(id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  validation_rules, termlist_id, multi_value, public, deleted, system_function, source_id, caption_i18n, term_name,
  term_identifier, allow_ranges, reporting_category_id, description_i18n, description, unit, image_path)
select id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  validation_rules, termlist_id, multi_value, public, deleted, system_function, source_id, caption_i18n, term_name,
  term_identifier, allow_ranges, null /*r eporting_category_id */, description_i18n, description, unit, image_path
from import.survey_attributes i
where i.new=true;

-- Sample attributes
insert into sample_attributes(id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  applies_to_location, validation_rules, termlist_id, multi_value, public, deleted, applies_to_recorder,
  system_function, source_id, caption_i18n, term_name, term_identifier, allow_ranges, reporting_category_id,
  description_i18n, description, unit, image_path)
select id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  applies_to_location, validation_rules, termlist_id, multi_value, public, deleted, applies_to_recorder,
  system_function, source_id, caption_i18n, term_name, term_identifier, allow_ranges, null /* reporting_category_id */,
  description_i18n, description, unit, image_path
from import.sample_attributes i
where i.new=true;

-- Occurrence attributes
insert into occurrence_attributes(id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  validation_rules, termlist_id, multi_value, public, deleted, system_function, source_id, caption_i18n, term_name,
  term_identifier, allow_ranges, reporting_category_id, description_i18n, description, unit, image_path)
select id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  validation_rules, termlist_id, multi_value, public, deleted, system_function, source_id, caption_i18n, term_name,
  term_identifier, allow_ranges, null /*r eporting_category_id */, description_i18n, description, unit, image_path
from import.occurrence_attributes i
where i.new=true;

-- Location attributes
insert into location_attributes(id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  validation_rules, termlist_id, multi_value, public, deleted, system_function, source_id, caption_i18n, term_name,
  term_identifier, allow_ranges, reporting_category_id, description_i18n, description, unit, image_path)
select id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  validation_rules, termlist_id, multi_value, public, deleted, system_function, source_id, caption_i18n, term_name,
  term_identifier, allow_ranges, null /*r eporting_category_id */, description_i18n, description, unit, image_path
from import.location_attributes i
where i.new=true;

-- Person attributes
insert into person_attributes(id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  validation_rules, termlist_id, multi_value, public, deleted, synchronisable, system_function, source_id, caption_i18n,
  term_name, term_identifier, allow_ranges, reporting_category_id, description_i18n, description, unit, image_path)
select id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  validation_rules, termlist_id, multi_value, public, deleted, synchronisable, system_function, source_id, caption_i18n,
  term_name, term_identifier, allow_ranges, null /*r eporting_category_id */, description_i18n, description, unit, image_path
from import.person_attributes i
where i.new=true;

-- Taxa taxon list attributes
insert into taxa_taxon_list_attributes(id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  validation_rules, termlist_id, multi_value, public, deleted, system_function, source_id, caption_i18n, term_name,
  term_identifier, allow_ranges, reporting_category_id, description_i18n, description, unit, image_path)
select id, caption, data_type, created_on, created_by_id, updated_on, updated_by_id,
  validation_rules, termlist_id, multi_value, public, deleted, system_function, source_id, caption_i18n, term_name,
  term_identifier, allow_ranges, null /*r eporting_category_id */, description_i18n, description, unit, image_path
from import.taxa_taxon_list_attributes i
where i.new=true;

-- Survey attributes websites
insert into survey_attributes_websites(id, website_id, survey_attribute_id, created_on, created_by_id, deleted,
  form_structure_block_id, validation_rules, weight, control_type_id, default_text_value, default_float_value,
  default_int_value, default_date_start_value, default_date_end_value, default_date_type_value, default_upper_value)
select id, website_id, survey_attribute_id, created_on, created_by_id, deleted,
  form_structure_block_id, validation_rules, weight, control_type_id, default_text_value, default_float_value,
  default_int_value, default_date_start_value, default_date_end_value, default_date_type_value, default_upper_value
from import.survey_attributes_websites i
where i.new=true;

-- Sample attributes websites
insert into sample_attributes_websites(id, website_id, sample_attribute_id, created_on, created_by_id,
  restrict_to_survey_id, deleted, form_structure_block_id, validation_rules, weight, control_type_id,
  default_text_value, default_float_value, default_int_value, default_date_start_value, default_date_end_value,
  default_date_type_value, restrict_to_sample_method_id, default_upper_value)
select id, website_id, sample_attribute_id, created_on, created_by_id,
  restrict_to_survey_id, deleted, form_structure_block_id, validation_rules, weight, control_type_id,
  default_text_value, default_float_value, default_int_value, default_date_start_value, default_date_end_value,
  default_date_type_value, restrict_to_sample_method_id, default_upper_value
from import.sample_attributes_websites i
where i.new=true;

-- Occurrence attributes websites
insert into occurrence_attributes_websites(id, website_id, occurrence_attribute_id, created_on, created_by_id,
  restrict_to_survey_id, deleted, form_structure_block_id, validation_rules, weight, control_type_id,
  default_text_value, default_float_value, default_int_value, default_date_start_value, default_date_end_value,
  default_date_type_value, default_upper_value)
select id, website_id, occurrence_attribute_id, created_on, created_by_id,
  restrict_to_survey_id, deleted, form_structure_block_id, validation_rules, weight, control_type_id,
  default_text_value, default_float_value, default_int_value, default_date_start_value, default_date_end_value,
  default_date_type_value, default_upper_value
from import.occurrence_attributes_websites i
where i.new=true;

-- Location attributes websites
insert into location_attributes_websites(id, website_id, location_attribute_id, created_on, created_by_id,
  restrict_to_survey_id, deleted, form_structure_block_id, validation_rules, weight, control_type_id,
  default_text_value, default_float_value, default_int_value, default_date_start_value, default_date_end_value,
  default_date_type_value, restrict_to_location_type_id, default_upper_value)
select id, website_id, location_attribute_id, created_on, created_by_id,
  restrict_to_survey_id, deleted, form_structure_block_id, validation_rules, weight, control_type_id,
  default_text_value, default_float_value, default_int_value, default_date_start_value, default_date_end_value,
  default_date_type_value, restrict_to_location_type_id, default_upper_value
from import.location_attributes_websites i
where i.new=true;

-- Taxon lists taxa taxon list attributes
insert into taxon_lists_taxa_taxon_list_attributes(id, taxon_list_id, taxa_taxon_list_attribute_id, created_on,
  created_by_id, deleted, form_structure_block_id, validation_rules, weight, control_type_id, default_text_value,
  default_float_value, default_int_value, default_date_start_value, default_date_end_value, default_date_type_value,
  default_upper_value)
select id, taxon_list_id, taxa_taxon_list_attribute_id, created_on,
  created_by_id, deleted, form_structure_block_id, validation_rules, weight, control_type_id, default_text_value,
  default_float_value, default_int_value, default_date_start_value, default_date_end_value, default_date_type_value,
  default_upper_value
from import.taxon_lists_taxa_taxon_list_attributes i
where i.new=true;

-- Survey attributes values
insert into survey_attribute_values(id, survey_id, survey_attribute_id, text_value, float_value, int_value,
  date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on, updated_by_id,
  deleted, upper_value)
select id, survey_id, survey_attribute_id, text_value, float_value, int_value,
  date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on, updated_by_id,
  deleted, upper_value
from import.survey_attribute_values i
where i.new=true;

-- Sample attributes values
insert into sample_attribute_values(id, sample_id, sample_attribute_id, text_value, float_value, int_value,
  date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on, updated_by_id,
  deleted, upper_value)
select id, sample_id, sample_attribute_id, text_value, float_value, int_value,
  date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on, updated_by_id,
  deleted, upper_value
from import.sample_attribute_values i
where i.new=true;

-- Occurrence attributes values
insert into occurrence_attribute_values(id, occurrence_id, occurrence_attribute_id, text_value, float_value,
  int_value, date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on, updated_by_id,
  deleted, upper_value)
select id, occurrence_id, occurrence_attribute_id, text_value, float_value,
  int_value, date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on, updated_by_id,
  deleted, upper_value
from import.occurrence_attribute_values i
where i.new=true;

-- Location attributes values
insert into location_attribute_values(id, location_id, location_attribute_id, text_value, float_value,
  int_value, date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on, updated_by_id,
  deleted, upper_value)
select id, location_id, location_attribute_id, text_value, float_value,
  int_value, date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on, updated_by_id,
  deleted, upper_value
from import.location_attribute_values i
where i.new=true;

-- Person attributes values
insert into person_attribute_values(id, person_id, person_attribute_id, text_value, float_value, int_value,
  date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on, updated_by_id,
  deleted, upper_value)
select id, person_id, person_attribute_id, text_value, float_value, int_value,
  date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on, updated_by_id,
  deleted, upper_value
from import.person_attribute_values i
where i.new=true;

-- Taxa taxon list attributes values
insert into taxa_taxon_list_attribute_values(id, taxa_taxon_list_id, taxa_taxon_list_attribute_id, text_value,
  float_value, int_value, date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on,
  updated_by_id, deleted, geom_value, upper_value)
select id, taxa_taxon_list_id, taxa_taxon_list_attribute_id, text_value,
  float_value, int_value, date_start_value, date_end_value, date_type_value, created_on, created_by_id, updated_on,
  updated_by_id, deleted, geom_value, upper_value
from import.taxa_taxon_list_attribute_values i
where i.new=true;

insert into work_queue(task, entity, record_id, params, cost_estimate, priority, created_on)
select 'task_cache_builder_update', 'occurrence', id, null, 100, 2, now()
from import.occurrences where new=true order by id;

insert into work_queue(task, entity, record_id, params, cost_estimate, priority, created_on)
select 'task_cache_builder_update', 'sample', id, null, 100, 2, now()
from import.samples where new=true order by id;