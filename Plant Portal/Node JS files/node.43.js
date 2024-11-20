function display_grid_ref_info(features) { 
  if (window.confirm('You have clicked on square ' + features[0].attributes.centroid_sref + '.\n' +
      'Would you like to view the plots for this square?')) {
    window.location.href='list-plots-npms-mode?dynamic-parent_id=' + features[0].attributes.location_id;
  };
}

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
