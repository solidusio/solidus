import { Controller } from "@hotwired/stimulus"
import { debounce } from "solidus_admin/utils"

export default class extends Controller {
  static targets = [
    "checkbox",
    "headerCheckbox",
    "batchToolbar",
    "scopesToolbar",
    "searchToolbar",
    "searchField",
    "searchForm",
    "filterToolbar",
    "defaultHeader",
    "batchHeader",
    "selectedRowsCount",
  ]

  static classes = ["selectedRow"]
  static values = {
    mode: { type: String, default: "scopes" },
  }

  initialize() {
    // Debounced search function.
    // This method submits the search form after a delay of 200ms.
    // If the function is called again within this delay, the previous call is cleared,
    // effectively ensuring the form is only submitted 200ms after the last call (e.g., user stops typing).
    this.search = debounce(this.search.bind(this), 200)
  }

  showSearch(event) {
    this.modeValue = "search"
    this.render()
    this.searchFieldTarget.focus()
  }

  search() {
    this.searchFormTarget.requestSubmit()
  }

  clearSearch() {
    this.searchFieldTarget.value = ''
    this.search()
  }

  cancelSearch() {
    this.resetFilters()
    this.search()
  }

  resetFilters() {
    if (!this.hasFilterToolbarTarget) return

    for (const fieldset of this.filterToolbarTarget.querySelectorAll('fieldset')) {
      fieldset.setAttribute('disabled', true)
    }
    this.searchFieldTarget.setAttribute('disabled', true)
    this.searchFormTarget.submit()
  }

  selectRow(event) {
    if (this.checkboxTargets.some((checkbox) => checkbox.checked)) {
      this.modeValue = "batch"
    } else if (this.hasSearchFieldTarget && (this.searchFieldTarget.value !== '')) {
      this.modeValue = "search"
    } else {
      this.modeValue = "scopes"
    }

    this.render()
  }

  selectAllRows(event) {
    if (event.target.checked) {
      this.modeValue = "batch"
    } else if (this.hasSearchFieldTarget && (this.searchFieldTarget.value !== '')) {
      this.modeValue = "search"
    } else {
      this.modeValue = "scopes"
    }

    this.checkboxTargets.forEach((checkbox) => (checkbox.checked = event.target.checked))

    this.render()
  }

  rowClicked(event) {
    // If the user clicked on a link, button, input or summary, skip the row url visit
    if (event.target.closest("td").contains(event.target.closest("a,select,textarea,button,input,summary"))) return

    if (this.modeValue === "batch") {
      this.toggleCheckbox(event.currentTarget)
    } else {
      window.Turbo.visit(event.params.url)
    }
  }

  toggleCheckbox(row) {
    const checkbox = this.checkboxTargets.find(selection => row.contains(selection))

    if (checkbox) {
      checkbox.checked = !checkbox.checked
      this.selectRow()
    }
  }

  render() {
    const selectedRows = this.checkboxTargets.filter((checkbox) => checkbox.checked)

    if (this.hasSearchFieldTarget) {
      this.searchToolbarTarget.toggleAttribute("hidden", this.modeValue !== "search")
    }

    if (this.hasFilterToolbarTarget) {
      this.filterToolbarTarget.toggleAttribute("hidden", this.modeValue !== "search")
    }

    this.batchToolbarTarget.toggleAttribute("hidden", this.modeValue !== "batch")
    this.batchHeaderTarget.toggleAttribute("hidden", this.modeValue !== "batch")
    this.defaultHeaderTarget.toggleAttribute("hidden", this.modeValue === "batch")

    this.scopesToolbarTarget.toggleAttribute("hidden", this.modeValue !== "scopes")

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
