// Note there are IDs in this script which are setup for the BRC Dev Warehouse. 
jQuery(document).ready(function () {
  // Make mandatory and Limit to 250 characters
  jQuery('#entry_form').submit(function(e) {
    if (jQuery('#group\\:description').val().length < 1) {
      alert('Please make sure the project description field is filled in');
      e.preventDefault();
    }
    if (jQuery('#group\\:description').val().length > 250 ) {
      alert('Please make sure the project description field length is 250 characters or less');
      e.preventDefault();
    }
  });

  //Code to automatically select required page links when user selects project type.
  
  //Always hide the links management list, as this is setup automatically
  jQuery('#group-pages-fieldset').hide();

  // Get group_id from URL to check if we are editing as we don't want to auto-set options when editing
  const urlParamsString = window.location.search;
  const urlParams = new URLSearchParams(urlParamsString);
  
  // Always make sure we start with 2 rows
  function resets_rows() {
    jQuery('[name="groupComplex:pages::2:0"]').remove(); 
    jQuery('[name="groupComplex:pages::2:1"]').remove();
    jQuery('[name="groupComplex:pages::2:2"]').remove();  
      	
    jQuery('[name="groupComplex:pages::3:0"]').remove(); 
    jQuery('[name="groupComplex:pages::3:1"]').remove();
    jQuery('[name="groupComplex:pages::3:2"]').remove();
      	
    jQuery('[name="groupComplex:pages::4:0"]').remove(); 
    jQuery('[name="groupComplex:pages::4:1"]').remove();
    jQuery('[name="groupComplex:pages::4:2"]').remove();
    
    jQuery('[name="groupComplex:pages::5:0"]').remove(); 
    jQuery('[name="groupComplex:pages::5:1"]').remove();
    jQuery('[name="groupComplex:pages::5:2"]').remove();
    
    jQuery('[name="groupComplex:pages::6:0"]').remove(); 
    jQuery('[name="groupComplex:pages::6:1"]').remove();
    jQuery('[name="groupComplex:pages::6:2"]').remove();
    
    jQuery('[name="groupComplex:pages::7:0"]').remove(); 
    jQuery('[name="groupComplex:pages::7:1"]').remove();
    jQuery('[name="groupComplex:pages::7:2"]').remove();
    
	jQuery('[name="groupComplex:pages::8:0"]').remove(); 
    jQuery('[name="groupComplex:pages::8:1"]').remove();
    jQuery('[name="groupComplex:pages::8:2"]').remove();
    
    jQuery('[name="groupComplex:pages::9:0"]').remove(); 
    jQuery('[name="groupComplex:pages::9:1"]').remove();
    jQuery('[name="groupComplex:pages::9:2"]').remove();
    
	jQuery('[name="groupComplex:pages::10:0"]').remove(); 
    jQuery('[name="groupComplex:pages::10:1"]').remove();
    jQuery('[name="groupComplex:pages::10:2"]').remove();
    
    jQuery('[name="groupComplex:pages::11:0"]').remove(); 
    jQuery('[name="groupComplex:pages::11:1"]').remove();
    jQuery('[name="groupComplex:pages::11:2"]').remove();
    
	jQuery('[name="groupComplex:pages::12:0"]').remove(); 
    jQuery('[name="groupComplex:pages::12:1"]').remove();
    jQuery('[name="groupComplex:pages::12:2"]').remove();
  }
  
  if (!urlParams.get('group_id')) {
  	// Setup links as mode is selected
  	jQuery('#group\\:group_type_id').on('change', function() {
  	  //NPMS Mode
      if (jQuery(this).val() == 18067) {
      // Current version for Live Warehouse
      //if (jQuery(this).val() == 18067) {  
        // Always make sure we start with 2 rows
		resets_rows();

    	// Put data entry selection page onto existing rows
      	jQuery('[name="groupComplex\\:pages\\:\\:0\\:0"] option[value="npms-mode-data-entry-selection:NPMS Mode - data entry level selection"]').prop('selected', true);  
      	jQuery('[name="groupComplex\\:pages\\:\\:0\\:1"]').val('Enter data'); 
      	
      	// Put My Samples list onto new row
      	jQuery('[name="groupComplex\\:pages\\:\\:1\\:0"] option[value="my-samples-npms-mode:NPMS Mode - My samples"]').prop('selected', true);
      	jQuery('[name="groupComplex\\:pages\\:\\:1\\:1"]').val('My samples');
      	
      	// Add new row to allow admins to see the samples for the project
      	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::2:0" value="samples-admin-npms-mode:NPMS Mode - Samples administration">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::2:1" value="Samples administration">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::2:2" value="t:Available only to group admins">');
      	
      	// Add new row to allow us to see the squares for the project
      	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::3:0" value="list-squares-npms-mode:NPMS Mode - List squares">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::3:1" value="List squares">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::3:2" value="f:Available only to group members">');
	  	
	  	// Admins get a special screen for square admins where the squares can be added and edited
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::4:0" value="squares-admin-npms-mode:NPMS Mode - Squares administration">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::4:1" value="Squares administration">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::4:2" value="t:Available only to group admins">');

      	
      	// Add new rows to allow us to setup Wildflower/Indicator/Inventory
      	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::5:0" value="wildflower-data-entry:NPMS Mode - Wildflower">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::5:1" value="Wildflower">');
      	
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::6:0" value="indicator-data-entry:NPMS Mode - Indicator">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::6:1" value="Indicator">');
	  
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::7:0" value="inventory-data-entry:NPMS Mode - Inventory">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::7:1" value="Inventory">');
	  	
	    jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::8:0" value="npms-mode-square-importer:NPMS Mode - Square importer for projects">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::8:1" value="Square importer">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::8:2" value="t:Available only to group admins">');
	  	
		// View square page for non-managers
	    jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::9:0" value="npms-mode-square-details:NPMS Mode - Square Details">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::9:1" value="Square details">');
	  	
	  	// Edit square page for project managers
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::10:0" value="npms-mode-square-administration:NPMS Mode - Square administration">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::10:1" value="Square administration">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::10:2" value="t:Available only to group admins">');
	  	
	  	// List plots for admins
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::11:0" value="list-plots-npms-mode-admin:NPMS Mode - Manage Plots (admin)">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::11:1" value="Manage plots (admin)">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::11:2" value="t:Available only to group admins">');
	  	
	  	// Edit plots for admins
	    jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::12:0" value="edit-plot-npms-mode-admin:NPMS Mode - Edit Plot (admin)">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::12:1" value="Edit plot (admin)">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::12:2" value="t:Available only to group admins">');
      }
    
      //Standard Mode
      if (jQuery(this).val() == 18068) {
      // Current version for Live Warehouse
      //if (jQuery(this).val() == 18068) {  
        // Always make sure we start with 2 rows
		resets_rows();
    	
        jQuery('[name="groupComplex\\:pages\\:\\:0\\:0"] option[value="standard-mode-data-entry:Standard Mode - data entry"]').prop('selected', true);  
      	jQuery('[name="groupComplex\\:pages\\:\\:0\\:1"]').val('Enter data'); 
      	
		jQuery('[name="groupComplex\\:pages\\:\\:1\\:0"] option[value="my-samples-standard-mode:Standard Mode - My samples"]').prop('selected', true);  
      	jQuery('[name="groupComplex\\:pages\\:\\:1\\:1"]').val('My samples'); 

		jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::2:0" value="samples-admin-standard-mode:Standard Mode - Samples administration">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::2:1" value="Samples administration">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::2:2" value="t:Available only to group admins">');

		jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::3:0" value="standard-mode-list-plots:Standard Mode - List plots">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::3:1" value="List plots">');

        jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::4:0" value="plots-admin-standard-mode:Standard Mode - Plot administration">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::4:1" value="Plots administration">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::4:2" value="t:Available only to group admins">');

		jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::5:0" value="standard-mode-plot-importer:Standard Mode - Plot importer">');
	  	jQuery('#complex-attr-grid-group-pages').append('<input type="text" name="groupComplex:pages::5:1" value="Plot importer">');

      }
  	});
  } else {
  	// Don't allow project type to be changed in edit mode
  	jQuery('#ctrl-wrap-group-group_type_id').remove();
  }
});