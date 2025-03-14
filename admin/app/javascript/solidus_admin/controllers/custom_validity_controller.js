import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    errorMessage: String,
  }

  connect() {
    if (this.errorMessageValue) this.element.setCustomValidity(this.errorMessageValue)
  }

  clearCustomValidity() {
    this.element.setCustomValidity("")
  }
}
