jQuery(document).ready(function($) {
  $('#submit-to-details-page').submit(function () {
    if (!$('#occurrence\\:taxa_taxon_list_id').val()) {
      alert('Please enter a species to search for');
      return false;
    }  
    $('#occurrence\\:taxa_taxon_list_id\\:taxon').prop('name', '');
    $('#occurrence\\:taxa_taxon_list_id').prop('name', 'taxa_taxon_list_id');
  });
});


 
 