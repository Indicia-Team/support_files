(function($){
  // Closure.
  
  // Function to calculate quantity attribute 
  function calculateQty() {
    // Get the row of the input which changed.
    var $tr = $(this).closest('tr');

    // Get the inputs of each part of the quantity calculation.
    var $qtyInside = $tr.find('.scQtyInside');
    var $qtyOutside = $tr.find('.scQtyOutside');
    var $qty = $tr.find('.scQty');

    // Get the inside and outside values in the changed row.
    var qtyInside = parseInt($qtyInside.val());
    var qtyOutside = parseInt($qtyOutside.val());

    // Calculate the overall quantity taking in to account that 0 means absent
    // while an empty row means present but not counted.
    var qty;
    if (isNaN(qtyInside)) {
      if (isNaN(qtyOutside)) {
        qty = '';
      }
      else {
        qty = (qtyOutside == 0) ? '' : qtyOutside;
      }
    }
    else {
      if (isNaN(qtyOutside)) {
        qty = (qtyInside == 0) ? '' : qtyInside;
      }
      else {
        qty = qtyInside + qtyOutside;
      }
    }
    // Set the calculated quantity
    $qty.val(qty);

    // Ensure the presence box is checked when a value is entered.
    $tr.find('.scPresence').prop('checked', true);
  }

  // Function to hide quantity cells as they are added to the table.
  function hideQty(data, row){
    $('table.species-grid tr.scClonableRow td.scQtyCell').hide();
  }

  // The jQuery.ready function.
  $(function(){
    // Add event handlers for changes to any inside or outside quantity input
    // present now or added in the future.
    $(document).on('change', '.scQtyInside', calculateQty);
    $(document).on('change', '.scQtyOutside', calculateQty);
    // Hide the quantity column as we will set its value with this script.
    $('table.species-grid th:nth-of-type(5)').hide();
    $('table.species-grid td.scQtyCell').hide();
    $('table tr.scClonableRow td.scQtyCell').hide();
    // Add the hideQty function to the array of functions called when a new
    // row is added to a checklist.
    // hook_species_checklist_new_row.push(hideQty);
  });
})(jQuery);
