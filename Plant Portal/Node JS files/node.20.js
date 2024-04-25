jQuery(document).ready(function () {
  //Code to automatically select required page links when user selects project type.

  // Get group_id to pass to data entry form
  const urlParamsString = window.location.search;
  const urlParams = new URLSearchParams(urlParamsString);
  
  jQuery('#level-select').on('change', function() {

    if (jQuery(this).val() == 'wildflower-option') {
		  window.location="npms-mode-wildflower-data-entry?group_id=" + urlParams.get('group_id');
    }
    
    if (jQuery(this).val() == 'indicator-option') {
		  window.location="npms-mode-indicator-data-entry?group_id=" + urlParams.get('group_id');
    }

	 if (jQuery(this).val() == 'inventory-option') {
		 window.location="inventory-data-entry?group_id=" + urlParams.get('group_id');
	 }
      
  });
});