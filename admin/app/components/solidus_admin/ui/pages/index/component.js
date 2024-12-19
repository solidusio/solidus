import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  async openModal(event) {
    event.preventDefault();
    const url = event.target.href;
    const response = await fetch(url);
    document.body.insertAdjacentHTML("beforeend", await response.text());
  }
}
