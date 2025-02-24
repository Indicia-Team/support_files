//Remove Bumblebee and Dragonfly recording for Hungary, as Hungary uses attributes (such as Life Stage) not compatible with these taxon groups
jQuery(document).ready(function($) {
  setTimeout(function(){
    if ($('#species_grid_table_2').length) {
      $('.species_grid_title').has("h3:contains('Bumblebees')").next().remove();
      $('.species_grid_title').has("h3:contains('Bumblebees')").remove();
      $('.species_grid_controls_2').remove();
      $('#species_grid_table_2').remove();

      $('.species_grid_title').has("h3:contains('Dragonflies')").next().remove();
      $('.species_grid_title').has("h3:contains('Dragonflies')").remove();
      $('.species_grid_controls_3').remove();
      $('#species_grid_table_3').remove();
    }
  }, 1500);
});