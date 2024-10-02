jQuery(document).ready(function($) {
  // all of search list plus first 3 rows of other grid have to be valid numbers
  $('#search-list .scOccAttrCell  input,#fixed-list tr:lt(4) .scOccAttrCell  input,#fixed-list tr:eq(8) .scOccAttrCell  input').addClass('{pattern:/^[0-9]*$/}');
  $('#fixed-list tr:eq(4) .scOccAttrCell  input,#fixed-list tr:eq(5) .scOccAttrCell  input').addClass('{pattern:/^[0SMA]$/}');
  $('#fixed-list tr:eq(6) .scOccAttrCell  input').addClass('{pattern:/^(Br|Bo|C)$/}');
  $('#fixed-list tr:eq(7) .scOccAttrCell  input').addClass('{pattern:/^[FQSV]$/}');
  $('#fixed-list .scOccAttrCell input').keyup(function(e) {
    e.target.value=e.target.value.charAt(0).toUpperCase() + e.target.value.slice(1)
  });
});