//Strip white space from grid references
jQuery(window).load(function () {
  jQuery('#imp-sref').blur(function () {
    jQuery('#imp-sref').val(jQuery('#imp-sref').val().replace(/\s/g,''));
  });
});