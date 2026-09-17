import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "paymentRadio" ]

  connect() {
    this.selectedRadio = this.paymentRadioTargets.find((radio) => radio.checked)
    this.render()
  }

  paymentSelected(e) {
    this.selectedRadio = e.target
    this.render()
  }

  render() {
    this.paymentRadioTargets.forEach(
      (radio) => {
        const fieldset = this.element.querySelector(`fieldset[name="${radio.dataset.fieldsetName}"]`)

        if (radio === this.selectedRadio) {
          fieldset.disabled = false
        } else {
          radio.checked = false
          fieldset.disabled = true
        }
      }
    )
  }
}
