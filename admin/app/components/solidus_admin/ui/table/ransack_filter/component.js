import { Controller } from '@hotwired/stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['details', 'summary', 'option', 'checkbox', 'menu']

  connect() {
    useClickOutside(this)
  }

  clickOutside(event) {
    this.detailsTarget.removeAttribute("open")
  }

  search() {
    this.dispatch('search')
  }

  sortCheckboxes() {
    const checkboxes = this.checkboxTargets

    checkboxes.sort((a, b) => {
      if (a.checked && !b.checked) return -1
      if (!a.checked && b.checked) return 1
      return 0
    }).forEach(checkbox => {
      this.menuTarget.appendChild(checkbox.closest('div'))
    })
  }
}
