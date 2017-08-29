
jQuery(document).ready(function($) {
  $('#imp-sref-system').change(function () {
    $('#imp-sref').val('');
  });
  
  $('.scEarthwormCountCell').show();
  $('.deh-required').hide();
  if ($('#samples-grid').find('.empty-row').length !== 0) {
    //If empty row exists, then it means no pit created yet, so hide the edit pit help
    $('.edit-pit-help').hide();
  } else {
    $('.first-pit-help').hide();
  }
  default_ecosystem_type_in_add_mode();
  //Note these need changing when the sort order changes
  function default_ecosystem_type_in_add_mode() {
    $('#sc\\:adult-soil-0\\:\\:occAttr\\:538').val(6105);
    $('#sc\\:adult-soil-1\\:\\:occAttr\\:538').val(6107);
    $('#sc\\:adult-soil-2\\:\\:occAttr\\:538').val(6106);
    
    $('#sc\\:immature-soil-0\\:\\:occAttr\\:538').val(6105);
    $('#sc\\:immature-soil-1\\:\\:occAttr\\:538').val(6107);
    $('#sc\\:immature-soil-2\\:\\:occAttr\\:538').val(6106);
    
    $('#sc\\:adult-mustard-0\\:\\:occAttr\\:538').val(6105);
    $('#sc\\:adult-mustard-1\\:\\:occAttr\\:538').val(6107);
    $('#sc\\:adult-mustard-2\\:\\:occAttr\\:538').val(6106);
    
    $('#sc\\:immature-mustard-0\\:\\:occAttr\\:538').val(6105);
    $('#sc\\:immature-mustard-1\\:\\:occAttr\\:538').val(6107);
    $('#sc\\:immature-mustard-2\\:\\:occAttr\\:538').val(6106);
  }
});

