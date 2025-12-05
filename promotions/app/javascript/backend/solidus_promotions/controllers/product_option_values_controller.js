import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["links", "template"];

  connect() {
    this.wrapperClass =
      this.data.get("wrapperClass") || "promo-condition-option-value";
  }

  add_row(event) {
    event.preventDefault();

    var content = this.templateTarget.innerHTML;
    this.linksTarget.insertAdjacentHTML("beforebegin", content);
  }

  propagate_product_id_to_value_input(event) {
    event.preventDefault();
    // targets the content of the last pair of square brackets
    // we first need to greedily match all other square brackets
    const regEx = /(\[.*\])\[.*?\]$/;
    let wrapper = event.target.closest("." + this.wrapperClass);
    let optionValuesInput = wrapper.querySelector("[is=option-value-picker]");
    optionValuesInput.dataset.productId = event.target.value;
    optionValuesInput.value = "";
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
}
