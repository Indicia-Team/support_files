jQuery(document).ready(function () {
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
  jQuery('<br>').insertBefore('.npms-mode-data-entry-selection');
});