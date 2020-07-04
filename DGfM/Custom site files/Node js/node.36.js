var mark_as_complete;
var reject_completion;
jQuery(document).ready(function($) {
  mark_as_complete = function(cttl_id) {
    var r = confirm('Are you sure you want to complete the description of this fungus?');
    if (r == true) {
      var postUrl='http://www.fungi-without-borders.eu/en/iform/ajaxproxy?node=&index=taxa_taxon_list_attribute_value';
      $.post(postUrl,
        {"website_id":"2","taxa_taxon_list_attribute_id":2197, "taxa_taxon_list_id":cttl_id, "int_value":1},
        function (data) {
          location.reload();
        },
        'json'
      );
      
    } else {
      return false;
    }
  }

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