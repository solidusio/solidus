class ProductPicker extends HTMLInputElement {
  connectedCallback() {
    $(this).productAutocomplete();
  }
}

customElements.define('product-picker', ProductPicker, { extends: 'input' });
