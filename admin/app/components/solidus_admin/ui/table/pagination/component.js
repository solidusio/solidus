import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["prevButton", "nextButton"]
  static values = { turboFrameId: String }

  connect() {
    const turboFrame = this.element.closest('turbo-frame')
    this.turboFrameIdValue = turboFrame ? turboFrame.id : null

    this.prevButtonTarget.dataset.turboFrame = this.turboFrameIdValue
    this.prevButtonTarget.dataset.turboAction = "replace"

    this.nextButtonTarget.dataset.turboFrame = this.turboFrameIdValue
    this.nextButtonTarget.dataset.turboAction = "replace"
  }
}
