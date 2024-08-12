var indicia_release_record, indicia_block_record;

(function ($) {
	function postToServer(s) {
	  $.post('http://www.brc.ac.uk/irecord/?q=ajaxproxy&node=616&index=occurrence', 
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
		"website_id":23,
		"occurrence:id":id,
		"occurrence:release_status":"R"
	  };
	  postToServer(s);
	}
	indicia_block_record = function(id) {
	  var s = {
		"website_id":23,
		"occurrence:id":id,
		"occurrence:release_status":"R",
		"occurrence:record_status":"D",
		"occurrence_comment:comment":"A huge thanks for this record from the Garden Bioblitz team. We've had a quick look at your record and "+
			"think that you will either need to provide more evidence for the record or that the identification might not be correct. "+
			"If you edit the record you can supply a photo or other evidence then correct the identification and resubmit it."
	  };
	  postToServer(s);
	}
}(jQuery));