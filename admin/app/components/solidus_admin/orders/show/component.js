import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  closeMenus() {
    this.element.querySelectorAll('details').forEach(details => details.removeAttribute('open'))
  }
}
