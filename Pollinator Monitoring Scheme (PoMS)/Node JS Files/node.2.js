(function($){
  // Closure.
  $(function(){
    // Ready.
    var $habitat = $('#smpAttr\\:1048');
    var $habitatOther = $('#smpAttr\\:1049');
    var $habitatOtherWrapper = $('#ctrl-wrap-smpAttr-1049');
    var habitatOtherOption = 13569;
    var habitatOther = '';
    var $flower = $('#smpAttr\\:1050');
    var $flowerOther = $('#smpAttr\\:1051');
    var $flowerOtherWrapper = $('#ctrl-wrap-smpAttr-1051');
    var vagueFlowerOptions = ['14100', '13572', '13610', '13608', '13612', '13613', '13575'];
    // Vague flowers are buttercup, hawthorn, knapweeds, ragwort, thistle, other
    var flowerOtherOption = 13575;
    var flowerOther = '';
    var $floralUnit = $('#smpAttr\\:1054');
    // Add a hidden input to send the value of the floral unit even when it
    // is disabled.
    $floralUnit.after(
      '<input id="hidden-smpAttr:1054" name="hidden-smpAttr:1054" type="hidden" value="">');
    var $floralUnitHidden = $('#hidden-smpAttr\\:1054');
    var floralUnitInputName;
    var manualUnit = '';
    var flower2floralUnit = [];
    flower2floralUnit[13571] = 13579; // Bramble
    flower2floralUnit[13607] = 13582; // Buddleja
    flower2floralUnit[14100] = 13579; // Buttercup
    flower2floralUnit[13570] = 13580; // Dandelion
    flower2floralUnit[13572] = 13579; // Hawthorn
    flower2floralUnit[13608] = 13582; // Heather
    flower2floralUnit[13609] = 13581; // Hogweed
    flower2floralUnit[14064] = 13580; // Ivy
    flower2floralUnit[13610] = 13580; // Knapweeds
    flower2floralUnit[13611] = 13582; // Lavender
    flower2floralUnit[13612] = 13580; // Ragwort
    flower2floralUnit[13613] = 13580; // Thistle
    flower2floralUnit[13573] = 13580; // White Clover
    flower2floralUnit[13574] = 13582; // White Dead-netle
    
    function otherHabitat(){
      // Function to control visibility of 'other habitat' control according to
      // selected habitat.
      if ($habitat.val() == habitatOtherOption) {
        $habitatOther.val(habitatOther);
        $habitatOtherWrapper.show('fast');
      }
      else {
        // Store current values so they can be quickly restored if checkbox
        // clicked in error.
        habitatOther = $habitatOther.val();
        $habitatOther.val('');
        $habitatOtherWrapper.hide('fast');
      }
    }
  
    function otherFlower(){
      // Function to control visibility of 'other flower' control according to
      // selected flower.
      if ($.inArray($flower.val(), vagueFlowerOptions) !== -1) {
        $flowerOther.val(flowerOther);
        $flowerOtherWrapper.show('fast');
      }
      else {
        // Store current values so they can be quickly restored if checkbox
        // clicked in error.
        flowerOther = $flowerOther.val();
        $flowerOther.val('');
        $flowerOtherWrapper.hide('fast');
      }
    }
  
    function floralUnit(){
      // Function to control value of 'floral unit' control according to
      // selected flower.
      if ($flower.val() == flowerOtherOption) {
        // Other flower selected so allow user to set floral unit.
        $floralUnitHidden.val('');
        $floralUnitHidden.prop('name', 'hidden-smpAttr:1054');
        $floralUnit.prop('name', floralUnitInputName);
        $floralUnit.val(manualUnit);
        $floralUnit.prop('disabled', false);
      }
      else {
        // Control floral unit automatically based on flower selected.
        var autoUnit = flower2floralUnit[$flower.val()];
        manualUnit = '';
        $floralUnit.val(autoUnit);
        $floralUnit.prop('name', 'disabled-smpAttr:1054');
        $floralUnit.prop('disabled', true);
        $floralUnitHidden.val(autoUnit);
        $floralUnitHidden.prop('name', floralUnitInputName);
      }
    }
  
    // Set up event handlers
    $habitat.change(function(){
      // On change to habitat selection.
      otherHabitat();
    });
    $flower.change(function(){
      // On change to flower selection.
      otherFlower();
      floralUnit();
    });

    
    // Initialise on load as we may be editing a record.
    habitatOther = $habitatOther.val();
    flowerOther = $flowerOther.val();
    manualUnit = $floralUnit.val();
    floralUnitInputName = $floralUnit.prop('name');
    otherHabitat();
    otherFlower();
    floralUnit();
    
  });
})(jQuery);


