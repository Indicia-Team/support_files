function handle_chart_click_path(path, series, point, data, id) {
  if (id==='records-by-week-chart') {
    var fromDate, toDate, dateObj;
      // calculate date range of the week from the weekdate, ignoring time component.
    fromDate=data.weekdate.substr(0,10);
    dateObj = new Date(fromDate);
    dateObj.setDate(dateObj.getDate() + 6);
    toDate = dateObj.toISOString().substr(0,10);
	return path + '?filter-date_age=&filter-input_date_from='+fromDate+'&filter-input_date_to='+toDate;
  }
  return path;
}