function display_grid_ref_info(features) { 
  if (features[0] && features[0].attributes.location_id && features[0].attributes.centroid_sref) {
      alert("You have clicked on square " + features[0].attributes.centroid_sref + ".");
  }
}