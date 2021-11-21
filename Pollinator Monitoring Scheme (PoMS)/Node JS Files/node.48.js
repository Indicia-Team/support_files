// Only include UK related items in the selection list
jQuery(document).ready(function () {
  var taxaToAllow = ['Bumblebees', 'Honeybees', 'Solitary bees', 'Wasps', 'Hoverflies',
	  'Other flies', 'Butterflies and moths', 'Beetles', 'Small insects (<3mm)', 'Other insects'];
  indiciaFns.on('click', '.autocomplete-select', {}, function () {
  	setTimeout(function() {
      jQuery('.ac_even').each(function() {
  	  	if (!taxaToAllow.includes(jQuery(this).find('span').text())) {
  	  	  jQuery(this).remove();
        }
  	  });
  	  jQuery('.ac_odd').each(function() {
  	    if (!taxaToAllow.includes(jQuery(this).find('span').text())) {
  	  	  jQuery(this).remove();
        }
  	  });
    }, 750);
  });
});