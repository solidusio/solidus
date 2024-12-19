import { Controller } from "@hotwired/stimulus"
import { useClickOutside } from "stimulus-use"

export default class extends Controller {
  static targets = ["bubble"]

  connect() {
    useClickOutside(this)
    this.open = false
  }

  clickOutside() {
    this.close()
  }

  toggle(e) {
    e.preventDefault()
    this.open = !this.open
    this.render()
  }

  open() {
    this.open = true
    this.render()
  }

  close() {
    this.open = false
    this.render()
  }

  render() {
    const needsPositioning = this.open && !this.element.open
    this.element.open = this.open

    if (needsPositioning) {
      const bubbleRect = this.bubbleTarget.getBoundingClientRect()
      if (bubbleRect.right > window.innerWidth)
        this.bubbleTarget.style.left = `${window.innerWidth - bubbleRect.width}px`
      if (bubbleRect.bottom > window.innerHeight)
        this.bubbleTarget.style.top = `${window.innerHeight - bubbleRect.height}px`
      if (bubbleRect.left < 0) this.bubbleTarget.style.left = "0px"
      if (bubbleRect.top < 0) this.bubbleTarget.style.top = "0px"
    }
  }
}
