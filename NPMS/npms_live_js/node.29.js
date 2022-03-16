jQuery(document).ready(function () {
  jQuery("#square-details-pdf-link").prop('href', 'https://www.npms.org.uk/sites/default/files/PDF/squares/' + jQuery('#imp-sref').val() + '.pdf');
});

mapInitialisationHooks.push(function (div) {
  //Switch off WMS layers by default
  jQuery.each(div.map.layers, function(idx, layer) {
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
