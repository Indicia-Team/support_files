var indicia_release_record, indicia_block_record, indicia_specify_record;

(function ($) {
	function postToServer(s) {
	  $.post('http://www2.habitas.org.uk/records/?q=ajaxproxy&node=69&index=occurrence', 
		s,
		function (data) {
		  if (typeof data.error === 'undefined') {
			indiciaData.reports.dynamic.grid_report_grid_0.reload(true);
		  } else {
			alert(data.error);
		  }
		},
		'json'
	  );
	}
	indicia_release_record = function(id) {
	  var s = {
		"website_id":29,
		"occurrence:id":id,
		"occurrence:release_status":"R"
	  };
	  postToServer(s);
	}
	indicia_block_record = function(id) {
	  var s = {
		"website_id":29,
		"occurrence:id":id,
		"occurrence:release_status":"R",
		"occurrence:record_status":"D",
		"occurrence_comment:comment":"A huge thanks for this record from the Garden Bioblitz team. Some species can be tricky to identify with certainty, and after "+
			"a quick look at your record we think you will either need to provide more evidence for the record (such as extra photos) "+
			"or that the identification might not be correct. If you edit the record using the button on the right you can supply a photo "+
			"or other evidence or correct the identification and resubmit it."
	  };
	  postToServer(s);
	}
	indicia_specify_record = function(id) {
	  var s = {
		"website_id":29,
		"occurrence:id":id,
		"occurrence:release_status":"R",
		"occurrence:record_status":"D",
		"occurrence_comment:comment":"A huge thanks for this record from the Garden Bioblitz team. Some species can be tricky to identify with certainty, but "+
		    "it is important to try to get records identified as species wherever possible in order that they can support conservation and science. If you "+
			"are not able to identify the species yourself but can post a photo of this record to iSpot then others can help you with the identification. "+
			"once identified, use the edit button on the notification or My Records page to edit the identification of the record."  
	  };
	  postToServer(s);
	}
}(jQuery));
