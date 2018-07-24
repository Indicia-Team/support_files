jQuery(document).ready(function($) {
  $('#submit-to-edit-page').submit(function () {
    $('#occurrence\\:taxa_taxon_list_id\\:taxon').prop('name', '');
    $('#occurrence\\:taxa_taxon_list_id').prop('name', 'taxa_taxon_list_id');
  });
});