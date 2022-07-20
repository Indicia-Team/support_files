// Introduced for ABLE Issue 68
jQuery(document).ready(function($) {
  $('#ctrl-wrap-country-select-list').addClass("col-sm-12");
  $('#ctrl-wrap-square-select-list').addClass("col-sm-6");
  $('#ctrl-wrap-transect-name-label').addClass("col-sm-12");
  $('#ctrl-wrap-sample-date').addClass("col-sm-6");
  $('#ctrl-wrap-imp-location').addClass("col-sm-6");
  $('#ctrl-wrap-smpAttr-1388').addClass("col-sm-6");
  $('#ctrl-wrap-smpAttr-1390').addClass("col-sm-6");
  $('#ctrl-wrap-smpAttr-1384').addClass("col-sm-6");
  $('#ctrl-wrap-smpAttr-1385').addClass("col-sm-6");
  $('#ctrl-wrap-smpAttr-1386').addClass("col-sm-6");
  $('#ctrl-wrap-smpAttr-1387').addClass("col-sm-6");
  $('#ctrl-wrap-smpAttr-1389').addClass("col-sm-6");
  $('#ctrl-wrap-smpAttr-1666').addClass("col-sm-12");
	
  // Start time
  $('#smpAttr\\:1385').change(function(e) {
    var myValue = $(this).val()
    $(this).closest('.form-group').removeClass('has-warning')
    $(this).closest('.form-group').find('.inline-warning').remove()
    if (myValue.match(/^((2[0-3])|([0,1][0-9])):[0-5][0-9]$/)) {
      var sHour = parseInt(myValue.slice(0,2))
      var sMinute = parseInt(myValue.slice(3))
      if (sHour < 8 || (sHour === 18 && sMinute > 0) || sHour > 18) {
        $(this).closest('.form-group').addClass('has-warning')
        $(this).closest('.form-group').append('<p for="smpAttr:1385" generated="true" class="inline-warning ui-state-highlight page-notice ui-corner-all">' +
            Drupal.t('Warning: Start time is outside expected hours of 08:00 to 18:00') + '</p>');
        return;
      }
      var endValue = $('#smpAttr\\:1386').val()
      if (endValue != "") {
        var eHour = parseInt(endValue.slice(0,2))
        var eMinute = parseInt(endValue.slice(3))
        if (sHour > eHour || (sHour === eHour && sMinute > eMinute)) {
          $(this).closest('.form-group').addClass('has-warning')
          $(this).closest('.form-group').append('<p for="smpAttr:1385" generated="true" class="inline-warning ui-state-highlight page-notice ui-corner-all">' +
              Drupal.t('Warning: Start time is after End time') + '</p>')
        }
      }
    }
  })
  $('#smpAttr\\:1385').change()
  // End time
  $('#smpAttr\\:1386').change(function(e) {
    var myValue = $(this).val()
    $(this).closest('.form-group').removeClass('has-warning')
    $(this).closest('.form-group').find('.inline-warning').remove()
    if (myValue.match(/^((2[0-3])|([0,1][0-9])):[0-5][0-9]$/)) {
      var eHour = parseInt(myValue.slice(0,2))
      var eMinute = parseInt(myValue.slice(3))
      if (eHour < 8 || (eHour === 18 && eMinute > 0) || eHour > 18) {
        $(this).closest('.form-group').addClass('has-warning')
        $(this).closest('.form-group').append('<p for="smpAttr:1386" generated="true" class="inline-warning ui-state-highlight page-notice ui-corner-all">' +
            Drupal.t('Warning: End time is outside expected hours of 08:00 to 18:00') + '</p>')
        return;
      }
      var startValue = $('#smpAttr\\:1385').val()
      if (startValue != "") {
        var sHour = parseInt(startValue.slice(0,2))
        var sMinute = parseInt(startValue.slice(3))
        if (sHour > eHour || (sHour === eHour && sMinute > eMinute)) {
          $(this).closest('.form-group').addClass('has-warning')
          $(this).closest('.form-group').append('<p for="smpAttr:1385" generated="true" class="inline-warning ui-state-highlight page-notice ui-corner-all">' +
              Drupal.t('Warning: End time is before Start time') + '</p>')
        }
      }
    }
  })
  $('#smpAttr\\:1386').change()  
});
