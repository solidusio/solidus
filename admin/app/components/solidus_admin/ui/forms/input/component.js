import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    customValidity: String,
  }

  connect() {
    if (this.customValidityValue)
      this.element.setCustomValidity(this.customValidityValue)
  }

  clearCustomValidity() {
    this.element.setCustomValidity('')
  }
}
