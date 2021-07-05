// Change the labels inside the importer as required.
jQuery(document).ready(function () {
  // Change the labels on the option sections in the select lists
  jQuery('[label="Groups location"]').prop('label','Project details');
  jQuery('[label="Location"]').prop('label','Square details');
  // Change the select option labels as required
  jQuery('[value="groups_location:fk_group"]').prop('label','Project (from controlled termlist)');
  jQuery('[value="location:name"]').prop('label','Square name');
  jQuery('[value="location:centroid_sref"]').prop('label','Spatial reference');
  jQuery('[value="location:centroid_sref_system"]').prop('label','Spatial reference system');

  // Remove all options apart from the ones we need
  jQuery('.import-mappings-table').find('option').each(function() {
    if (jQuery(this).val() !== 'groups_location:fk_group' &&
        jQuery(this).val() !== 'location:name' &&
        jQuery(this).val() !== 'location:centroid_sref' &&
        jQuery(this).val() !== 'location:centroid_sref_system') {
      jQuery(this).remove();
    }
  });

  // Clear the drop-down section labels we aren't going to use
  jQuery('select').find('optgroup').each(function() {
    if (jQuery(this).prop('label') !== 'Project details' &&
        jQuery(this).prop('label') !== 'Square details') {
      jQuery(this).prop('label','');
    }
  });
});