class ProductPicker extends HTMLInputElement {
  connectedCallback() {
    const multiple = this.dataset.multiple !== "false";
    $(this).productAutocomplete({ multiple });
  }
}

customElements.define('product-picker', ProductPicker, { extends: 'input' });
