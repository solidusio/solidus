import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["countriesWrapper", "statesWrapper", "countriesSelect", "statesSelect"]
  static values = {
    kind: { type: String, default: "state" }
  }

  connect() {
    this.toggleSelectsVisibility();
    this.toggleSelectDisabled();
  }

  toggleKind(event) {
    if (!event.target.value) return;

    this.kindValue = event.target.value;

    this.toggleSelectsVisibility();
    this.toggleSelectDisabled();
  }

  toggleSelectsVisibility() {
    this.countriesWrapperTarget.classList.toggle("hidden", this.kindValue === "state");
    this.statesWrapperTarget.classList.toggle("hidden", this.kindValue === "country");
  }

  toggleSelectDisabled() {
    this.countriesSelectTarget.disabled = this.kindValue === "state";
    this.statesSelectTarget.disabled = this.kindValue === "country";
  }
}
