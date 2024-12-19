import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    initialCountOnHand: Number,
  }

  static targets = ["countOnHand", "quantityAdjustment"]

  connect() {
    this.updateCountOnHand()
  }

  updateCountOnHand() {
    this.countOnHandTarget.value =
      parseInt(this.initialCountOnHandValue) + parseInt(this.quantityAdjustmentTarget.value)
  }
}
