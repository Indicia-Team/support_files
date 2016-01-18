jQuery(window).load(function () {
  jQuery('#save-button').click(function(){
    //Check to make sure user has entered at least one species.
    //We count the visible rows in the grid to make sure there are at least 3
    //An empty grid consists of the header and an empty row.
    if (jQuery('#[id^="species-grid"] tr:visible').length < 3) {
      alert('Oops, you seem to have forgotten to enter the species you recorded.');
      return false;
    } else {
      jQuery('#entry_form').submit();
    }
  });
});