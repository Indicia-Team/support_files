// Change the labels inside the importer as required.
jQuery(document).ready(function () {
  // Change the labels on the option sections in the select lists
  jQuery('[label="Location"]').prop('label','Plot details');
  jQuery('[label="Location custom attributes"]').prop('label','Plot attributes');
  // Change the select option labels as required
  jQuery('[value="location:name"]').prop('label','Plot name');
  jQuery('[value="location:fk_location_type"]').prop('label','Plot type');
  jQuery('[value="location:centroid_sref"]').prop('label','Spatial reference');
  jQuery('[value="location:centroid_sref_system"]').prop('label','Spatial reference system');
  jQuery('[value="location:fk_parent:id"]').prop('label','Square ID number');
  jQuery('[value="locAttr:fk_30"]').prop('label','Plot direction');
  jQuery('[value="locAttr:fk_31"]').prop('label','Plot slope');


  // Remove all options apart from the ones we need
  jQuery('.import-mappings-table').find('option').each(function() {
    if (jQuery(this).val() !== '<Not imported>' &&
    	jQuery(this).val() !== 'location:name' &&
        jQuery(this).val() !== 'location:fk_location_type' &&
        jQuery(this).val() !== 'location:centroid_sref' &&
        jQuery(this).val() !== 'location:centroid_sref_system' &&
        jQuery(this).val() !== 'location:fk_parent:id' &&
        jQuery(this).val() !== 'location:comment' &&
        jQuery(this).val() !== 'locAttr:fk_30' &&
        jQuery(this).val() !== 'locAttr:fk_31' &&
        jQuery(this).val() !== 'locAttr:143' &&
        jQuery(this).val() !== 'locAttr:144' &&
        jQuery(this).val() !== 'locAttr:146') {
      jQuery(this).remove();
    }
  });

  // Clear the drop-down section labels we aren't going to use
  jQuery('select').find('optgroup').each(function() {
    if (jQuery(this).prop('label') !== 'Plot details' &&
        jQuery(this).prop('label') !== 'Plot attributes') {
      jQuery(this).prop('label','');
    }
  });
});