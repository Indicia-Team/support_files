var trainingEventsImageReplace;
jQuery(document).ready(function () {
  // Get full size images instead of thumbnails on grid
  trainingEventsImageReplace = function trainingEventsImageReplace() {
    jQuery('.col-images img').each(function(){
      jQuery(this).attr('src', jQuery(this).attr('src').replace('thumb-', ''))
    });
  }
});