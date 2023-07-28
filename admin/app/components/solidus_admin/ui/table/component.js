import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "checkbox",
    "headerCheckbox",
    "batchToolbar",
    "scopesToolbar",
    "defaultHeader",
    "batchHeader",
    "selectedRowsCount",
  ]
  static classes = ["selectedRow"]
  static values = {
    mode: { type: String, default: "scopes" },
  }

  connect() {
    this.modeValue = "scopes"

    this.render()
  }

  selectRow(event) {
    if (this.checkboxTargets.some((checkbox) => checkbox.checked)) {
      this.modeValue = "batch"
    } else {
      this.modeValue = "scopes"
    }

    this.render()
  }

  selectAllRows(event) {
    this.modeValue = event.target.checked ? "batch" : "scopes"
    this.checkboxTargets.forEach((checkbox) => (checkbox.checked = event.target.checked))

    this.render()
  }

  render() {
    const selectedRows = this.checkboxTargets.filter((checkbox) => checkbox.checked)

    this.batchToolbarTarget.toggleAttribute("hidden", this.modeValue !== "batch")
    this.batchHeaderTarget.toggleAttribute("hidden", this.modeValue !== "batch")
    this.scopesToolbarTarget.toggleAttribute("hidden", this.modeValue !== "scopes")
    this.defaultHeaderTarget.toggleAttribute("hidden", this.modeValue !== "scopes")

    // Update the rows background color
    this.checkboxTargets.filter((checkbox) =>
      checkbox.closest("tr").classList.toggle(this.selectedRowClass, checkbox.checked),
    )

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
