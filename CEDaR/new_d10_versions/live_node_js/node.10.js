jQuery(window).load(function () {
  jQuery('#save-button').click(function(){
    //Check to make sure user has entered at least one species.
    //We count the visible rows in the grid to make sure there are at least 3
    //An empty grid consists of the header and an empty row.
    //Don't do this in edit mode, as in CEDaR there is (currently) no clonable empty row in edit mode, which makes things more complicated to code.
    //Also we don't really need this functionality in edit mode as there will already be a species. If someone wants to remove it deliberately
    //we may as well let them.
    //Check occurrence_id or sample_id isn't in the URL (i.e. ignore in Edit Mode)
    if (jQuery('#[id^="species-grid"] tr:visible').length < 3 && window.location.href.indexOf("occurrence_id") == -1 && window.location.href.indexOf("sample_id") == -1) {
      alert('Oops, you seem to have forgotten to enter the species you recorded.');
      return false;
    } else {
      jQuery('#entry_form').submit();
    }
  });
});