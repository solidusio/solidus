import TomSelect from "tom-select";
import { setValidity, parseLinkHeader } from "solidus_admin/utils";

class SolidusSelect extends HTMLSelectElement {
  static observedAttributes = ["synced"];

  connectedCallback() {
    const tomselect = new TomSelect(this, this.getTomSelectSettings());

    this.setAttribute("synced", "true");

    // set default style for inner input field
    tomselect.control_input.style =
      "flex: 1 1 auto;\n" +
      "line-height: inherit !important;\n" +
      "max-height: none !important;\n" +
      "max-width: 100% !important;\n" +
      "min-height: 0 !important;\n" +
      "min-width: 7rem;\n" +
      "outline: none !important;"

    this.setAttribute("hidden", "true");
    this.setAttribute("aria-hidden", "true");
    this.fixDropdownScroll();
    setValidity(this, this.dataset.errorMessage);
  }

  attributeChangedCallback(name, oldValue, newValue) {
    switch (name) {
      case "synced":
        if (newValue === "false") {
          const keepNone = function() { return false; }
          this.tomselect.clearOptions(keepNone);
          this.tomselect.sync();
          this.setAttribute("synced", "true");
        }
        break;
    }
  }

  getTomSelectSettings() {
    const originalSelect = this;
    const settings = {
      controlClass: "control",
      dropdownClass: "dropdown",
      dropdownContentClass: "dropdown-content",
      optionClass: "option",
      wrapperClass: "wrapper",
      maxOptions: null,
      refreshThrottle: 0,
      plugins: {
        no_active_items: true,
        remove_button: {
          append: originalSelect.multiple,
          className: "remove-button"
        },
      },
      onType: function() {
        if (!originalSelect.multiple && !this.currentResults.items.length) {
          this.setTextboxValue("");
          this.refreshOptions();
        }
      },
    };

    if (originalSelect.getAttribute("data-src")) {
      settings.plugins.virtual_scroll = true
      settings.firstUrl = () => originalSelect.getAttribute("data-src");
      settings.load = originalSelect.loadOptions.bind(originalSelect);
      settings.shouldLoad = (query) => query.length > 1
      settings.preload = true;
      settings.valueField = originalSelect.getAttribute("data-option-value-field") || "id";
      settings.labelField = originalSelect.getAttribute("data-option-label-field") || "name";
      settings.searchField = [settings.labelField];
      settings.render = {
        loading: function() {
          return "<div class='loading'>Loading</div>";
        },
        loading_more: function() {
          return "<div class='loading-more disabled'>Loading...</div>";
        }
      };
    }

    return settings;
  }

  buildUrl(query) {
    const url = new URL(this.tomselect.getUrl(query));
    if (!query) return url;

    url.searchParams.set(this.getAttribute("data-query-param"), query);
    return url.toString();
  }

  // Fetch all options from remote source and setup pagination if needed
  async loadOptions(query, callback) {
    const { options, next } = await this.fetchOptions(query);
    if (next) {
      this.tomselect.setNextUrl(query, next);
    }

    callback(options);
  }

  // Fetch options from remote source. If options data is nested in json response, specify path to it with "data-json-path"
  // E.g. https://whatcms.org/API/List data is deep nested in json response: `{ result: { list: [...] } }`, so
  //  in order to access it, specify attributes as follows:
  //  "data-src"="https://whatcms.org/API/List"
  //  "data-json-path"="result.list"
  async fetchOptions(query) {
    const dataPath = this.getAttribute("data-json-path");
    const response = await fetch(this.buildUrl(query), { headers: { "Accept": "application/json" } });
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

  fixDropdownScroll() {
    // https://github.com/orchidjs/tom-select/issues/556
    // https://github.com/orchidjs/tom-select/issues/867
    this.patch("onOptionSelect");
    this.patch("loadCallback");
  }

  patch(fnName) {
    const originalFn = this.tomselect[fnName];
    this.tomselect.hook("instead", fnName, function() {
      const originalScrollToOption = this.scrollToOption;

      this.scrollToOption = () => {};
      originalFn.apply(this, arguments);
      this.scrollToOption = originalScrollToOption;
    });
  }
}

customElements.define("solidus-select", SolidusSelect, { extends: "select" });
