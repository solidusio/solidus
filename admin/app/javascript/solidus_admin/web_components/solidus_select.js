import TomSelect from "solidus_admin/tom-select";
import { setValidity } from "solidus_admin/utils";

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
          append: this.multiple,
          className: "remove-button"
        },
        patch_scroll: true,
        stash_on_search: true,
      },
    };

    if (this.getAttribute("data-src")) {
      settings.plugins.remote_with_pagination = {
        src: this.getAttribute("data-src"),
        preload: this.getAttribute("data-no-preload") !== "true",
        valueField: this.getAttribute("data-option-value-field"),
        labelField: this.getAttribute("data-option-label-field"),
        jsonPath: this.getAttribute("data-json-path"),
        queryParam: this.getAttribute("data-query-param"),
      };
    }

    return settings;
  }
}

customElements.define("solidus-select", SolidusSelect, { extends: "select" });
