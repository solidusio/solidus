import TomSelect from "solidus_admin/tom-select";
import { setValidity } from "solidus_admin/utils";

class SolidusSelect extends HTMLSelectElement {
  static observedAttributes = ["synced"];

  connectedCallback() {
    const tomselect = new TomSelect(this, this.tomSelectSettings);

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

  get tomSelectSettings() {
    const settings = {
      controlClass: "control",
      dropdownClass: "dropdown",
      dropdownContentClass: "dropdown-content",
      optionClass: "option",
      wrapperClass: "wrapper",
      allowEmptyOption: true,
      maxOptions: null,
      refreshThrottle: 0,
      plugins: {
        no_active_items: true,
        remove_button: {
          append: this.multiple,
          className: "remove-button"
        },
        patch_scroll: true,
        stash_on_search: true,
      },
      render: {
        no_results: function() {
          const message = this.input.getAttribute("data-no-results-message");
          return `<div class='no-results'>${message}</div>`;
        },
      },
    };

    if (this.getAttribute("data-src")) {
      settings.valueField = this.getAttribute("data-option-value-field") || "id";
      settings.labelField = this.getAttribute("data-option-label-field") || "name";

      settings.plugins.remote_with_pagination = {
        src: this.getAttribute("data-src"),
        preload: this.getAttribute("data-no-preload") !== "true",
        jsonPath: this.getAttribute("data-json-path"),
        queryParam: this.getAttribute("data-query-param"),
        loadingMessage: this.getAttribute("data-loading-message"),
        loadingMoreMessage: this.getAttribute("data-loading-more-message"),
      };
    }

    return settings;
  }
}

customElements.define("solidus-select", SolidusSelect, { extends: "select" });
