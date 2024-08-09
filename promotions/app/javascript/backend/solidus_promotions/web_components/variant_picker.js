class VariantPicker extends HTMLInputElement {
  connectedCallback() {
    $(this).variantAutocomplete();
  }
}

customElements.define('variant-picker', VariantPicker, { extends: 'input' });
