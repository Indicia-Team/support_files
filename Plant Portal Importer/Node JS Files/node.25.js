jQuery(document).ready(function () {
  //Code to automatically select required page links when user selects project type.

  // Get group_id from URL to check if we are editing as we don't want to auto-set options when editing
  const urlParamsString = window.location.search;
  const urlParams = new URLSearchParams(urlParamsString);
  
  jQuery('#level-select').on('change', function() {

    if (jQuery(this).val() == 'wildflower-option') {
		  window.location="node/wildflower-data-entry?group_id=" + urlParams.get('group_id');
    }
    
    if (jQuery(this).val() == 'indicator-option') {
		  window.location="node/indictor-data-entry?group_id=" + urlParams.get('group_id');
    }

	 if (jQuery(this).val() == 'inventory-option') {
		 window.location="node/inventory-data-entry?group_id=" + urlParams.get('group_id');
	 }
      
  });
});