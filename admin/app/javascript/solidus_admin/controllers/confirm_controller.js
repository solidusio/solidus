import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {"text": String}

  connect() {
    this.element.addEventListener("click", this)
    this.element.addEventListener("submit", this)
  }

  disconnect() {
    this.element.removeEventListener("click", this)
    this.element.removeEventListener("submit", this)
  }

  handleEvent(event) {
    if (!confirm(this.textValue)) {
      event.preventDefault()
    }
  }
}
