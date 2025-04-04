import TomSelect from "tom-select";
import { setValidity } from "solidus_admin/utils";

class SolidusSelect extends HTMLSelectElement {
  static observedAttributes = ["synced"];

  constructor() {
    super();
    this.initializeModalProperties();
  }

  connectedCallback() {
    this.tomselect = new TomSelect(this, this.getTomSelectSettings());
    this.setupBasicStyles();

    if (this.isModal) this.setupDropdownPositioning();

    this.setAttribute("synced", "true");
    this.setAttribute("hidden", "true");
    this.setAttribute("aria-hidden", "true");

    setValidity(this, this.dataset.errorMessage);
  }

  disconnectedCallback() {
    if (this.isModal) this.teardownDropdownPositioning();
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

  initializeModalProperties() {
    const modalSelector = this.getAttribute("data-modal-container") || "dialog";
    this.modalContainer = this.closest(modalSelector);
    this.isModal = !!this.modalContainer;

    if (this.isModal) {
      const scrollableParentSelector = this.getAttribute("data-scrollable-parent") || ".modal-scrollable";
      this.scrollableParent = this.closest(scrollableParentSelector);
      if (!this.scrollableParent) {
        console.warn(`SolidusSelect: Expected a scrollable container "${scrollableParentSelector}", but none was found.\n` +
          "Please, make sure to have one if your modal content is expected to overflow max modal height.");
      }
    }
  }

  getTomSelectSettings() {
    const originalSelect = this;

    return {
      controlClass: "control",
      dropdownClass: originalSelect.getAttribute("dropdown-class"),
      dropdownContentClass: originalSelect.getAttribute("dropdown-content-class"),
      optionClass: originalSelect.getAttribute("option-class"),
      dropdownParent: originalSelect.modalContainer || null, // if no modalContainer, i.e. not in a modal - will by default append dropdown to "wrapper"
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
      onType: function() {
        if (!originalSelect.multiple && !this.currentResults.items.length) {
          this.setTextboxValue("");
          this.refreshOptions();
        }
      },
    };
  }

  setupBasicStyles() {
    // set default style for inner input field
    this.tomselect.control_input.style =
      "flex: 1 1 auto;\n" +
      "line-height: inherit !important;\n" +
      "max-height: none !important;\n" +
      "max-width: 100% !important;\n" +
      "min-height: 0 !important;\n" +
      "min-width: 7rem;\n" +
      "outline: none !important;"
  }

  setupDropdownPositioning() {
    // patch TomSelect's #positionDropdown function as it does not support any dropdown parents other than "body"
    this.tomselect.positionDropdown = this.positionDropdown;
    this.scrollableParent?.addEventListener("scroll", this.positionDropdown);
  }

  teardownDropdownPositioning() {
    this.scrollableParent?.removeEventListener("scroll", this.positionDropdown);
  }

  positionDropdown = () => {
    if (!this.tomselect.isOpen) return;

    const trigger = this.tomselect.control;
    const modal = this.modalContainer;

    const triggerRect = trigger.getBoundingClientRect();
    const modalRect = modal.getBoundingClientRect();

    const top = triggerRect.bottom - modalRect.top;
    const left = triggerRect.left - modalRect.left;

    Object.assign(this.tomselect.dropdown.style, {
      width: triggerRect.width + "px",
      top: top + "px",
      left: left + "px"
    });
  }
}

customElements.define("solidus-select", SolidusSelect, { extends: "select" });
