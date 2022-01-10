
jQuery(document).ready(function () {
    // Remove the parent list items to avoid empty bullet point lines being left on the screen
    jQuery('[href*="wildflower-data-entry"]').closest("li").remove(); 
    jQuery('[href*="indicator-data-entry"]').closest("li").remove(); 
    jQuery('[href*="inventory-data-entry"]').closest("li").remove();  

    jQuery('[href*="npms-mode-data-entry-selection"]').closest('ul').siblings('p').before('<br>');

    jQuery('[href*="npms-mode-data-entry-selection"]').closest('li').before('<hr>');
    jQuery('<div>Enter your Wildflower, Inventory and Indicator data here</div>').insertBefore('[href*="npms-mode-data-entry-selection"]');
    
    jQuery('[href*="list-squares-npms-mode"]').closest('li').before('<hr>');
    jQuery('<div>View a list of squares for the project here</div>').insertBefore('[href*="list-squares-npms-mode"]');

    jQuery('[href*="my-samples-npms-mode"]').closest('li').before('<hr>');
    jQuery('<div>View your visits here</div>').insertBefore('[href*="my-samples-npms-mode"]');

    jQuery('[href*="my-projects"]').closest('li').before('<hr>');
    jQuery('[href*="my-projects"]').text('Return to your projects list');
});