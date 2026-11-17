(function($){
  // Closure.
  
  // Change handlers for quantity inputs. 
  function changeQty() {
    // Get the row of the input which changed.
    setPresence($(this).closest('tr'));
  }

  // Event handler for new row (or taxon changed which also triggers this).
  function newRow(data, row){
    setPresence($(row));
  }

  // Set presence checkbox according to quantity inputs.
  function setPresence($row) {
    // Get the quantity inputs.
    var $qtyInside = $row.find('.scQty');
    var $qtyOutside = $row.find('.scQtyOutside');

    // Get the inside and outside values in the changed row.
    var qtyInside = parseInt($qtyInside.val());
    var qtyOutside = parseInt($qtyOutside.val());

    // Set the presence checkbox.
    var $presence = $row.find('.scPresence');
    if (isNaN(qtyInside) && isNaN(qtyOutside)) {
      $presence.prop('checked', false);
    }
    else {
      $presence.prop('checked', true);
    }
  }

  // The jQuery.ready function.
  $(function(){
    // Add event handlers for changes to any inside or outside quantity input
    // present now or added in the future.
    $(document).on('change', '.scQty', changeQty);
    $(document).on('change', '.scQtyOutside', changeQty);
    // Add the newRow function to the array of functions called when a new
    // row is added to a checklist.
    hook_species_checklist_new_row.push(newRow);
  });
})(jQuery);
