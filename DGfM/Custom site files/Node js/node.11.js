
var setLegendState;
var mapZoomEnd;
mapInitialisationHooks.push(function(div) {

  div.map.events.register('changelayer', null, mapLayerChanged);
  
  function mapLayerChanged(event) {
    // Get any selected layers (not there might be more than one as there is also the report layer)
    var layers = div.map.getLayersBy("visibility", true); 
    // Cycle through each active layer and check it
    for (var i = 0; i < layers.length; i++) {
      setLegendState(layers[i].name);
    }
    // Workaround a problem where the default Openlayers switcher is not hiding/showing
    // layers properly, we don't know why, so workaround this
    var layers = div.map.layers; 
    for (var i = 0; i < div.map.layers.length; i++) {
      if (layers[i].isBaseLayer==true) {
        if (layers[i].visibility == true) {
          jQuery(div.map.layers[i].div).show();
        } else {
		  jQuery(div.map.layers[i].div).hide();
        }
      }
    }
  }

  //Cycle through each visible layer and show the appropriate legend image
  setLegendState = function setLegendState(layerName) {
    if (layerName==='Altitude') {
      jQuery("#altitude-legend").show();
      jQuery("#geology-legend").hide();
      jQuery("#topography-legend").hide();
    }

    if (layerName==='Geology') {
      jQuery("#altitude-legend").hide();
      jQuery("#geology-legend").show();
      jQuery("#topography-legend").hide();
    }

    if (layerName==='Topography') {
      jQuery("#altitude-legend").hide();
      jQuery("#geology-legend").hide();
      jQuery("#topography-legend").show();
    }
  }
});