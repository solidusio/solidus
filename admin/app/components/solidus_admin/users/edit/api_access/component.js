import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  confirm(event) {
    if (!confirm(event.params.message)) {
      event.preventDefault()
    }
  }
}
