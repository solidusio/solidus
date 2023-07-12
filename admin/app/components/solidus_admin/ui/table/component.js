import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "headerCheckbox", "batchToolbar", "scopesToolbar", "defaultHeader", "batchHeader", "selectedRowsCount"]
  static classes = ["selectedRow"]

  connect() {
    this.mode = "default"

    this.render()
  }

  selectRow(event) {
    if (this.checkboxTargets.some((checkbox) => checkbox.checked)) {
      this.mode = "batch"
    } else {
      this.mode = "default"
    }

    this.render()
  }

  selectAllRows(event) {
    this.mode = event.target.checked ? "batch" : "default"
    this.checkboxTargets.forEach((checkbox) => (checkbox.checked = event.target.checked))

    this.render()
  }

  render() {
    const selectedRows = this.checkboxTargets.filter((checkbox) => checkbox.checked)

    this.batchToolbarTarget.toggleAttribute("hidden", this.mode !== "batch")
    this.batchHeaderTarget.toggleAttribute("hidden", this.mode !== "batch")
    this.scopesToolbarTarget.toggleAttribute("hidden", this.mode !== "default")
    this.defaultHeaderTarget.toggleAttribute("hidden", this.mode !== "default")

    // Update the rows background color
    this.checkboxTargets.filter((checkbox) => checkbox.closest('tr').classList.toggle(this.selectedRowClass, checkbox.checked))

    // Update the selected rows count
    this.selectedRowsCountTarget.textContent = `${selectedRows.length}`

    // Update the header checkboxes
    this.headerCheckboxTargets.forEach((checkbox) => {
      checkbox.indeterminate = false
      checkbox.checked = false

      if (selectedRows.length === this.checkboxTargets.length) checkbox.checked = true
      else if (selectedRows.length > 0) checkbox.indeterminate = true
    })
  }
}
