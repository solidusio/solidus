import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['updateButton']

  setQuantityToZero(e) {
    this.element.querySelector(`#${e.params.quantityId}`).value = '0'
  }

  disableUpdateButton() {
    this.updateButtonTarget.setAttribute('disabled', true)
  }
}
