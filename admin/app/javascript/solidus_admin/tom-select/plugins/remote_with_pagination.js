import { parseLinkHeader } from "solidus_admin/utils";

// Fetch all options from remote source and setup pagination if needed
const loadOptions = async function(query, callback) {
  const { options, next } = await fetchOptions.call(this, query);
  if (next) {
    this.setNextUrl(query, next);
  }

  callback(options);
}

// Fetch options from remote source. If options data is nested in json response, specify path to it with "jsonPath"
// E.g. https://whatcms.org/API/List data is deep nested in json response: `{ result: { list: [...] } }`, so
//  in order to access it, pass config options to this plugin as follows:
//  {
//    src: "https://whatcms.org/API/List",
//    jsonPath: "result.list"
//  }
const fetchOptions = async function(query) {
  const dataPath = this.settings.jsonPath;
  const response = await fetch(buildUrl.call(this, query), { headers: { "Accept": "application/json" } });
  if (!response.ok) {
    return { options: [] };
  }

  const next = parseLinkHeader(response.headers.get("Link")).next;
  const json = await response.json();

  let options;
  if (!dataPath) {
    options = json;
  } else {
    options = dataPath.split('.').reduce((acc, key) => acc && acc[key], json);
  }

  return { options, next };
}

const buildUrl = function(query) {
  const url = new URL(this.getUrl(query));
  const queryParam = this.settings.queryParam;
  if (!query || !queryParam) return url.toString();

  url.searchParams.set(queryParam, query);
  return url.toString();
}

export default function(config) {
  this.settings.firstUrl = () => config.src;
  this.settings.load = loadOptions.bind(this);
  this.settings.preload = config.preload;
  this.settings.valueField = config.valueField || "id";
  this.settings.labelField = config.labelField || "name";
  this.settings.searchField = [this.settings.labelField];
  this.settings.jsonPath = config.jsonPath;
  this.settings.queryParam = config.queryParam;
  this.settings.render = {
    loading: function() {
      return "<div class='loading'>Loading</div>";
    },
    loading_more: function() {
      return "<div class='loading-more'>Loading more results</div>";
    },
    no_more_results: function() {},
  };

  this.require("virtual_scroll");
}
