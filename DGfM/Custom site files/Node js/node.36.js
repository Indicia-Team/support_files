var reject_completion;
jQuery(document).ready(function($) {
  reject_completion = function(ttlav_id) {
    var r = confirm('Are you sure you want to undo the completion of this fungus?');
    if (r == true) {
      var postUrl='http://www.fungi-without-borders.eu/en/iform/ajaxproxy?node=&index=taxa_taxon_list_attribute_value';
      $.post(postUrl,
        {"website_id":"2","id":ttlav_id, "deleted":"t"},
        function (data) {
          location.reload();
        },
        'json'
      );
    } else {
      return false;
    }
  }
});