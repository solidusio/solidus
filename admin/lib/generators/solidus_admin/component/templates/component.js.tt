import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['output']

  typed(event) {
    this.text = event.currentTarget.value
    this.render()
  }

  render() {
    this.outputTarget.innerText = this.text
  }
}
