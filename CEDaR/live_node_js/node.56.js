(function ($) {
  jQuery(document).ready(function($) {
    if ($('#occAttr\\:302').val()||$('#occAttr\\:303').val()) {
      $('#ctrl-wrap-occAttr-302').show();
      $('#ctrl-wrap-occAttr-303').show();
      $('#ctrl-wrap-occAttr-608').hide();
      $('#ctrl-wrap-occAttr-609').hide();
    } else {
      $('#ctrl-wrap-occAttr-302').hide();
      $('#ctrl-wrap-occAttr-303').hide();
      $('#ctrl-wrap-occAttr-608').show();
      $('#ctrl-wrap-occAttr-609').show();
    }
  });
}) (jQuery);