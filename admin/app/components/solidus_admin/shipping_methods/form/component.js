import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["stockLocationCheckbox", "stockLocations"]

  connect() {
    this.toggle();
  }

  toggle() {
    if (this.stockLocationCheckboxTarget.checked) {
      this.stockLocationsTarget.classList.add("hidden");
    } else {
      this.stockLocationsTarget.classList.remove("hidden");
    }
  }
}
