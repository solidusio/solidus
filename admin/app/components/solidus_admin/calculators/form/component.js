import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "preferences"]

  connect() {
    this.toggle()
  }

  toggle() {
    const selectedType = this.selectTarget.value

    this.preferencesTargets.forEach((el) => {
      const isActive = el.dataset.calculatorType === selectedType

      el.classList.toggle("hidden", !isActive)

      el.querySelectorAll("input, select, textarea, button").forEach(input => {
        input.disabled = !isActive
      })
    })
  }
}
