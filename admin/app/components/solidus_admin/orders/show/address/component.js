import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["addresses"]

  close() {
    this.addressesTarget.removeAttribute('open')
  }
}
