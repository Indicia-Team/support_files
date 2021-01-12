jQuery(document).ready(function($) {
  // Don't want the attribute that holds whether a description is finished to be visible
  $('#ctrl-wrap-taxAttr-2197').hide();
  
  // Remove the Popularname fields as the common names field should be used instead
  $("fieldset:contains('Populärname')").remove();
  $("fieldset:contains('vernacular name')").remove();
  $("fieldset:contains('jméno v národním jazyce')").remove();
    
  $('#finish-button').prop('value', 'Finish description');
  // On page load if the description is already finished, then make page read-only
  if ($('#taxAttr\\:2197').is(':checked')) {
    $('.read-only-capable').find('input, textarea, text, button, select').prop('disabled', true);
    $('.page-notice').hide();
    $('.delete-file').hide();
    $('.finish-button-help').hide();
    $('#finish-button').hide();
    $('#save-button').hide();
    $('#taxAttr\\:2197').prop('disabled', true);
  }

  $('#finish-button').click(function() {
    // When finish description button is clicked, if it is already finished, then undo the finish state (this can only be done before the save button is clicked,
    // after this, the page is read-only for good)
    if ($('#taxAttr\\:2197').is(':checked')) {
      $('.read-only-capable').find('input, textarea, text, button, select').prop('disabled',false);
      $('.page-notice').show();
      $('.delete-file').show();
      $('#finish-button').prop('value', 'Finish description');
      $('#taxAttr\\:2197').prop('checked',false);
      $('#taxAttr\\:2197').val('0');
    } else {
      // If Finish Description is clicked and it is not already finished, then set the description to be read-only and change the Finish button to be an undo
      // button instead.
      $('.read-only-capable').find('input, textarea, text, button, select').prop('disabled',true);
      $('.page-notice').hide();
      $('.delete-file').hide();
      $('#finish-button').prop('value', 'Undo finish description');
      $('#taxAttr\\:2197').prop('checked', true);
      $('#taxAttr\\:2197').val('1');
    }
  });
  
  //Disabled fields won't submit, so remove these before submission
  $('#entry_form').submit(function(e) {
    $(':disabled').each(function(e) {
        $(this).removeAttr('disabled');
    })
  });

  $('<p><a href="#invisible_macro_tag_id" style="color:blue"><em><small>Click here to go straight to Macro Description section</small></em></a></p>').insertBefore("#ctrl-wrap-taxon-taxon");
  $('<p><a href="#invisible_micro_tag_id" style="color:blue"><em><small>Click here to go straight to Micro Description section</small></em></a></p>').insertBefore("#ctrl-wrap-taxon-taxon");


  $('<a id="invisible_macro_tag_id" style="visibility: hidden">invisible macro description tag</a>').insertBefore("legend:contains('macro description')");
  $('<a id="invisible_macro_tag_id" style="visibility: hidden">invisible macro description tag</a>').insertBefore("legend:contains('Makromerkmale')");
  $('<a id="invisible_macro_tag_id" style="visibility: hidden">invisible macro description tag</a>').insertBefore("legend:contains('makroskopické znaky')");


  $('<a id="invisible_micro_tag_id" style="visibility: hidden">invisible micro description tag</a>').insertBefore("legend:contains('Micro description')");
  $('<a id="invisible_micro_tag_id" style="visibility: hidden">invisible micro description tag</a>').insertBefore("legend:contains('Mikromerkmale')");
  $('<a id="invisible_micro_tag_id" style="visibility: hidden">invisible micro description tag</a>').insertBefore("legend:contains('mikroskopické znaky')");
  
  //Hide the delete button, so contributors can't delete taxa
  $('#delete-button').hide();
  
  // Remove redlist fields as these won't be edited
  $('#ctrl-wrap-taxAttr-1076').remove();
  $('#ctrl-wrap-taxAttr-1077').remove();
  $('#ctrl-wrap-taxAttr-1920').remove();
  $('#ctrl-wrap-taxAttr-1921').remove();
  
  //These ones are hidden for now but should be read-only
  $('#ctrl-wrap-taxa_taxon_list-parent_id').hide();
  $('#ctrl-wrap-taxon-taxon_group_id').hide();
  $('#ctrl-wrap-taxon-taxon_rank_id').hide();

  
  //These fields shouldn't be seen by the user
  $('#ctrl-wrap-taxon-attribute').hide();
  $('#ctrl-wrap-taxa_taxon_list-description').hide();
  $('#ctrl-wrap-taxon-external_key').hide();
  $('#ctrl-wrap-taxon-search_code').hide();
  $('#ctrl-wrap-taxa_taxon_list-taxonomic_sort_order').hide();


  
  var sitePath = '/';
  var spectrumPath = sitePath + 'sites/default/files/indicia/js/spectrum/';
  var attrs = [35,
   50,
   51,
   79,
   80,
   91,
  125,
  145,
  146,
  147,
  178,
  179,
  180,
  181,
  182,
  183,
  219,
  220,
  242,
  243,
  244,
  245,
  265,
  266,
  267,
  268,
  286,
  287,
  288,
  289,
  313,
  314,
  336,
349,
  350,
  396,
  397,
  436,
  437,
  438,
  439,
  500,
  501,
  539,
  540,
  558,
  559,
  596,
  597,
  615,
  616,
  617,
  682,
  726,
731,
  735,
  736,
  737,
  738,
  775,
  780,
  781,
  782,
  783,
  784,
  785,
  804,
  805,
  806,
  807,
  808,
  809,
  810,
  811,
  814,
  815,
  816,
  817,
 818,
  819,
  820,
  821,
  823,
  826,
  827,
  828,
  872,
  873,
  874,
  875,
  877,
  878,
  879,
  881,
  882,
  883,
  884,
  885,
  890,
  891,
 1066,
 1067,
 1068,
1069,
 1070,
 1071,
 1072,
 1073,
 1074,
 1759,
 1760,
 1766,
 1796,
 1797,
 1798,
 1799,
 1803,
 1804,
 1841,
 1842,
 1843,
 1925,
 1938,
 1939,
 1940,
 1967,
 1968,
 2132,
 2133];
  //JVB's original attrs
  /*var attrs = [
    35,50,51,79,80,91,125,145,146,147,178,179,180,181,182,183,219,220,242,243,244,245,265,266,267,268,285,286,
    287,288,289,313,314,336,349,350,396,397,436,500,501,539,540,558,559,596,597,615,616,617,682,726,731,735,736,
    737,738,775,780,781,782,783,784,785,804,805,806,807,808,809,810,811,814,815,816,817,818,819,820,821,823,826,
    827,828,872,873,874,875,877,878,879,881,882,883,884,885,890,891,1066,1067,1068,1069,1070,1071,1072,1073,1074
  ];*/
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
    $.each($(selectors.join(',')), function() {
      $(this).hide();
      var values = $(this).val().split(';');
      var value1 = values.length > 0 ? values[0] : '';
      var value2 = values.length > 1 ? values[1] : '';
      $(this).after(
        '<br/> ' +
        '<label>1: <input type="text" class="spectrum-input" value="' + value1 + '" data-for="' + this.id + '" data-idx="1"/></label> ' +
        '<label>2: <input type="text" class="spectrum-input" value="' + value2 + '" data-for="' + this.id + '" data-idx="2"/></label>'
      );
    });
    $('.spectrum-input').spectrum({
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
    $('.spectrum-input').change(function() {
      var idSafe = $(this).attr('data-for').replace(':', '\\:');
      var input = $('#' + idSafe);
      if ($('input[data-for="' + idSafe + '"][data-idx="1"]').val() || 
      	  $('input[data-for="' + idSafe + '"][data-idx="2"]').val()) {
        $(input).val(
          $('input[data-for="' + idSafe + '"][data-idx="1"]').val() + ';' +
          $('input[data-for="' + idSafe + '"][data-idx="2"]').val()
        );
      } else {
      	// Don't want to leave a hanging semi-colon in database, as that would cause attribute caption to show
      	// for blank value on description
        $(input).val('');
      }
    });
  });
});
