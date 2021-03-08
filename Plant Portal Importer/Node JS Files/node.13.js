jQuery(document).ready(function () {
  //Code to automatically select required page links when user selects project type.

  // Get group_id from URL to check if we are editing as we don't want to auto-set options when editing
  const urlParamsString = window.location.search;
  const urlParams = new URLSearchParams(urlParamsString);
  
  if (!urlParams.get('group_id')) {
  	//NPMS Mode
  	jQuery('#group\\:group_type_id').on('change', function() {
      if (jQuery(this).val() == 15068) {
    
      	jQuery('[name="group+\\:pages\\:\\:0\\:0"] option[value="node/25\\:NPMS Mode - data entry level selection"]').prop('selected', true);  
      	jQuery('[name="group+\\:pages\\:\\:0\\:1"]').val('Enter data'); 

      	jQuery('[name="group+\\:pages\\:\\:1\\:0"] option[value="project-plot-list-npms-mode\\:NPMS Mode - project plot list"]').prop('selected', true);
      	jQuery('[name="group+\\:pages\\:\\:1\\:1"]').val('Manage Plots'); 
      	jQuery('[name="group+\\:pages\\:\\:1\\:2"] option[value="t\\:Available only to group admins"]').prop('selected', true);

      }
    
      //Standard Mode
      if (jQuery(this).val() == 15069) {
    
      	jQuery('[name="group+\\:pages\\:\\:0\\:0"] option[value="standard-mode-data-entry\\:Standard Mode - data entry"]').prop('selected', true);  
      	jQuery('[name="group+\\:pages\\:\\:0\\:1"]').val('Enter data'); 

      	jQuery('[name="group+\\:pages\\:\\:1\\:0"] option[value="project-plot-list-standard-mode\\:Standard Mode - project plot list"]').prop('selected', true);
      	jQuery('[name="group+\\:pages\\:\\:1\\:1"]').val('Manage Plots'); 
      	jQuery('[name="group+\\:pages\\:\\:1\\:2"] option[value="t\\:Available only to group admins"]').prop('selected', true);

      }
      
      // We aren't going to use the 3rd row of options
      jQuery('[name="group+\\:pages\\:\\:2\\:0"]').hide();
      jQuery('[name="group+\\:pages\\:\\:2\\:1"]').hide();
	  jQuery('[name="group+\\:pages\\:\\:2\\:2"]').hide();
	  jQuery('[name="group+\\:pages\\:\\:2\\:deleted"]').hide();
	  jQuery('.ind-delete-icon').hide();
	  jQuery('.add-btn').hide();  
  	});
  }
});