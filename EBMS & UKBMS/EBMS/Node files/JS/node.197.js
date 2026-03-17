(function ($) {
  $(document).ready(function() {
    $('#dynamic-taxon_list_filter option[value=""]').text("<all>");
    $('#dynamic-country_region_ttl_attr_id option[value=""]').text("<all>");
    $('#dynamic-species_presence_filter option[value=""]').text("<all>");
    $('#dynamic-day_active_moths option[value=""]').text("<all>");
    $('#dynamic-common_names_language option[value=""]').text("<none>");
    show_hide_day_active_moths_checkbox();
  });
  $('#dynamic-taxon_list_filter').change(function() {
    show_hide_day_active_moths_checkbox();
  });
  
  function show_hide_day_active_moths_checkbox() {
    if ($('#dynamic-taxon_list_filter').val() === '260') {
      $('#ctrl-wrap-dynamic-day_active_moths').show();
    } else {
      $('#ctrl-wrap-dynamic-day_active_moths').hide();
      $('#dynamic-day_active_moths').val('');
    }
  }
}) (jQuery);