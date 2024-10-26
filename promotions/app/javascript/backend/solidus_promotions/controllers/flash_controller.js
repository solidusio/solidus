import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    window.show_flash(
      this.element.dataset.severity,
      this.element.dataset.message
    );
  }
}
