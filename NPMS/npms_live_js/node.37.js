(function ($) {
  jQuery(document).ready(function($) {
    // Copy raw html from location comment field to a field that actually suppose html rendering
    // Also hide original field
    $("#event-desc-html").html($('#location\\:comment').val());
    $('#ctrl-wrap-location-comment').hide();
    if ($('#locAttr\\:136').val()) {
      $('#pdf-link-path').attr('href',$('#locAttr\\:136').val());
    } else {
      $('#pdf-link-path').hide();
    }
    $('#container-locAttr-136').hide();
  });
}) (jQuery);