import { Controller } from "@hotwired/stimulus"
import { useDebounce } from "stimulus-use"

export default class extends Controller {
  static values = { productsUrl: String }
  static debounces = [{ name: "submitLineItems", wait: 500 }]

  connect() {
    useDebounce(this)
    this.lineItemsToBeSubmitted = []
  }

  async search({ detail: { query, controller } }) {
    controller.resultsValue = await (
      await fetch(`${this.productsUrlValue}?q[name_or_variants_including_master_sku_cont]=${query}`)
    ).text()
  }

  updateLineItem(event) {
    if (!this.lineItemsToBeSubmitted.includes(event.currentTarget)) {
      this.lineItemsToBeSubmitted.push(event.currentTarget)
    }

    this.submitLineItems()
  }

  // This is a workaround to permit using debounce when needing to pass a parameter
  submitLineItems() {
    this.lineItemsToBeSubmitted.forEach((lineItem) => lineItem.form.requestSubmit())
    this.lineItemsToBeSubmitted = []
  }

  selectResult(event) {
    const form = event.detail.resultTarget.querySelector("form")
    form.submit()
  }
}
