jQuery(document).ready(function($) {
  "option strict";
  indiciaFns.quickViewSample = function(doc) {

    var reportingURL = indiciaData.read.url + 'index.php/services/report/requestReport' +
      '?report=projects/ebms/ebms_sample_quick_view.xml&callback=?';
    var reportOptions = {
      mode: 'json',
      nonce: indiciaData.read.nonce,
      auth_token: indiciaData.read.auth_token,
      reportSource: 'local',
      sample_id: doc.event.event_id,
    };
    $.getJSON(reportingURL, reportOptions,
      function (data) {
        if (data.length === 0) {
          alert(indiciaData.lang.mysamples.noSampleDetails);
          return;
        }
        html = '<h3>' + indiciaData.lang.mysamples.popupTitle.replace('@date', data[0].date).replace('@recorder',  data[0].recorder) + '</h3>';
        html += '<table class="table"><tbody>'
        $.each(data, function (i, item) {
          // Skip sample only rows (due to SQL left join).
          if (item.taxon !== null) {
            html += '<tr><th scope="row"><em>' + item.taxon + '</em></th><td>' + item.individuals + '</td></tr>'
          }
        });
        html += '</tbody></table>';
        html += '<a class="btn btn-primary pull-right" href="/mydata/samples/details?sample_id=' + doc.event.event_id + '">' + indiciaData.lang.mysamples.fullDetails + '</a>';
        $.fancybox.open(html);
      }
    );
  }

  // Force the input_form for edit links, as incorrect in early records from app.
  indiciaFns.editSample = function(doc) {
    var inputForm = doc.metadata.input_form;
    if (doc.metadata.survey.id == 565 || doc.metadata.survey.id == 645) {
      inputForm = 'mydata/samples/edit';
    }
    window.location.href = '/' + inputForm + '?sample_id=' + doc.event.event_id;
  }
});