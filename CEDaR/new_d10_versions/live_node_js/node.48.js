jQuery(document).ready(function() {
  // use mapSettingsHooks to delay this to the end, so that the report's standard zoom extent is overridden.
  mapSettingsHooks.push(function(div) {
    mapInitialisationHooks.push(function(div) {
      var bl=new OpenLayers.LonLat(0,0).transform(new OpenLayers.Projection('EPSG:27700'), div.map.projection),
	      tr=new OpenLayers.LonLat(700000,1300000).transform(new OpenLayers.Projection('EPSG:27700'), div.map.projection),
 	      maxbounds=new OpenLayers.Bounds(bl.lon, bl.lat, tr.lon, tr.lat);
      if (!maxbounds.containsBounds(div.map.getExtent())) {
	    div.map.zoomToExtent(maxbounds);	  
	  }
    });
  });
});