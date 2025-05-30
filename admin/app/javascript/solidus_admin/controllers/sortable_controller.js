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
    if (!item.dataset.sortableUrl) return

    const data = new FormData()
    let newPosition = newIndex + 1;
    if (this.pageValue && this.perPageValue) {
      const offset = (this.pageValue - 1) * this.perPageValue;
      newPosition += offset;
    }
    data.append(this.paramValue, newPosition)

    return await patch(item.dataset.sortableUrl, { body: data, responseKind: "js" })
  }

  disconnect() {
    this.sortable.destroy()
    this.sortable = null
  }
}
