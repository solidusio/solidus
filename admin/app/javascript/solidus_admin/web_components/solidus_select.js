import TomSelect from "tom-select";
import { setValidity } from "solidus_admin/utils";

class SolidusSelect extends HTMLSelectElement {
  static observedAttributes = ["synced"];

  connectedCallback() {
    const originalSelect = this;

    const tomselect = new TomSelect(originalSelect, {
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
      onItemAdd: function() {
        this.setTextboxValue("");
        if (originalSelect.multiple) this.refreshOptions();
      },
    });

    originalSelect.setAttribute("synced", "true");

    // set default style for inner input field
    tomselect.control_input.style =
      "flex: 1 1 auto;\n" +
      "line-height: inherit !important;\n" +
      "max-height: none !important;\n" +
      "max-width: 100% !important;\n" +
      "min-height: 0 !important;\n" +
      "min-width: 7rem;\n" +
      "outline: none !important;"

    originalSelect.setAttribute("hidden", "true");
    originalSelect.setAttribute("aria-hidden", "true");

    setValidity(originalSelect, originalSelect.dataset.errorMessage);
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
}

customElements.define("solidus-select", SolidusSelect, { extends: "select" });
