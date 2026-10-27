jQuery(document).ready(function() {
  if (!jQuery( "h2:contains('Moth trap downloads')" ).length) {
    jQuery('#trap-and-lamp-types-link').remove();
  }
  // Attach group_id from URL to the report download link if present.
  var params = new URLSearchParams(window.location.search);
  var groupId = params.get('group_id');
  if (groupId) {
    var link = jQuery('section.sites a');
    if (link.length) {
      var href = link.prop('href');
      var url = new URL(href, window.location.href);
      url.searchParams.set('group_id', groupId);
      link.prop('href', url.href);
    }
  }
});