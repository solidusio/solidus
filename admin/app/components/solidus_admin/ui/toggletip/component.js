import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button', 'bubble', 'content']

  connect () {
    // Progressive enhancement && a11y: the content is visible in plain HTML.
    // We first remove it and then make it an aria-live region so users are
    // updated when it's readded.
    this.contentTarget.textContent = ''
    this.contentTarget.setAttribute('role', 'status')

    // Close the bubble when clicking outside of it or pressing escape.
    document.addEventListener('click', (event) => {
      if (!this.buttonTarget.contains(event.target) && !this.bubbleTarget.contains(event.target)) {
        this.close()
      }
    })
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        this.close()
      }
    })
  }

  // Toggle the bubble when clicking the button. The content is added and
  // remove every time so that the aria-live region is updated and users are
  // notified..
  toggle () {
    if (this.bubbleTarget.classList.contains('hidden')) {
      this.open()
    } else {
      this.close()
    }
  }

  open () {
    this.bubbleTarget.classList.remove('hidden')
    this.contentTarget.textContent = this.bubbleTarget.dataset.content
  }

  close () {
    this.bubbleTarget.classList.add('hidden')
    this.contentTarget.textContent = ''
  }
}
