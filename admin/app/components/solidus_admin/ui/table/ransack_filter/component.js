import { Controller } from '@hotwired/stimulus'
export default class extends Controller {
  static targets = ['details', 'summary', 'option', 'checkbox', 'menu']

  search() {
    this.dispatch('search')
  }
}
