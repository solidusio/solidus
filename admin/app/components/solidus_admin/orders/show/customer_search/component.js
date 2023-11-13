import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { customersUrl: String }

  async search({ detail: { query, controller } }) {
    controller.resultsValue =
      (await (await fetch(`${this.customersUrlValue}?q[name_or_variants_including_master_sku_cont]=${query}`)).text())
  }

  submit(event) {
    event.detail.resultTarget.querySelector('form').submit()
  }
}
