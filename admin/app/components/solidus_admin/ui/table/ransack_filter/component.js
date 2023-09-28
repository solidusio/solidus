import { Controller } from '@hotwired/stimulus'
import { useClickOutside, useDebounce } from 'stimulus-use'

export default class extends Controller {
  static targets = ['details', 'summary', 'option', 'checkbox', 'menu']
  static debounces = ['init']

  connect() {
    useDebounce(this, { wait: 50 })
    useClickOutside(this)
    this.init()
  }

  clickOutside(event) {
    this.detailsTarget.removeAttribute("open")
  }

  init() {
    this.showSearch()
  }

  showSearch() {
    if (this.isAnyCheckboxChecked()) this.dispatch('showSearch')
  }

  filterOptions(event) {
    const query = event.currentTarget.value.toLowerCase()
    this.optionTargets.forEach((option) => {
      option.style.display = option.textContent.toLowerCase().includes(query) ? 'block' : 'none'
    })
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

  isAnyCheckboxChecked() {
    return this.checkboxTargets.some(checkbox => checkbox.checked)
  }
}
