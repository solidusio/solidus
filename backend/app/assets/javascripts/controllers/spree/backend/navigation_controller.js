import { Controller } from "stimulus"
import stickybits from "spree/backend/stickybits"

export default class extends Controller {
  static targets = [ "header", "menu", "footer", "sticky" ]

  initialize() {
    this.fixFooterIfFits()
    stickybits(this.stickyTarget)
  }

  resize() {
    this.fixFooterIfFits()
  }

  fixFooterIfFits() {
    this.element.classList.toggle("fits", this.heightLessThenWindowHeight())
  }

  heightLessThenWindowHeight() {
    return this.height() < window.innerHeight
  }

  height() {
    return this.headerTarget.offsetHeight + this.menuTarget.offsetHeight + this.footerTarget.offsetHeight
  }
}
