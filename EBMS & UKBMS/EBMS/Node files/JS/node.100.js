jQuery(document).ready(function($) {
  indiciaFns.formatOutput = function(el, sourceSettings, response) {
    var table = $('<table class="table" />');
    var thead = $('<thead><tr><th>Country</th><th>Summary</th></tr></thead>')
      .appendTo(table);
    var tbody = $('<tbody />')
      .appendTo(table);
    var buckets = response.aggregations.by_nesting.filtered.by_loc.buckets;
    $.each(buckets, function eachBucket() {
      var row = $('<tr><td>' + this.key + '</td><td class="subtable"></td></tr>')
        .appendTo(tbody);
      var subTable = $('<table class="table" />');
      var subThead = $('<thead><tr><th class="col-year">Year</th><th class="col-sites">Sites</th><th class="col-child-sites">Sites</th><th class="col-smps">Samples</th><th class="col-child-smps">Samples</th><th class="col-occs">Occurrences</th><th class="col-species">Species</th></tr></thead>')
        .appendTo(subTable);
      var subTbody = $('<tbody />')
        .appendTo(subTable);
      var subBuckets = this.back_to_occurrence.by_year.buckets;
      $.each(subBuckets, function eachSubbucket() {
        $('<tr><td class="col-year">' + this.key + '</td>' +
          '<td class="col-sites">' + this.sites.value + '</td>' +
          '<td class="col-child-sites">' + this.child_sites.value + '</td>' +
          '<td class="col-smps">' + this.samples.value + '</td>' +
          '<td class="col-child-smps">' + this.child_samples.value + '</td>' +
          '<td class="col-occs">' + this.doc_count + '</td>' +
          '<td class="col-species">' + this.species.value + '</td></tr>')
          .appendTo(subTbody);
      })
      subTable.appendTo(row.find('.subtable'));
    });
    $(el).html('');
    $(el).append(table);
    // If Moth Trap survey, we don't want to show parent sites/sample
    // as the survey structure is different.
    if ($('#filter-survey').val() == 681) {
      $('.col-child-sites').show();
      $('.col-child-smps').show();
      $('.col-sites').hide();
      $('.col-smps').hide();
    } else {
      $('.col-child-sites').hide();
      $('.col-child-smps').hide();
      $('.col-sites').show();
      $('.col-smps').show();
    }
  }
});