import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import { patch } from '@rails/request.js'

export default class extends Controller {
  static values = {
    param: { type: String, default: 'position' },
    handle: { type: String, default: null },
    animation: { type: Number, default: 150 },
    page: { type: Number },
    perPage: { type: Number },
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      onEnd: this.onEnd.bind(this),
      animation: this.animationValue,
      handle: this.handleValue,
    })
  }

  async onEnd({ item, newIndex }) {
    if (!item.dataset.sortableUrl) return this.renumber()

    const data = new FormData()
    let newPosition = newIndex + 1;
    if (this.pageValue && this.perPageValue) {
      const offset = (this.pageValue - 1) * this.perPageValue;
      newPosition += offset;
    }
    data.append(this.paramValue, newPosition)

    return await patch(item.dataset.sortableUrl, { body: data, responseKind: "js" })
  }

  renumber() {
    Array.from(this.element.children)
      .filter((item) => !item.querySelector('input[name$="[_destroy]"]:checked'))
      .forEach((item, index) => {
        const input = item.querySelector(`input[name$="[${this.paramValue}]"]`)
        if (input) input.value = index + 1
      })
  }

  disconnect() {
    this.sortable.destroy()
    this.sortable = null
  }
}
