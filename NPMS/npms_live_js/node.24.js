(function ($) {
  $(document).ready(function() {
    $('#survey_id').one('focus', function(e){
      //Hide the old inactive surveys from download
      $("#survey_id option[value='88']").remove();
      $("#survey_id option[value='89']").remove();
      $("#survey_id option[value='229']").remove();
    });
  });
}) (jQuery);