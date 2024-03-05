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
  
    function otherFlower() {
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
  
    // Set up event handlers
    $habitat.change(function(){
      // On change to habitat selection.
      otherHabitat();
    });
    $flower.change(function(){
      // On change to flower selection.
      otherFlower();
    });

    
    // Initialise on load as we may be editing a record.
    habitatOther = $habitatOther.val();
    flowerOther = $flowerOther.val();
    otherHabitat();
    otherFlower();
    
  });
})(jQuery);


