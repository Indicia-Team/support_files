(function($){
  // Closure.
  
  // Function to calculate quantity attribute 
  function changeQty() {
    // Get the row of the input which changed.
    var $tr = $(this).closest('tr');

    // Get the inputs of each part of the quantity change function.
    var $qtyInside = $tr.find('.scQty');
    var $qtyOutside = $tr.find('.scQtyOutside');
    var $presence = $tr.find('.scPresence');

    // Get the inside and outside values in the changed row.
    var qtyInside = parseInt($qtyInside.val());
    var qtyOutside = parseInt($qtyOutside.val());

    // Determine the presence
    var qty;
    if (isNaN(qtyInside) && isNaN(qtyOutside)) {
      $presence.prop('checked', false);
    }
    else {
      $presence.prop('checked', true);
    }
  }

  // Function to ensure new species rows are marked as not present when
  // added to the table.
  function uncheckPresence(data, row){
    $(row).find('.scPresence').prop('checked', false);
  }

  // The jQuery.ready function.
  $(function(){
    // Add event handlers for changes to any inside or outside quantity input
    // present now or added in the future.
    $(document).on('change', '.scQty', changeQty);
    $(document).on('change', '.scQtyOutside', changeQty);
    // Hide the presence column as we will set its value with this script.
    $('table.species-grid th:nth-of-type(2)').hide();
    $('table.species-grid td.scPresenceCell').hide();
    $('table tr.scClonableRow td.scPresenceCell').hide();
    // Add the hideQty function to the array of functions called when a new
    // row is added to a checklist.
    // $('table.species-grid tr.scClonableRow .scPresence').prop('checked', false);
    hook_species_checklist_new_row.push(uncheckPresence);
  });
})(jQuery);
