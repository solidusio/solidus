import { Controller } from "@hotwired/stimulus"
import { setValidity } from "solidus_admin/utils";

export default class extends Controller {
  static values = {
    errorMessage: String,
  }

  connect() {
    setValidity(this.element, this.errorMessageValue);
  }
}
