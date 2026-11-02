//Note the code in this file requires the supply_indicia_data_to_map_square_allocator splash_extension

jQuery(document).ready(function () {

  // By default, Indicia just selects squares without zooming on single grid row clicks.
  // Change to zoom map when user single clicks on grid
  $('#report-grid-0').find('tbody').click(function (e) {
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

function setSelectedSquareLinks(ftr) {
  // console.log(ftr);
  gr = ftr.attributes.entered_sref;
  $('#selected-square-link').html(`<b>${gr}<b> - <a href="/content/site-details?gr=${gr}">see details</a>`);
  $('#selected-square-link').css('background-color', 'yellow');
}

//Warning to display on the public version of the Request a Square page.
function login_to_allocate_message(features) { 
  //Only show the warning if there is a feature that has actually been clicked on, rather than for ever click on the map.
  if (features[0]&&features[0].attributes.id&& features[0].attributes.entered_sref) {
    setSelectedSquareLinks(features[0]);
    //Detect if it has been allocated by the square colour
    if (features[0].attributes.fc==='#FFA62F') {
      setTimeout(function() {
        simpleDialog('You have clicked on square <a target="_blank" href="/content/site-details?gr=' + features[0].attributes.entered_sref + '">' + features[0].attributes.entered_sref + '</a>. This square has already been allocated to someone.<br>Simply sign up (or login using your existing account details) to allocate any blue square to yourself using this map.',
            'Square Already Allocated',
            false);
      }, 1);
    } else {
      setTimeout(function() {
        simpleDialog('You have clicked on square <a target="_blank" href="/content/site-details?gr=' + features[0].attributes.entered_sref + '">' + features[0].attributes.entered_sref + '</a>.<br>Simply sign up (or login using your existing account details) to allocate this square to yourself using this map.',
            'Sign Up To Allocate',
            false);
      }, 1);
    }
  }
}

/**
 * Don't use standard Javascript confirm, as that doesn't support HTML
 */
function simpleDialog(message, title, forcePageReload) {
  if (!$('.ui-dialog').length) {
    $('<div></div>').appendTo('body')
      .html('<div>' + message + '</div>')
      .dialog({
        open: function() {
          $('.ui-dialog-titlebar-close').remove();
        },
        modal: true,
        title: title,
        zIndex: 10000,
        autoOpen: true,
        width: 'auto',
        resizable: false,
        buttons: {
          OK: function() {
	        $(this).dialog("close");
		    if (forcePageReload === true) {
		      location.reload();
		    }
          },
        },
        close: function(event, ui) {
          $(this).remove();
        }
      });
  }  
};

function getOnScreenLayerName(actualLayerName) {
  switch (actualLayerName) {
    case 'NPMS SSSIs':
      onScreenLayerName = 'SSSIs';
      break;
    case 'NPMS National Parks':
      onScreenLayerName = 'National Parks';
      break;
    case 'NPMS NNRs':
      onScreenLayerName = 'National Nature Reserves';
      break;
    case 'NPMS AONBs':
      onScreenLayerName = 'AONBs';
      break;
    case 'NPMS National Trust Properties':
      onScreenLayerName = 'National Trust Properties';
      break;
    case 'NPMS Vice Counties':
      onScreenLayerName = 'Vice County Boundaries';
      break;
    case 'NPMS RSPB reserves':
      onScreenLayerName = 'RSPB Reserves';
      break;
    case 'GB Contour Lines':
      onScreenLayerName = 'Elevation (GB)';
      break;
    case 'NI Historic Parks and Gardens':
      onScreenLayerName = 'Parks Gardens (NI)';
      break;
    case 'Wales Open Access Land':
      onScreenLayerName = 'Open Access Land (Wales)';
      break;
    case 'England_Right_of_Way_500m_Buffer':
      onScreenLayerName = 'RoW (England)';
      break;
    case 'GB_Public_Transport_500m_Buffer':
      onScreenLayerName = 'Transport Hubs (GB)';
      break;
    case 'NIBusstops500mb_4326':
      onScreenLayerName = 'Transport Hubs (NI)';
      break;
    default:
      onScreenLayerName = '';
  }
  return onScreenLayerName;
}
    
mapInitialisationHooks.push(function (div) {
  div.map.events.register('click', div.map, function (event) {
    // if the info balloon icon is selected, attempt to
    // get layer feature information (e.g. National Park name)
    if ($('.olControlSelectFeatureItemActive').length) {
      var selectedWMSLayerNames = [];
      var wmsUrl = '';
      var onScreenLayerName = '';
      // Cycle layers
      $.each(div.map.layers, function () {
        // We are only interested in WMS layers
        if (this.CLASS_NAME === 'OpenLayers.Layer.WMS') {
          // Get layer name as it appears on screen.
		  onScreenLayerName = getOnScreenLayerName(this.params.LAYERS);
          // If the layer is selected then keep it for use
          if ($('[name="' + onScreenLayerName + '"]').is(":checked")) {
            selectedWMSLayerNames.push(this.params.LAYERS);
          }
          if (wmsUrl === '') {
            // store just the first wms layer's URL since all clickable layers must be from the same url.
            wmsUrl = this.url;
          }
        }
      });
      selectedWMSLayerNames = selectedWMSLayerNames.join(',');  
      //Click point
      var x = event.xy.x;
      var y = event.xy.y;
      // Setup the request to the Warehouse.
      var params = {
        REQUEST: 'GetFeatureInfo',
        EXCEPTIONS: 'text/javascript',
        VERSION: '1.1.0',
        STYLES: '',
        BBOX: div.map.getExtent().toBBOX(),
        X: Math.round(x),
        Y: Math.round(y),
        INFO_FORMAT: 'text/javascript',
        LAYERS: selectedWMSLayerNames,
        QUERY_LAYERS: selectedWMSLayerNames,
        WIDTH: div.map.size.w,
        HEIGHT: div.map.size.h,
        SRS: div.map.projection,
        BUFFER: div.settings.clickPixelTolerance,
        FEATURE_COUNT: 13
      };
      
      // Decode the Warehouse response.
      var handleWarehouseWMSResponse = function(response) {
        var onScreenFeatureDetails = '';
        var previousLayerName = '';
        var layerName;
        // Cycle through the layers returned for the click point
        for (const [key, value] of Object.entries(response)) {
          if (key === 'data') {
            if (value.features) {
              for (const [key, feature] of Object.entries(value.features)) {
                layerName = feature.id.split(".")[0];
                if (feature.id) {
                  onScreenLayerName = getOnScreenLayerName(layerName);
                }
                // When we display the dialog, we might have more than one feature
                // for each layer, so we can group them together.
                // Only show the Layer Name title itself if a feature is found to be from 
                // a different layer
                if (layerName != previousLayerName) {
                  if (feature.properties.name) {
                    onScreenFeatureDetails += onScreenLayerName + ':<br>' + 
                        // Chop off the 3 letter country code at the end of the name in brackets
                        '&emsp;&emsp;<em>' + feature.properties.name.split(' (')[0] + '</em><br>';
                  }
                  if (feature.properties.SITE) {
                    onScreenFeatureDetails += onScreenLayerName + ':<br>' + 
                       '&emsp;&emsp;<em>' + feature.properties.SITE.split(' (')[0] + '</em><br>';
                  }
                }
                else {
                  if (feature.properties.name) {
                    onScreenFeatureDetails += 
                        '&emsp;&emsp;<em>' + feature.properties.name.split(' (')[0] + '</em><br>';
                  }
                  else if (feature.properties.SITE) {
                    onScreenFeatureDetails += 
                        '&emsp;&emsp;<em>' + feature.properties.SITE.split(' (')[0] + '</em><br>';
                  }
                }
                previousLayerName = feature.id.split(".")[0];
              }
            }
          }
        }
        // Remove line break from last line
        onScreenFeatureDetails = onScreenFeatureDetails.substring(0, onScreenFeatureDetails.length - 4);
        if (onScreenFeatureDetails) {
          simpleDialog(
            onScreenFeatureDetails,
            'Location Details',
            false
          );
        }
      }
      
      // Call the Warehouse
      var protocol = new OpenLayers.Protocol.Script({
        url: wmsUrl,
        params: params,
        callback: handleWarehouseWMSResponse,
        callbackKey: 'format_options',
        callbackPrefix: 'callback:'
      });

      protocol.read({
        params: params,
        callback: handleWarehouseWMSResponse
      });
      
    }
  });

  //Switch off WMS layers by default
  jQuery.each(div.map.layers, function(idx, layer) {
    if (layer.name === "Ordnance Survey Outdoor") {
      layer.name = "OS Outdoor";
    }
    if (layer.name === "Dynamic (*OpenStreetMap* > Ordnance Survey Leisure > Google Satellite)") {
      layer.name = "Dynamic";
    }
    if (layer.name === "SSSIs" ||
        layer.name === "National Parks" ||
        layer.name === "National Nature Reserves" ||
        layer.name === "AONBs" ||
        layer.name === "National Trust Properties" ||
        layer.name === "Vice County Boundaries" ||
        layer.name === "RSPB Reserves" ||
        layer.name === "Elevation (GB)" ||
        layer.name === "Parks Gardens (NI)" ||
        layer.name === "Open Access Land (Wales)" ||
        layer.name === "RoW (England)" ||
        layer.name === "Transport Hubs (GB)" ||
        layer.name === "Transport Hubs (NI)") {
      layer.setVisibility(false);
    }
    if (layer.name === 'Parks Gardens (NI)' ||
        layer.name === 'Open Access Land (Wales)') {
      layer.setOpacity(0.5);
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

    //Set the click "?" map control to be the default one
    if (ctrl.displayClass === "left olControlSelectFeature") {
      ctrl.activate();
    } else if (ctrl.displayClass === "left olControlNavigation" || ctrl.displayClass === "left olControlClickSref") {
      ctrl.deactivate();
    }
  });
});
