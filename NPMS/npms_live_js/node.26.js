
/*
 * Javascript for grid ref popup on maps
 */
function map_square_info_popup(features, div,columns) {  
  if (features.length!==0) {
    alert('Grid reference: '+features[0].attributes.entered_sref);
  } else {
    alert('No grid reference information available.\n\nPlease close this box and zoom closer to the square for an accurate reading.'); 
  }
}

jQuery(document).ready(function () {
  // By default, Indicia just selects squares without zooming on single grid row clicks.
  // Change to zoom map when user single clicks on grid
  $('#report-grid-1').find('tbody').click(function (e) {
    if (e.target.nodeName != 'A') {
      var tr = $(e.target).parents('tr')[0];
      var featureId = tr.id.substr(3);
      highlightFeatureById(featureId, true);
    }
  });
});

// Not this code is based on code from jquery.reportgrid.js from the media folder.
// There are a couple of changes that were need to get it working, but it might contain
// extra code that isn't really needed here but was not removed to avoid extending testing.
function highlightFeatureById(featureId, zoomIn) {
  var featureArr;
  var map;
  var extent;
  var zoom;
  var zoomToFeature;
  if (typeof div === 'undefined') {
    div = this[0];
  }
  if (typeof indiciaData.reportlayer !== 'undefined') {
    map = indiciaData.reportlayer.map;
    featureArr = map.div.getFeaturesByVal(indiciaData.reportlayer, featureId, 'id');
    zoomToFeature = function () {
      var i;
      if (featureArr.length !== 0) {
        extent = featureArr[0].geometry.getBounds().clone();
        for (i = 1; i < featureArr.length; i++) {
          extent.extend(featureArr[i].geometry.getBounds());
        }
        if (zoomIn) {
          zoom = Math.min(
            indiciaData.reportlayer.map.getZoomForExtent(extent) - 2, 11);
            indiciaData.reportlayer.map.setCenter(extent.getCenterLonLat(), zoom
          );
        } else {
          indiciaData.reportlayer.map.setCenter(extent.getCenterLonLat());
        }
        indiciaData.mapdiv.map.events.triggerEvent('moveend');
      }
    };
    if (featureArr.length === 0) {
      // feature not available on the map, probably because we are loading just the viewport and
      // and the point is not visible. So try to load it with a callback to zoom in.
      mapRecords(div, false, featureId, function () {
        featureArr = map.div.getFeaturesByVal(indiciaData.reportlayer, featureId, 'id');
        zoomToFeature();
      });
    } else {
      // feature available on the map, so we can pan and zoom to show it.
      zoomToFeature();
    }
  }
};

mapInitialisationHooks.push(function (div) {
  jQuery.each(div.map.layers, function(idx, layer) {
    if (layer.name === "Ordnance Survey Outdoor") {
      layer.name = "OS Outdoor";
    }
    if (layer.name === "Dynamic (*OpenStreetMap* > Ordnance Survey Leisure > Google Satellite)") {
      layer.name = "Dynamic";
    }
  });

  // Set the layer name, this actually only takes effect on the label when the layer
  // checkbox is switch on and off
  jQuery.each(div.map.layers, function(idx, lay) {
    if (lay.name === 'Report output') {
      lay.name = 'Display Square Search';
    }
  });

  jQuery.each(div.map.controls, function(idx, ctrl) {
    // Need to set the layer checkbox name, otherwise it isn't what we want when the page initially
    // loads
    if (ctrl.dataLayers) {
      jQuery.each(ctrl.dataLayers, function(idx, dataLayer) {
        if (dataLayer.labelSpan.innerHTML === 'Report output') {
          dataLayer.labelSpan.innerHTML = 'Display Square Search';
          dataLayer.inputElem.defaultValue = 'Display Square Search';
          dataLayer.inputElem.name = 'Display Square Search';
        }
      });
    }
  });
});
