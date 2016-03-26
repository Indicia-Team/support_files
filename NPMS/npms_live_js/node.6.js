//Strip white space from grid references
jQuery(window).load(function () {
  jQuery('#imp-sref').blur(function () {
    jQuery('#imp-sref').val(jQuery('#imp-sref').val().replace(/\s/g,''));
  });
});

mapClickForSpatialRefHooks.push(updateToIrishSystemAfterMapClick);
//If in Ireland, force use of the Irish Grid system if invalid system is used.
function updateToIrishSystemAfterMapClick(data, div, feature) {
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