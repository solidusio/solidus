import { Controller } from "@hotwired/stimulus"
import { useClickOutside } from "stimulus-use"

export default class extends Controller {
  connect() {
    useClickOutside(this)
  }

  clickOutside() {
    this.close()
  }

  close() {
    this.element.removeAttribute("open")
  }
}
