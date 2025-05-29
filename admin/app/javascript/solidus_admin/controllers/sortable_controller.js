import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import { patch } from '@rails/request.js'

export default class extends Controller {
  static values = {
    param: { type: String, default: 'position' },
    handle: { type: String, default: null },
    animation: { type: Number, default: 150 },
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
    data.append(this.paramValue, newIndex + 1)

    return await patch(item.dataset.sortableUrl, { body: data, responseKind: "js" })
  }

  disconnect() {
    this.sortable.destroy()
    this.sortable = null
  }
}
