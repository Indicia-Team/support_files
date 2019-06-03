(function ($) {
  $(document).ready(function() {
    // Put hardcoded values in to variables for reliable re-use throughout the form

    // Variables for first total
    var treeAgesAttrId = 1308;
    var treeSpacingAttrId = 1309;
    var treeGroundCoveringAttrId = 1310; 
    var treeTotalAttrID = 1188; 

    var youngThinTreesTtId = 14716;
    var matureBiggerTreesTtId = 14717;
    var mixtureSizesTtId = 14718;
    var oldBigTreesTtId = 14719;

    var treesVeryCloseTtId = 14720;
    var treesQuiteCloseTtId = 14721;
    var treesMoreSpacedTtId = 14722;

    var brambleIvyThroughoutTtId = 14723;
    var brambleIvyBigPatchesTtId = 14724;
    var brambleIvySomePatchesTtId = 14725;
    var brambleIvyNoneTtId = 14726;

    var treeTotal;
    var treeAgesConverted;
    var treeSpacingConverted;
    var treeGroundCoveringConverted;

    //Variables for second total
    var habitatsLiveTreesAttrId = 1311;
    var habitatsDeadTreesAttrId = 1333
    var openSpaceAttrId = 1334;
    var rockFeaturesAttrId = 1335;
    var waterFeaturesAttrId = 1336;
    var habitatsTotalAttrId = 1189;

    var veryWideTreeTtId = 14728;
    var oldTreeDeadBranchesTtId = 14729;
    var oldTreeholeInTrunkTtId = 14730;
    var oldTreeBigBranchesTtId = 14731;
    var oldPollardTreeTtId = 14732;
    var deadTreeStillStandingTtId = 16439;
    var smallBranchesLyingOnGroundTtId = 16440;
    var bigBranchesLyingOnGroundTtId = 16441;
    var rottingTreeStumpsTtId = 16442;
    var gladeTtId = 16443;
    var smallRocksTtId = 16444;
    var largeRocksTtId = 16445;
    var rockFaceCliffTtId = 16446;
    var rockFaceWaterTtId = 16447;
    var areaBoggyGroundTtId = 16448;
    var streamsRiversTtId = 16449;
    var waterfallTtId = 16450;

    var habitatsTotal;
    var habitatsLiveTreesConverted;
    var habitatsDeadTreesConverted;
    var openSpaceConverted;
    var rockFeaturesConverted;
    var waterFeaturesConverted;

    //Variables for third total
    var mossesAttrId = 1312;
    var lichensAttrId = 1313;
    var mossesLichensTotalAttrId = 1190;

    var hardlyAnyMossTtId = 14744;
    var fewPatchesMossTtId = 14745;
    var bigPatchesMossTtId = 14746;
    var coveredMossTtId = 14747;

    var noLichenTtId = 14748;
    var someLichenTtId = 14749;
    var notManyLichenTtId = 14750;
    var lotsOfLichenTtId = 14751;

    var mossLichenTotal;
    var mossConverted;
    var lichenConverted;
    
    // Recalculate first total from scratch when one of the controls related to it changes
    // It is possible to only adjust total based on the changing control, but in practice that is more complicated as you
    // need to keep track of what the previous selection was in order to adjust total correctly
    // Controls are rabio buttons in this case
    $('#smpAttr\\:' + treeAgesAttrId + ', #smpAttr\\:' + treeSpacingAttrId  + ', #smpAttr\\:' + treeGroundCoveringAttrId).change(function() {
      treeTotal = 0;
      treeAgesConverted = 0;
      treeSpacingConverted = 0;
      treeGroundCoveringConverted = 0;
      // Need to use name^= (name starts with) because when editing existing data, the attribute_value is placed on the end of the name,
      // so the name varies
      if ($("input[name^=smpAttr\\:" + treeAgesAttrId+"]").filter(":checked").val()) {
        treeAgesConverted=convertIdToRealValue($("input[name^=smpAttr\\:" + treeAgesAttrId+"]").filter(":checked").val());
        treeTotal=treeTotal+treeAgesConverted;
      }
      if ($("input[name^=smpAttr\\:"+treeSpacingAttrId+"]").filter(":checked").val()) {
        treeSpacingConverted = convertIdToRealValue($("input[name^=smpAttr\\:" + treeSpacingAttrId+"]").filter(":checked").val());
        treeTotal = treeTotal+treeSpacingConverted;
      }
      if ($("input[name^=smpAttr\\:"+treeGroundCoveringAttrId+"]").filter(":checked").val()) {
        treeGroundCoveringConverted = convertIdToRealValue($("input[name^=smpAttr\\:"+treeGroundCoveringAttrId + "]").filter(":checked").val());
        treeTotal = treeTotal + treeGroundCoveringConverted;
      }
      $('#smpAttr\\:' + treeTotalAttrID).val(treeTotal);
    });
    
    //Slightly different as control is multi-select checkbox group
    $('#smpAttr\\:' + habitatsLiveTreesAttrId).change(function() {
      countAndSetHabitatFeaturesTotal();
    });

    $('#smpAttr\\:' + habitatsDeadTreesAttrId).change(function() {
      countAndSetHabitatFeaturesTotal();
    });

    $('#smpAttr\\:' + openSpaceAttrId).change(function() {
      countAndSetHabitatFeaturesTotal();
    });

    $('#smpAttr\\:' + rockFeaturesAttrId ).change(function() {
      countAndSetHabitatFeaturesTotal();
    });

    $('#smpAttr\\:' + waterFeaturesAttrId).change(function() {
      countAndSetHabitatFeaturesTotal();
    });

    $('#smpAttr\\:' + habitatsTotalAttrId).change(function() {
      countAndSetHabitatFeaturesTotal();
    });

    function countAndSetHabitatFeaturesTotal() {
      habitatsTotal = 0;

      habitatsLiveTreesConverted = 0;
      habitatsDeadTreesConverted = 0;
      openSpaceConverted = 0;
      rockFeaturesConverted = 0;
      waterFeaturesConverted = 0;

      $.each($("input[name^='smpAttr\\:" + habitatsLiveTreesAttrId + "']:checked"), function() {
        habitatsLiveTreesConverted  = convertIdToRealValue($(this).val());
      });

      $.each($("input[name^='smpAttr\\:" + habitatsDeadTreesAttrId + "']:checked"), function() {
        habitatsDeadTreesConverted  = convertIdToRealValue($(this).val());
      });

      $.each($("input[name^='smpAttr\\:" + openSpaceAttrId + "']:checked"), function() {
        openSpaceConverted  = convertIdToRealValue($(this).val());
      });

      $.each($("input[name^='smpAttr\\:" + rockFeaturesAttrId + "']:checked"), function() {
        rockFeaturesConverted  = convertIdToRealValue($(this).val());
      });

      $.each($("input[name^='smpAttr\\:" + waterFeaturesAttrId + "']:checked"), function() {
        waterFeaturesConverted  = convertIdToRealValue($(this).val());
      });

      habitatsTotal = habitatsTotal + habitatsLiveTreesConverted + habitatsDeadTreesConverted +
          openSpaceConverted + rockFeaturesConverted + waterFeaturesConverted;  
      $('#smpAttr\\:' + habitatsTotalAttrId).val(habitatsTotal);
    }

    //Radio buttons again
    $('#smpAttr\\:' + mossesAttrId + ', #smpAttr\\:' + lichensAttrId).change(function() {
      mossLichenTotal = 0;
      mossConverted = 0;
      lichenConverted = 0;

      // Need to use name^= (name starts with) because when editing existing data, the attribute_value is placed on the end of the name,
      // so the name varies
      if ($("input[name^=smpAttr\\:" + mossesAttrId+"]").filter(":checked").val()) {
        mossConverted=convertIdToRealValue($("input[name^=smpAttr\\:" + mossesAttrId+"]").filter(":checked").val());
        mossLichenTotal=mossLichenTotal+mossConverted;
      }
      if ($("input[name^=smpAttr\\:"+lichensAttrId+"]").filter(":checked").val()) {
        lichenConverted = convertIdToRealValue($("input[name^=smpAttr\\:" + lichensAttrId+"]").filter(":checked").val());
        mossLichenTotal = mossLichenTotal+lichenConverted;
      }
      $('#smpAttr\\:' + mossesLichensTotalAttrId).val(mossLichenTotal);
    });
    
    // When selecting an item from controls, we only have a termlist_term ID for the item, convert this to the real value we want to use
    function convertIdToRealValue(valueToConvert) {
      // When editing data for checkbox groups, the value isn't just the termlist term id, so just collect this part of the value
      valueToConvert = valueToConvert.split(':')[0];
      // Keep track of what all the termlists term IDs means e.g. everything that is for value 1 goes in the idsForZero array
      var idsForZero = [youngThinTreesTtId,brambleIvyThroughoutTtId,hardlyAnyMossTtId,noLichenTtId];
      var idsForOne = [matureBiggerTreesTtId,treesVeryCloseTtId,brambleIvyBigPatchesTtId,smallBranchesLyingOnGroundTtId,fewPatchesMossTtId];
      var idsForTwo = [mixtureSizesTtId,treesQuiteCloseTtId,brambleIvySomePatchesTtId,gladeTtId,veryWideTreeTtId,oldTreeDeadBranchesTtId,
          oldTreeholeInTrunkTtId,oldTreeBigBranchesTtId,oldPollardTreeTtId,deadTreeStillStandingTtId,bigBranchesLyingOnGroundTtId,
          rottingTreeStumpsTtId,smallRocksTtId,largeRocksTtId,rockFaceCliffTtId,rockFaceWaterTtId,areaBoggyGroundTtId,
          streamsRiversTtId,waterfallTtId,bigPatchesMossTtId,notManyLichenTtId];
      var idsForThree = [oldBigTreesTtId,treesMoreSpacedTtId,brambleIvyNoneTtId,coveredMossTtId,lotsOfLichenTtId];
      
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