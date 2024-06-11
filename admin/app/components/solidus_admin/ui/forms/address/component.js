import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["country", "state"]

  loadStates() {
    const countryId = this.countryTarget.value

    fetch(`/admin/countries/${countryId}/states`)
      .then(response => response.json())
      .then(data => {
        this.updateStateOptions(data)
      })
  }

  updateStateOptions(data) {
    const stateSelect = this.stateTarget

    stateSelect.innerHTML = ""

    if (data.length === 0) {
      stateSelect.disabled = true
    } else {
      stateSelect.disabled = false

      data.forEach((state) => {
        const option = document.createElement("option")
        option.value = state.id
        option.innerText = state.name
        stateSelect.appendChild(option)
      })
    }
  }
}
