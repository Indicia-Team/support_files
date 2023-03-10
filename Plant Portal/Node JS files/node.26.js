jQuery(document).ready(function () {
  // Do not allow return to submit the form
  jQuery('#entry_form').keydown(function (e) {
    if (e.keyCode == 13) {
      e.preventDefault();
      return false;
    }
  });

  jQuery('#tab-submit').val('Submit');
  jQuery('#tab-submit').click(function() {
    if (confirm('Are you sure you want to submit this survey?')) {
      jQuery('#tab-submit').trigger();
    } else {
      return false;
    }
  });
});