import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    openOnConnect: { type: Boolean, default: true }
  };

  connect() {
    if (this.openOnConnectValue) {
      this.element.showModal();
    }
  }
}
