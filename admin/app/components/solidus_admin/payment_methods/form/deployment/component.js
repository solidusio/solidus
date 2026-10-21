// payment_methods/form/deployment_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
  }

  connect() {
    this.frame = document.getElementById("payment_method_form_deployment_frame")
  }

  change(event) {
    const params = new URLSearchParams()
    params.set("payment_method[type]", this.typeSelect.value)
    params.set("payment_method[preference_source]", this.preferenceSourceSelect.value)

    this.frame.src = `${this.urlValue}?${params}`
  }

  get typeSelect() {
    return this.element.querySelector("select[name*='[type]']");
  }

  get preferenceSourceSelect() {
    return this.element.querySelector("select[name*='[preference_source]']");
  }
}
