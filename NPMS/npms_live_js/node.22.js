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

//Called if the user clicks on a square on the authorised version of the request a square page.
function allocate_square_to_user(features) { 

  if (!indiciaData.website_id || !indiciaData.mySitesPsnAttrId || !indiciaData.postUrl||!indiciaData.indiciaUserId) {
    alert('The page has not been setup correctly. Please contact an administrator (the supply_indicia_data_to_map_square_allocator extension is not setup correctly).');
    return false;
  }
  if (features.length<2) {
    if (features[0]&&features[0].attributes.id && features[0].attributes.entered_sref) {
      setSelectedSquareLinks(features[0]);
      setTimeout(function() {
        allocationConfirmDialog(
          'Would you like to assign square <a target="_blank" href="/site-details?gr=' + features[0].attributes.entered_sref + '">' + features[0].attributes.entered_sref + '</a> to yourself?',
          features
        );
      }, 1);
    }

  } else {
    simpleDialog('<p>You are currently zoomed out too far to get an accurate<br>reading on the square you have clicked on.</p>' +
        '<p>If you use the distance box and Get Squares button, the<br>system will automatically zoom the map<br>' +
        '(located next to the Return All Squares button above the map).</p>' +
        '<p>Alternatively use the zoombar, or click on the navigation<br>crosshair icon in the top-right and then double-click on the<br>map.</p>',
        "",
       false
    );    
  }
}

/**
 * Don't use standard Javascript confirm, as that doesn't support HTML
 */
function allocationConfirmDialog(message, features) {
  $('<div></div>').appendTo('body')
    .html('<div>' + message + '?</div>')
    .dialog({
      open: function() {
        $('.ui-dialog-titlebar-close').remove();
      },
      modal: true,
      dialogClass: 'allocation_dialog',
      title: 'Allocate Square',
      zIndex: 10000,
      autoOpen: true,
      width: 'auto',
      resizable: false,
      buttons: {
        Yes: function() {
          var locationId, userId;
          locationId = features[0].attributes.id;    
          userId = indiciaData.indiciaUserId;
          duplicateCheck(locationId,userId,features);
          $(this).dialog("close");
        },
        No: function() {
          $(this).dialog("close");
        }
      },
      close: function(event, ui) {
        $(this).remove();
      }
    });
};

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

//This function is almost identical to the version that can be found in splash extensions. We could not call that code
//to re-use, so a version of the code is here.
//It is different to the splash extensions function, in this one we just check a square hasn't been allocated at all.
//The duplicate check in splash extensions checks if the square hasn't been allocated to exactly the same user.
//This is different because the map used here still shows allocated squares.
function duplicateCheck(locationId, userId,features) {
  var userIdToAdd = userId;
  var locationIdToAdd = locationId;
  var sitesReport = indiciaData.read.url +'/index.php/services/report/requestReport?report=library/locations/all_user_sites.xml&mode=json&mode=json&callback=?';

  var sitesReportParameters = {
    'person_site_attr_id': indiciaData.mySitesPsnAttrId,
    'auth_token': indiciaData.read.auth_token,
    'nonce': indiciaData.read.nonce,
    'reportSource':'local'
  };
  if (!userIdToAdd||!locationIdToAdd) {
    alert('Please select both a user and a location to add.');
  } else {
    jQuery.getJSON (
      sitesReport,
      sitesReportParameters,
      function (data) {
        var duplicateDetected=false;
        jQuery.each(data, function(i, dataItem) {
          if (locationIdToAdd==dataItem.location_id) {
              duplicateDetected=true;
          }
        });
        if (duplicateDetected===true) {
          simpleDialog('This square has already been allocated to someone. Squares shown in orange are already allocated, try a blue square instead.<br>If the square is blue, it may have become allocated in the time since you initially loaded the screen.',
            'Square Already Allocated',
            false);
        } else {
          addUserSiteData(locationId, userIdToAdd,features);
        }
      }
    );
  }    
}

//Again this is almost identical to the version of the function from the splash_extensions file.
function addUserSiteData(locationId, userIdToAdd,features) {
  if (!indiciaData.updatedBySystem) {
    indiciaData.updatedBySystem='';
  }
  if (!isNaN(locationId) && locationId!=='') {
    jQuery.post(indiciaData.postUrl, 
      {'website_id':indiciaData.website_id,'person_attribute_id':indiciaData.mySitesPsnAttrId,'user_id':userIdToAdd,'int_value':locationId,'updated_by_id':indiciaData.updatedBySystem},
      function (data) {
        if (typeof data.error === 'undefined') {
          // Send forcePageReload parameter as true. When the user closes the dialogue we want to update the map with the allocated square colour.
          simpleDialog('The square '+features[0].attributes.entered_sref+' has been allocated to you, pending approval by the NPMS coordinator.<br>Enjoy taking part, and thank you for participating.',
            'Square Successfully Allocated',
            true);
        } else {
          alert(data.error);
        }              
      },
      'json'
    );
  }
}

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
            'Layers',
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

  // Set the layer label, this actually only takes effect on the label when the layer
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
