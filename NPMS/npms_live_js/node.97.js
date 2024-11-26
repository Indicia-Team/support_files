// Hide filter row as it can't work with the way the report is structured
jQuery(document).ready(function($) {
  $('.filter-row').hide();
});

jQuery(document).ready(function () {
  if(jQuery('#sampleList').length === 0) {
    jQuery('#sampleList-description').remove();
  }
});

mapInitialisationHooks.push(function (div) {
  jQuery.each(div.map.layers, function(idx, layer) {
    if (layer.name === "Ordnance Survey Outdoor") {
      layer.name = "OS Outdoor";
    }
    if (layer.name === "Dynamic (*OpenStreetMap* > Ordnance Survey Leisure > Google Satellite)") {
      layer.name = "Dynamic";
    }
  });
});
