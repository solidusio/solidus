import { Controller } from "@hotwired/stimulus"
import { useClickOutside, useDebounce } from "stimulus-use"

const QUERY_KEY = "q[name_or_variants_including_master_sku_cont]"

export default class extends Controller {
  static targets = ["result", "results", "searchField"]
  static values = {
    results: String,
    productsUrl: String,
    loadingText: String,
    initialText: String,
    emptyText: String,
  }
  static debounces = [
    {
      name: "requestSubmitForLineItems",
      wait: 500,
    },
    "search",
  ]

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
    this.lineItemsToBeSubmitted = []

    if (this.query) {
      this.showResults()
      this.search()
    }
  }

  selectResult(event) {
    switch (event.key) {
      case "Enter":
        event.preventDefault()
        this.selectedResult?.click()
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex -= 1
        this.render()
        break
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex += 1
        this.render()
        break
    }
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

      this.resultsValue = (await (await fetch(`${this.productsUrlValue}?${QUERY_KEY}=${query}`)).text()) || this.emptyTextValue
      this.render()
    } else {
      this.resultsValue = this.initialTextValue
      this.render()
    }
  }

  showResults() {
    this.openResults = true
    this.render()
  }

  updateLineItem(event) {
    if (!this.lineItemsToBeSubmitted.includes(event.currentTarget)) {
      this.lineItemsToBeSubmitted.push(event.currentTarget)
    }

    this.requestSubmitForLineItems()
  }

  // This is a workaround to permit using debounce when needing to pass a parameter
  requestSubmitForLineItems() {
    this.lineItemsToBeSubmitted.forEach((lineItem) => {
      lineItem.form.requestSubmit()
    })
    this.lineItemsToBeSubmitted = []
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
