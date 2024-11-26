jQuery(document).ready(function($) {
  if ($('#group_id').val()) {
    $.ajax({
      dataType: 'jsonp',
      url: indiciaData.read.url + 'index.php/services/data/group' +
          '?id=' + $('#group_id').val() +
          '&nonce=' + indiciaData.read.nonce + '&auth_token=' + indiciaData.read.auth_token +
          '&mode=json&callback=?'
    }).done(function(data) {
      if (data.length === 1) {
        const isAgroecologyTRANSECT = data[0].title.match(/Agroecology-TRANSECT/);
        const isCAP4GI = data[0].title.match(/CAP4GI/);
        const isUNPplus = data[0].title.match(/UNPplus/);
        const isVielFalterGarten = data[0].title.match(/VielFalterGarten/);
        if (isAgroecologyTRANSECT || isCAP4GI || isUNPplus || isVielFalterGarten) {
          if (!isUNPplus && !isVielFalterGarten) {
            $('#ctrl-wrap-locAttr-340').hide();
            $('#ctrl-wrap-locAttr-365').hide();
            $('#ctrl-wrap-locAttr-366').hide();
            $('#ctrl-wrap-locAttr-367').hide();
            $('#ctrl-wrap-locAttr-368').hide();
            $('#ctrl-wrap-locAttr-369').hide();
            $('#ctrl-wrap-locAttr-370').hide();
            $('#ctrl-wrap-locAttr-371').hide();
            $('#ctrl-wrap-locAttr-372').hide();
            $('#ctrl-wrap-locAttr-373').hide();
            $('#ctrl-wrap-locAttr-374').hide();
          }
          if (!isAgroecologyTRANSECT && !isCAP4GI) {
            $('#land-usage').hide();
            $('#ctrl-wrap-locAttr-364').hide();
            $('#ctrl-wrap-locAttr-375').hide();
          }
          $('#extra-controls-cntr').show();
        }
      }
    });
  }
});