jQuery(document).ready(function($) {

function setRecorderName() {
  var $recorder=$('#smpAttr\\:127'), $firstName=$('#smpAttr\\:36'), $lastName=$('#smpAttr\\:58');
  if ($recorder.val().match(/[a-zA-Z]/)===null) {
    $recorder.val($lastName.val() + ', ' + $firstName.val());
  }
}

$($('#tab-species').parent()).bind('tabsshow', setRecorderName);

});