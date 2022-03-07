function display_grid_ref_info(features) { 
  if (features[0] && features[0].attributes.id && features[0].attributes.name) {
      alert("You have clicked on square " + features[0].attributes.name + ".");
  }
}