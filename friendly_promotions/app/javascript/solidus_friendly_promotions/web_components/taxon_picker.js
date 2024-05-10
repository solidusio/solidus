class TaxonPicker extends HTMLInputElement {
  connectedCallback() {
    $(this).taxonAutocomplete();
  }
}

customElements.define('taxon-picker', TaxonPicker, { extends: 'input' });
