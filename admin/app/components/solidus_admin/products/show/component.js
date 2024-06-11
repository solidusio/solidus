import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  confirmDelete(event) {
    if (!confirm(event.params.message)) {
      event.preventDefault()
    }
  }
}
