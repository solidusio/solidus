import lunr from 'lunr';

var query = decodeURIComponent(window.location.search.match(/inputSearch=(.*?)(&|$)/)[1]).replace('+', ' ');

function populateIndex(data) {
  var index = lunr(function(){
    this.field('title', { boost: 10 });
    this.field('content');
    this.field('url');
    this.ref('id');
    var lunr_index = this

    data.forEach(function(item) {
      lunr_index.add(item);
    });
  });

  return index;
}

function contentList(data) {
  var contents = [];
  data.forEach(function(item) {
    contents.push(item);
  });
  return contents;
}

function search(index, contents){
  let results = index.search(query)
  document.querySelector('.search-results-title strong').innerHTML = query;
  addSearchResults(results, contents, query)
}

function addSearchResults(results, contents) {
  let template = document.querySelector('.result-template').content;
  let resultList = document.querySelector('.results-list');

  results.forEach(function(result) {
    let list_item = template.cloneNode(true);

    let title = contents[result.ref].title;
    let body = contents[result.ref].content;
    let href = contents[result.ref].url;

    list_item.querySelector('.title a').innerHTML = highlightQuery(title, query);
    list_item.querySelector('.title a').href = href;
    list_item.querySelector('.category').innerHTML = formatCategory(href);
    list_item.querySelector('p').innerHTML = formatBody(body, query)

    resultList.appendChild(list_item);
  });
}

function formatCategory(href, title) {
  let category = href.split('/')[2].split('-').join(' ').replace(/^./g, l => l.toUpperCase());
  return 'Developer Documentation > ' + category;
}

function highlightQuery(text) {
  let re = new RegExp('((?:^|>)[^<>]*?)('+query+')([^<>]*?(?:$|<))', "gim");
  return text.replace(re, '$1<span class="search-highlight">$2</span>$3');
}

function formatBody(body) {
  return highlightQuery(body.match(/<p>([\s\S]*?)<\/p>/)[0]);
}

let data = JSON.parse(sessionStorage.getItem('search_index'));
let index = populateIndex(data);
let contents = contentList(data);
search(index, contents);
