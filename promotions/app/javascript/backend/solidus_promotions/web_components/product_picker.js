class ProductPicker extends HTMLInputElement {
  connectedCallback() {
    const multiple = this.dataset.multiple !== "false";
    $(this).productAutocomplete({ multiple });
    $(this).on("change", (_) => {
      let event = new Event('select2Change', { bubbles: true }) // fire a native event
      this.dispatchEvent(event)
    })
  }
}

customElements.define('product-picker', ProductPicker, { extends: 'input' });
