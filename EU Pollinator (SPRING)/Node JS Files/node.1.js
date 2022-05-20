// Restrict the country drop-down to participating counties only
var validCountries = [
  215970,215983,215985,216036,216017,216018,216022,216027,
  216005,216023,216020,216031,
  216038,216077,216069,216094,216092,216093,216108,216120,
  216139,216122,216126,216176,216175,216035,216172,216189
];

$('#dynamic-parent_country_id').ready(function() {
  $('#dynamic-parent_country_id option').each(function () {
  	// Check for existence of $(this).val(), otherwise we end up removing the "please select" option
    if ($(this).val() && !inArray($(this).val(), validCountries)) {
      $(this).remove();
    }
  });
});

function inArray(needle, haystack) {
  var length = haystack.length;
  for(var i = 0; i < length; i++) {
    if(haystack[i] == needle) return true;
  }
  return false;
};