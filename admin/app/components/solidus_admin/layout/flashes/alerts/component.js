import { Controller } from "@hotwired/stimulus"

// An open modal dialog sits in the top layer and makes the rest of the page
// inert, so alerts rendered next to it would be hidden behind it. Move them
// inside the dialog instead (e.g. errors returned for a form in a modal).
export default class extends Controller {
  connect() {
    requestAnimationFrame(() => {
      const dialog = document.querySelector("dialog[open]")

      if (dialog && this.element.children[0]?.children.length > 0) dialog.append(this.element)
    })
  }
}
