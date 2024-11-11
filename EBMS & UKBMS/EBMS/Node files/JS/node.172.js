jQuery(document).ready(function($) {
  indiciaData.onloadFns.push(function() {
    if ($('#tab-myprojects .empty-row:visible').length>0) {
      indiciaFns.activeTab($('#controls'), 1);
    }
  });

  function searchMyProjects() {
    indiciaData.reports.dynamic.grid_my_projects[0].settings.extraParams.search_text = $('#search-projects-my').val();
    indiciaData.reports.dynamic.grid_my_projects.reload(true);
  }

  function searchAllProjects() {
    indiciaData.reports.dynamic.grid_all_projects[0].settings.extraParams.search_text = $('#search-projects-all').val();
    indiciaData.reports.dynamic.grid_all_projects.reload(true);
  }

  $('#search-btn-my').click(searchMyProjects);
  $('#search-btn-all').click(searchAllProjects);
  $('#search-projects-my').on('keyup', function (e) {
    if (e.key === 'Enter' || e.keyCode === 13) {
      searchMyProjects();
    }
  });
  $('#search-projects-all').on('keyup', function (e) {
    if (e.key === 'Enter' || e.keyCode === 13) {
      searchAllProjects();
    }
  });

});
