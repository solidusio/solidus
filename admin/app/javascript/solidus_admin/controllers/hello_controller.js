import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  greet() {
    console.log(`Hello World! ${new Date()}`)
  }
}
