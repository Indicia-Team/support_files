/**
 *
 * HTML5 Color Picker
 *
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2012, Script Tutorials
 * http://www.script-tutorials.com/
 */

jQuery(document).ready(function($) {
  //$('#ctrl-wrap-taxon-attribute').hide();
  //$('#taxon\\:authority').attr('disabled', true);
  //$('#metaFields\\:synonyms').attr('disabled', true);
  //$('#taxa_taxon_list\\:parent_id\\:taxon').attr('disabled', true);
  //$('#ctrl-wrap-taxon-external_key').hide();
  //$('#ctrl-wrap-taxon-search_code').hide();
  //$('#ctrl-wrap-taxa_taxon_list-description').hide();
  //$('#taxon\\:taxon_group_id').attr('disabled', true);
  //$('#taxon\\:taxon_rank_id').attr('disabled', true);
  //$('#ctrl-wrap-taxa_taxon_list-taxonomic_sort_order').hide();
   
  var colourSelector = 
  	'.colour-wheel,'+
  	'[id="taxAttr\\:35"],'+
 	'[id="taxAttr\\:50"],'+
  	'[id="taxAttr\\:51"],'+
  	'[id="taxAttr\\:79"],'+
  	'[id="taxAttr\\:80"],'+
  	'[id="taxAttr\\:91"],'+
  	'[id="taxAttr\\:125"],'+
  	'[id="taxAttr\\:145"],'+
  	'[id="taxAttr\\:146"],'+
  	'[id="taxAttr\\:147"],'+
  	'[id="taxAttr\\:178"],'+
 	'[id="taxAttr\\:179"],'+
	'[id="taxAttr\\:180"],'+
 	'[id="taxAttr\\:181"],'+
 	'[id="taxAttr\\:182"],'+
  	'[id="taxAttr\\:183"],'+
  	'[id="taxAttr\\:183"],'+
  	'[id="taxAttr\\:219"],'+
    '[id="taxAttr\\:220"],'+
    '[id="taxAttr\\:242"],'+
    '[id="taxAttr\\:243"],'+
    '[id="taxAttr\\:244"],'+
    '[id="taxAttr\\:245"],'+
    '[id="taxAttr\\:265"],'+
    '[id="taxAttr\\:266"],'+
    '[id="taxAttr\\:267"],'+
    '[id="taxAttr\\:268"],'+
    '[id="taxAttr\\:285"],'+
    '[id="taxAttr\\:286"],'+
    '[id="taxAttr\\:287"],'+
    '[id="taxAttr\\:288"],'+
    '[id="taxAttr\\:289"],'+
    '[id="taxAttr\\:313"],'+
    '[id="taxAttr\\:314"],'+
    '[id="taxAttr\\:336"],'+
    '[id="taxAttr\\:349"],'+
    '[id="taxAttr\\:350"],'+
    '[id="taxAttr\\:396"],'+
    '[id="taxAttr\\:397"],'+
    '[id="taxAttr\\:436"],'+
    '[id="taxAttr\\:437"],'+
    '[id="taxAttr\\:438"],'+
    '[id="taxAttr\\:439"],'+
    '[id="taxAttr\\:500"],'+
    '[id="taxAttr\\:501"],'+
    '[id="taxAttr\\:539"],'+
    '[id="taxAttr\\:540"],'+
    '[id="taxAttr\\:558"],'+
    '[id="taxAttr\\:559"],'+
    '[id="taxAttr\\:596"],'+
    '[id="taxAttr\\:597"],'+
    '[id="taxAttr\\:615"],'+
    '[id="taxAttr\\:616"],'+
    '[id="taxAttr\\:617"],'+
    '[id="taxAttr\\:682"],'+
    '[id="taxAttr\\:726"],'+
    '[id="taxAttr\\:731"],'+
    '[id="taxAttr\\:735"],'+
    '[id="taxAttr\\:736"],'+
    '[id="taxAttr\\:737"],'+
    '[id="taxAttr\\:738"],'+
    '[id="taxAttr\\:775"],'+
    '[id="taxAttr\\:780"],'+
    '[id="taxAttr\\:781"],'+
  	'[id="taxAttr\\:782"],'+
    '[id="taxAttr\\:783"],'+
    '[id="taxAttr\\:784"],'+
   	'[id="taxAttr\\:785"],'+
   	'[id="taxAttr\\:804"],'+
   	'[id="taxAttr\\:805"],'+
    '[id="taxAttr\\:806"],'+
    '[id="taxAttr\\:807"],'+
    '[id="taxAttr\\:808"],'+
    '[id="taxAttr\\:809"],'+
    '[id="taxAttr\\:810"],'+
    '[id="taxAttr\\:811"],'+
   	'[id="taxAttr\\:814"],'+
    '[id="taxAttr\\:815"],'+
    '[id="taxAttr\\:816"],'+
    '[id="taxAttr\\:817"],'+
    '[id="taxAttr\\:818"],'+
    '[id="taxAttr\\:819"],'+
    '[id="taxAttr\\:820"],'+
    '[id="taxAttr\\:821"],'+
   	'[id="taxAttr\\:823"],'+
    '[id="taxAttr\\:826"],'+
    '[id="taxAttr\\:827"],'+
    '[id="taxAttr\\:828"],'+
    '[id="taxAttr\\:872"],'+
    '[id="taxAttr\\:873"],'+
    '[id="taxAttr\\:874"],'+
    '[id="taxAttr\\:875"],'+
   	'[id="taxAttr\\:877"],'+
   	'[id="taxAttr\\:878"],'+
   	'[id="taxAttr\\:879"],'+
   	'[id="taxAttr\\:881"],'+
   	'[id="taxAttr\\:882"],'+
    '[id="taxAttr\\:883"],'+
    '[id="taxAttr\\:884"],'+
    '[id="taxAttr\\:885"],'+
    '[id="taxAttr\\:890"],'+
    '[id="taxAttr\\:891"],'+
   	'[id="taxAttr\\:1066"],'+
   	'[id="taxAttr\\:1067"],'+
   	'[id="taxAttr\\:1068"],'+
   	'[id="taxAttr\\:1069"],'+
   	'[id="taxAttr\\:1070"],'+
   	'[id="taxAttr\\:1071"],'+
   	'[id="taxAttr\\:1072"],'+
   	'[id="taxAttr\\:1073"],'+
  	'[id="taxAttr\\:1074"]';
  	
  indiciaData.colourPickerCount = 0;
  indiciaFns.hookDynamicAttrsAfterLoad.push(function() {
    $.each($(colourSelector), function() {
      var input = this;
      indiciaData.colourPickerCount++;
      $(input).wrap('<div class="input-group">');
      $(input).after('<!-- preview element --> \
<div class="colorpicker-preview input-group-addon" id="colorpicker-preview-' + indiciaData.colourPickerCount + '"></div>');
      $(input).parent().after('<!-- colorpicker element --> \
<div id="colorpicker-' + indiciaData.colourPickerCount + '" style="display:none"> \
  <canvas class="picker" var="1" width="300" height="300"></canvas> \
  <input type="hidden" class="hexVal" id="hexVal' + indiciaData.colourPickerCount + '" /> \
</div>');
      var bCanPreview = true; // can preview

      // create canvas and context objects
      var $ctrl = $('#colorpicker-' + indiciaData.colourPickerCount);
      var $canvas = $ctrl.find('canvas');
      var ctx = $canvas[0].getContext('2d');

      // drawing active image
      var image = new Image();
      image.onload = function () {
          ctx.drawImage(image, 0, 0, image.width, image.height); // draw the image on the canvas
      }

      // select desired colorwheel
      var imageSrc = 'colorwheel1.png';
      switch ($canvas.attr('var')) {
          case '2':
              imageSrc = 'colorwheel2.png';
              break;
          case '3':
              imageSrc = 'colorwheel3.png';
              break;
          case '4':
              imageSrc = 'colorwheel4.png';
              break;
          case '5':
              imageSrc = 'colorwheel5.png';
              break;
      }
      image.src = '/sites/default/files/indicia/images/' + imageSrc;

      $ctrl.find('.picker').mousemove(function(e) { // mouse move handler
        if (bCanPreview) {
          // get coordinates of current position
          var canvasOffset = $canvas.offset();
          var canvasX = Math.floor(e.pageX - canvasOffset.left);
          var canvasY = Math.floor(e.pageY - canvasOffset.top);

          // get current pixel
          var imageData = ctx.getImageData(canvasX, canvasY, 1, 1);
          var pixel = imageData.data;

          // update preview color
          var pixelColor = "rgb("+pixel[0]+", "+pixel[1]+", "+pixel[2]+")";
          $('#colorpicker-preview-' + indiciaData.colourPickerCount).css('backgroundColor', pixelColor);

          // update controls
          var dColor = pixel[2] + 256 * pixel[1] + 65536 * pixel[0];
          $ctrl.find('.hexVal').val('#' + ('0000' + dColor.toString(16)).substr(-6));
        }
      });
      var selectColour = function(e) {
        // preview click
        $ctrl.fadeToggle("slow", "linear");
        bCanPreview = true;
        $(input).val($ctrl.find('.hexVal').val());
      };
      $ctrl.find('.picker').click(selectColour);
      $('#colorpicker-preview-' + indiciaData.colourPickerCount).click(selectColour);
    });
  });
});
