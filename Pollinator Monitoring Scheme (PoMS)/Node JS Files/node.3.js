(function($){
  // Closure.
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
      if (valid) {
        valid = validateSref();
      }
      if (!valid) {
        e.preventDefault();
      }
    });

  });
})(jQuery);
