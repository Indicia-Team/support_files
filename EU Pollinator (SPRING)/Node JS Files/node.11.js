function display_info_popup(features) { 
  // Don't display popup if user clicks on nothing on the map
  if (features && features[0].attributes['sample_id']) {

    var labelsArray = ['Beetles', 'Bumblebees', 'Butterflies and moths', 'Honeybees', 'Hoverflies', 'Other flies', 'Other insects',
    'Small insects', 'Solitary bees', 'Wasps', 'Start time', 'Cover within patch', 'Flowers counted', 'Flowers unit', 'Patch context',
    'Cloud cover', 'Wind', 'Patch sunshine'];

    var popup_html = '<div id="count-details-popup" style="min-width:200px; padding:15px">';

    // If there is more than one sample, then allow the user to select
    if (features.length > 1) {
      popup_html = popup_html + '<div id="multi-feature-selection-panel">';
      popup_html = popup_html + 'Please select a count to view the details of:<br>';
      for (var idx=0; idx < features.length; idx++) {
        popup_html = popup_html + '&ensp;<a class="sample-link" id="sample-' +  features[idx].attributes['sample_id'] +'-link" href="#">' + features[idx].attributes['sample_id'] + '</a><br>';
      }
      popup_html = popup_html + '</div>';
    }

    // Build up a panel of details for each sample user clicked on map
    for (var idx2=0; idx2 < features.length; idx2++) {
      // If there is more than one, then these panels are initial hidden from view until user selects sample to view details of
      if (features.length === 1) {
        popup_html = popup_html + '<div id="sample-' + features[idx2].attributes['sample_id'] + '-panel">';
      } else {
        popup_html = popup_html + '<div id="sample-' + features[idx2].attributes['sample_id'] + '-panel" style="display:none">';
      }
      popup_html = popup_html + '<span><em>Count details</em></span>';
      // For each data label we need, display a label along with its data item provide the data exists
      for (var idx3 = 0; idx3 < labelsArray.length; idx3++) {
        if (features[idx2].attributes[labelsArray[idx3].toLowerCase().replace(/\s/g, "_")]) {
          popup_html = 
          popup_html + "<br>" + labelsArray[idx3] + ': ' + features[idx2].attributes[labelsArray[idx3].toLowerCase().replace(/\s/g, "_")];
        }
      }
      popup_html = popup_html + '</div>';
    }
    popup_html = popup_html + '</div>';
    // If we have built some HTML, then display it
    if (popup_html !== '') {
      jQuery.fancybox(popup_html);
    }
  }
}

(function($){
  $(function(){
  $( "body" ).on( "click", ".sample-link", function() {
    $('#multi-feature-selection-panel').hide();
    $("#sample-" + $(this).prop('id').replace(/\D/g, "") + "-panel").show();
  });

  $('#dynamic-survey_id option[value="670"]').hide();
  });
})(jQuery);

