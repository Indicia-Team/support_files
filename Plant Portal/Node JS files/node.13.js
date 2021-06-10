// Note there are IDs in this script which are setup for the BRC Dev Warehouse. 
jQuery(document).ready(function () {
  //Code to automatically select required page links when user selects project type.
  
  //Always hide the links management list, as this is setup automatically
  jQuery('#group-pages-fieldset').hide();

  // Get group_id from URL to check if we are editing as we don't want to auto-set options when editing
  const urlParamsString = window.location.search;
  const urlParams = new URLSearchParams(urlParamsString);
  
  // Always make sure we start with 2 rows
  function resets_rows() {
    jQuery('[name="group+:pages::2:0"]').remove(); 
    jQuery('[name="group+:pages::2:1"]').remove();
    jQuery('[name="group+:pages::2:2"]').remove();  
      	
    jQuery('[name="group+:pages::3:0"]').remove(); 
    jQuery('[name="group+:pages::3:1"]').remove();
    jQuery('[name="group+:pages::3:2"]').remove();
      	
    jQuery('[name="group+:pages::4:0"]').remove(); 
    jQuery('[name="group+:pages::4:1"]').remove();
    jQuery('[name="group+:pages::4:2"]').remove();
  }
  
  if (!urlParams.get('group_id')) {
  	// Setup links as mode is selected
  	jQuery('#group\\:group_type_id').on('change', function() {
  	  //NPMS Mode
      if (jQuery(this).val() == 15068) {
      // Current version for Live Warehouse
      //if (jQuery(this).val() == 18067) {  
        // Always make sure we start with 2 rows
		resets_rows();

    	// Put data entry selection page onto existing rows
      	jQuery('[name="group+\\:pages\\:\\:0\\:0"] option[value="npms-mode-data-entry-selection:NPMS Mode - data entry level selection"]').prop('selected', true);  
      	jQuery('[name="group+\\:pages\\:\\:0\\:1"]').val('Enter data'); 
      	// Put user square list onto existing row
      	jQuery('[name="group+\\:pages\\:\\:1\\:0"] option[value="list-squares-npms-mode:NPMS Mode - List squares"]').prop('selected', true);
      	jQuery('[name="group+\\:pages\\:\\:1\\:1"]').val('List squares');
      	
      	// Add new rows to allow us to setup Wildflower/Indicator/Inventory
      	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::2:0" value="node/wildflower-data-entry:NPMS Mode - Wildflower">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::2:1" value="Wildflower">');
      	
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::3:0" value="node/indicator-data-entry:NPMS Mode - Indicator">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::3:1" value="Indicator">');
	  
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::4:0" value="node/inventory-data-entry:NPMS Mode - Inventory">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="group+:pages::4:1" value="Inventory">');

      }
    
      //Standard Mode
      if (jQuery(this).val() == 15069) {
      // Current version for Live Warehouse
      //if (jQuery(this).val() == 18068) {  
        // Always make sure we start with 2 rows
		resets_rows();
    	
      	jQuery('[name="group+\\:pages\\:\\:0\\:0"] option[value="standard-mode-data-entry:Standard Mode - data entry"]').prop('selected', true);  
      	jQuery('[name="group+\\:pages\\:\\:0\\:1"]').val('Enter data'); 
      	
      	// Put user plot list onto existing row
      	jQuery('[name="group+\\:pages\\:\\:1\\:0"] option[value="list-plots-standard-mode:Standard Mode - List plots"]').prop('selected', true);
      	jQuery('[name="group+\\:pages\\:\\:1\\:1"]').val('List plots'); 


      }
  	});
  }
});