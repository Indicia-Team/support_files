// Change references to Group to say Project in the importer, and remove fields that aren't needed.
jQuery(window).load(function () {
  jQuery('[label="Groups location"]').prop('label','Projects');
  jQuery('[value="groups_location:fk_group"]').prop('label','Project (from controlled termlist)');
  jQuery('[value="groups_location\\:fk_created_by"]').remove();
  jQuery('[value="groups_location\\:id"]').remove();
});