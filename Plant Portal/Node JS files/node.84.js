// Hide the square selection drop-down and replace with a read-only label
jQuery(document).ready(function () {
  var url = window.location.href;
  // Hide in edit mode, we prefer to support this but at moment the location:parent_id field is removed
  // so we can't copy from it, so that code would need changing first.
  if (url.indexOf('location_id') > -1) {
    jQuery('#container-square-name-label').hide();
  }
  // Hide the original drop-down along with its label
  jQuery('#container-location\\:parent_id').hide();
  // Not a nice solution, but put in a delay to make sure the system has updated the location:parent_id field to be the square
  // This is done in the Plant Portal Plot Location prebuilt form code
  setTimeout(function() {
    // Put the drop-down select text into the label
    jQuery('#square-name-label').text(jQuery('#location\\:parent_id option:selected').text());
  }, 2000);
});