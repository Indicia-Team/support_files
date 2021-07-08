// Remove the individual data entry forms from the list of accessible pages when the system
// confirms to the user that they have joined a group (leaving just the Data Entry selection page visible)
jQuery(document).ready(function () {
    jQuery('[href*="wildflower-data-entry"]').remove(); 
    jQuery('[href*="indicator-data-entry"]').remove(); 
    jQuery('[href*="inventory-data-entry"]').remove();  
    
    // Remove the parent list items to avoid empty bullet point lines being left on the screen
    jQuery('[href*="wildflower-data-entry"]').closest("li").remove(); 
    jQuery('[href*="indicator-data-entry"]').closest("li").remove(); 
    jQuery('[href*="inventory-data-entry"]').closest("li").remove();  
});