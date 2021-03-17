jQuery(document).ready(function () {
  //Code to automatically select required page links when user selects project type.

  // Get group_id from URL to check if we are editing as we don't want to auto-set options when editing
  const urlParamsString = window.location.search;
  const urlParams = new URLSearchParams(urlParamsString);
  
  if (!urlParams.get('group_id')) {
  	//Hide the links management list, as this is setup automatically
  	jQuery('#group-pages-fieldset').hide();
  	// Setup links as mode is selected
  	jQuery('#group\\:group_type_id').on('change', function() {
  	  //NPMS Mode
      if (jQuery(this).val() == 15068) {
      
        // We need the third row again if it was hidden by Standard Mode
      	jQuery('[name="group+\\:pages\\:\\:2\\:0"]').show();
      	jQuery('[name="group+\\:pages\\:\\:2\\:1"]').show();
	  	jQuery('[name="group+\\:pages\\:\\:2\\:2"]').show();
	  	jQuery('[name="group+\\:pages\\:\\:2\\:deleted"]').show();
    	// Put data entry selection page onto existing rows
      	jQuery('[name="group+\\:pages\\:\\:0\\:0"] option[value="node/25:NPMS Mode - data entry level selection"]').prop('selected', true);  
      	jQuery('[name="group+\\:pages\\:\\:0\\:1"]').val('Enter data'); 
	    // Put plot management onto existing rows
      	jQuery('[name="group+\\:pages\\:\\:1\\:0"] option[value="project-plot-list-npms-mode:NPMS Mode - project plot list"]').prop('selected', true);
      	jQuery('[name="group+\\:pages\\:\\:1\\:1"]').val('Manage Plots'); 
      	jQuery('[name="group+\\:pages\\:\\:1\\:2"] option[value="t:Available only to group admins"]').prop('selected', true);
      	// Put Wildflower onto one of the existing grid rows
      	jQuery('[name="group+\\:pages\\:\\:2\\:0"] option[value="node/wildflower-data-entry:NPMS Mode - Wildflower"]').prop('selected', true);
      	jQuery('[name="group+\\:pages\\:\\:2\\:1"]').val('Wildflower'); 
      	jQuery('[name="group+\\:pages\\:\\:2\\:2"] option[value="t:Available only to group admins"]').prop('selected', true);
      	// Add new rows to allow us to setup Indicator/Inventory
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::3:0" value="node/indicator-data-entry:NPMS Mode - Indicator">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::3:1" value="Indicator">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::3:2" value="t:Available only to group admins">');
	  
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::4:0" value="node/inventory-data-entry:NPMS Mode - Inventory">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::4:1" value="Inventory">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::4:2" value="t:Available only to group admins">');

      }
    
      //Standard Mode
      if (jQuery(this).val() == 15069) {
    	
      	jQuery('[name="group+\\:pages\\:\\:0\\:0"] option[value="standard-mode-data-entry:Standard Mode - data entry"]').prop('selected', true);  
      	jQuery('[name="group+\\:pages\\:\\:0\\:1"]').val('Enter data'); 

      	jQuery('[name="group+\\:pages\\:\\:1\\:0"] option[value="project-plot-list-standard-mode:Standard Mode - project plot list"]').prop('selected', true);
      	jQuery('[name="group+\\:pages\\:\\:1\\:1"]').val('Manage Plots'); 
      	jQuery('[name="group+\\:pages\\:\\:1\\:2"] option[value="t:Available only to group admins"]').prop('selected', true);
      	
      	// We don't need the third rows or the additional rows used for all the NPMS forms in Standard Mode
      	jQuery('[name="group+:pages::2:0"]').val('');
      	jQuery('[name="group+:pages::2:1"]').val('');
      	jQuery('[name="group+:pages::2:2"]').val('');
      	
      	jQuery('[name="group+:pages::3:0"]').remove(); 
      	jQuery('[name="group+:pages::3:1"]').remove();
      	jQuery('[name="group+:pages::3:2"]').remove();  
      	
      	jQuery('[name="group+:pages::4:0"]').remove(); 
      	jQuery('[name="group+:pages::4:1"]').remove();
      	jQuery('[name="group+:pages::4:2"]').remove();

      }
  	});
  }
});