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
        alert("You have clicked on square "+features[0].attributes.entered_sref+ ". This square has already been allocated to someone. Simply sign up (or login using your existing account details) to allocate any blue square to yourself using this map.");
      }, 1);
    } else {
      setTimeout(function() {
        alert("You have clicked on square "+features[0].attributes.entered_sref+ ". Simply sign up (or login using your existing account details) to allocate this square to yourself using this map.")
      }, 1);
    }    
  }
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
        var r = confirm("Would you like to assign square "+features[0].attributes.entered_sref+ " to yourself?");
        //Only perform if user confirms.
        if (r == true) {
          var locationId, userId;
          locationId = features[0].attributes.id;    
          userId = indiciaData.indiciaUserId;
          duplicateCheck(locationId,userId,features);
        }
      }, 1);
    }

  } else {
    alert("You are currently zoomed out too far to get an accurate reading on the square you have clicked on.\n\
\n\
If you use the distance box and Get Squares button, the system will automatically zoom the map (located next to the Return All Squares button above the map).\n\
\n\
Alternatively use the zoombar, or click on the navigation crosshair icon in the top-right and then double-click on the map.");    
  }
}

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
          alert('This square has already been allocated to someone. Squares shown in orange are already allocated, try a blue square instead. If the square is blue, it may have become allocated in the time since you initially loaded the screen.');
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
          alert('The square '+features[0].attributes.entered_sref+' has been allocated to you, pending approval by the NPMS coordinator. Enjoy taking part, and thank you for participating.');
          location.reload();
        } else {
          alert(data.error);
        }              
      },
      'json'
    );
  }
}
    
mapInitialisationHooks.push(function (div) {
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
        layer.name === "RSPB Reserves") {
      layer.setVisibility(false);
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
