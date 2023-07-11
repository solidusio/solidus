import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["links", "button"]

  static classes = ["active"]

  // Toggle the visibility of the links and mark the button as active
  toggleLinks() {
    this.buttonTarget.classList.toggle(
      this.activeClass,
    )
    this.linksTarget.classList.toggle("hidden")
  }
}
