import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["country", "state", "stateName", "stateWrapper", "stateNameWrapper"]

  loadStates() {
    const countryId = this.countryTarget.value

    fetch(`/admin/countries/${countryId}/states`)
      .then((response) => response.json())
      .then((data) => {
        this.updateStateOptions(data)
      })
  }

  updateStateOptions(states) {
    if (states.length === 0) {
      // Show state name text input if no states to choose from.
      this.toggleStateFields(false)
    } else {
      // Show state select dropdown.
      this.toggleStateFields(true)
      this.populateStateSelect(states)
    }
  }

  toggleStateFields(showSelect) {
    const stateWrapper = this.stateWrapperTarget
    const stateNameWrapper = this.stateNameWrapperTarget
    const stateSelect = this.stateTarget
    const stateName = this.stateNameTarget

    if (showSelect) {
      // Show state select dropdown.
      stateSelect.disabled = false
      stateName.value = ""
      stateWrapper.classList.remove("hidden")
      stateNameWrapper.classList.add("hidden")
    } else {
      // Show state name text input if no states to choose from.
      stateSelect.disabled = true
      stateWrapper.classList.add("hidden")
      stateNameWrapper.classList.remove("hidden")
    }
  }

  populateStateSelect(states) {
    const stateSelect = this.stateTarget
    stateSelect.innerHTML = ""

    states.forEach((state) => {
      const option = document.createElement("option")
      option.value = state.id
      option.innerText = state.name
      stateSelect.appendChild(option)
    })
  }
}
