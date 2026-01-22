// Check if less than 2 items before hiding as there is always a Please Select item
// that we shouldn't count.
jQuery(document).ready(function($) {
  if($('#sample\\:group_id > option').length < 2) {
    $('#ctrl-wrap-sample-group_id').hide();
  }
  // Change "Select group" label to "Select project"
  $("[for='sample\\:group_id']").html('Select project:');
});