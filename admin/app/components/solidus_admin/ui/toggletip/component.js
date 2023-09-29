import { Controller } from '@hotwired/stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['button', 'bubble', 'content']

  connect () {
    useClickOutside(this)
  }

  clickOutside () {
    this.close()
  }

  toggle (e) {
    this.element.open = !this.element.open
  }

  open () {
    this.element.open = true
  }

  close () {
    this.element.open = false
  }
}
