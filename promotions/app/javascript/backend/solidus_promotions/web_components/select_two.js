class SelectTwo extends HTMLSelectElement {
  connectedCallback() {
    $(this).select2({
      allowClear: true,
      dropdownAutoWidth: true,
      minimumResultsForSearch: 8,
    });
  }
}

customElements.define("select-two", SelectTwo, { extends: "select" });
