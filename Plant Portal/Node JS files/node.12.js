/*
 * This should be included in the the report grid @callback option
 */
function organise_project_links() {  
  // Hide the links to the data entry pages as these must be associated with a group, 
  // but are actually accessed via another page
  jQuery('.wildflower-data-entry').hide();
  jQuery('.indicator-data-entry').hide();
  jQuery('.inventory-data-entry').hide();
  
  // Remove link types for old projects. 
  // This has changed, so this bit of code should not be needed going forward once test 
  // projects are removed from system.
  jQuery('.node-wildflower-data-entry').hide();
  jQuery('.node-indicator-data-entry').hide();
  jQuery('.node-inventory-data-entry').hide();
  
  // Make sure the links aren't all on one line
  jQuery('<br>').insertBefore('.my-samples-npms-mode');
  jQuery('<br>').insertBefore('.npms-mode-data-entry-selection');
  jQuery('<br>').insertBefore('.samples-admin-npms-mode');
  jQuery('<br>').insertBefore('.squares-admin-npms-mode');
  jQuery('<br>').insertBefore('.npms-mode-square-importer');
  
  // Change grid headers
  jQuery('#my-activities-th-pages').find('a:contains("Links")').text('Project options');
  jQuery('.report-grid').find('.col-actions:first').html('Membership options');
}