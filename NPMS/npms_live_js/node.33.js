// Hide filter row as it can't work with the way the report is structured
jQuery(document).ready(function($) {
  $('.filter-row').hide();
});

jQuery(window).on('load', function () {
  if(jQuery('#sampleList').length === 0) {
    jQuery('#sampleList-description').remove();
  }
});