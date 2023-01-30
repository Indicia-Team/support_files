// Always default filter to current year
jQuery(window).on('load', function() {
  // Only set default if user hasn't already selected the year
  if (!jQuery('#dynamic-year_sort_order').val()) {
    var theYear = new Date().getFullYear();
    // Need to use minus because of the way the lookup ordering works
    theYear = '-' + theYear;
    jQuery('#dynamic-year_sort_order option[value="' + theYear + '"]').prop('selected', true);
    // Check for the presence of the grid otherwise the page 
    // gets into a loop reloading and firing clicks
    if (!jQuery('.report-grid-container').length) {
      jQuery('#run-report').trigger('click');
    }
  }
});