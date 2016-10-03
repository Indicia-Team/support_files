(function ($) {
  jQuery(document).ready(function($) {
    if ($('#locAttr\\:136').val()) {
      $('#pdf-link-path').attr('href',$('#locAttr\\:136').val());
    } else {
      $('#pdf-link-path').hide();
    }
    $('#ctrl-wrap-locAttr-136').hide();
  });
}) (jQuery);