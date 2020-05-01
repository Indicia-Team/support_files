--To run this code, you will need to do replacements of,
-- <min_ttl_attr_id_to_process>
-- <min_occ_attr_id_to_process>
-- This will allow you to process new attributes without having to risk re-processing all existing attributes

update indicia.taxa_taxon_list_attributes
set unit = substring(caption, '\[(.*?)\]')
where id > <min_ttl_attr_id_to_process>;

update indicia.occurrence_attributes
set unit = substring(caption, '\[(.*?)\]')
where id > <min_ttl_attr_id_to_process>;

update indicia.taxa_taxon_list_attributes
set caption = replace(caption, ' [μm]', '')
where id > <min_ttl_attr_id_to_process>;

update indicia.taxa_taxon_list_attributes
set caption_i18n = replace(caption_i18n::text, ' [μm]', '')::jsonb
where id > <min_ttl_attr_id_to_process>;

update indicia.occurrence_attributes
set caption = replace(caption, ' [μm]', '')
where id > <min_occ_attr_id_to_process>;

update indicia.occurrence_attributes
set caption_i18n = replace(caption_i18n::text, ' [μm]', '')::jsonb
where id > <min_occ_attr_id_to_process>;

update indicia.taxa_taxon_list_attributes
set caption = replace(caption, ' [mm]', '')
where id > <min_ttl_attr_id_to_process>;

update indicia.taxa_taxon_list_attributes
set caption_i18n = replace(caption_i18n::text, ' [mm]', '')::jsonb
where id > <min_ttl_attr_id_to_process>;

update indicia.occurrence_attributes
set caption = replace(caption, ' [mm]', '')
where id > <min_occ_attr_id_to_process>;

update indicia.occurrence_attributes
set caption_i18n = replace(caption_i18n::text, ' [mm]', '')::jsonb
where id > <min_occ_attr_id_to_process>;

