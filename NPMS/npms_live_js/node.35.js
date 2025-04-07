var trainingEventsGridFurtherSetup;

jQuery(document).ready(function () {
  trainingEventsGridFurtherSetup = function() {
    trainingEventsImageReplace();
    trainingEventsLoginButtons();
  }

  // Get full size images instead of thumbnails on grid
   function trainingEventsImageReplace() {
    jQuery('.col-images img').each(function(){
      jQuery(this).attr('src', jQuery(this).attr('src').replace('thumb-', ''))
    });
  }

  function trainingEventsLoginButtons() {
    if ((!(jQuery('body').hasClass('user-logged-in'))) && (!(jQuery('body').hasClass('event-login-btns')))) {
        jQuery('body').addClass('event-login-btns');
        jQuery('.report-grid-container > table > tbody > tr').append('<td class="col-actions"><a class="disabled action-button add-my-event-link">Register/Login above to book</a></td>');
    }
  }
});