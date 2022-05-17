/*
 * Load the textboxes into the correction column for an sample media checking report
 * Call must be placed into the @callback option on the report grid
 */
function load_textboxes_into_grid() {
  jQuery("td.col-corrected_species_name").each(function() {
    // Include the sample ID in the id attribute to make it uniquely identifiable
    // Also copy the existing text value from the report column and display it in the newly inserted textboxes.
    jQuery(this).html('<input type="text" id="' + jQuery(this).siblings('.col-id').text() + '-corrected-species" class="corrected-species"  value="' + jQuery(this).text() + '">');
  });
}

/*
 * Load the autocompletes into the correction column for an occurrence media checking report
 * Call must be placed into the @callback option on the report grid
 */
function load_species_autocomplete_boxes_into_grid() {
  var idx;
  idx=0;
  var textAndAttrValId;
  var existingCorrectionAttrValId;
  var existingCorrectionText;

  if (indiciaData.selectMode && indiciaData.selectMode == true) {
    jQuery('.ac_input').attr('readonly', 'true');
    jQuery('.ac_input').css('background-color' , '#DEDEDE');
  }

  // Cycle through the rows in the grid. Specifically we cycle through the report output column which has output data in the follecting format
  // corrected_taxon_name-occurrence_attribute_value_id
  // e.g. bumblebee-12314
  // (noting that the occurrence_attribute_value is storing a taxa_taxon_list_id, but it is the actual occurrence_attribute_value_id here we are using here)
  jQuery("td.col-corrected_species_name_id").each(function() {

    // For each autocomplete container, copy the ID into the class for future use, as we are going to
    // manipulate the ID to have the attribue_value IDs in it
    if (!jQuery('.' + 'ctrl-wrap-species_correction-' + idx).length) {
      jQuery('#ctrl-wrap-species_correction-' + idx).addClass('ctrl-wrap-species_correction-' + idx);
    }

    // For rows with an existing correction, store the taxon name & occurrence attribute value ID in a variable
    // (which has been output into one field by the report and are separated by a hyphen)
    // Once we have done that we then hide the data in this column as we never want that visible, as this
    // column will be where the corrections are placed.
    if (jQuery(this).text()) {
      textAndAttrValId = jQuery(this).text();
      jQuery(this).text('');
    } else {
      textAndAttrValId = '';
    }
    
    // Move the species autocompletes created by PHP onto the grid. Note we do this even if there is an existing correction
    // else there would be no box to fill in
    jQuery('.ctrl-wrap-species_correction-' + idx).detach().appendTo(this);
    // Show the autocompletes now they are in the correct position
    jQuery('.ctrl-wrap-species_correction-' + idx).show();
    // Make sure the species autocomplete container includes the occurrence ID in its ID attribute, so we change its ID
    // We don't lose the original ID as we copy that into the class instead)
    jQuery(this).find('div').prop(
      'id',
      'species-correction-div-container-' + jQuery(this).closest('td').siblings('.col-id').text()
    );
    // If there is an existing correction
    if (jQuery(this).text()) {
      // Store the occurrence_attribute_value ID
      existingCorrectionAttrValId = textAndAttrValId.split('-').pop();
      // Collect the correction name text, which is everything before the hyphen
      existingCorrectionText = textAndAttrValId.substring( 0, textAndAttrValId.indexOf('-' + existingCorrectionAttrValId));
      // Add the occurrence_attribute_value_id to the hidden field in the species autocomplete so the system knows which
      // attribute_value to overwrite
      jQuery('#species_correction-' + idx ).val(
        existingCorrectionAttrValId
      );
      // Fill in the text box with the name so the user can see the correction on screen
      jQuery('#species_correction-' + idx + '\\:taxon').val(
        existingCorrectionText
      );
    }
    idx++;
  });
}

/*
 * Sometimes we want the autocompletes to be off grid and hidden. 
 * This includes when we build the autocompletes initially and they are out of position,
 * or when we need to move them off the report gid during a page change or sort as the grid refresh destroys them otherwise
 */
function setup_remove_and_position_autocompletes_off_grid_handlers() {
  // When sorting, filtering or paging through the grid, we must shift the autocompletes off grid so they are not
  // destroyed by the refresh
  jQuery('th.sortable').find('a').on('click', function() {
    remove_and_position_autocompletes_off_grid();
  });
  
  // Handle when user clicks off filter row cell to fire filter
  jQuery('tr.filter-row').find('input').on('blur', function() {
      remove_and_position_autocompletes_off_grid();
  });
  
  // Handle when user presses return to invoke filter
  jQuery('tr.filter-row').find('input').on('keypress',function(e) {
    if(e.which == 13) {
      remove_and_position_autocompletes_off_grid();
    }
  });
  
  // Handle when user uses the page controls on the grid (such as Prev or Next)
  // For some reason this doesn't work with standard 'click' event handler (although "live" click used to work on old jQuery versions)
  // indiciaFns handlers the version differences
  indiciaFns.on('click', '.pager-button', {}, function () {
    remove_and_position_autocompletes_off_grid();
  });
}


function remove_and_position_autocompletes_off_grid() {
  var detachmentAreaSelector = '#autocomplete-containment-area';
  for (var i = 0; i < indiciaData.reportRowsPerPageNumber; i++) {
    jQuery('.ctrl-wrap-species_correction-' + i).hide();
    jQuery('#ctrl-wrap-species_correction-' + i).hide();

    jQuery('.ctrl-wrap-species_correction-' + i).each(function() {
      jQuery(this).detach().appendTo(detachmentAreaSelector);
    });
    jQuery('#ctrl-wrap-species_correction-' + i).each(function() {
      jQuery(this).detach().appendTo(detachmentAreaSelector);
    });
  }
}

jQuery(document).ready(function ($) {
  // This little bit of code is only used by the limit_termlists_and_species_to_selected_location extension
  // We hide the fields and show a Country drop-down unless an existing sample is found with a language filter in an attribute
  // or the user is adding new data and the country filter selection has already been made
  if (indiciaData.limitTermlistsExtension && indiciaData.limitTermlistsExtension === true) {
    if (indiciaData.foundFilterInUrl) {
      show_fields_after_country_selection();
    } else {
      hide_fields_until_country_selection();
    }
  }

  // Hide the correction autocompletes until the grid is loaded and they have been moved into the correct position
  remove_and_position_autocompletes_off_grid();

  // setup the handlers for same task for when the grid is rebuilt in other ways such as for a sort
  setup_remove_and_position_autocompletes_off_grid_handlers();

  /*
   * Must be called from a button/link on the report grid column configuration to actually allow the corrected species name to actually be saved.
   * corrected_species_sample_attr_val_id is the ID of the row in the sample_attribute_value table that holds the corrected species.
   *
   */
  indiciaFns.submit_corrected_sample_media_name = function(sample_id, corrected_species_sample_attr_val_id) {
    var mode;
    var data;
    if (!corrected_species_sample_attr_val_id) {
      // mode 1 is add mode
      mode = 1;
    } else {
      // mode 2 is edit mode
      mode = 2;
    }
    // Setup submission data for adding new data
    if (mode === 1) {
      var data = {
        "website_id":indiciaData.websiteIdForSampleMediaChecking, "sample_id":sample_id,
        "sample_attribute_id":indiciaData.sampleMediaNameCheckingAttrId, "text_value":jQuery('#' + sample_id + '-corrected-species').val()
      };
    }
    // In edit mode which just need to supply the existing sample attribute value ID and the new text value
    if (mode === 2) {
      var data = {
        "website_id":indiciaData.websiteIdForSampleMediaChecking, "id":corrected_species_sample_attr_val_id, 
        "text_value":jQuery('#' + sample_id + '-corrected-species').val() 
      };
    }

    jQuery.post(indiciaData.postUrlForSampleMediaChecking,
      data,
      function (data) {
        if (typeof data.error === 'undefined') {
          alert('The species has been successfully corrected to ' + jQuery('#' + sample_id + '-corrected-species').val() + '.');        } else {
          alert(data.error);
        }
      },
      'json'
    );
  }

  /*
   * Must be called from a button/link on the report grid column configuration to allow the corrected species name to actually be saved
   */
  indiciaFns.submit_corrected_occurrence_media_name = function(occurrence_id, existing_occurrence_attr_val_id) {
    var correctionValueContainerSelector = '#species-correction-div-container-' + occurrence_id;
    var mode;
    var data;
    if (!existing_occurrence_attr_val_id) {
      // mode 1 is add mode
      mode = 1;
    } else {
      // mode 2 is edit existing data mode
      mode = 2;
    }
    // Setup submission data for adding new data
    // The taxa_taxon_list_id is in a hidden field in the species_autocomplete which is placed into the attribute_value int field
    if (mode === 1) {
      data = {
        "website_id":indiciaData.websiteIdForOccurrenceMediaChecking, "occurrence_id":occurrence_id,
        "occurrence_attribute_id":indiciaData.occurrenceMediaNameCheckingAttrId, "int_value":jQuery(correctionValueContainerSelector).find('input[type=hidden]').val()
      };
    }
    // In edit mode which just need to supply the existing occurrence attribute value ID and the new taxa_taxon_list_id to store the occurrence_attribute_value int field
    if (mode === 2) {
      data = {
        "website_id":indiciaData.websiteIdForOccurrenceMediaChecking, "id":existing_occurrence_attr_val_id, 
        "int_value":jQuery(correctionValueContainerSelector).find('input[type=hidden]').val()
      };
    }
    jQuery.post(indiciaData.postUrlForOccurrenceMediaChecking,
      data,
      function (data) {
        if (typeof data.error === 'undefined') {
          alert('The species has been successfully corrected to ' + jQuery(correctionValueContainerSelector).find(':input:not([type=hidden])').val());
        } else {
          alert(data.error);
        }
      },
      'json'
    );
  }
  var url = window.location.href;
  // When user selects a location to filter by, reload page with filtering applied.
  jQuery("#location_termlist_and_species_filter").on('change', function() {
    if (url.indexOf('?') > -1){
        url += '&location_termlist_and_species_filter=' + jQuery("#location_termlist_and_species_filter").val();
    } else {
        url += '?location_termlist_and_species_filter=' + jQuery("#location_termlist_and_species_filter").val();
    }
    window.location.href = url;
  });

  // For SPRING pan-trap  
  // Delay the square default otherwise the country and its children will not be ready first
  $('#country-select-list').ready(function() {
    setTimeout(function() {
      if (indiciaData.defaultSquareSelection) {
        $('#imp-location option[value=' + indiciaData.defaultSquareSelection + ']').prop('selected', true);
        // This isn't a user made change, so stop browser from warning user if they leave page
        window.onbeforeunload = null;
      }
    }, 1000);
  });
});

// This code is only used by the limit_termlists_and_species_to_selected_location extension
// We hide the fields and show a Country drop-down unless an existing sample is found with a language filter in an attribute
// or the user is adding new data and the country filter selection has already been made
function hide_fields_until_country_selection() {
  jQuery('#language-selection-container').show();
  jQuery('#save-button').hide();
  jQuery('#data-entry-container').hide();
}

function show_fields_after_country_selection() {
  jQuery('#language-selection-container').hide();
  jQuery('#save-button').show();
  jQuery('#data-entry-container').show();
}

// Use jQuery to hide the terms associated with attributes on the page based on a language
// held in an existing sample or country selection made by the user from a drop-down in add mode
// Different types of jquery used as drop-downs and radio buttons have different html
function filter_termlists_by_location(termlistTermIdsToFilterBy) {
  if (termlistTermIdsToFilterBy && termlistTermIdsToFilterBy instanceof Array) {
    jQuery('[id^="smpAttr"] option').each(function() {
      if (jQuery(this).val() && !termlistTermIdsToFilterBy.includes(jQuery(this).val())) {
        jQuery(this).remove();
      }
    });
    jQuery('[id^="smpAttr"]').each(function() {
      if (jQuery(this).val() && !termlistTermIdsToFilterBy.includes(jQuery(this).val())) {
        jQuery(this).parent('li').remove();
      }
    });
  }
}

// Same with the species grid
function filter_species_by_location(taxaTaxonListIdsToFilterBy) {
  if (taxaTaxonListIdsToFilterBy && taxaTaxonListIdsToFilterBy instanceof Array) {
    jQuery('.scTaxaTaxonListId').each(function() {
      if (jQuery(this).val() && !taxaTaxonListIdsToFilterBy.includes(jQuery(this).val())) {
        jQuery(this).closest('tr').remove();
      }
    });
  }
}