jQuery(window).on('load', function() {
  detect_organisation_option();
});

// School or community group change
jQuery('#smpAttr\\:2103').on('change', function() {
  detect_organisation_option();
});

function detect_organisation_option() {
  // Community group
  if (jQuery('#smpAttr\\:2103 option:selected').val() == '24892') {
    // Make sure all tabs showing
    jQuery('#tab-where-tab').show();
    jQuery('#tab-otherinformation-tab').show();
    jQuery('#tab-listofrecords-tab').show();
    
    // Change tab names
    jQuery('#tab-where-tab span:first-child').text('Community Group Details');
    jQuery('#tab-otherinformation-tab span:first-child').text('Contact Details');
    // Make sure we clear the Name field if the user decides to change their mind
    // and switch from School to Community Group and a name had previously been entered
    jQuery('#sample\\:location_name').val('');
    jQuery("label[for='sample\\:location_name']").text("Community Group Name");
    // Make sure the School Year cleared too for same reason
    jQuery('#smpAttr\\:2104').val('');
    // Hide same field
    jQuery('#ctrl-wrap-smpAttr-2104').hide();
  }
  else if (jQuery('#smpAttr\\:2103 option:selected').val() == '24893') {
    jQuery('#tab-where-tab').show();
    jQuery('#tab-otherinformation-tab').show();
    jQuery('#tab-listofrecords-tab').show();
    
    jQuery('#tab-where-tab span:first-child').text('School Details');
    jQuery('#tab-otherinformation-tab span:first-child').text('Teacher Details');
    
    jQuery('#sample\\:location_name').val('');
    jQuery("label[for='sample\\:location_name']").text("School Name");
    jQuery('#ctrl-wrap-smpAttr-2104').show();
  } else {
    // Only show Introduction tab to begin with
    jQuery('#tab-where-tab').hide();
    jQuery('#tab-otherinformation-tab').hide();
    jQuery('#tab-listofrecords-tab').hide();
  }
}