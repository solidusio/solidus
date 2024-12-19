import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  actionButtonClicked(event) {
    const url = new URL(event.params.url, "http://dummy.com")
    const params = new URLSearchParams(url.search)
    const frameId = params.get("_turbo_frame")
    const frame = frameId ? { frame: frameId } : {}
    // remove the custom _turbo_frame param from url search:
    params.delete("_turbo_frame")
    url.search = params.toString()

    window.Turbo.visit(url.pathname + url.search, frame)
  }
}
