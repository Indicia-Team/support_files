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
  indiciaData.colourPickerCount = 0;
  indiciaFns.hookDynamicAttrsAfterLoad.push(function() {
    $.each($('.colour-wheel'), function() {
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
