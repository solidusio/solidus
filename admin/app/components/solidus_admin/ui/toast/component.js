import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static classes = ['closing']
  static values = { transition: Number }

  close () {
    this.element.classList.add(...this.closingClasses);
    setTimeout(() => this.element.remove(), this.transitionValue)
  }
}
