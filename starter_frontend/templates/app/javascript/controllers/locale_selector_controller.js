import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['selector']

  submitForm() {
    this.selectorTarget.form.submit()
  }
}
