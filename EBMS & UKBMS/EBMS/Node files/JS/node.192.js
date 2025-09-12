//Only show Butterfly, Moth, Dragonfly, Hymenopteran taxon groups
jQuery(document).ready(function($) {
    $('#report-taxon_group_id').children('option').each(function() {
      if ($(this).val() != 104 &&
          $(this).val() != 107 &&
          $(this).val() != 110 &&
          $(this).val() != 114) {
        $(this).hide();
      }
    });
});