import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    cookie: String
  }

  setCookie(event) {
    let value = !event.currentTarget.checked

    document.cookie = `${this.cookieValue}=${value}; Path=/`
    location.reload()
  }
}
