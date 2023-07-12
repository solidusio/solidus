import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "headerCheckbox", "batchToolbar", "scopesToolbar", "tableHeader", "selectedRowsCount"]

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

    this.batchToolbarTarget.classList.toggle("hidden", this.mode !== "batch")
    this.scopesToolbarTarget.classList.toggle("hidden", this.mode !== "default")
    this.tableHeaderTarget.classList.toggle("hidden", this.mode !== "default")

    // Update the rows background color
    this.checkboxTargets.filter((checkbox) => checkbox.classList.toggle('bg-gray-15', checkbox.checked))

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
