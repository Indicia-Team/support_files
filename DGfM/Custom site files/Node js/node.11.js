
var setLegendState;
var mapZoomEnd;
mapInitialisationHooks.push(function(div) {

  div.map.events.register('changelayer', null, mapLayerChanged);
  
  function mapLayerChanged(event) {
    // Get any selected layers (not there might be more than one as there is also the report layer)
    var layers = div.map.getLayersBy("visibility", true); 
    // Cycle through each active layer and check it
    for (var i = 0; i < layers.length; i++) {
      setLegendState(layers[i].name);
    }
    // Workaround a problem where the default Openlayers switcher is not hiding/showing
    // layers properly, we don't know why, so workaround this
    var layers = div.map.layers; 
    for (var i = 0; i < div.map.layers.length; i++) {
      if (layers[i].isBaseLayer==true) {
        if (layers[i].visibility == true) {
          jQuery(div.map.layers[i].div).show();
        } else {
		  jQuery(div.map.layers[i].div).hide();
        }
      }
    }
  }

  //Cycle through each visible layer and show the appropriate legend image
  setLegendState = function setLegendState(layerName) {
    if (layerName==='Altitude') {
      jQuery("#altitude-legend").show();
      jQuery("#geology-legend").hide();
      jQuery("#topography-legend").hide();
    }

    if (layerName==='Geology') {
      jQuery("#altitude-legend").hide();
      jQuery("#geology-legend").show();
      jQuery("#topography-legend").hide();
    }

    if (layerName==='Topography') {
      jQuery("#altitude-legend").hide();
      jQuery("#geology-legend").hide();
      jQuery("#topography-legend").show();
    }
  }
});

jQuery(document).ready(function($) {

	// Hide the language in the popular name field, as DGfM don't want it shown on screen
	$("dt").filter(function() {
    	return $(this).text() === "German" || $(this).text() === "deutsch" || $(this).text() === "německy" || 
    	$(this).text() === "english" || $(this).text() === "englisch" || $(this).text() === "anglicky" || 
    	$(this).text() === "Czech" || $(this).text() === "tschechisch" || $(this).text() === "česky"
	}).hide();
	
	// Copy the first appearance thumbnail and add it after the page title 
	$('.page-header').after($('.thumbnail:contains(Habitus):first, .thumbnail:contains(Appearance):first, .thumbnail:contains(Celkový vzhled):first').find('img').clone().prop('id', 'title-thumbnail'));
	// Change the element before the image (the heading) so the image is at the end of the heading rather than the previous line
	$('#title-thumbnail').prev().css("display", "inline-block");
	// Add spaces between title and img
	$('#title-thumbnail').before("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
	
	// Stop the Endangerness label in German cutting off by giving a bit more room to it
	//$("dt:contains(Bestand und Bedrohung)").css("width", "170px");
	
	// Move the description author from the Details tab to the Descriptions tab.
	// The html for author-move-to is held in the Form Structure.
    $('#author-move-from').insertBefore('#author-move-to');
    
    // Change the Drupal page title to be the same as the species name (which we have setup in a hidden field in species_details)
    $('.js-quickedit-page-title').each(function( index ) {
      $(this).text($('#species-name-hidden').text());
    });
	
	// Remove the pages caption in the literature section leaving only the comma behind
	$('#tab-literature').find("b:contains(page)").each(function() {
	  $(this).html($(this).html().replace('page', ''));
	});
	$('#tab-literature').find("b:contains(Pages)").each(function() {
	  $(this).html($(this).html().replace('Pages', ''));
	});
	$('#tab-literatur').find("b:contains(Seitenzahl (von bis bei zeitschrift, Gesamtseitenz)").each(function() {
	  $(this).html($(this).html().replace('Seitenzahl (von bis bei zeitschrift, Gesamtseitenz', ''));
	});
	$('#tab-literatur').find("b:contains(Seiten)").each(function() {
	  $(this).html($(this).html().replace('Seiten', ''));
	});
	$('#tab-literatura').find("b:contains(Stránky)").each(function() {
	  $(this).html($(this).html().replace('Stránky', ''));
	});
	$('#tab-literatura').find("b:contains(strana)").each(function() {
	  $(this).html($(this).html().replace('strana', ''));
	});
	
	// On the protection tab remove the are/sub-area names
	$('#tab-protection').find("dt:contains(Endangerness)").each(function() {
	  $(this).html($(this).html().replace('Endangerness', ''));
	});
	$('#tab-schutz').find("dt:contains(Bestand und Bedrohung)").each(function() {
	  $(this).html($(this).html().replace('Bestand und Bedrohung', ''));
	});
	$('#tab-ochrana').find("dt:contains(ohrožení)").each(function() {
	  $(this).html($(this).html().replace('ohrožení', ''));
	});
	
	//Change the Ecology label on the Protection tab to be a custom one
	$('#tab-schutz').find("h3:contains(Ökologie)").text("Gefährdungsstatus");
	$('#tab-protection').find("h3:contains(Ecology)").text("Endangerness");
	$('#tab-ochrana').find("h3:contains(ekologie)").text("Stav nebezpečí");
});


 