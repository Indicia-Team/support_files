function display_grid_ref_info(features) { 
  if (window.confirm('You have clicked on square ' + features[0].attributes.centroid_sref + '.\n' +
      'Would you like to view the plots for this square?')) {
    window.location.href='list-plots-npms-mode?dynamic-parent_id=' + features[0].attributes.location_id;
  };
}