import TomSelect from "tom-select";
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
    const originalSelect = this;
    const settings = {
      controlClass: "control",
      dropdownClass: "dropdown",
      dropdownContentClass: "dropdown-content",
      optionClass: "option",
      wrapperClass: "wrapper",
      maxOptions: 500,
      refreshThrottle: 0,
      plugins: {
        no_active_items: true,
        remove_button: {
          append: originalSelect.multiple,
          className: "remove-button"
        },
      },
      onItemAdd: function() {
        if (!originalSelect.multiple || !this.isOpen) return;

        this.setTextboxValue("");
        this.refreshOptions();
      },
      onLoad: function() {
        originalSelect.tomselect.setValue(
          originalSelect.getAttribute("data-selected")?.split(",") || [],
          true
        );
      },
      onType: function() {
        if (!originalSelect.multiple && !this.currentResults.items.length) {
          this.setTextboxValue("");
          this.refreshOptions();
        }
      },
    };

    if (originalSelect.getAttribute("data-src")) {
      settings.load = originalSelect.loadOnce.bind(originalSelect);
      settings.preload = true;
      settings.valueField = originalSelect.getAttribute("data-option-value-field") || "id";
      settings.labelField = originalSelect.getAttribute("data-option-label-field") || "name";
      settings.searchField = [settings.labelField];
      settings.render = {
        loading: function() {
          return "<div class='loading'>Loading</div>";
        }
      }
    }

    return settings;
  }

  // Fetch all options from remote source and remove #load callback
  // https://tom-select.js.org/examples/remote/
  async loadOnce(query, callback) {
    // Avoid queueing more load requests (e.g. searching while options are still loading) if there's one already running
    if (this.tomselect.loading > 1) {
      callback();
      return;
    }

    const options = await this.fetchOptions();
    callback(options);
    this.tomselect.settings.load = null;
  }

  async fetchOptions() {
    const response = await fetch(this.getAttribute("data-src"));
    return await response.json();
  }
}

customElements.define("solidus-select", SolidusSelect, { extends: "select" });
