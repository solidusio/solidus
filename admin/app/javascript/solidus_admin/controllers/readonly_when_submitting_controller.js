import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("submit", this)
  }

  disconnect() {
    this.element.removeEventListener("submit", this)
  }

  handleEvent() {
    for (const element of this.element.elements) {
      element.setAttribute("readonly", true)
    }
  }
}
