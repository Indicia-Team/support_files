jQuery(document).ready(function($) {
  // Do not allow return to submit the form
  $('#entry_form').keydown(function (e) {
    if (e.keyCode == 13) {
      e.preventDefault();
      return false;
    }
  });
  $('#imp-sref-system').hide();
  $('#tab-submit').val('Submit');
});