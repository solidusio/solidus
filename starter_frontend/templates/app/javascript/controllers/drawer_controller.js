import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["drawer"];

  toggle() {
    this.drawerTarget.classList.toggle("-translate-x-full");
    document.getElementById("overlay").classList.toggle("hidden");
  }
}
