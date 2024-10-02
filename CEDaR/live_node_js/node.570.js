jQuery(document).ready(function($) {
  $('.locationPicker').change(function() {
    if (typeof indiciaData.mapdiv!=='undefined') {
      indiciaData.mapdiv.locationSelectedInInput(indiciaData.mapdiv, this.value);
    }
  });
  var autocompleteSettings = {
    extraParams : {"auth_token":indiciaData.read.auth_token,"nonce":indiciaData.read.nonce,
        "query":'{"where":["(simplified=\'t\' or simplified is null) AND (preferred=\'t\' or language_iso<>\'lat\')"]}',
        "qfield":"searchterm","taxon_list_id":15,"taxon_group_id":89},
    continueOnBlur: true,
    simplify: true, // uses simplified version of search string in cache to remove errors due to punctuation etc.
    max: 20,
    selectMode: false,
    parse: function(data) {
      var results = [], done={};
      jQuery.each(data, function(i, item) {
        // note we track the distinct ttl_id and display term, so we don't output duplicates
        if (!done.hasOwnProperty(item.taxon_meaning_id + '_' + item.display)) {
          results[results.length] =
          {
            'data' : item,
            'result' : item.searchterm,
            'value' : item.original
          };
          done[item.taxon_meaning_id + '_' + item.display]=true;
        }
      });
      return results;
    },
    formatItem: function(item) {
      return item.original;
    }
  };
  if ($('.scFlowerVisited').width()<200) {
    autocompleteSettings.width = 200;
  }
  // Attach auto-complete code to the input
  ctrl = $('#occAttr\\:314,#occAttr\\:315').autocomplete(indiciaData.warehouseUrl+'index.php/services/data/cache_taxon_searchterm', autocompleteSettings);
});