
/*
 * Javascript for grid ref popup on maps
 */
function map_square_info_popup(features, div,columns) {  
  if (features.length!==0) {
    alert('Grid reference: '+features[0].attributes.entered_sref);
  } else {
    alert('No grid reference information available.\n\nPlease close this box and zoom closer to the square for an accurate reading.'); 
  }
}