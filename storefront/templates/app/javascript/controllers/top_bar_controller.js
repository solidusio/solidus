import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['cartLink']
  static values = {
    cartUrl: { type: String, default: Solidus.pathFor('cart_link') }
  }

  async updateCartLink() {
    const response = await fetch(this.cartUrlValue)
    this.cartLinkTarget.innerHTML = await response.text()
  }

  connect() {
    this.updateCartLink()
  }
}
