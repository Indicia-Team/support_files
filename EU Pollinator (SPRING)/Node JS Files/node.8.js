jQuery(document).ready(function($) {
  // Make sure the system only ever shows the initially agreed upon sets or terms, nothing added for other countries
  // or the app
  
  var trapDisturbedNames = ['','yes','no','not sure'];
  
  var habitatCodeClassificationNames = ['','H1 - Marine saltmarshes/estuaries/saline reedbeds',
    'H2 - Coastal dune grassland','H3 - Coastal dune and sand heath','H4 - Coastal dune and sand scrub',
    'H5 - Coastal dune and sand woods','H6 - Coastal dune slacks','H7 - Coastal machair','H8 - Coastal shingle',
    'H9 - Coastal cliffs/undercliffs','H10 - Fen/swamp/marsh vegetation of inland freshwater edges',
    'H11 - Bare ground/sparse vegetation of inland freshwater edges','H12 - Acid bog/mire habitats',
    'H13 - Flushes','H14 - Inland swamp/fen stands without open water (e.g. reedbeds)',
    'H15 - Dry semi/unimproved (flower-rich) chalk/limestone grassland','H16 - Dry semi/unimproved acid grassland',
    'H17 - Dry semi/unimproved (flower-rich) neutral grassland','H18 - Agriculturally improved/re-seeded/ heavily fertilised grassland',
    'H19 - Seasonally wet and wet marshy grasslands','H20 - Bracken dominated glades or hillsides',
    'H21 - Stands of tall herbs (e.g. nettle and willow-herb beds)','H22 - Dry scrub/shrub thickets','H23 - Wet and dry heathland/ dry heather moorland',
    'H24 - Wet Willow scrub of fen, river and lake-side','H25 - Hedgerows','H26 - Mature broadleaved woodland',
    'H27 - Mature coniferous woodland','H28 - Mature mixed broadleaved and coniferous woodland',
    'H29 - Lines of trees or scattered trees of parkland','H30 - Small man-made woodlands',
    'H31 - Recently felled areas/early-stage woodland and coppice',
    'H32 - Bare ground/herb/grass mosaics of wood rides, hedgebanks and green lanes','H33 - Orchards, hop gardens and vineyards',
    'H34 - Inland screes/cliffs/ rock pavements, and outcrops','H35 - Intensive arable crops','H36 - Horticultural crops',
    'H37 - Organic arable crops','H38 - Bare ground/weeds of arable field margins or fallow/recently abandoned arable crops (e.g. set-aside)',
    'H39 - Ornamental shrubs/trees/lawns of parks/domestic gardens, etc.','H40 - Bare ground/weed communities of post-industrial sites',
    'H0 - not recorded'];
   
  // Trap station number drop-down
  jQuery('#smpAttr\\:1093 option').each(function() {
    if (jQuery.inArray(jQuery(this).text(),stationNumberNames) === -1) {
	  jQuery(this).remove();
    }
  });
  
  // Pant trap disturbed drop-down
  jQuery('#smpAttr\\:1096 option').each(function() {
    if (jQuery.inArray(jQuery(this).text(),trapDisturbedNames) === -1) {
	  jQuery(this).remove();
    }
  });
  
  // First habitat drop-down
  jQuery('#smpAttr\\:1106 option').each(function() {
    if (jQuery.inArray(jQuery(this).text(),habitatCodeClassificationNames) === -1) {
	  jQuery(this).remove();
    }
  });
  
  // Second habitat drop-down
  jQuery('#smpAttr\\:1107 option').each(function() {
    if (jQuery.inArray(jQuery(this).text(),habitatCodeClassificationNames) === -1) {
	  jQuery(this).remove();
    }
  });
});     

// Closure.
(function($){
  $(function(){
    // Ready.

    function validate1kmSquare() {
      if ($('#imp-location\\:name').val().length === 0) {
        alert("Please select a 1km square from the defined list.");
        return false;
      }
      else {
        return true;
      }
    }
  
    function validateSref() {
      // First 6 characters of location_autocomplete should be a 4-figure gridref.
      var bigSref = $('#imp-location\\:name').val().slice(0, 6);
      var smallSref = $('#imp-sref').val();
      if (smallSref.length === 0) {
        alert("Please enter a precise grid reference.");
        return false
      }
      // smallSref must be inside bigSref (the 1km square).
      if (bigSref.slice(0,2).toLowerCase() == smallSref.slice(0, 2).toLowerCase()) {
        // Good! First two letter match.
        bigSref = bigSref.slice(2);
        smallSref = smallSref.slice(2);
        var smallSrefLen = smallSref.length;
        if (smallSrefLen % 2 == 0) {
          // Still good! smallSref has an even number of digits. 
          var bigSrefEasting = bigSref.slice(0, 2);
          var bigSrefNorthing = bigSref.slice(2);
          var smallSrefEasting = smallSref.slice(0, smallSrefLen/2);
          var smallSrefNorthing = smallSref.slice(smallSrefLen/2);
          if ((smallSrefEasting.slice(0, 2) == bigSrefEasting) &&
              (smallSrefNorthing.slice(0, 2) == bigSrefNorthing)) {
            // Yay! Its either the same as bigSref or inside it.
            return true;
          }
        }
      }
      
      alert("Please ensure the precise grid reference is inside the 1km square.");
      return false;
    }
  
    // Set up event handlers
    $('#save-button').click(function(e){
      // On form submit, validate location.
      var valid;
      valid = validate1kmSquare();
      // Validation only works on OSGB
      if (valid && $('#imp-sref-system option:selected').val() == 'OSGB') {
        valid = validateSref();
      }
      if (!valid) {
        e.preventDefault();
      }
    });

  });
})(jQuery);
