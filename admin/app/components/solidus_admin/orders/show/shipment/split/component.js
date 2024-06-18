import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    "checkbox",
    "headerCheckbox",
    "quantity"
  ]

  selectAllRows(event) {
    this.checkboxTargets.forEach((checkbox) => (checkbox.checked = event.target.checked))
  }

  selectRow(event) {
    const checkbox = this.checkboxTargets.find(selection => event.target.closest("tr").contains(selection))
    if (checkbox) checkbox.checked = true
  }

  submit(event) {
    event.preventDefault()
    this.quantityTargets.forEach((quantity) => {
      let checkbox = quantity.closest("tr").querySelector("input[type=checkbox]")
      quantity.disabled = !checkbox.checked
    })
    event.target.submit()
  }
}
