jQuery(document).ready(function() {
  jQuery('#ctrl-wrap-occurrence-comment').insertAfter(jQuery('#container-occurrence_medium-default'));
  jQuery('<h3 style="text-align:center">OR</h3>').insertAfter(jQuery('#container-occurrence_medium-default'));
  jQuery('[for^="occurrence\\:comment"]').text('Description of Species:');
});