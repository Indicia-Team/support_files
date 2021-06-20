jQuery(document).ready(function () {
  // Hide the links to the data entry pages as these must be associated with a group, 
  // but are actually accessed via another page
  jQuery('.node-wildflower-data-entry').hide();
  jQuery('.node-indicator-data-entry').hide();
  jQuery('.node-inventory-data-entry').hide();
  // Make sure the links aren't all on one line
  jQuery('<br>').insertBefore('.node-inventory-data-entry');
});