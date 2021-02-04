/* Spree/Backend/HiddenByCheckbox Stimulus Controller
 * Usage:

  <div data-controller="spree--backend--hidden-by-checkbox">
    <label data-action="click->spree--backend--hidden-by-checkbox#toggleContent">
      <input data-spree--backend--hidden-by-checkbox-target="checkbox" type="checkbox" checked="checked" name="name" />
        Click to hide content
    </label>

    <div data-spree--backend--hidden-by-checkbox-target="content">
      Content to hide
    </div>
  </div>

 *
 * Maybe not the best way to document usage, TODO: find a better (more standard) alternative.
 */
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "checkbox", "content" ]

  initialize() {
    this.toggleContent()
  }

  toggleContent() {
    this.contentTarget.classList.toggle('hidden', this.checkboxTarget.checked);
  }
}
