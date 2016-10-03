
/*
 * Javascript for grid ref popup on maps
 */
function map_square_info_popup(features, div,columns) {  
  if (features.length!==0) {
    var html;
    html="<div>";
    html+="<label>Grid reference</label><br>";
    html+="<em>"+features[0].attributes.entered_sref+"</em><br>";
    html+="<div>";
    return html;
  } else {
    return "<div><em>No grid reference information available.<br>Please close this box and zoom closer to the square for an accurate reading.</em></div>"; 
  }
}