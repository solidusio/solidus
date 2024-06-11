import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['closeButton']
  static classes = ['animation']
  static values = { transition: Number }

  connect() {
    this.closeButtonTarget.focus()

    requestAnimationFrame(() => {
      this.element.classList.remove(...this.animationClasses)
    })
  }

  close() {
    this.element.classList.add(...this.animationClasses)
    setTimeout(() => this.element.remove(), this.transitionValue)
  }
}
