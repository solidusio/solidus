import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["accept"]

  open(message, { details = "", buttonText } = {}) {
    const dialog = this.element.querySelector("dialog")

    dialog.querySelector(".modal-title").textContent = message
    dialog.querySelector(".modal-body").textContent = details
    if (buttonText) this.acceptTarget.textContent = buttonText

    dialog.showModal()

    return new Promise((resolve) => {
      const controller = new AbortController()
      this.acceptTarget.addEventListener("click", () => { resolve(true); controller.abort(); dialog.close() }, { signal: controller.signal })
      dialog.addEventListener("close", () => { resolve(false); controller.abort() }, { signal: controller.signal })
    })
  }
}
