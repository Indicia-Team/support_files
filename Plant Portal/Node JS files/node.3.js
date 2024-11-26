function display_grid_ref_info(features) { 
  if (features[0] && features[0].attributes.id && features[0].attributes.name) {
      alert("You have clicked on square " + features[0].attributes.name + ".");
  }
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
