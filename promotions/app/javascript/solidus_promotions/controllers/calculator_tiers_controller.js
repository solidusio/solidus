import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["links", "template"];

  connect() {
    this.wrapperClass = this.data.get("wrapperClass") || "calculator-tiers";
  }

  add_association(event) {
    event.preventDefault();

    var content = this.templateTarget.innerHTML;
    this.linksTarget.insertAdjacentHTML("beforebegin", content);
  }

  propagate_base_to_value_input(event) {
    event.preventDefault();

    // targets the content of the last pair of square brackets
    // we first need to greedily match all other square brackets
    const regEx = /(\[.*\])\[.*?\]$/;
    let wrapper = event.target.closest("." + this.wrapperClass);
    let valueInput = wrapper.querySelector(".js-value-input");
    valueInput.name = valueInput.name.replace(
      regEx,
      `$1[${event.target.value}]`
    );
  }

  remove_association(event) {
    event.preventDefault();

    let wrapper = event.target.closest("." + this.wrapperClass);
    wrapper.remove();
  }
}
