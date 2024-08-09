import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["links", "template"];

  connect() {
    this.wrapperClass =
      this.data.get("wrapperClass") || "promo-condition-option-value";

    this.element.querySelectorAll("." + this.wrapperClass).forEach((element) => this.buildSelects(element))
  }

  add_row(event) {
    event.preventDefault();

    var content = this.templateTarget.innerHTML;
    this.linksTarget.insertAdjacentHTML("beforebegin", content);
    this.buildSelects(this.linksTarget.previousElementSibling)
  }

  propagate_product_id_to_value_input(event) {
    event.preventDefault();
    // targets the content of the last pair of square brackets
    // we first need to greedily match all other square brackets
    const regEx = /(\[.*\])\[.*?\]$/;
    let wrapper = event.target.closest("." + this.wrapperClass);
    let optionValuesInput = wrapper.querySelector(".option-values-select[type='hidden']");
    optionValuesInput.name = optionValuesInput.name.replace(
      regEx,
      `$1[${event.target.value}]`
    );
  }

  remove_row(event) {
    event.preventDefault();

    let wrapper = event.target.closest("." + this.wrapperClass);
    wrapper.remove();
  }

  // helper functions

  buildSelects(wrapper) {
    let productSelect = wrapper.querySelector(".product-select")
    let optionValueSelect = wrapper.querySelector(".option-values-select[type='hidden']")
    this.buildProductSelect(productSelect)
    $(optionValueSelect).optionValueAutocomplete({ productSelect });
  }

  buildProductSelect(productSelect) {
    var jQueryProductSelect = $(productSelect)
    jQueryProductSelect.productAutocomplete({
      multiple: false,
    })
    // capture the jQuery "change" event and re-emit it as DOM event "select2Change"
    // so that Stimulus can capture it
    jQueryProductSelect.on('change', function () {
      let event = new Event('select2Change', { bubbles: true }) // fire a native event
      productSelect.dispatchEvent(event);
    });
  }
}
