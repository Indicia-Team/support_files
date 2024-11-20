jQuery(document).ready(function () {
  // Do not allow return to submit the form
  jQuery('#entry_form').keydown(function (e) {
    if (e.keyCode == 13) {
      e.preventDefault();
      return false;
    }
  });

  jQuery('#tab-submit').val('Submit');
  jQuery('#tab-submit').click(function() {
    if (confirm('Are you sure you want to submit this survey?')) {
      jQuery('#tab-submit').trigger();
    } else {
      return false;
    }
  });
});

mapInitialisationHooks.push(function (div) {
  jQuery.each(div.map.layers, function(idx, layer) {
    if (layer.name === "Ordnance Survey Outdoor") {
      layer.name = "OS Outdoor";
    }
    if (layer.name === "Dynamic (*OpenStreetMap* > Ordnance Survey Leisure > Google Satellite)") {
      layer.name = "Dynamic";
    }
  });
});
