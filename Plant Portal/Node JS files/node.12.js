/*
 * This should be included in the the report grid @callback option
 */
function organise_project_links() {  
  // NPMS MODE LINKS

  // Hide the links that are associated with a group but are accessed via other pages 
  // so shouldn't be in the links list. 
  jQuery('.wildflower-data-entry').hide();
  jQuery('.indicator-data-entry').hide();
  jQuery('.inventory-data-entry').hide();
  jQuery('.npms-mode-square-details').hide();
  jQuery('.npms-mode-square-administration').hide();
  jQuery('.list-plots-npms-mode-admin').hide();
  jQuery('.edit-plot-npms-mode-admin').hide();
  
  // Remove link types for old projects. 
  // This has changed, so this bit of code should not be needed going forward once test 
  // projects are removed from system.
  jQuery('.node-wildflower-data-entry').hide();
  jQuery('.node-indicator-data-entry').hide();
  jQuery('.node-inventory-data-entry').hide();
  
  // Make sure the links aren't all on one line
  jQuery('<br>').insertBefore('.my-samples-npms-mode');
  jQuery('<br>').insertBefore('.npms-mode-data-entry-selection');
  jQuery('<br>').insertBefore('.npms-mode-square-importer');
  jQuery('<br>').insertBefore('.samples-admin-npms-mode');
  jQuery('<br>').insertBefore('.squares-admin-npms-mode');

  // STANDARD MODE LINKS
  jQuery('.standard-mode-edit-plot').hide();
  jQuery('.standard-mode-plot-group-admin').hide();
  jQuery('.standard-mode-maintain-plot-group').hide();
  jQuery('.standard-mode-my-plot-groups').hide();

  jQuery('<br>').insertBefore('.standard-mode-data-entry');
  jQuery('<br>').insertBefore('.standard-mode-list-plots');
  jQuery('<br>').insertBefore('.samples-admin-standard-mode');
  jQuery('<br>').insertBefore('.plots-admin-standard-mode');
  jQuery('<br>').insertBefore('.standard-mode-plot-importer');
  
  // Change grid headers
  jQuery('#my-activities-th-pages').find('a:contains("Links")').text('Project options');
  jQuery('.report-grid').find('.col-actions:first').html('Membership options');
}