(function ($) {
  $(document).ready(function() {
    // Put hardcoded values in to variables for reliable re-use throughout the form
    // Variables for first total
    // Attribute IDs
    var treeAgeProfileAttrId = 1164;
    var treeDensityAttrId = 1165;
    var treeGroundCoverAttrId = 1166;
    var treeTotalAttrID = 1188;
    
    // Termlist term IDs
    var youngAgedWoodTtId = '14152';
    var matureAgedWoodTtId = '14153'
    var mixAgedWoodTtId = '14154';
    var woodWithManyOldTtId = '14155';
    var youngTreesCloselyPackedTtId = '14156';
    var matureTreesCloselyPackedTtId = '14157';
    var matureTreesSomeGapsTtId = '14158';
    var matureTreesLargeGapsTtId = '14159';
    var abundantCoverTtId = '14160';
    var frequentDenseCoverTtId = '14161';
    var someDensePatchesTtId = '14162';
    var isolatedPatchesTtId = '14163';
    
    var treeTotal;
    var treeAgeProfileConverted;
    var treeDensityConverted;
    var treeGroundCoverConverted;
    
    // Variables for second total
    var gladesTreesAttrId = 1167;
    var veteranTreesAttrId = 1168;
    var deadWoodAttrId = 1169;
    var rockFeaturesAttrId = 1170;
    var wetFeaturesAttrId = 1171;
    var woodFeaturesTotalAttrId = 1189;
    
    var presenceWideTreesTtId = '14164';
    var oldDeadWoodCanopyTtId = '14165';
    var oldTreesDecayHolesTtId = '14166';
    var oldPollardsTtId = '14167';
    var oldTreesHorizontalTtId = '14168';
    
    var sparseDeadWoodTtId = '14169';
    var newlyCutDeadWoodTtId = '14170';
    var freqLyingDeadWoodTtId = '14171';
    var lyingDeadWoodLargeDiamTtId = '14172';;
    var rottingTreeStumpsTtId = '14173';
    var standingDeadWoodTtId = '14174';
    
    var noRockFeaturesTtId = '14175';
    var smallBouldersTtId = '14176';
    var largeBouldersTtId = '14177';
    var naturalRockTtId = '14178';
    
    var noFeaturesTtId = '14179';
    var boggyAreasTtId = '14180';
    var streamsTtId = '14181';
    var wetRockTtId = '14182';
    var ravinesTtId = '14183';
    
    // Variables for third total
    var woodFeaturesTotal;
    var veteranTreesConverted;
    var deadWoodConverted;
    var rockFeaturesConverted;
    var wetFeaturesConverted;
    
    var bryophyteAttrId = 1172;
    var lichenAttrId = 1173;
    var bryophyteLichenTotalAttrId = 1190;
    
    var littleBryophyteTtId = '14184';
    var patchyBryophyteTtId = '14185';
    var largerAreasBryophyteTtId = '14186';
    var carpetedBryophyteTtId = '14187';
    
    var trunksMostlyBareTtId = '14188';
    var trunksSomeLichenTtId = '14189';
    var fewTrunksWithLichenTtId = '14190';
    var trunksWithLuxuriantLichenTtId = '14191';
    var oldTreesWithLichenTtId = '14192';
    
    var bryophyteLichenTotal;
    var bryophyteConverted;
    var lichenConverted;
    
    // Variables for fourth total
    var denseAbundantAttrId = 1182;
    var rhododendronAttrId = 1183;
    var balsamAttrId = 1184;
    var conifersAbundantAttrId = 1185;
    var sycamoreAttrId = 1186;
    var otherSpeciesAttrId = 1187;
    var lackOfRegenerationAttrId = 1192;
    var threatTotalAttrId = 1191;
    
    var threatAbsentTtId = '14221';
    var threatMinorTtId = '14222';
    var threatExtensiveTtId = '14223';
    var threatLargeTtId = '14224';

    var threatTotal;
    var denseAbundantConverted;
    var rhododendronConverted;
    var balsamConverted;
    var conifersAbundantConverted;
    var sycamoreConverted;
    var otherSpeciesConverted;
    
    // Recalculate first total from scratch when one of the controls related to it changes
    // It is possible to only adjust total based on the changing control, but in practice that is more complicated as you
    // need to keep track of what the previous selection was in order to adjust total correctly
    $('#smpAttr\\:' + treeAgeProfileAttrId + ', #smpAttr\\:' + treeDensityAttrId  + ', #smpAttr\\:' + treeGroundCoverAttrId).change(function() {
      treeTotal = 0;
      treeAgeProfileConverted = 0;
      treeDensityConverted = 0;
      treeGroundCoverConverted = 0;
      // Need to use name^= (name starts with) because when editing existing data, the attribute_value is placed on the end of the name,
      // so the name varies
      if ($("input[name^=smpAttr\\:" + treeAgeProfileAttrId+"]").filter(":checked").val()) {
        treeAgeProfileConverted=convertIdToRealValue($("input[name^=smpAttr\\:" + treeAgeProfileAttrId+"]").filter(":checked").val());
        treeTotal=treeTotal+treeAgeProfileConverted;
      }
      if ($("input[name^=smpAttr\\:"+treeDensityAttrId+"]").filter(":checked").val()) {
        treeDensityConverted = convertIdToRealValue($("input[name^=smpAttr\\:" + treeDensityAttrId+"]").filter(":checked").val());
        treeTotal = treeTotal+treeDensityConverted;
      }
      if ($("input[name^=smpAttr\\:"+treeGroundCoverAttrId+"]").filter(":checked").val()) {
        treeGroundCoverConverted = convertIdToRealValue($("input[name^=smpAttr\\:"+treeGroundCoverAttrId + "]").filter(":checked").val());
        treeTotal = treeTotal + treeGroundCoverConverted;
      }
      $('#smpAttr\\:' + treeTotalAttrID).val(treeTotal);
    });
    
    // Similar thing for second total, apart from this time there is a checkbox, and the other controls are multi-select checkbox groups
    // so we need to cycle through all options and add up a total of the user selected items
    $('#smpAttr\\:' + gladesTreesAttrId + ', #smpAttr\\:' + veteranTreesAttrId + ', #smpAttr\\:' + deadWoodAttrId+', #smpAttr\\:' + rockFeaturesAttrId+', #smpAttr\\:' + wetFeaturesAttrId).change(function() {
      woodFeaturesTotal = 0;
      veteranTreesConverted = 0;
      deadWoodConverted = 0;
      rockFeaturesConverted = 0;
      wetFeaturesConverted = 0;
      
      if ($('#smpAttr\\:' + gladesTreesAttrId).is(":checked")) {
        woodFeaturesTotal = woodFeaturesTotal+2;  
      }
        
      $.each($("input[name^='smpAttr\\:" + veteranTreesAttrId + "']:checked"), function() {
        veteranTreesConverted = convertIdToRealValue($(this).val());
        woodFeaturesTotal = woodFeaturesTotal + veteranTreesConverted;  
      });
      
      $.each($("input[name^='smpAttr\\:" + deadWoodAttrId + "']:checked"), function() {
        deadWoodConverted = convertIdToRealValue($(this).val());
        woodFeaturesTotal = woodFeaturesTotal + deadWoodConverted;  
      });
      
      $.each($("input[name^='smpAttr\\:" + rockFeaturesAttrId + "']:checked"), function() {
        rockFeaturesConverted = convertIdToRealValue($(this).val());
        woodFeaturesTotal = woodFeaturesTotal + rockFeaturesConverted;  
      });
      
      $.each($("input[name^='smpAttr\\:"+wetFeaturesAttrId+"']:checked"), function() {
        wetFeaturesConverted = convertIdToRealValue($(this).val());
        woodFeaturesTotal = woodFeaturesTotal + wetFeaturesConverted;  
      });
      
      $('#smpAttr\\:' + woodFeaturesTotalAttrId).val(woodFeaturesTotal);
    });
    
    // Third total calculated from one single selection radio group, and the other control is multi-selection checkboxes
    $('#smpAttr\\:' + bryophyteAttrId + ', #smpAttr\\:' + lichenAttrId).change(function() {
      bryophyteLichenTotal = 0;
      bryophyteConverted = 0;
      lichenConverted = 0;
        
      if ($('input[name^=smpAttr\\:'+bryophyteAttrId+']').filter(":checked").val()) {
        bryophyteConverted=convertIdToRealValue($("input[name^=smpAttr\\:"+bryophyteAttrId+"]").filter(":checked").val());
        bryophyteLichenTotal=bryophyteLichenTotal+bryophyteConverted;
      }
      $.each($("input[name^='smpAttr\\:"+lichenAttrId+"[]']:checked"), function() {
        lichenConverted=convertIdToRealValue($(this).val());
        bryophyteLichenTotal=bryophyteLichenTotal+lichenConverted;  
      });
      
      $('#smpAttr\\:'+bryophyteLichenTotalAttrId).val(bryophyteLichenTotal);
    });
    
    // Fourth total is several multi-selection controls, and one checkbox
    $("#smpAttr\\:" + denseAbundantAttrId + ", #smpAttr\\:" + rhododendronAttrId + ", #smpAttr\\:" + balsamAttrId +
    ", #smpAttr\\:" + conifersAbundantAttrId + ", #smpAttr\\:" + sycamoreAttrId + ", #smpAttr\\:" + otherSpeciesAttrId + 
    ", #smpAttr\\:" + lackOfRegenerationAttrId).change(function() {
      threatTotal = 0;
      denseAbundantConverted = 0;
      rhododendronConverted = 0;
      balsamConverted = 0;
      conifersAbundantConverted = 0;
      sycamoreConverted = 0;
      otherSpeciesConverted = 0;
      if ($("#smpAttr\\:" + denseAbundantAttrId).val()) {
        denseAbundantConverted=convertIdToRealValue($("#smpAttr\\:" + denseAbundantAttrId).val());
        threatTotal=threatTotal+denseAbundantConverted;
      }
      
      if ($("#smpAttr\\:" + rhododendronAttrId).val()) {
        rhododendronConverted=convertIdToRealValue($("#smpAttr\\:" + rhododendronAttrId).val());
        threatTotal=threatTotal+rhododendronConverted;
      }
      
      if ($("#smpAttr\\:" + balsamAttrId).val()) {
        balsamConverted=convertIdToRealValue($("#smpAttr\\:" + balsamAttrId).val());
        threatTotal=threatTotal+balsamConverted;
      }
      
      if ($("#smpAttr\\:" + conifersAbundantAttrId).val()) {
        conifersAbundantConverted=convertIdToRealValue($("#smpAttr\\:" + conifersAbundantAttrId).val());
        threatTotal=threatTotal+conifersAbundantConverted;
      }
      
      if ($("#smpAttr\\:" + sycamoreAttrId).val()) {
        sycamoreConverted=convertIdToRealValue($("#smpAttr\\:" + sycamoreAttrId).val());
        threatTotal=threatTotal+sycamoreConverted;
      }
      
      if ($("#smpAttr\\:" + otherSpeciesAttrId).val()) {
        otherSpeciesConverted=convertIdToRealValue($("#smpAttr\\:" + otherSpeciesAttrId).val());
        threatTotal=threatTotal+otherSpeciesConverted;
      }
      if ($('#smpAttr\\:'+lackOfRegenerationAttrId).is(":checked")) {
        threatTotal=threatTotal+3;  
      }
      $('#smpAttr\\:'+threatTotalAttrId).val(threatTotal);
    });
    
    // When selecting an item from controls, we only have a termlist_term ID for the item, convert this to the real value we want to use
    function convertIdToRealValue(valueToConvert) {
      // When editing data for checkbox groups, the value isn't just the termlist term id, so just collect this part of the value
      valueToConvert = valueToConvert.split(':')[0];
      // Keep track of what all the termlists term IDs means e.g. everything that is for value 1 goes in the idsForZero array
      var idsForZero = [youngAgedWoodTtId,youngTreesCloselyPackedTtId,abundantCoverTtId,littleBryophyteTtId,trunksMostlyBareTtId,
      sparseDeadWoodTtId,noRockFeaturesTtId,noFeaturesTtId,threatAbsentTtId];
      var idsForOne = [matureAgedWoodTtId,matureTreesCloselyPackedTtId,frequentDenseCoverTtId,patchyBryophyteTtId,trunksSomeLichenTtId,fewTrunksWithLichenTtId,
      newlyCutDeadWoodTtId,freqLyingDeadWoodTtId,threatMinorTtId];
      var idsForTwo = [mixAgedWoodTtId,matureTreesSomeGapsTtId,someDensePatchesTtId,largerAreasBryophyteTtId,
      presenceWideTreesTtId,oldDeadWoodCanopyTtId,oldTreesDecayHolesTtId,oldPollardsTtId,oldTreesHorizontalTtId,
      lyingDeadWoodLargeDiamTtId,rottingTreeStumpsTtId,standingDeadWoodTtId,
      smallBouldersTtId,largeBouldersTtId,naturalRockTtId,
      boggyAreasTtId,streamsTtId,wetRockTtId,ravinesTtId,
      threatExtensiveTtId];
      var idsForThree = [woodWithManyOldTtId,matureTreesLargeGapsTtId,isolatedPatchesTtId,carpetedBryophyteTtId,trunksWithLuxuriantLichenTtId,oldTreesWithLichenTtId,
      threatLargeTtId];
      
      var convertedValue;
      if (inArray(valueToConvert, idsForZero)) {
        convertedValue = 0;
      }
      
      if (inArray(valueToConvert, idsForOne)) {
        convertedValue = 1;
      }
      
      if (inArray(valueToConvert, idsForTwo)) {
        convertedValue = 2;
      }
      
      if (inArray(valueToConvert, idsForThree)) {
        convertedValue = 3;
      }
      return convertedValue;
    }
    
    // Need this as Javascript doesn't have an in_array function like PHP
    function inArray(needle, haystack) {
      var length = haystack.length;
      for(var i = 0; i < length; i++) {
        if(haystack[i] == needle) 
          return true;
        }
      return false;
    }
  });
}) (jQuery);