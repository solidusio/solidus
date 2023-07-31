import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "checkbox",
    "headerCheckbox",
    "batchToolbar",
    "scopesToolbar",
    "searchToolbar",
    "searchField",
    "searchForm",
    "defaultHeader",
    "batchHeader",
    "selectedRowsCount",
  ]

  static classes = ["selectedRow"]
  static values = {
    mode: { type: String, default: "scopes" },
  }

  connect() {
    if (this.searchFieldTarget.value !== "") this.modeValue = "search"

    this.render()
  }

  showSearch(event) {
    this.modeValue = "search"
    this.render()
  }

  clearSearch() {
    this.searchFieldTarget.value = ''
    this.searchFormTarget.requestSubmit()
  }

  cancelSearch() {
    this.clearSearch()

    this.modeValue = "scopes"
    this.render()
  }

  selectRow(event) {
    if (this.checkboxTargets.some((checkbox) => checkbox.checked)) {
      this.modeValue = "batch"
    } else if (this.searchFieldTarget.value !== '') {
      this.modeValue = "search"
    } else {
      this.modeValue = "scopes"
    }

    this.render()
  }

  selectAllRows(event) {
    if (this.modeValue = event.target.checked) {
      this.modeValue = "batch"
    } else if (this.searchFieldTarget.value !== '') {
      this.modeValue = "search"
    } else {
      this.modeValue = "scopes"
    }

    this.checkboxTargets.forEach((checkbox) => (checkbox.checked = event.target.checked))

    this.render()
  }

  render() {
    const selectedRows = this.checkboxTargets.filter((checkbox) => checkbox.checked)

    this.searchToolbarTarget.toggleAttribute("hidden", this.modeValue !== "search")
    this.batchToolbarTarget.toggleAttribute("hidden", this.modeValue !== "batch")
    this.batchHeaderTarget.toggleAttribute("hidden", this.modeValue !== "batch")
    this.scopesToolbarTarget.toggleAttribute("hidden", this.modeValue !== "scopes")

    this.defaultHeaderTarget.toggleAttribute("hidden", this.modeValue === "batch")

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
