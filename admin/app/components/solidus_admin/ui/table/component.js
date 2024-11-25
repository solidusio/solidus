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
    "tableBody",
    "selectedRowsCount",
  ]

  static classes = ["selectedRow"]
  static values = {
    mode: { type: String, default: "scopes" },
    sortable: { type: Boolean, default: false },
  }

  initialize() {
    // Debounced search function.
    // This method submits the search form after a delay of 200ms.
    // If the function is called again within this delay, the previous call is cleared,
    // effectively ensuring the form is only submitted 200ms after the last call (e.g., user stops typing).
    this.search = debounce(this.search.bind(this), 200)
  }

  // Determine if sortable should be enabled
  modeValueChanged() {
    const shouldSetSortable = this.sortableValue && this.modeValue !== "batch" && this.modeValue !== "search"

    if (shouldSetSortable) {
      this.tableBodyTarget.setAttribute('data-controller', 'sortable')
    } else {
      this.tableBodyTarget.removeAttribute('data-controller')
    }
  }

  showSearch({ detail: { avoidFocus } }) {
    this.modeValue = "search"
    this.render()

    if (!avoidFocus) this.searchFieldTarget.focus()
  }

  search() {
    this.searchFormTarget.requestSubmit()
  }

  clearSearch() {
    this.searchFieldTarget.value = ''
    this.search()
  }

  resetSearchAndFilters() {
    if (this.hasFilterToolbarTarget) {
      this.filterToolbarTarget.querySelectorAll('fieldset').forEach(fieldset => fieldset.disabled = true)
    }

    this.searchFieldTarget.disabled = true
    this.searchFormTarget.submit()
  }

  selectRow(event) {
    if (this.checkboxTargets.some((checkbox) => checkbox.checked)) {
      this.modeValue = "batch"
    } else if (this.hasSearchFieldTarget && (this.searchFieldTarget.value !== '')) {
      this.modeValue = "search"
    } else if (this.hasScopesToolbarTarget) {
      this.modeValue = "scopes"
    } else {
      this.modeValue = "search"
    }

    this.render()
  }

  selectAllRows(event) {
    if (event.target.checked) {
      this.modeValue = "batch"
    } else if (this.hasSearchFieldTarget && (this.searchFieldTarget.value !== '')) {
      this.modeValue = "search"
    } else if (this.hasScopesToolbarTarget) {
      this.modeValue = "scopes"
    } else {
      this.modeValue = "search"
    }

    this.checkboxTargets.forEach((checkbox) => (checkbox.checked = event.target.checked))

    this.render()
  }

  rowClicked(event) {
    // Skip if the user clicked on a link, button, input or summary
    if (event.target.closest("td").contains(event.target.closest("a,select,textarea,button,input,summary"))) return

    if (this.modeValue === "batch") {
      this.toggleCheckbox(event.currentTarget)
    }
  }

  toggleCheckbox(row) {
    const checkbox = this.checkboxTargets.find(selection => row.contains(selection))

    if (checkbox) {
      checkbox.checked = !checkbox.checked
      this.selectRow()
    }
  }

  selectedRows() {
    return this.checkboxTargets.filter((checkbox) => checkbox.checked)
  }

  confirmAction(event) {
    const message = event.params.message
      .replace(
        "${count}",
        this.selectedRows().length
      ).replace(
        "${resource}",
        this.selectedRows().length > 1 ?
        event.params.resourcePlural :
        event.params.resourceSingular
      )

    if (!confirm(message)) {
      event.preventDefault()
    }
  }

  render() {
    const selectedRows = this.selectedRows()

    if (this.hasSearchFieldTarget) {
      this.searchToolbarTarget.toggleAttribute("hidden", this.modeValue !== "search")
    }

    if (this.hasFilterToolbarTarget) {
      this.filterToolbarTarget.toggleAttribute("hidden", this.modeValue !== "search")
    }

    this.batchToolbarTarget.toggleAttribute("hidden", this.modeValue !== "batch")
    this.batchHeaderTarget.toggleAttribute("hidden", this.modeValue !== "batch")
    this.defaultHeaderTarget.toggleAttribute("hidden", this.modeValue === "batch")

    if (this.hasScopesToolbarTarget) {
      this.scopesToolbarTarget.toggleAttribute("hidden", this.modeValue !== "scopes")
    }

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

      if (this.checkboxTargets.length > 0 && selectedRows.length === this.checkboxTargets.length)
        checkbox.checked = true
      else if (selectedRows.length > 0) checkbox.indeterminate = true
    })
  }
}
