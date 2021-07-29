jQuery(document).ready(function($) {
  // Make sure the system only ever shows the initially agreed upon sets or terms, nothing added for other countries
  // or the app
  var habitatNames = ['','Garden','School grounds','Parkland with trees','Churchyard',
      'Grassy verge or hedgerow edge','Grassland with wild flowers (e.g. meadow)',
      'Amenity grassland (usually mown short)','Farm crops or grassy pasture',
      'Upland moorland','Lowland heath',"Brownfield or other 'waste ground'",
      'Woodland','Other - please describe below',
      'Gardd','Tir ysgol','Tir parc gyda choed','Mynwent eglwys','Ymyl glaswelltog neu ymyl gwrych',
      'Glaswelltir gyda blodau gwyllt (e.e. dôl)','Glaswelltir amwynder (wedi ei dorri’n fyr fel arfer)',
      'Cnydau fferm neu boraf laswelltog','Rhostir ucheldir','Gweundir iseldir','Tir llwyd neu ‘dir gwastraff’ arall',
      'Coetir','Arall - disgrifiwch isod'];
	
  var targetNames = ['','Bramble (Blackberry) - Rubus fruticosus','Buddleja','Buttercup - Ranunculus species',
      'Dandelion - Taraxacum officinale','Hawthorn - Crataegus','Heathers - Calluna and Erica species',
      'Hogweed - Heracleum sphondylium','Ivy - Hedera','Knapweeds (Common or Greater) - Centaurea nigra or scabiosa',
      'Lavender (English) - Lavandula angustifolia','Ragwort - Jacobaea/Senecio species','Thistle - Cirsium or Carduus',
      'White Clover - Trifolium repens','White Dead-nettle - Lamium album','Other - please describe below',
      'Miaren/Mwyaren Ddu - Rubus fruticosus','Buddleja','Blodyn menyn - rhywogaethau Ranunculus',
      'Dant y llew - Taraxacum officinale','Draenen Wen - Crataegus','Grug - Rhywogaethau Calluna ac Erica',
      'Efwr - Heracleum sphondylium','Iorwg - Hedera','Y Bengaled/Bengaled Fawr - Centaurea nigra neu scabiosa',
      'Lafant (Saesnig) - Lavandula angustifolia','Llysiau’r Gingroen - rhywogaethau Jacobaea/Senecio',
      'Ysgall - Carduus neu Cirsium','Meillionen Wen - Trifolium repens',
      'Marddanhadlen Wen - Lamium album','Arall - disgrifiwch isod'];
      
  var typeNames = ['','individual flower','flower head','flower umbel','flower spike',
      'blodyn unigol','pen blodau','wmbel blodau','pigyn blodau'];
  
  var patchOccupationNames = ['','Growing in a larger patch of the same flower','Growing in a larger patch of many different flowers',
      'More or less isolated','Not recorded',
      "Mae'r blodau targed yn gorchuddio llai na hanner y llain","Mae'r blodau targed yn gorchuddio tua hanner y llain",
      "Mae'r blodau targed yn gorchuddio dros hanner y llain","Heb ei gofnodi"];
      
  var patchContextNames = ['','Growing in a larger patch of the same flower','Growing in a larger patch of many different flowers',
      'More or less isolated','Not recorded',
      'Yn tyfu mewn llain fwy o’r un blodyn','Yn tyfu mewn llain fwy o lawer o flodau gwahanol',
      'Wedi ei hynysu fwy neu lai','Heb ei gofnodi'];
      
  var skyNames = ['','All or mostly blue','Half blue and half cloud','All or mostly cloud','Not recorded',
      "I gyd neu’r rhan fwyaf yn las","Hanner yn las hanner yn gymylog",
      "Yn gwbl neu’n bennaf gymylog","Heb ei gofnodi"];
    
  var sunShadeNames = ['','Entirely in sunshine','Partly in sun and partly shaded','Entirely shaded','Not recorded',
      'Yn gyfan gwbl yn yr haul','Rhannol yn yr haul a rhannol yn y cysgod',
      'Yn gyfan gwbl yn y cysgod','Heb ei gofnodi'];
  
  var windNames = ['','Leaves still/moving occasionally','Leaves moving gently all the time',
      'Leaves moving strongly','Not recorded',
      'Dail yn llonydd/symud weithiau',"Dail yn symud yn ysgafn drwy’r amser",
      "Dail yn symud yn sylweddol","Heb ei gofnodi"];
	
  // Habitat drop-down
  jQuery('#smpAttr\\:1048 option').each(function() {
    if (jQuery.inArray(jQuery(this).text(),habitatNames) === -1) {
	  jQuery(this).remove();
    }
  });
  
  // Target flower drop-down
  jQuery('#smpAttr\\:1050 option').each(function() {
    if (jQuery.inArray(jQuery(this).text(),targetNames) === -1) {
	  jQuery(this).remove();
    }
  });
  
  // Type flower drop-down
  jQuery('#smpAttr\\:1054 option').each(function() {
    if (jQuery.inArray(jQuery(this).text(),typeNames) === -1) {
	  jQuery(this).remove();
    }
  });
  
  // Patch occupation radio buttons
  jQuery('#smpAttr\\:1052').find('input').each(function() {
    if (jQuery.inArray(jQuery(this).text(),patchOccupationNames) === -1) {
	  jQuery(this).parent('li').remove();
    }
  });
  
  // Patch context radio buttons
  jQuery('#smpAttr\\:1055').find('input').each(function() {
    if (jQuery.inArray(jQuery(this).text(),patchContextNames) === -1) {
	  jQuery(this).parent('li').remove();
    }
  });
  
  // Sky above your location
  jQuery('#smpAttr\\:1057 option').each(function() {
    if (jQuery.inArray(jQuery(this).text(),skyNames) === -1) {
	  jQuery(this).remove();
    }
  });
  
  // Sun or shade
  jQuery('#smpAttr\\:1061 option').each(function() {
    if (jQuery.inArray(jQuery(this).text(),sunShadeNames) === -1) {
	  jQuery(this).remove();
    }
  });
  
  // Wind strength
  jQuery('#smpAttr\\:1058 option').each(function() {
    if (jQuery.inArray(jQuery(this).text(),windNames) === -1) {
	  jQuery(this).remove();
    }
  });
});

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


