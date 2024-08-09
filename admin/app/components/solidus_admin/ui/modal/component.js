import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    if (this.element.getAttribute('data-modal-open') === "true") {
      this.element.showModal();
    }
  }
}
