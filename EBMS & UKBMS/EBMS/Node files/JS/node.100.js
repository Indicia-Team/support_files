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
      var subThead = $('<thead><tr><th>Year</th><th>Sites</th><th>Samples</th><th>Occurrences</th><th>Species</th></tr></thead>')
        .appendTo(subTable);
      var subTbody = $('<tbody />')
        .appendTo(subTable);
      var subBuckets = this.back_to_occurrence.by_year.buckets;
      $.each(subBuckets, function eachSubbucket() {
        $('<tr><td>' + this.key + '</td>' +
          '<td>' + this.transects.value + '</td>' +
          '<td>' + this.samples.value + '</td>' +
          '<td>' + this.doc_count + '</td>' +
          '<td>' + this.species.value + '</td></tr>')
          .appendTo(subTbody);
      })
      subTable.appendTo(row.find('.subtable'));
    });
    $(el).html('');
    $(el).append(table);
  }
});