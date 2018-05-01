import 'jquery';

if (sessionStorage.getItem('search_index') === null) {
  $.getJSON("/contents.json", function(data) {
    sessionStorage.setItem('search_index', JSON.stringify(data));
  });
}