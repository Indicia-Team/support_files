(function ($) {
  $(document).ready(function() {
    $('#dynamic-taxon_list_filter option[value=""]').text("<all>");
    $('#dynamic-country_region_ttl_attr_id option[value=""]').text("<all>");
    $('#dynamic-species_presence_filter option[value=""]').text("<all>");
    // Default species presence to "P"
    $('#dynamic-common_names_language option[value=""]').text("<none>");
  });
}) (jQuery);