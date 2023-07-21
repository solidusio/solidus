import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["links", "button"]

  static classes = ["active"]

  toggleLinks() {
    // Toggle button's active state
    this.buttonTarget.classList.toggle(
      this.activeClass,
    )
    // Toggle aria-expanded state
    this.buttonTarget.setAttribute(
      "aria-expanded",
      this.buttonTarget.classList.contains(
        this.activeClass,
      ),
    )
    // Toggle links' visibility
    this.linksTarget.classList.toggle("hidden")
  }

  hideLinks() {
    // Remove button's active state
    this.buttonTarget.classList.remove(
      this.activeClass,
    )
    // Set aria-expanded to false
    this.buttonTarget.setAttribute(
      "aria-expanded",
      "false"
    )
    // Hide the links
    this.linksTarget.classList.add("hidden")
  }
}
