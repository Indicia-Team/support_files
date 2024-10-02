// JavaScript Document
jQuery(document).ready(function($) {
  var startDate = new Date(),
    startTime = startDate.getTime(),
    doneTimeMessage = false,
    doneRowsMessage = false;
  
  hook_species_checklist_new_row.push(function() {
    if (!doneTimeMessage) {
      nowDate = new Date();
      nowTime = nowDate.getTime();
      if (((nowTime - startTime)/(1000*60)) > 30) { // 30 minutes
        doneTimeMessage=true;
        alert("You've been working on that list for a while now. Why not submit the records then start a new form for the rest of your records? "+
            "This way there will be less chance of something going wrong like losing your internet connection or your session timing out. "+
            "Note that you can submit as many forms as you like and they will all count towards your Garden Bioblitz total");
      }
    }
    if (!doneRowsMessage && $('table#fulllist tbody tr').length===51) {
      doneRowsMessage=true;
      alert("You've built up quite a long list of records on the form now. Why not submit the records then start a new form for the rest of your records? "+
            "This way there will be less chance of something going wrong like losing your internet connection or your session timing out. "+
            "Note that you can submit as many forms as you like and they will all count towards your Garden Bioblitz total");
    }
  });
});
