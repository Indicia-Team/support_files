jQuery(document).ready(function($) {
  $('#occurrence\\:zero_abundance').change(function() {
    if ($('#occurrence\\:zero_abundance:checked').length>0) {
      $('#non-zero-controls').css('opacity', 0.5).attr('disabled', true);
    } else {
      $('#non-zero-controls').css('opacity', 1).attr('disabled', false);
    }
  });

  $('occurrence:zero_abundance').change();
});