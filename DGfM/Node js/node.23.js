jQuery(document).ready(function($) {
  var sitePath = '/';
  var spectrumPath = sitePath + 'sites/default/files/indicia/js/spectrum/';
  var attrs = [
    35,50,51,79,80,91,125,145,146,147,178,179,180,181,182,183,219,220,242,243,244,245,265,266,267,268,285,286,
    287,288,289,313,314,336,349,350,396,397,436,500,501,539,540,558,559,596,597,615,616,617,682,726,731,735,736,
    737,738,775,780,781,782,783,784,785,804,805,806,807,808,809,810,811,814,815,816,817,818,819,820,821,823,826,
    827,828,872,873,874,875,877,878,879,881,882,883,884,885,890,891,1066,1067,1068,1069,1070,1071,1072,1073,1074
  ];
  var selectors = [];
  $.each(attrs, function() {
    selectors.push('#taxAttr\\:' + this);
    selectors.push('[id^="taxAttr\\:' + this + ':"]');
  });
  $('<link/>', {
    rel: 'stylesheet',
    type: 'text/css',
    href: spectrumPath + 'spectrum.css'
  }).appendTo('head');
  jQuery.getScript(spectrumPath + 'spectrum.js', function() {
    $(selectors.join(',')).spectrum({
      showPaletteOnly: true,
      showSelectionPalette: true,
      showInput: true,
      allowEmpty: true,
      togglePaletteOnly: true,
      hideAfterPaletteSelect: true,
      togglePaletteMoreText: '+',
      togglePaletteLessText: '-',
      chooseText: '✓',
      cancelText: '✗',
      localStorageKey: 'colours',
      preferredFormat: "hex",
      palette: [
          ["#000","#444","#666","#999","#ccc","#eee","#f3f3f3","#fff"],
          ["#f00","#f90","#ff0","#0f0","#0ff","#00f","#90f","#f0f"],
          ["#f4cccc","#fce5cd","#fff2cc","#d9ead3","#d0e0e3","#cfe2f3","#d9d2e9","#ead1dc"],
          ["#ea9999","#f9cb9c","#ffe599","#b6d7a8","#a2c4c9","#9fc5e8","#b4a7d6","#d5a6bd"],
          ["#e06666","#f6b26b","#ffd966","#93c47d","#76a5af","#6fa8dc","#8e7cc3","#c27ba0"],
          ["#c00","#e69138","#f1c232","#6aa84f","#45818e","#3d85c6","#674ea7","#a64d79"],
          ["#900","#b45f06","#bf9000","#38761d","#134f5c","#0b5394","#351c75","#741b47"],
          ["#600","#783f04","#7f6000","#274e13","#0c343d","#073763","#20124d","#4c1130"]
      ]
    });
  });
});
