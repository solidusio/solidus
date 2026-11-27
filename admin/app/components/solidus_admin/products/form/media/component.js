import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "loading", "uploadContent"]

  connect() {
    this.element.addEventListener("dragover", this.onDragOver.bind(this))
    this.element.addEventListener("dragenter", this.onDragEnter.bind(this))
    this.element.addEventListener("dragleave", this.onDragLeave.bind(this))
    this.element.addEventListener("drop", this.onDrop.bind(this))
    this.fileInputTarget.addEventListener("change", this.submitForm.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("dragover", this.onDragOver.bind(this))
    this.element.removeEventListener("dragenter", this.onDragEnter.bind(this))
    this.element.removeEventListener("dragleave", this.onDragLeave.bind(this))
    this.element.removeEventListener("drop", this.onDrop.bind(this))
    this.fileInputTarget.removeEventListener("change", this.submitForm.bind(this))
  }

  preventDefaultAndHighlight(event) {
    event.preventDefault()
    event.stopPropagation()
    this.element.classList.add("border-solidus-blue", "bg-sky")
  }

  unhighlight(event) {
    event.preventDefault()
    event.stopPropagation()
    this.element.classList.remove("border-solidus-blue", "bg-sky")
  }

  onDragOver(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  onDragEnter(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  onDragLeave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.element.classList.remove("border-solidus-blue", "bg-sky")
  }

  onDrop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.element.classList.remove("border-solidus-blue", "bg-sky")

    const files = event.dataTransfer.files
    if (files.length > 0) {
      this.fileInputTarget.files = files
      this.submitForm()
    }
  }

  openFileInput() {
    this.fileInputTarget.click()
  }

  submitForm() {
    const fileCount = this.fileInputTarget.files.length
    if (fileCount === 0) return

    this.loadingTarget.classList.remove("hidden")
    this.uploadContentTarget.classList.add("hidden")

    const form = this.fileInputTarget.closest("form")
    if (form) {
      form.requestSubmit()
    }
  }
}
