import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['closeButton']
  static classes = ['closing']
  static values = { transition: Number }

  connect () {
    // Give focus to the close button
    this.closeButtonTarget.focus();
  }

  close () {
    this.element.classList.add(...this.closingClasses);
    setTimeout(() => this.element.remove(), this.transitionValue)
  }
}
