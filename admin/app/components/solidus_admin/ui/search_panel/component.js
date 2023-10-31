import { Controller } from "@hotwired/stimulus"
import { useClickOutside, useDebounce } from "stimulus-use"

export default class extends Controller {
  static targets = ["result", "results", "searchField"]
  static values = {
    results: String,
    loadingText: String,
    initialText: String,
    emptyText: String,
  }
  static debounces = ["search"]

  get query() {
    return this.searchFieldTarget.value
  }

  get selectedResult() {
    // Keep the index within boundaries
    if (this.selectedIndex < 0) this.selectedIndex = 0
    if (this.selectedIndex >= this.resultTargets.length) this.selectedIndex = this.resultTargets.length - 1

    return this.resultTargets[this.selectedIndex]
  }

  connect() {
    useClickOutside(this)
    useDebounce(this)

    this.selectedIndex = 0

    if (this.query) {
      this.showResults()
      this.search()
    }
  }

  selectResult(event) {
    event.preventDefault()
    this.dispatch("submit", { detail: { resultTarget: this.selectedResult } })
  }

  clickedResult(event) {
    this.selectedIndex = this.resultTargets.indexOf(event.currentTarget)
    this.render()
    this.selectResult(event)
  }

  selectPrev(event) {
    event.preventDefault()
    this.selectedIndex -= 1
    this.render()
  }

  selectNext(event) {
    event.preventDefault()
    this.selectedIndex += 1
    this.render()
  }

  clickOutside() {
    this.openResults = false
    this.render()
  }

  async search() {
    const query = this.query

    if (query) {
      this.resultsValue = this.loadingTextValue
      this.render()
      this.dispatch("search", { detail: { query, controller: this } })
    } else {
      this.resultsValue = this.initialTextValue
      this.render()
    }
  }

  resultsValueChanged() {
    this.selectedIndex = 0
    this.render()
  }

  showResults() {
    this.openResults = true
    this.render()
  }

  render() {
    let resultsHtml = this.resultsValue

    if (this.renderedHtml !== resultsHtml) {
      this.renderedHtml = resultsHtml
      this.resultsTarget.innerHTML = resultsHtml
    }

    if (this.openResults && resultsHtml && this.query) {
      if (!this.resultsTarget.parentNode.open) this.selectedIndex = 0

      for (const result of this.resultTargets) {
        if (result === this.selectedResult) {
          if (!result.hasAttribute("aria-selected") && result.scrollIntoViewIfNeeded) {
            // This is a non-standard method, but it's supported by all major browsers
            result.scrollIntoViewIfNeeded()
          }
          result.setAttribute("aria-selected", true)
        } else {
          result.removeAttribute("aria-selected")
        }
      }
      this.resultsTarget.parentNode.open = true
    } else {
      this.resultsTarget.parentNode.open = false
    }
  }
}
