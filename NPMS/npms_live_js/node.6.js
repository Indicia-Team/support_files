jQuery(window).load(function () {
  
  //Don't allow removal of existing sketches, deletions can only be made if the user adds a photo and wants to remove it in the same session
  jQuery('.delete-file').hide();
  jQuery('#imp-sref').keyup(function() {
    //Remove spaces from most spatial references.
    //For lat long spatial references makes sure there is a space after N and S as a reference without a space is invalid
    jQuery('#imp-sref').val(jQuery('#imp-sref').val().replace(/\s/g,''));
    if (jQuery('#imp-sref-system').val()=='4326') {  
      //Always capitalise lat long spatial reference and then add a space after North or South.
      jQuery('#imp-sref').val(jQuery('#imp-sref').val().toUpperCase());
      jQuery('#imp-sref').val(jQuery('#imp-sref').val().replace(/N/g, 'N '));
      jQuery('#imp-sref').val(jQuery('#imp-sref').val().replace(/S/g, 'S '));
    }
  });
  
  jQuery('#imp-sref').change(function () {
    var spSystem = jQuery('#imp-sref-system').val();
    //If the user enters a spatial reference then pad with zeroes. Don't do this for lat long as that wouldn't work.
    if (spSystem==='OSGB' || spSystem==='OSIE' || spSystem==='utm30wgs84') {
      var fieldSize;
      //The field size we need to pad to varies depending on the spatial reference system type.
      if (spSystem==='OSGB'||spSystem==='utm30wgs84') {
        fieldSize = 12;
      } else {
        fieldSize=11;
      }
      //Strip white space from grid references
      jQuery('#imp-sref').val(jQuery('#imp-sref').val().replace(/\s/g,''));
      //If grid reference is too short, pad with zeros. 
      //The problem is the indiciamappanel also tries to pad the spatial reference (not using zeros). So to get the padding to work I
      //to wait for the indiciamappanel to do its padding, then overwrite it with my own zero padding. Not ideal, but better than changing core indiciamappanel code for just one project.
      if (jQuery('#imp-sref').val().length < fieldSize) {
         var changedToValue=jQuery('#imp-sref').val();
         setTimeout(function(){ 
           //Only try to pad if it isn't a completely unrecognised spatial reference.
           if (!indiciaData.invalidSrefDetected || indiciaData.invalidSrefDetected==false) {
             changedToValue=pad(changedToValue, fieldSize);
             jQuery('#imp-sref').val(changedToValue).change();
             alert('The spatial reference you entered does not have the enough resolution, so I have padded it with zeros. Your grid reference estimate might not be correct, you can try clicking on the map to select the plot position rather than relying on your grid reference estimate.');
           }
         }, 1500); 
      }
      //Do same, but truncate the spatial reference if it is too long.
      if (jQuery('#imp-sref').val().length > fieldSize) {
        var changedToValue=jQuery('#imp-sref').val();
        setTimeout(function(){
          if (!indiciaData.invalidSrefDetected || indiciaData.invalidSrefDetected==false) {
            changedToValue=changedToValue.substring(0, fieldSize);
            jQuery('#imp-sref').val(changedToValue).change();
            alert('The spatial reference you entered had too much resolution, so I have padded it with zeros. Your grid reference estimate might not be correct, you can try clicking on the map to select the plot position rather than relying on your grid reference estimate.');
          }
        }, 1500);
      }
    }
    updateToIrishSystemAfterMapClick();
  });
});

function pad (str, max) {
  return str.length < max ? pad(str + "0" , max) : str;
}

mapClickForSpatialRefHooks.push(updateToIrishSystemAfterMapClick);
//If in Ireland, force use of the Irish Grid system if invalid system is used.
function updateToIrishSystemAfterMapClick() {
  var clickedGeomObj = OpenLayers.Geometry.fromWKT(jQuery('#imp-geom').val());
  var irishGeomObj = OpenLayers.Geometry.fromWKT("POLYGON((-916381.69280417 7430373.5814919,-882137.90413717 7410805.7022536,-814873.31925558 7448718.4682777,-680344.14949239 7426704.6041347,-679121.15704 7409582.7098012,-588619.71556295 7271384.5626808,-595957.67027731 7235917.7815614,-684013.12684957 7149085.3174416,-650992.33063497 7007218.192964,-695142.36563089 6803386.1113448,-859023.3542515 6776480.2773922,-947078.81082376 6720222.6245821,-1096283.8900157 6663964.971772,-1218583.1352549 6815616.0358687,-1079161.9956822 6967267.0999654,-1162325.4824449 7082228.3904903,-1152541.5428257 7241217.4093013,-978876.61458597 7251001.3489205,-991106.5391099 7361070.6696358,-916381.69280417 7430373.5814919))");
  //When the user clicks on the map, find if it is in ireland.
  //If it is in Ireland, and the British or Channel Ireland grid system is selected, then warn the user and select Irish Grid System.
  var result = clickedGeomObj.intersects(irishGeomObj);
  if (result===true && jQuery('#imp-sref-system').val()!=='OSIE' && jQuery('#imp-sref-system').val()!=='4326') {
      alert('As you are recording in Ireland, you must use a valid Irish spatial reference system, so we have changed it automatically for you.')
      jQuery('#imp-sref-system').val('OSIE').change();
  }
}

