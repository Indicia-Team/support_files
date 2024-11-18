jQuery(document).ready(function () {
  jQuery("#square-details-pdf-link").prop('href', 'https://www.npms.org.uk/sites/default/files/PDF/squares/' + jQuery('#imp-sref').val() + '.pdf');
  jQuery("#square-details-page-link").prop('href', '/content/site-details?gr=' + jQuery('#imp-sref').val());
});

mapInitialisationHooks.push(function (div) {
  jQuery.each(div.map.layers, function(idx, layer) {
    if (layer.name === "Ordnance Survey Outdoor") {
      layer.name = "OS Outdoor";
    }
    if (layer.name === "Dynamic (*OpenStreetMap* > Ordnance Survey Leisure > Google Satellite)") {
      layer.name = "Dynamic";
    }
    //Switch off WMS layers by default
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

  jQuery.each(div.map.controls, function(idx, ctrl) {
    //Set the click "?" map control to be the default one
    if (ctrl.displayClass === "left olControlSelectFeature") {
      ctrl.activate();
    } else if (ctrl.displayClass === "left olControlNavigation" || ctrl.displayClass === "left olControlClickSref") {
      ctrl.deactivate();
    }
  });
});
