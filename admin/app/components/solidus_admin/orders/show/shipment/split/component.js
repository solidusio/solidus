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
    //this.quantityTargets.forEach((quantity) => (quantity.disabled = !this.checkboxTargets.find(selection => quantity.contains(selection).checked )))
  }
}
