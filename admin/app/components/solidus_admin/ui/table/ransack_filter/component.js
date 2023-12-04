import { Controller } from '@hotwired/stimulus'
import { useClickOutside, useDebounce } from 'stimulus-use'

const BG_GRAY = 'bg-gray-100'

export default class extends Controller {
  static targets = ['details', 'summary', 'option', 'checkbox', 'menu']
  static debounces = ['init']

  connect() {
    useDebounce(this, { wait: 50 })
    useClickOutside(this)
    this.init()
    this.updateHiddenInputs()
  }

  clickOutside(event) {
    this.detailsTarget.removeAttribute("open")
  }

  init() {
    this.highlightFilter()
    this.showSearch()
  }

  highlightFilter() {
    const optionIsSelected = this.isAnyCheckboxChecked()
    this.summaryTarget.classList.toggle(BG_GRAY, optionIsSelected)
  }

  showSearch() {
    if (this.isAnyCheckboxChecked()) {
      this.dispatch("showSearch", { detail: { avoidFocus: true } })
    }
  }

  filterOptions(event) {
    const query = event.currentTarget.value.toLowerCase()
    this.optionTargets.forEach((option) => {
      option.style.display = option.textContent.toLowerCase().includes(query) ? 'block' : 'none'
    })
  }

  search() {
    this.dispatch("search")
    this.highlightFilter()
  }

  updateHiddenInputs() {
    this.checkboxTargets.forEach((checkbox) => {
      const hiddenElements = checkbox.parentElement.querySelectorAll("input[type='hidden']")
      checkbox.checked
        ? hiddenElements.forEach(e => e.removeAttribute("disabled"))
        : hiddenElements.forEach(e => e.setAttribute("disabled", true))
    })
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
