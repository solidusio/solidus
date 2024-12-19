import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.showModal()
    this.element.addEventListener("close", () => this.removeModal())
  }

  close() {
    this.element.close()
  }

  removeModal() {
    this.element.remove()
  }
}
