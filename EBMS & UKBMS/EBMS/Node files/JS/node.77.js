$(window).on('load', function () {
  // Get the column position of each of the extra abundance attributes we will use
  // so we can reference the class of html tags in the column which is of the form "col-<position>"
  var idxQtyInside = $('th[data-field="#attr_value:occurrence:133#"]').index() - 1;
  var idxQtyOutside = $('th[data-field="#attr_value:occurrence:898#"]').index() - 1;
  var idxQtyTransect = $('th[data-field="#attr_value:occurrence:911#"]').index() - 1;
  // Hide the survey specific columns by default
  $('[data-field="location.parent.verbatim_locality"]').hide();
  $('.field-location--parent--verbatim-locality').hide();
  $('.col-'+idxQtyInside).hide();
  $('.col-'+idxQtyOutside).hide();
  $('.col-'+idxQtyTransect).hide();
});

$('#filter-survey').on('change', function() {
  var idxQtyInside = $('th[data-field="#attr_value:occurrence:133#"]').index() - 1;
  var idxQtyOutside = $('th[data-field="#attr_value:occurrence:898#"]').index() - 1;
  var idxQtyTransect = $('th[data-field="#attr_value:occurrence:911#"]').index() - 1;
  // Transect survey, we want to show standard count column and Outside Transect Count
  if ($('#filter-survey').val() == 562) {
    $('[data-field="occurrence.individual_count"]').show();
    $('.field-occurrence--individual-count').show();
    $('.col-' + idxQtyTransect).show();

    $('[data-field="location.parent.verbatim_locality"]').hide();
    $('.field-location--parent--verbatim-locality').hide();
    $('.col-'+idxQtyInside).hide();
    $('.col-'+idxQtyOutside).hide();
  // 15-Min Count, just show standard count
  } else if ($('#filter-survey').val() == 565) {
    $('[data-field="occurrence.individual_count"]').show();
    $('.field-occurrence--individual-count').show();
    
    $('[data-field="location.parent.verbatim_locality"]').hide();
    $('.field-location--parent--verbatim-locality').hide();
    $('.col-'+idxQtyInside).hide();
    $('.col-'+idxQtyOutside).hide();
    $('.col-'+idxQtyTransect).hide();
    // Moth trap, show inside and outside quantity
  } else if ($('#filter-survey').val() == 681) {
    $('.col-'+idxQtyInside).show();
    $('.col-'+idxQtyOutside).show();
    
    $('[data-field="location.parent.verbatim_locality"]').hide();
    $('.field-location--parent--verbatim-locality').hide();
    $('[data-field="occurrence.individual_count"]').hide();
    $('.field-occurrence--individual-count').hide();
    $('.col-'+idxQtyTransect).hide();
    // Bait Trap, just show the Parent Location
  } else if ($('#filter-survey').val() == 1032) {
    $('[data-field="location.parent.verbatim_locality"]').show();
    $('.field-location--parent--verbatim-locality').show();
    $('[data-field="occurrence.individual_count"]').hide();
    $('.field-occurrence--individual-count').hide();
    $('.col-'+idxQtyInside).hide();
    $('.col-'+idxQtyOutside).hide();
    $('.col-'+idxQtyTransect).hide();
  } else {
    // If anything other than a specific survey is selected, then just show the standard count
    $('[data-field="occurrence.individual_count"]').show();
    $('.field-occurrence--individual-count').show();
    
    $('[data-field="location.parent.verbatim_locality"]').hide();
    $('.field-location--parent--verbatim-locality').hide();
    $('.col-'+idxQtyInside).hide();
    $('.col-'+idxQtyOutside).hide();
    $('.col-'+idxQtyTransect).hide();
  }
});